unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl,glaux;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  RC: HGLRC=0;
  DC: HDC=0;
  tex : gluInt;

PROCEDURE glGenTextures(n: GLsizei; VAR textures: GLuint); STDCALL; EXTERNAL opengl32;
PROCEDURE glBindTexture(target: GLenum; texture: GLuint); STDCALL; EXTERNAL  opengl32;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF: Integer;
  textur: PTAUX_RGBImageRec;
begin
  // Nastavenie Device Contextu:
  DC:=GetDC(Handle);
  FillChar(PFD, SizeOf(TPixelFormatDescriptor), 0);
  PFD.nSize:=SizeOf(TPixelFormatDescriptor);
  PFD.nVersion:=1;
  PFD.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  PFD.iPixelType:=PFD_TYPE_RGBA;
  PFD.cColorBits:=24;
  PFD.cDepthBits:=32;
  PFD.iLayerType:=PFD_MAIN_PLANE;
  PF:=ChoosePixelFormat(DC, @PFD);
  if PF=0 then Exit;
  SetPixelFormat(DC, PF, @PFD);
  // Vytvorenie Rendering Contextu:
  RC:=wglCreateContext(DC);
  wglMakeCurrent(DC, RC);
  glClearColor(0, 0, 0, 0);
  glClearDepth(1);
  glEnable(GL_DEPTH_TEST);
  //zapneme priesvitnosù
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-8,+8,-8,+8,-8,+8);

  textur := auxDIBImageLoadA('himmel.bmp');
if not Assigned( textur ) then showmessage(ÇFehler beim Laden der Texturí);
glGenTextures(1, tex);
glBindTexture(GL_TEXTURE_2D, tex);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_linear);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_linear);
glTexImage2D(GL_TEXTURE_2D, 0, 3, textur^.sizeX, textur^.sizeY, 0, GL_RGB,
GL_UNSIGNED_BYTE, textur^.data);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;

end;

end.
 