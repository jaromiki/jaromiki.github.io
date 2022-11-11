unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl, StdCtrls, ExtCtrls ;

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
  aa:gluint;
  Form1: TForm1;
  RC: HGLRC=0;
  DC: HDC=0;
  uholy:integer=0;
  f:Tcolor;
  bmp128: array[0..127,0..127] of record r, g, b: byte;  end;
  bmp256: array[0..255,0..255] of record r, g, b: byte;  end;
  implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  f:Tcolor;
  i,j:integer;
  PFD: TPixelFormatDescriptor;
  PF: Integer;
  b1,b2:TBitmap;
//  textur: PTAUX_RGBImageRec;
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
 // glEnable(GL_BLEND);
 // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(-1,+1,-1,+1,-1,+1);

 glenable(gl_texture_2d); //Texturen aktivieren

  b1:=Tbitmap.Create;
  b1.LoadFromFile('t1-128x128.bmp');
  for i:=0 to 127 do
    for j:=0 to 127 do
    Begin  f:=b1.Canvas.pixels[i,j];
      move(f,bmp128[i,j],3);
    End;
b2:=Tbitmap.Create;
  b2.LoadFromFile('maca2.bmp');
  for i:=0 to 255 do
    for j:=0 to 255 do
    Begin  f:=b2.Canvas.pixels[i,j];
      move(f,bmp256[i,j],3);
    End;

glEnable(GL_TEXTURE_2D);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_linear);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_linear);
//glTexImage2D(GL_TEXTURE_2D, 0, 3, 128, 128, 0, GL_RGB, GL_UNSIGNED_BYTE, @bmp128);
glTexImage2D(GL_TEXTURE_2D, 0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, @bmp256);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
uholy:=(uholy+2) mod 360;
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;
glRotate( 30,1,0,0);
glRotate( uholy,0,1,0);
 //left:
//glTexImage2D(GL_TEXTURE_2D, 0, 3, 128, 128, 0, GL_RGB, GL_UNSIGNED_BYTE, @bmp128);
glTexImage2D(GL_TEXTURE_2D, 0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, @bmp256);
 glBegin(GL_QUADS);
 glTexCoord2f(1.0,0.0);
 glVertex3f(-0.5,-0.5,-0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(-0.5,0.5,-0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(-0.5,0.5,0.5);
 glTexCoord2f(0.0,0.0);
 glVertex3f(-0.5,-0.5,0.5);
 glEnd();

 //right:
 glBegin(GL_QUADS);
 glTexCoord2f(0.0,0.0);
 glVertex3f(0.5,-0.5,-0.5);
 glTexCoord2f(1.0,0.0);
 glVertex3f(0.5,-0.5,0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(0.5,0.5,0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(0.5,0.5,-0.5);
 glEnd();

 //front:
 glBegin(GL_QUADS);
 glTexCoord2f(0.0,0.0);
 glVertex3f(-0.5,-0.5,0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(-0.5,0.5,0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(0.5,0.5,0.5);
 glTexCoord2f(1.0,0.0);
 glVertex3f(0.5,-0.5,0.5);
 glEnd();

 //back:
 glBegin(GL_QUADS);
 glTexCoord2f(0.0,0.0);
 glVertex3f(-0.5,-0.5,-0.5);
 glTexCoord2f(1.0,0.0);
 glVertex3f(0.5,-0.5,-0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(0.5,0.5,-0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(-0.5,0.5,-0.5);
 glEnd();

   //top:
 glBegin(GL_QUADS);
 glTexCoord2f(1.0,0.0);
 glVertex3f(-0.5,0.5,-0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(0.5,0.5,-0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(0.5,0.5,0.5);
 glTexCoord2f(0.0,0.0);
 glVertex3f(-0.5,0.5,0.5);
 glEnd();

 //bottom:
 glBegin(GL_QUADS);
 glTexCoord2f(1.0,0.0);
 glVertex3f(-0.5,-0.5,-0.5);
 glTexCoord2f(1.0,1.0);
 glVertex3f(-0.5,-0.5,0.5);
 glTexCoord2f(0.0,1.0);
 glVertex3f(0.5,-0.5,0.5);
 glTexCoord2f(0.0,0.0);
 glVertex3f(0.5,-0.5,-0.5);
 glEnd();
SwapBuffers(DC);

end;

end.



var
  Form1: TForm1;
  f:Tcolor;
  bmp: array[0..255,0..255] of record r, g, b: byte;  end;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  b1:TBitmap;
begin
   b1:=TBitmap.Create;
 //  b1.LoadFromFile('maca2.bmp');
   Image1.Canvas.Brush.Color:=clblue;
   image1.Canvas.FillRect(image1.ClientRect);
   f:=Image1.Canvas.Pixels[0,0];
   move(f,bmp[0,0],3);
   Edit1.Text:=IntToStr(bmp[0,0].r);
   Edit2.Text:=IntToStr(bmp[0,0].g);
   Edit3.Text:=IntToStr(bmp[0,0].b);
/