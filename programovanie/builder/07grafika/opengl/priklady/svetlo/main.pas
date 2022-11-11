unit main;

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,
  OpenGL, ExtCtrls, StdCtrls, ComCtrls;

type
  TGLForm = class(TForm)
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    TrackBar8: TTrackBar;
    TrackBar9: TTrackBar;
    TrackBar: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure zmena(Sender: TObject);
  private
    hrc: HGLRC;         //OpenGL rendering context
    DC: HDC;     //využívá se jako druhý buffer, které se s prvním søídají pro plynulou animaci
    Klik: boolean;
    KlikX, KlikY: Integer;
    procedure DrawScene;          //main drawing procedure
    procedure InitOpenGL;
  end;

var
  GLForm: TGLForm;

const uhelX: GLfloat = 30;
      uhelY: GLfloat = 70;
      PozorovaciUhel: GLfloat = 50;
  MaterialBarva: array[0..3] of GLfloat = (0.0, 0.2, 0.8, 1.0);
  glfLightAmbient : Array[0..3] of GLfloat = (1.0, 0.1, 0.1, 1.0);
  glfLightDiffuse : Array[0..3] of GLfloat = (0.7, 0.07, 0.07, 1.0);
  glfLightSpecular: Array[0..3] of GLfloat = (0.0, 0.0, 0.0, 1.0);
  PoziceSvetla: array[0..3] of GLfloat = (-1,0.5,2,0);

implementation

{$R *.DFM}

//uses GLU;

//setup the device context format

procedure SetDCPixelFormat(Handle: HDC);
var
  pfd: TPixelFormatDescriptor;         //see win32 help for details
  t: Integer;
begin
  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
    begin
      nSize     := sizeof(pfd);
      nVersion  := 1;

      //for almost all applications you can add or PDF_DOUBLEBUFFER here
      //to enable double buffer (no flicker in animations)
      dwFlags   := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
      iPixelType:= PFD_TYPE_RGBA;
      cColorBits:= 24;
      cDepthBits:= 32;
      iLayerType:= PFD_MAIN_PLANE;
    end;
  t := ChoosePixelFormat(Handle, @pfd);
  SetPixelFormat(Handle, t, @pfd);
end;

procedure TGLForm.InitOpenGL;
begin
  //here you can enable z-buffering, lighting, cull-facing...
end;

procedure TGLForm.DrawScene;
begin
  // MaterialBarva[0]:=0.5;
  // reset
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  //Zmìní prùsvitné plochy na neprùsvitné
  glEnable(GL_CULL_FACE);

  //pracuje s mojím modelem krychle
  glMatrixMode(GL_MODELVIEW);

  //znovu obnoví matici bodù => vše zùstane na stejném místì
  glLoadIdentity;

  //intenzita svìtla v RGBA
  glLightfv(GL_LIGHT0, GL_AMBIENT, @glfLightAmbient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, @glfLightDiffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR,@glfLightSpecular);
  glLightfv(GL_LIGHT0, GL_POSITION,@PoziceSvetla); //umístìní zdroje svìtla
  glEnable(GL_LIGHTING);   //povolení svìtel
  glEnable(GL_LIGHT0);     //povolení svìtla èíslo 0, které jsem si nastavil
  glEnable(GL_NORMALIZE);

  glTranslatef(0.0, 0.0, -5.0); //kde je støed, kolem kterého bude vše rotovat
  glRotatef(uhelY,1,0,0);
  glRotatef(uhelX,0,1,0);

  glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, @MaterialBarva);

    glBegin(GL_POLYGON);
      glNormal3f(0.0, 0.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, 0.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(-1.0, 0.0, 0.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(1.0, 0.0, 0.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, 1.0, 0.0);
      glVertex3f(-1.0, 1.0, -1.0);
      glVertex3f(-1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, 1.0);
      glVertex3f(1.0, 1.0, -1.0);
    glEnd;

    glBegin(GL_POLYGON);
      glNormal3f(0.0, -1.0, 0.0);
      glVertex3f(-1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, -1.0);
      glVertex3f(1.0, -1.0, 1.0);
      glVertex3f(-1.0, -1.0, 1.0);
    glEnd;
{
  glBegin(GL_POLYGON); //spodek
    glNormal3f(0.0, -1.0, 0.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON); //prava
    glNormal3f(1.0, 0.0, 0.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(1.0, 1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON); //leva
    glNormal3f(-1.0, 0.0, 0.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON); //predni
    glNormal3f(0.0, 0.0, -1.0);
    glVertex3f(-1.0, -1.0, -1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(1.0, -1.0, -1.0);
    glVertex3f(1.0, 1.0, -1.0);
  glEnd;

  glBegin(GL_POLYGON); //zadni
    glNormal3f(0.0, 0.0, 1.0);
    glVertex3f(-1.0, -1.0, 1.0);
    glVertex3f(-1.0, 1.0, 1.0);
    glVertex3f(1.0, -1.0, 1.0);
    glVertex3f(1.0, 1.0, 1.0);
  glEnd;

  glBegin(GL_POLYGON); //horni
    glNormal3f(0.0, 1.0, 0.0);
    glVertex3f(1.0, 1.0, -1.0);
    glVertex3f(1.0, 1.0, 1.0);
    glVertex3f(-1.0, 1.0, -1.0);
    glVertex3f(-1.0, 1.0, 1.0);
  glEnd;}

  SwapBuffers(DC);
//  glFlush; //pokud nepoužívám dva buffery
end;

procedure TGLForm.FormCreate(Sender: TObject);
begin
  DC := GetDC(Handle);
  hrc := wglCreateContext(DC);
  wglMakeCurrent(DC, hrc);
  SetDCPixelFormat(Canvas.Handle);
  hrc := wglCreateContext(Canvas.Handle);
  InitOpenGL;
end;

procedure TGLForm.FormDestroy(Sender: TObject);
begin
  // Delete OpenGL rendering context
  wglMakeCurrent(0, 0);
  ReleaseDC(Handle, DC);
  wglDeleteContext(hrc);
end;

//redefine the viewport
procedure TGLForm.FormResize(Sender: TObject);
var
  Aspect : GLdouble;
begin
  wglMakeCurrent(Canvas.Handle, hrc);
  Aspect := Width / Height;

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(PozorovaciUhel,          //see OpenGL help for details
                 Aspect,
                 1.0,
                 20.0);
  glViewport(0, 0, Width, Height);
  wglMakeCurrent(0, 0);
  Invalidate;                   //repaint the entire window
end;

procedure TGLForm.FormPaint(Sender: TObject);
begin
  // Draw
  wglMakeCurrent(Canvas.Handle, hrc);
  DrawScene;
  wglMakeCurrent(0, 0);
end;

procedure TGLForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Klik := true;
 KlikX := x;
 KlikY := y;
end;

procedure TGLForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Klik := false;
end;

procedure TGLForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not Klik then exit;
 UhelX := UhelX+X-KlikX;
 UhelY := UhelY+Y-KlikY;
 KlikX := X;
 KlikY := Y;
 InvalidateRect(Handle, nil, false);
end;

procedure TGLForm.Button1Click(Sender: TObject);
begin
 gluLookAt(-5,-2,5,0,0,0,20,5,10);
 InvalidateRect(Handle, nil, false);
end;

procedure TGLForm.zmena(Sender: TObject);
begin
  glfLightAmbient[0]:=TrackBar1.Position /10;
  glfLightAmbient[1]:=TrackBar2.Position /10;
  glfLightAmbient[2]:=TrackBar3.Position /10;
  glfLightDiffuse[0]:=TrackBar4.Position /10;
  glfLightDiffuse[1]:=TrackBar5.Position /10;
  glfLightDiffuse[2]:=TrackBar6.Position /10;
  glfLightSpecular[0]:=TrackBar7.Position /10;
  glfLightSpecular[1]:=TrackBar8.Position /10;
  glfLightSpecular[2]:=TrackBar9.Position /10;
  PoziceSvetla[1]:=TrackBar.Position /10;
  wglMakeCurrent(Canvas.Handle, hrc);
  DrawScene;
  wglMakeCurrent(0, 0);
end;

end.

