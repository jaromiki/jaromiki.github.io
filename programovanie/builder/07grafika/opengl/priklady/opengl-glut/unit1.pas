unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, opengl, StdCtrls, ExtCtrls, glut;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    Button2: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure kon(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
var
  RC: HGLRC=0;
  DC: HDC=0;
  uhol,aa: real;
  Textura: array[0..255, 0..255] of record
    R, G, B,a: Byte;
  end;
  da:byte;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF: Integer;
  x,y: byte;
begin
  da:=2;
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
  // Nastavenie zobrazovania:
  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(60, ClientWidth/ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  for Y:=0 to 255 do
    for X:=0 to 255 do
    if ((x div 32)+(y div 32)) mod 2 = 0 then
    begin
      Textura[Y, X].R:=x;
      Textura[Y, X].G:=y;
      Textura[Y, X].B:=0;
     Textura[Y, X].a:=1;
    end
    else
    begin
      Textura[Y, X].R:=x div 2;
      Textura[Y, X].G:=y div 2;
      Textura[Y, X].B:=0;
     Textura[Y, X].a:=250;
    end;

  glEnable(GL_TEXTURE_2D);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameter(GL_TEXTURE_2D, GL_Texture_WRAP_T, GL_REPEAT);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage2d(GL_TEXTURE_2D, 0, 4, 256, 256, 0, GL_rgba, GL_UNSIGNED_BYTE, @Textura);

 glColor3f(1.0, 1.0, 1.0);
    glutSolidSphere(2,4,3);


end;

procedure TForm1.kon(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    da:=2;
  timer1.Enabled:=True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslate(0, 0, -5);
  glRotate(30, 0, 1, 0);
  glRotate(Uhol, 1, 0, 0);
 glColor3f(1.0, 1.0, 1.0);
    glutSolidTeapot(2);

  glBegin(GL_POLYGON);
  glTexCoord(aa, 1);
  glVertex(-1, +1, 0);
  glTexCoord(1, 1);
  glVertex(+1, +1, 0);
  glTexCoord(1, aa);
  glVertex(+1, -1, 0);
  glTexCoord(aa, aa);
  glVertex(-1, -1, 0);
 glEnd;
  glBegin(GL_POLYGON);
  glTexCoord(1, 1);
  glVertex(-1, +1, 0);
  glTexCoord(1, -1);
  glVertex(+1, +1, 0);
  glTexCoord(-1,-1);
  glVertex(+1, +1, -2);
  glTexCoord(-1, +1);
  glVertex(-1, +1, -2);
  glEnd;
  glBegin(GL_POLYGON);
  glTexCoord(1, aa);
  glVertex(+1, -1, 0);
  glTexCoord(aa, aa);
  glVertex(-1, -1, 0);
  glTexCoord(0,1);
  glVertex(0, -1, -2);
  glEnd;
  glBegin(GL_POLYGON);
  glTexCoord(1, aa);
  glVertex(+1, +1, -2);
  glTexCoord(aa, aa);
  glVertex(-1, +1, -2);
  glTexCoord(0,1);
  glVertex(0, -1, -2);
  glEnd;
//  glColor(1.0, 1.0, 0.5);
  glBegin(GL_LINES);
  glTexCoord(+1, +1);
  glVertex(-1, -1, 0);
  glTexCoord(0.6, 0.6);
  glVertex(+1, 1, -2);
  glEnd;

  SwapBuffers(DC);
  Uhol:=Uhol+da;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  aa:=aa+0.05;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
da:=0;
end;

end.
 