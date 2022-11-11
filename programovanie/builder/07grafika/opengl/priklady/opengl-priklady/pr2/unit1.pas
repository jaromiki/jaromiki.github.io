unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure dole(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
var
  RC: HGLRC=0;
  DC: HDC=0;
  SUR: array[0..50] of record x,y,z: glfloat; end;
  s,s1: string;
  jj,n,uholx,uholy,mx,my,mx1,my1,posun: Integer;
  j:single;
  mdole:Boolean;

procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF: Integer;
begin
  uholy:=-300; uholx:=-20;
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
  glOrtho(-5, 5, -5, 5, -5, 5);                 // mapovani abstraktnich souradnic do souradnic okna
//  gluPerspective(60, ClientWidth/ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);
//  glLoadIdentity;
  glEnable(GL_LINE_STIPPLE);
   end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  // priesvitnost
  glblendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glenable(GL_BLEND);

  glTranslate(0, -0.5, -3);
  glRotate(-uholx, 1, 0, 0);
  glRotate(-uholy, 0, 1, 0);
  glColor(0.8,0.8,0.8);
  glDisable(GL_LINE_STIPPLE);
  glBegin(GL_LINES);
  glColor(1.0,1.0,1.0);
  glVertex(0.0, 0.0, 0.0);
  glVertex(3.0, 0.0, 0.0);
  glColor(0.8,0.8,0.8);
  glVertex(0.0, 0.0, 0.0);
  glVertex(0.0, 3.0, 0.0);
  glVertex(0.0, 0.0, 0.0);
  glVertex(0.0, 0.0, 3.0);
  glVertex(1.0, 0.0, 1.0);
  glVertex(2.0, 2.0, 0.0);
  glEnd;
  glEnable(GL_LINE_STIPPLE);
  glLineStipple(1,3);
  glBegin(GL_LINES);
  glVertex(0.0,-2.0, 2.0);
  glVertex(1.0, 0.0, 1.0);
  glVertex(2.0, 2.0, 0.0);
  glVertex(3.0, 4.0,-1.0);
  glEnd;
  glPointSize(5);
  glBegin( GL_POINTS);
  glVertex(0.0,-2.0, 2.0);
  glVertex(1.0, 0.0, 1.0);
  glVertex(2.0, 2.0, 0.0);
  glVertex(3.0, 4.0,-1.0);
  glEnd;
  glLineStipple(1,15+32);
  glBegin(GL_LINES);
    glVertex(0.0, 0.0, 2.0);
//    glVertex(1.0, 0.0, 1.0);
//    glVertex(2.0, 0.0, 0.0);
    glVertex(3.0, 0.0,-1.0);
  glEnd;
  glbegin(GL_QUADS);
    glColor4f(1.0,0.8,0.8,0.5);
    glVertex(0.0, 0.0, 0.0);
    glVertex(3.0, 0.0, 0.0);
    glVertex(3.0, 0.0, 3.0);
    glVertex(0.0, 0.0, 3.0);
    glColor4f(0.8,1.0,0.8,0.5);
    glVertex(0.0, 0.0, 0.0);
    glVertex(3.0, 0.0, 0.0);
    glVertex(3.0, 3.0, 0.0);
    glVertex(0.0, 3.0, 0.0);
    glColor4f(0.8,0.8,1.0,0.5);
    glVertex(0.0, 0.0, 0.0);
    glVertex(0.0, 3.0, 0.0);
    glVertex(0.0, 3.0, 3.0);
    glVertex(0.0, 0.0, 3.0);
  glEnd;
  SwapBuffers(DC);
end;

procedure TForm1.dole(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mx:=x+uholy; my:=y+uholx;
  mdole:=True;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  mdole:=False;
end;

procedure TForm1.pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if mdole then
  begin
    uholy:=mx-x;
    uholx:=my-y;
    Button1Click(form1);
  end;

end;

end.
