unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,opengl,glaux, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
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
  uholy:integer=0;

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

 glenable(gl_texture_2d); //Texturen aktivieren
  textur := auxDIBImageLoadA('t1-128x128.bmp');
if not Assigned( textur ) then begin showmessage('Fehler beim Laden der Textur'); close;End;
glGenTextures(1, tex);
glBindTexture(GL_TEXTURE_2D, tex);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_linear);
glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_linear);
glTexImage2D(GL_TEXTURE_2D, 0, 3, textur^.sizeX, textur^.sizeY, 0, GL_RGB, GL_UNSIGNED_BYTE, textur^.data);
//glLoadIdentity;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglMakeCurrent(0, 0);
  wglDeleteContext(RC);
  RC:=0;
  ReleaseDC(Handle, DC);
  DC:=0;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glMatrixMode( GL_TEXTURE  );
glLoadIdentity;
glBindTexture(GL_TEXTURE_2D, tex); //Hiermit w‰hlen wir die Textur an
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;

glbegin(gl_quads);
//glColor3f(1.0,1.0,0.2);
gltexcoord2f(0,0); //UV ñ Zuweisung f¸r den ersten Punkt
glvertex3f(-5,-5,-3);
gltexcoord2f(0,1); //UV ñ Zuweisung f¸r den zweiten Punkt
glvertex3f(-5, 5,-3);
gltexcoord2f(1,1); //UV ñ Zuweisung f¸r den dritten Punkt
glvertex3f( 5, 5,-3);
gltexcoord2f(1,0); //UV ñ Zuweisung f¸r den vierten Punkt
glvertex3f( 5,-5,-3);
glend;
SwapBuffers(DC);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
uholy:=(uholy+2) mod 360;
glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;
glRotate( uholy,0,1,0);
glbegin(gl_quads);
//glColor3f(1.0,1.0,0.2);
gltexcoord2f(0,0); //UV ñ Zuweisung f¸r den ersten Punkt
glvertex3f(-5,-5,-3);
gltexcoord2f(0,1); //UV ñ Zuweisung f¸r den zweiten Punkt
glvertex3f(-5, 5,-3);
gltexcoord2f(1,1); //UV ñ Zuweisung f¸r den dritten Punkt
glvertex3f( 5, 5,-3);
gltexcoord2f(1,0); //UV ñ Zuweisung f¸r den vierten Punkt
glvertex3f( 5,-5,-3);
glend;
SwapBuffers(DC);

end;

end.
 