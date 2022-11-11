unit ctverec_f;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GL, GLU, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; DX,
      DY: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    DC: HDC;
    hrc: HGLRC;
    Palette: HPALETTE;

    procedure Ctverec;
    procedure Svetlo;
    procedure SetDCPixelFormat;

  protected
    procedure Kreslit(var Msg: TWMPaint); message WM_PAINT;

  public
    X,Y,Z: real;
    oldx,oldy: integer;
    UhelX,UhelY,UhelZ: integer;
    bool,stisknuto: boolean;
  end;

var
  Form1: TForm1;

implementation


{$R *.DFM}


procedure TForm1.SetDCPixelFormat;      //Nastaveni pixelu
var
  hHeap: THandle;
  Barvy, i: Integer;
  Paleta: PLogPalette;
  Cervena, Zelena, Modra: Byte;
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;

begin
  FillChar(pfd, SizeOf(pfd), 0);

  with pfd do begin
    nSize     := sizeof(pfd);                               // Velikost struktury pixelu
    nVersion  := 1;                                         // Èíslo verze
    dwFlags   := PFD_DRAW_TO_WINDOW or
                 PFD_SUPPORT_OPENGL or
                 PFD_DOUBLEBUFFER;                          // struktura pixelu
    iPixelType:= PFD_TYPE_RGBA;                             // RGBA pixelové hodnoty
    cColorBits:= 24;                                        // 24-bit barva
    cDepthBits:= 32;                                        // 32-bit depth buffer
    iLayerType:= PFD_MAIN_PLANE;                            // typ vrstvy
  end;

  nPixelFormat := ChoosePixelFormat(DC, @pfd);
  SetPixelFormat(DC, nPixelFormat, @pfd);

  DescribePixelFormat(DC, nPixelFormat, sizeof(TPixelFormatDescriptor), pfd);

  if ((pfd.dwFlags and PFD_NEED_PALETTE) <> 0) then begin
    Barvy   := 1 shl pfd.cColorBits;
    hHeap     := GetProcessHeap;
    Paleta := HeapAlloc(hHeap, 0, sizeof(TLogPalette) + (Barvy * sizeof(TPaletteEntry)));

    Paleta^.palVersion := $300;
    Paleta^.palNumEntries := Barvy;

    Cervena   := (1 shl pfd.cRedBits) - 1;
    Zelena := (1 shl pfd.cGreenBits) - 1;
    Modra  := (1 shl pfd.cBlueBits) - 1;

    for i := 0 to Barvy - 1 do begin
      Paleta^.palPalEntry[i].peRed   := (((i shr pfd.cRedShift)   and Cervena)   * 255) DIV Cervena;
      Paleta^.palPalEntry[i].peGreen := (((i shr pfd.cGreenShift) and Zelena) * 255) DIV Zelena;
      Paleta^.palPalEntry[i].peBlue  := (((i shr pfd.cBlueShift)  and Modra)  * 255) DIV Modra;
      Paleta^.palPalEntry[i].peFlags := 0;
    end;

    Palette := CreatePalette(Paleta^);
    HeapFree(hHeap, 0, Paleta);

    if (Palette <> 0) then begin
      SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
  end;
end;

procedure TForm1.Svetlo;
const
  glfLightAmbient : Array[0..3] of GLfloat = (0.1, 0.1, 0.1, 1.0);
  glfLightDiffuse : Array[0..3] of GLfloat = (0.7, 0.7, 0.7, 1.0);
  glfLightSpecular: Array[0..3] of GLfloat = (0.0, 0.0, 0.0, 1.0);
  glfLightShininess: GLfloat = 40;
  light_position: Array[0..3] of GLfloat = (100.0,100.0,100.0,1.0);
  glfLightEmission: Array[0..3] of GLfloat = (0.0,0.0,1.0,1.0);

begin
  glEnable(GL_DEPTH_TEST);

  glLightfv(GL_LIGHT0, GL_AMBIENT, @glfLightAmbient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @glfLightDiffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR, @glfLightSpecular);
  glLightfv(GL_LIGHT0, GL_SHININESS, @glfLightShininess);
  glLightfv(GL_LIGHT0, GL_EMISSION, @glfLightEmission);


  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);

end;

procedure TForm1.Ctverec;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(X,Y,Z);			//pozice kamery
  glTranslatef(0,0,0);			//støed rotace objektu
  glRotatef(UhelX, 1, 0, 0);		//rotace objektu po ose X
  glRotatef(UhelY, 0, 1, 0);		//rotace objektu po ose Y
  glRotatef(UhelZ, 0, 0, 1);		//rotace objektu po ose Z


    glEnable(GL_COLOR_MATERIAL);
    glBegin(GL_POLYGON);
    glNormal3f(0.0, 0.0, 1.0);
     glColor3b(0,0,127);
     glVertex3f(1.0, 1.0,0.0);
     glColor3b(0,127,0);
     glVertex3f(1.0, -1.0,0.0);
     glColor3b(127,0,0);
     glVertex3f(-1.0,-1.0,0.0);
     glColor3b(127,127,0);
     glVertex3f(-1.0, 1.0,0.0);
  glEnd;



  SwapBuffers(DC);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  UhelX := 0;
  UhelY := 0;
  UhelZ := 0;
  X := 0.0; Y := 0; Z := -4.0;
  SetcursorPos(left+round(width/2),top+round(height/2));
  bool:=true;
  DC := GetDC(Handle);
  SetDCPixelFormat;
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  Svetlo;
  Timer.Enabled := True;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  PomerStran : GLdouble;

begin
  PomerStran := Width / Height;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0, PomerStran, 0.1, 400);
  glViewport(0, 0, Width ,Height);
  InvalidateRect(Handle, nil, False);
end;

procedure TForm1.Kreslit(var Msg: TWMPaint);
var
  ps : TPaintStruct;

begin
  BeginPaint(Handle, ps);
  Ctverec;
  EndPaint(Handle, ps);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Timer.Enabled := False;
  wglMakeCurrent(0, 0);
  wglDeleteContext(hrc);
  ReleaseDC(Handle, DC);

  if (Palette <> 0) then
    DeleteObject(Palette);
end;


procedure TForm1.TimerTimer(Sender: TObject);
begin
  InvalidateRect(Handle, nil, False);
end;


procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; DX,
  DY: Integer);
begin
if bool then begin oldx:=dx;oldy:=dy;bool:=false;end;

if not stisknuto then begin
x:=x+round((oldx-dx));
z:=z+round((oldy-dy));
end;

if stisknuto then uhely:=uhely+round((oldx-dx));
if stisknuto then uhelx:=uhelx+round((oldy-dy));

oldx:=dx;oldy:=dy;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
stisknuto:=true;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
stisknuto:=false;
end;

end.

