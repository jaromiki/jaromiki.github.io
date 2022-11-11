unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, opengl, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure odchod(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure dole(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure hore(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  RC: HGLRC=0;
  DC: HDC=0;
  mdole,mx,my,uholy,uholx :integer;
  uholx0: integer =0;
  uholy0: integer =0;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF: Integer;
begin
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
  glLoadIdentity();
  glOrtho(-8, 8, -8, +8, -8, 8);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
    SwapBuffers(DC);

 end;

procedure TForm1.odchod(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;


end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
//   timer1.Enabled:=False;
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glBegin(gl_lines);
  glVertex3i(0,0,0);glVertex3i(7,0,0);
  glVertex3i(0,0,0);glVertex3i(0,7,0);
  glVertex3i(0,0,0);glVertex3i(0,0,7);
   glend();

  glBegin(GL_TRIANGLES);
  glColor4f(0.5,0.5,1.0,0.7);
  glVertex3i(6,0,0);glVertex3i(0,6,0);glVertex3i(0,0,6);
   glend();
  glColor4f(1.0,1.0,0.2,0.8);
   glBegin(GL_POLYGON);
  glColor4f(1.0,1.0,0.2,0.8);
  glVertex3i(3,0,0);glVertex3i(0,0,3);glVertex3i(0,7,3);glVertex3i(3,7,0);
   glend();

  SwapBuffers(DC);

end;

procedure TForm1.dole(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
mx:=X; my:=Y;
mdole:=1;
end;

procedure TForm1.pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
if mdole =1 then
Begin
  uholx:=uholx0-(my-Y) div 2; uholy:=uholy0-(mx-X) div 2;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glRotate(uholx,1,0,0);
  glRotate(uholy,0,1,0);
  Timer1Timer(Form1);
End;
end;

procedure TForm1.hore(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    mdole:=0;
    uholx0:=uholx;
    uholy0:=uholy;
end;

end.
