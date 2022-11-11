unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, opengl,
  ExtCtrls, glaux;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private-Deklarationen }
   myDC : HDC;
   myRC : HGLRC;
   myPalette : HPALETTE;
   procedure SetupPixelFormat;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  tex : gluInt;


implementation

{$R *.DFM}

PROCEDURE glGenTextures(n: GLsizei; VAR textures: GLuint); STDCALL; EXTERNAL opengl32;
PROCEDURE glBindTexture(target: GLenum; texture: GLuint);  STDCALL; EXTERNAL opengl32;

procedure TForm1.SetupPixelFormat;
var    hHeap: THandle;
  nColors, i: Integer;
  lpPalette : PLogPalette;
  byRedMask, byGreenMask, byBlueMask: Byte;
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do begin
    nSize     := sizeof(pfd);               // Länge der pfd-Struktur
    nVersion  := 1;                         // Version
    dwFlags   := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;          // Flags
    iPixelType:= PFD_TYPE_RGBA;             // RGBA Pixel Type
    cColorBits:= 24;                        // 24-bit color
    cDepthBits:= 32;                        // 32-bit depth buffer
    iLayerType:= PFD_MAIN_PLANE;            // Layer Type
  end;
  nPixelFormat:= ChoosePixelFormat(myDC, @pfd);
  SetPixelFormat(myDC, nPixelFormat, @pfd);
                                            // Farbpalettenoptimierung wenn erforderlich
  DescribePixelFormat(myDC, nPixelFormat,
                      sizeof(TPixelFormatDescriptor),pfd);
  if ((pfd.dwFlags and PFD_NEED_PALETTE) <> 0) then begin
    nColors  := 1 shl pfd.cColorBits;
    hHeap    := GetProcessHeap;
    lpPalette:= HeapAlloc
       (hHeap,0,sizeof(TLogPalette)+(nColors*sizeof(TPaletteEntry)));
    lpPalette^.palVersion := $300;
    lpPalette^.palNumEntries := nColors;
    byRedMask  := (1 shl pfd.cRedBits) - 1;
    byGreenMask:= (1 shl pfd.cGreenBits) - 1;
    byBlueMask := (1 shl pfd.cBlueBits) - 1;
    for i := 0 to nColors - 1 do begin
      lpPalette^.palPalEntry[i].peRed  :=
        (((i shr pfd.cRedShift)  and byRedMask)  *255)DIV byRedMask;
      lpPalette^.palPalEntry[i].peGreen:=
        (((i shr pfd.cGreenShift)and byGreenMask)*255)DIV byGreenMask;
      lpPalette^.palPalEntry[i].peBlue :=
        (((i shr pfd.cBlueShift) and byBlueMask) *255)DIV byBlueMask;
      lpPalette^.palPalEntry[i].peFlags:= 0;
    end;
    myPalette:= CreatePalette(lpPalette^);
    HeapFree(hHeap, 0, lpPalette);
    if (myPalette <> 0) then begin
      SelectPalette(myDC, myPalette, False);
      RealizePalette(myDC);
    end;
  end;
end;

procedure InitTextures;
var
  textur: PTAUX_RGBImageRec;
begin
  textur := auxDIBImageLoadA('himmel.bmp');
  if not Assigned( textur ) then begin
    showmessage('Fehler beim Laden der Textur');
  end;

  glGenTextures(1, tex);
  glBindTexture(GL_TEXTURE_2D, tex);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_linear);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_linear);
  glTexImage2D(GL_TEXTURE_2D, 0, 3, textur^.sizeX, textur^.sizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, textur^.data);

end;

procedure render;
begin
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //Farb und Tiefenpuffer löschen
glLoadIdentity;

glmatrixmode(gl_texture);
gltranslate(random(2)/30, 0,0);
glmatrixmode(gl_modelview);

glBindTexture(GL_TEXTURE_2D, tex);
glbegin(gl_quads);
gltexcoord2f(0,0);
glvertex3f(-0.5,-0.5,-3);
gltexcoord2f(0,1);
glvertex3f(-0.5, 0.5,-3);
gltexcoord2f(1,1);
glvertex3f( 0.5, 0.5,-3);
gltexcoord2f(1,0);
glvertex3f( 0.5,-0.5,-3);
glend;                                                     //hier kommen die Objekte hin
SwapBuffers(form1.myDC);                             //scene ausgeben
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
form1.myDC:= GetDC(Handle);
SetupPixelFormat;
myRC:= wglCreateContext(myDC);
wglMakeCurrent(myDC, myRC);
glenable(gl_texture_2d);
glEnable(GL_DEPTH_TEST);
InitTextures;
glLoadIdentity;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
wglmakecurrent(0,0);
wgldeletecontext(mydc);
releasedc(handle,mydc);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
glViewport(0, 0, Width, Height);    // Setzt den Viewport für das OpenGL Fenster
glMatrixMode(GL_PROJECTION);        // Matrix Mode auf Projection setzen
glLoadIdentity();                   // Reset View
gluPerspective(45.0, Width/Height, 1, 100.0);  // Perspektive den neuen Maßen anpassen.
glMatrixMode(GL_MODELVIEW);         // Zurück zur Modelview Matrix
glLoadIdentity();
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
render;
end;

end.
