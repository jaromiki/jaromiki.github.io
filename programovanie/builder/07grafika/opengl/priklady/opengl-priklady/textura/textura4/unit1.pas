unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl, StdCtrls,ExtCtrls;

type
  tex= array[1..256,1..256] of record
                                  blue, green, red : byte
                                end;
  utex = ^tex;
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure kresli(Sender: TObject);
    procedure LoadBitmap(Path : string; kam:utex);
    procedure dole(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure hore(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
     buffer1,buffer2 : tex;
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
  uhol:real;
  Body1: array[1..50,1..2] of real;
  Body2: array[1..50,1..2] of real;
  u,uholx,uholy,mx,my,x,y:real;
  rovno,stlacene : Boolean;


procedure TForm1.FormCreate(Sender: TObject);
var
  PFD: TPixelFormatDescriptor;
  PF: Integer;
begin
  uholx:=90; uholy:=90;u:=90;
     y:=80;x:=0;
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
  glClearColor(0.0, 0.0, 0.0, 0.0);       // barva pozadi
  GLCLEAR(GL_COLOR_BUFFER_BIT);

  LoadBitmap('Image1.bmp',@buffer1);
  LoadBitmap('tehla.bmp',@buffer2);
 // glEnable(GL_TEXTURE_2D);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameter(GL_TEXTURE_2D, GL_Texture_WRAP_T, GL_REPEAT);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  end;

procedure TForm1.Kresli(Sender: TObject);
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glLoadIdentity;
  glTranslate(0, -y, -x-10);
//  glTranslate(0, -y, -200);
  glRotate(-uholx, 0, 1, 0);
  glRotate(-uholy, 0, 0, 1);
  glDisable(GL_TEXTURE_2D);
//
  glBegin(GL_QUAD_STRIP);
    glColor(0.9,0.5,0.5);
    glVertex(-50,-20,10);
    glColor(0.5,0.5,0.9);
    glVertex(-50,-30,10);
    glColor(0.5,0.9,0.5);
    glVertex(-50-20*sin(pi/6),-20*cos(pi/6),10);
    glVertex(-50-30*sin(pi/6),-30*cos(pi/6),10);
    glVertex(-50-20*sin(pi/3),-20*cos(pi/3),10);
    glVertex(-50-30*sin(pi/3),-30*cos(pi/3),10);
    glVertex(-50-20*sin(pi/2),-20*cos(pi/2),10);
    glVertex(-50-30*sin(pi/2),-30*cos(pi/2),10);
    glVertex(-50-20*sin(2*pi/3),-20*cos(2*pi/3),10);
    glVertex(-50-30*sin(2*pi/3),-30*cos(2*pi/3),10);
    glVertex(-50-20*sin(5*pi/6),-20*cos(5*pi/6),10);
    glVertex(-50-30*sin(5*pi/6),-30*cos(5*pi/6),10);
    glVertex(-50,+20,10);
    glVertex(-50,+30,10);
  glEnd;
  glBegin(GL_QUAD_STRIP);
    glColor(0.9,0.5,0.5); glVertex(-50,-20,-10);
    glColor(0.5,0.5,0.9); glVertex(-50,-30,-10);
    glColor(0.5,0.9,0.5); glVertex(-50-20*sin(pi/6),-20*cos(pi/6),-10);
    glVertex(-50-30*sin(pi/6),-30*cos(pi/6),-10);
    glVertex(-50-20*sin(pi/3),-20*cos(pi/3),-10);
    glVertex(-50-30*sin(pi/3),-30*cos(pi/3),-10);
    glVertex(-50-20*sin(pi/2),-20*cos(pi/2),-10);
    glVertex(-50-30*sin(pi/2),-30*cos(pi/2),-10);
    glVertex(-50-20*sin(2*pi/3),-20*cos(2*pi/3),-10);
    glVertex(-50-30*sin(2*pi/3),-30*cos(2*pi/3),-10);
    glVertex(-50-20*sin(5*pi/6),-20*cos(5*pi/6),-10);
    glVertex(-50-30*sin(5*pi/6),-30*cos(5*pi/6),-10);
    glVertex(-50,+20,-10);
    glVertex(-50,+30,-10);
  glEnd;

  glBegin(GL_QUAD_STRIP);
    glColor(0.9,0.5,0.5);
    glVertex(+50,-20,10);
    glColor(0.5,0.5,0.9);
    glVertex(+50,-30,10);
    glColor(0.5,0.9,0.5);
    glVertex(+50+20*sin(pi/6),-20*cos(pi/6),10);
    glVertex(+50+30*sin(pi/6),-30*cos(pi/6),10);
    glVertex(+50+20*sin(pi/3),-20*cos(pi/3),10);
    glVertex(+50+30*sin(pi/3),-30*cos(pi/3),10);
    glVertex(+50+20*sin(pi/2),-20*cos(pi/2),10);
    glVertex(+50+30*sin(pi/2),-30*cos(pi/2),10);
    glVertex(+50+20*sin(2*pi/3),-20*cos(2*pi/3),10);
    glVertex(+50+30*sin(2*pi/3),-30*cos(2*pi/3),10);
    glVertex(+50+20*sin(5*pi/6),-20*cos(5*pi/6),10);
    glVertex(+50+30*sin(5*pi/6),-30*cos(5*pi/6),10);
  glVertex(+50,+20,10);
  glVertex(+50,+30,10);
  glEnd;
  glTexImage2d(GL_TEXTURE_2D, 0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, @buffer1);
  glEnable(GL_TEXTURE_2D);
    glBegin(GL_QUADS);
        glTexCoord(0.0, 0.0); glVertex3f(-50, 30, 10);
        glTexCoord(0.0, 1.0); glVertex3f(-50, 20, 10);
        glTexCoord(10.0, 1.0); glVertex3f(+50, 20, 10);
        glTexCoord(10.0, 0.0); glVertex3f(+50, 30, 10);
        glTexCoord(0.0, 0.0); glVertex3f(-50, -20, 10);
        glTexCoord(0.0, 1.0); glVertex3f(-50, -30, 10);
        glTexCoord(10.0, 1.0); glVertex3f(+50, -30, 10);
        glTexCoord(10.0, 0.0); glVertex3f(+50, -20, 10);
    glend;
  glBegin(GL_QUAD_STRIP);
    glColor(0.9,0.5,0.5);  glVertex(+50,-20,-10);
    glColor(0.5,0.5,0.9);  glVertex(+50,-30,-10);
    glColor(0.5,0.9,0.5);  glVertex(+50+20*sin(pi/6),-20*cos(pi/6),10);
    glVertex(+50+30*sin(pi/6),-30*cos(pi/6),-10);
    glVertex(+50+20*sin(pi/3),-20*cos(pi/3),-10);
    glVertex(+50+30*sin(pi/3),-30*cos(pi/3),-10);
    glVertex(+50+20*sin(pi/2),-20*cos(pi/2),-10);
    glVertex(+50+30*sin(pi/2),-30*cos(pi/2),-10);
    glVertex(+50+20*sin(2*pi/3),-20*cos(2*pi/3),-10);
    glVertex(+50+30*sin(2*pi/3),-30*cos(2*pi/3),-10);
    glVertex(+50+20*sin(5*pi/6),-20*cos(5*pi/6),-10);
    glVertex(+50+30*sin(5*pi/6),-30*cos(5*pi/6),-10);
  glVertex(+50,-20,-10);
  glVertex(+50,-30,-10);
  glEnd;
  glEnable(GL_TEXTURE_2D);
    glBegin(GL_QUADS);
        glTexCoord(0.0, 0.0); glVertex3f(-50, 30, -10);
        glTexCoord(0.0, 1.0); glVertex3f(-50, 20, -10);
        glTexCoord(10.0, 1.0); glVertex3f(+50, 20, -10);
        glTexCoord(10.0, 0.0); glVertex3f(+50, 30, -10);

        glTexCoord(0.0, 0.0); glVertex3f(-50, -20, -10);
        glTexCoord(0.0, 1.0); glVertex3f(-50, -30, -10);
        glTexCoord(10.0, 1.0); glVertex3f(+50, -30, -10);
        glTexCoord(10.0, 0.0); glVertex3f(+50, -20, -10);
    glend;
  glTexImage2d(GL_TEXTURE_2D, 0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, @buffer2);
  glEnable(GL_TEXTURE_2D);
    glBegin(GL_QUAD_STRIP);
        glTexCoord(1.0, 0.0); glVertex3f(-50, -20, -10);
        glTexCoord(1.0, 1.0); glVertex3f(-50, -20, +10);
        glTexCoord(0.0, 1.0); glVertex3f(-50-20*sin(pi/6), -20*cos(pi/6), -10);
        glTexCoord(0.0, 0.0); glVertex3f(-50-20*sin(pi/6), -20*cos(pi/6), +10);
        glTexCoord(1.0, 0.0); glVertex3f(-50-20*sin(pi/3), -20*cos(pi/3), -10);
        glTexCoord(1.0, 1.0); glVertex3f(-50-20*sin(pi/3), -20*cos(pi/3), +10);

        glTexCoord(0.0, 1.0); glVertex3f(-50-20*sin(pi/2), -20*cos(pi/2), -10);
        glTexCoord(0.0, 0.0); glVertex3f(-50-20*sin(pi/2), -20*cos(pi/2), +10);
        glTexCoord(1.0, 0.0); glVertex3f(-50-20*sin(2*pi/3), -20*cos(2*pi/3), -10);
        glTexCoord(1.0, 1.0); glVertex3f(-50-20*sin(2*pi/3), -20*cos(2*pi/3), +10);

        glTexCoord(0.0, 1.0); glVertex3f(-50-20*sin(5*pi/6), -20*cos(5*pi/6), -10);
        glTexCoord(0.0, 0.0); glVertex3f(-50-20*sin(5*pi/6), -20*cos(5*pi/6), +10);
        glTexCoord(1.0, 0.0); glVertex3f(-50, -20, -10);
        glTexCoord(1.0, 1.0); glVertex3f(-50, -20, +10);
    glend;
    glBegin(GL_QUADS);
        glTexCoord(0.0, 0.0); glVertex3f(-50, +20, -10);
        glTexCoord(0.0, 1.0); glVertex3f(-50, +20, +10);
        glTexCoord(10.0, 1.0); glVertex3f(+50, +20,+10);
        glTexCoord(10.0, 0.0); glVertex3f(+50, +20, -10);
    glend;

    glBegin(GL_QUAD_STRIP);
        glTexCoord(1.0, 0.0); glVertex3f(50, -30, -10);
        glTexCoord(1.0, 1.0); glVertex3f(50, -30, +10);
        glTexCoord(0.0, 1.0); glVertex3f(50+30*sin(pi/6), 30*cos(pi/6), -10);
        glTexCoord(0.0, 0.0); glVertex3f(50+30*sin(pi/6), 30*cos(pi/6), +10);
        glTexCoord(1.0, 0.0); glVertex3f(50+30*sin(pi/3), 30*cos(pi/3), -10);
        glTexCoord(1.0, 1.0); glVertex3f(50+30*sin(pi/3), 30*cos(pi/3), +10);

        glTexCoord(0.0, 1.0); glVertex3f(50+30*sin(pi/2), 30*cos(pi/2), -10);
        glTexCoord(0.0, 0.0); glVertex3f(50+30*sin(pi/2), 30*cos(pi/2), +10);
        glTexCoord(1.0, 0.0); glVertex3f(50+30*sin(2*pi/3), 30*cos(2*pi/3), -10);
        glTexCoord(1.0, 1.0); glVertex3f(50+30*sin(2*pi/3), 30*cos(2*pi/3), +10);

        glTexCoord(0.0, 1.0); glVertex3f(50+30*sin(5*pi/6), 30*cos(5*pi/6), -10);
        glTexCoord(0.0, 0.0); glVertex3f(50+30*sin(5*pi/6), 30*cos(5*pi/6), +10);
        glTexCoord(1.0, 0.0); glVertex3f(50, -30, -10);
        glTexCoord(1.0, 1.0); glVertex3f(50, -30, +10);
    glend;
    glBegin(GL_QUADS);
        glTexCoord(0.0, 0.0); glVertex3f(50, +30, -10);
        glTexCoord(0.0, 1.0); glVertex3f(50, +30, +10);
        glTexCoord(10.0, 1.0); glVertex3f(-50, +30,+10);
        glTexCoord(10.0, 0.0); glVertex3f(-50, +30, -10);
    glend;

      SwapBuffers(DC);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  uholx:=90; uholy:=90; u:=90;
     y:=80;x:=0;
Timer1.Enabled:= True;
end;

procedure TForm1.LoadBitmap(Path : string; kam:utex);
var
 X : TImage;
 bih : TBitmapInfoHeader;
 bi : TBitmapInfo;
 b : byte;
 i,j : word;
begin
  X := TImage.Create(Self);
  X.Picture.LoadFromFile(Path);
  with bih do
    begin
      biSize := SizeOf(bih);
      biWidth := 256;
      biHeight := 256;
      biPlanes := 1;
      biBitCount := 24;
      biCompression := BI_RGB;
      biSizeImage := 256;
      biXPelsPerMeter := 0;
      biYPelsPerMeter := 0;
      biClrImportant := 0;
      biClrUsed := 0;
    end;
  bi.bmiHeader := bih;
  GetDIBits(X.Picture.Bitmap.Canvas.Handle,X.Picture.Bitmap.Handle,
            0,256,kam,bi,dib_rgb_colors);
  for i := 1 to 256 do
    for j := 1 to 256 do
      begin
        b := kam^[i,j].red;
        kam^[i,j].red := kam^[i,j].blue;
        kam^[i,j].blue := b;
      end;
  X.Free
end;

procedure TForm1.dole(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  stlacene:=TRUE;
  mx:=uholx+x div 4; my:=uholy+y div 4;
end;

procedure TForm1.pohyb(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if stlacene then
  BEGIN
    Uholx := mx - x div 4;
    Uholy := my - y div 4;
  END;
  kresli(form1);
end;

procedure TForm1.hore(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  stlacene:=FALSE;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if rovno then
  begin
    x:=x-1;
    y:= x*sin(u/180*pi)+26;
    if x<=-50 then begin rovno:= false; u:= 0;end;
  end
  else
  begin
     uholy:=uholy+0.5;
     u:=u+0.5;
     y:= 50*sin(u/180*pi)+26;x:=-50*cos(u/180*pi);
     if y<=24.5 then begin rovno:= TRUE; y:=25;end;
  end;
  kresli(form1);
end;

end.
  uholx:=90; uholy:=90;
     y:=80;x:=0;

