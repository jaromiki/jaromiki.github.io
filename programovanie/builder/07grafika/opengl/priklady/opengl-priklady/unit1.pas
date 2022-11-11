unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    RadioGroup1: TRadioGroup;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure koniec(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure zmena(Sender: TObject);
    procedure dole(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure hore(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pribliz(Sender: TObject);
    procedure priesv(Sender: TObject);
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
  PF,i: Integer;
//  j:single;
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
  glLoadIdentity;
  gluPerspective(60, ClientWidth/ClientHeight, 1, 1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  n:=memo1.Lines.Count;
  for i:=0 to n-1 do
  begin
    s:=memo1.Lines[i];
    s1:=copy(s,1,4); val(s1,sur[i].x,jj);
    s1:=copy(s,5,4); val(s1,sur[i].y,jj);
    s1:=copy(s,9,4); val(s1,sur[i].z,jj);
  end;
  uholx:=0; uholy:=0; posun:=5;
end;

procedure TForm1.koniec(Sender: TObject);
begin
 wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;

end;

procedure TForm1.Button1Click(Sender: TObject);
var i: integer;
begin
  glblendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glenable(GL_BLEND);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslate(0, 0, -trackBar1.Position);
  glRotate(-uholx, 1, 0, 0);
  glRotate(-uholy, 0, 1, 0);
  glColor(0.8,0.8,0.8);
  glBegin(GL_LINES);
  glColor(1.0,1.0,1.0);
  glVertex(0.0, 0.0, 0.0);
  glVertex(2.0, 0.0, 0.0);
  glColor(0.8,0.8,0.8);
  glVertex(0.0, 0.0, 0.0);
  glVertex(0.0, 2.0, 0.0);
  glVertex(0.0, 0.0, 0.0);
  glVertex(0.0, 0.0, 2.0);
  glEnd;
  CASE RADIOGROUP1.ItemIndex OF
  0:;
  1:Begin
       glbegin(GL_LINES);
       for i:=0 to n-1 do
       begin
         glColor(1.0-0.1*i,0.1*i,0.5);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;

  2: Begin
       glbegin(GL_LINE_STRIP);
       for i:=0 to n-1 do
       begin
         glColor(1.0-0.1*i,0.1*i,0.5);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;
  3: Begin
       glbegin(GL_LINE_LOOP);
       for i:=0 to n-1 do
       begin
         glColor(1.0-0.1*i,0.1*i,0.5);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;
  4: Begin
       glbegin(GL_TRIANGLES);
       for i:=0 to n-1 do
       begin
         glColor4f(1.0-0.05*i,0.05*i,0.5,TrackBar2.Position/10.0);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;
  5: Begin
       glbegin(GL_TRIANGLE_FAN);
       for i:=0 to n-1 do
       begin
         glColor(1.0-0.1*i,0.1*i,0.5);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;
  6:      ;
  7: Begin
       glbegin(GL_QUADS);
       for i:=0 to n-1 do
       begin
         glColor(1.0-0.2*i,0.2*i,0.5,0.5);
         glVertex3f(sur[i].x,sur[i].y,sur[i].z);
       end;
       glEnd;
     End;
  8:        ;
  9:         ;
  10:         ;
  END;
  SwapBuffers(DC);

end;

procedure TForm1.zmena(Sender: TObject);
var i: integer;
begin
  n:=memo1.Lines.Count;
  for i:=0 to n do
  begin
    s:=memo1.Lines[i];
    s1:=copy(s,1,4); val(s1,sur[i].x,jj);
    s1:=copy(s,5,4); val(s1,sur[i].y,jj);
    s1:=copy(s,9,4); val(s1,sur[i].z,jj);
  end;
end;

procedure TForm1.dole(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 mx:=x+uholy; my:=y+uholx;
 mdole:=True;
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

procedure TForm1.hore(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 mdole:=False;
end;

procedure TForm1.pribliz(Sender: TObject);
begin
    Button1Click(form1);
end;

procedure TForm1.priesv(Sender: TObject);
begin
  Button1Click(form1);
end;

end.
