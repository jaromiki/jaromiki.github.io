//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
#include <gl\gl.h>// Hlavièkový soubor pro OpenGL32 knihovnu
#include <gl\glu.h>// Hlavièkový soubor pro Glu32 knihovnu
#include <gl\glaux.h>// Hlavièkový soubor pro Glaux knihovnu

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
int uholx=20,uholy=20, mys_dx,mys_dy, uholy0=20,uholx0=20;
GLfloat LightAmbient[] =  {0.2f,0.2f,0.2f,1.0f};
GLfloat LightDiffuse[] =  {0.5f,0.5f,0.5f,1.0f};
GLfloat LightSpecular[] =  {1.0f,1.0f,1.0f,1.0f};
GLfloat LightPosition[] = {-10.0f,0.0f,0.0f,1.0f};
GLfloat Mat_Amb[] =  {0.3f,0.3f,0.3f,1.0f};
GLfloat Mat_Diff[] =  {0.5f,0.2f,0.2f,1.0f};
GLfloat Mat_Spec[] =  {0.9f,0.9f,0.9f,1.0f};

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{    ogl_inicialized=0;
     ogl_init();
}
void TForm1::ogl_draw()
{ glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glRotatef(uholx,1.0f,0.0f,0.0f);
  glRotatef(uholy,0.0f,1.0f,0.0f);
//tu zadávame príkazy na kreslenie

    glBegin(GL_QUADS);
 //       glNormal3f(0.0f,0.0f,+1.0f);
         glVertex3f(-4,-4,-4);
         glVertex3f(-4,+4, -4);
         glVertex3f(+4, +4,-4);
         glVertex3f(+4, -4,-4);

 //       glNormal3f(0.0f,0.0f,-1.0f);
         glVertex3f(-4,-4,+4);
         glVertex3f(-4,+4, +4);
         glVertex3f(+4, +4,+4);
         glVertex3f(+4, -4,+4);

 //        glNormal3f(-1.0f,0.0f,0.0f);
         glVertex3f(-4,-4,-4);
         glVertex3f(-4,+4, -4);
         glVertex3f(-4, +4,+4);
         glVertex3f(-4, -4,+4);

 //       glNormal3f(+1.0f,0.0f,0.0f);
          glVertex3f(+4,-4,-4);
         glVertex3f(+4,+4,-4);
         glVertex3f(+4,+4,+4);
         glVertex3f(+4,-4,+4);

 //        glNormal3f(0.0f,1.0f,0.0f);
         glVertex3f(-4,+4,-4);
         glVertex3f(+4,+4,-4);
         glVertex3f(+4,+4,+4);
         glVertex3f(-4,+4,+4);
   glEnd();

glFlush();
SwapBuffers(hdc);

}

//---------------------------------------------------------------------------

void __fastcall TForm1::destroy(TObject *Sender)
{
  ogl_exit();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::resize(TObject *Sender)
{
ogl_resize();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{ glEnable(GL_LIGHTING);
  glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmbient);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, LightDiffuse);
  glLightfv(GL_LIGHT0, GL_SPECULAR, LightSpecular);
  glLightfv(GL_LIGHT0, GL_POSITION, LightPosition);
  glEnable(GL_LIGHT0);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, Mat_Amb);
  glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, Mat_Diff);
  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, Mat_Spec);
  glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 64.0);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::mys_dole(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  mys_dx=X; mys_dy=Y;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::mys_poh(TObject *Sender, TShiftState Shift, int X,
      int Y)
{  if (Shift.Contains(ssLeft))
  {
  uholy=uholy0-(mys_dx-X); uholx=uholx0-(mys_dy-Y);
  }

}
//---------------------------------------------------------------------------

void __fastcall TForm1::mys_hore(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{  uholy0=uholy;
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Timer1Timer(TObject *Sender)
{ uholy++;
ogl_draw();
}
//---------------------------------------------------------------------------



void __fastcall TForm1::ambi(TObject *Sender)
{  LightAmbient[0]=LightAmbient[1]=LightAmbient[2]=LightAmbient[3]=TrackBar1->Position/10.0;
   glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmbient);
}
//---------------------------------------------------------------------------


