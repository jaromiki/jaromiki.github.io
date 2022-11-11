unit ihlan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGl, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  Vrcholy: array[1..8] of record            // zoznam vrcholov
    X, Y, Z: Real;
    R, G, B: Real;
  end=(
    (X: -1; Y: +1; Z: 0; R: 1; G: 0; B: 0),
    (X: +1; Y: +1; Z: 0; R: 1; G: 1; B: 0),
    (X: +1; Y: -1; Z: 0; R: 0; G: 1; B: 0),
    (X: -1; Y: -1; Z: 0; R: 0; G: 1; B: 1),
    (X: -1; Y: +1; Z: 0; R: 0; G: 0; B: 1),
    (X: +1; Y: +1; Z: 0; R: 1; G: 0; B: 1),
    (X: +1; Y: -1; Z: 0; R: 1; G: 1; B: 1),
    (X: -1; Y: -1; Z: 0; R: 0; G: 0; B: 0));

  Steny: array[1..6] of record              // zoznam stien
    I: array[1..4] of Integer;              // stena kocky = štyri vrcholy
  end=(
    (I: (1, 2, 7)),
    (I: (2, 3, 7)),
    (I: (3, 4, 7)),
    (I: (4, 5, 7)),
    (I: (5, 6, 7)),
    (I: (2, 3, 7)));

implementation

{$R *.DFM}

var
  RC: HGLRC=0;
  DC: HDC=0;

procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF,i: Integer;
begin
  // Nastavenie DeviceContext:
  DC:=GetDC(Handle);
  FillChar(PFD, SizeOf(TPixelFormatDescriptor), 0);
  PFD.nSize:=SizeOf(TPixelFormatDescriptor);
  PFD.nVersion:=1;
  PFD.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  PFD.iPixelType:=PFD_TYPE_RGBA;
  PFD.cColorBits:=32;
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
  for i:=0 to 5 do
  begin  vrcholy[i+1].X:=cos(i*60);
         vrcholy[i+1].Y:=sin(i*60);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  ReleaseDC(Handle, DC);
end;


var
  Uhol: Real=0;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  I, S, V: Integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glRotate(30, 1, 0, 0);
  glRotate(Uhol, 0, 1, 0);
  for S:=1 to 6 do begin
    glBegin(GL_Triangles);
    for V:=1 to 3 do begin
      I:=Steny[S].I[V];
      glColor(Vrcholy[I].R, Vrcholy[I].G, Vrcholy[I].B);
      glVertex(Vrcholy[I].X, Vrcholy[I].Y, Vrcholy[I].Z);
    end;
    glEnd;
  end;
  SwapBuffers(DC);
  Uhol:=Uhol+1;
end;

end.
