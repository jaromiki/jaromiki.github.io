//---------------------------------------------------------------------------
//#include <windows.h>// Hlavičkový soubor pro Windows
#include <vcl.h>
#pragma hdrstop
#include <gl\gl.h>// Hlavičkový soubor pro OpenGL32 knihovnu
#include <gl\glu.h>// Hlavičkový soubor pro Glu32 knihovnu
#include <gl\glaux.h>// Hlavičkový soubor pro Glaux knihovnu

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
int uholx,uholy;
void TForm1::ogl_draw()
    {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    float x=2.5,y=2.5,z=20.0;
glColor4f(1.0f, 1.0f, 1.0f,1.0f);
        glBegin(GL_LINES);
  glVertex3i(0,0,0);glVertex3i(7,0,0);
  glVertex3i(0,0,0);glVertex3i(0,7,0);
  glVertex3i(0,0,0);glVertex3i(0,0,7);
   glEnd();

    glBegin(GL_QUADS);

    glColor4f(1.0f, 1.0f, 0.3f,1.0f);
    glVertex3f(-x,-y,7);
    glVertex3f(-x,+y,7);
    glVertex3f(+x,+y,7);
    glVertex3f(+x,-y,7);
 glColor4f(1.0f, 0.0f, 1.0f, 1.0f);
    glVertex3f(-x,-y,7);
    glVertex3f(-x,+y,7);
    glVertex3f(-x,+y,-7);
    glVertex3f(-x,-y,-7);
 glColor4f(0.0f, 1.0f, 1.0f, 1.0f);
    glVertex3f(+x,+y,7);
    glVertex3f(+x,-y,7);
    glVertex3f(+x,-y,-7);
    glVertex3f(+x,+y,-7);

    glColor4f(0.0f, 0.0f, 1.0f, 0.5f);
    glVertex3f(-x,-y,-5);
    glVertex3f(-x,+y,-5);
    glVertex3f(+x,+y,-5);
    glVertex3f(+x,-y,-5);
    glEnd();
    //glColor4f(1.0f, 1.0f, 1.0f,1.0f);



    glFlush();
    SwapBuffers(hdc);
    }
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
    {
    ogl_inicialized=0;
     ogl_init();
    }
//---------------------------------------------------------------------------

void __fastcall TForm1::des(TObject *Sender)
{
   ogl_exit();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::res(TObject *Sender)
{
  ogl_resize();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::mwd(TObject *Sender, TShiftState Shift,
      TPoint &MousePos, bool &Handled)
{
    glMatrixMode(GL_PROJECTION);
    glScalef(1.1,1.1,+1.1);
    ogl_draw();

}
//---------------------------------------------------------------------------
void __fastcall TForm1::mwu(TObject *Sender, TShiftState Shift,
      TPoint &MousePos, bool &Handled)
{
    glMatrixMode(GL_PROJECTION);
    glScalef(1/1.1,1/1.1,1/1.1);
    ogl_draw();

}
//---------------------------------------------------------------------------
void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glRotatef(1.0f*uholx,1.0f,0.0f,0.0f);
  glRotatef(1.0f*uholy,0.0f,1.0f,0.0f);
  ogl_draw();

  uholx=(uholx+2) % 360;
   uholy=(uholy+1) % 360;
   Edit1->Text=uholx;
 // SwapBuffers(hdc);

}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{
Timer1->Enabled=1;
}
//---------------------------------------------------------------------------

