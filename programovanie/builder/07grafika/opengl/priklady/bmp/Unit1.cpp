//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
#include <gl\gl.h>// Hlavièkový soubor pro OpenGL32 knihovnu
#include <gl\glu.h>// Hlavièkový soubor pro Glu32 knihovnu
#include <gl\glaux.h>// Hlavièkový soubor pro Glaux knihovnu
#include <soil\soil.h>

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
char bmp[256][256][3];
float s=0,t=0;
int uholx,uholy=20;
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
//  glRotatef(20.0,1.0f,0.0f,0.0f);
//  glRotatef(uholy,0.0f,1.0f,0.0f);

//tu zadávame príkazy na kreslenie
  glColor4f(1.0f, 1.0f, 1.0f,1.0f);
    glBegin(GL_QUADS);
         glTexCoord2f(0.0, 0.0); glVertex3f(-6, +4, 0);
        glTexCoord2f(2.0, 0.0); glVertex3f(+6, +4, 0);
        glTexCoord2f(2.0*10/12, 1.0); glVertex3f(+4, -4, 0);
        glTexCoord2f(2.0*2/12, 1.0); glVertex3f(-4, -4, 0);
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
{
for (int y=0;y<256;y++)             // pro vsechny radky pixmapy
        for (int x=0;x<256;x++)        // pro vsechny pixely na radku
        if ((y/32+x/32)%2)
            bmp[y][x][0]= bmp[y][x][1]= bmp[y][x][2]= 0;// cierne policko
        else
		{ //  bmp[y][x][0]=256-abs(x-128)-abs(y-128); bmp[y][x][1]=(256-abs(x-128)-abs(y-128))/2; bmp[y][x][2]= abs(x-128)+abs(y-128);
                    bmp[y][x][0]=x;  bmp[y][x][1]=y; bmp[y][x][2]=0;}
    glEnable(GL_TEXTURE_2D);       // povolime texturu
 //   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);      // v smere osi x povolime opakovanie textury
 //   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);      // v smere osi y povolime opakovanie textury
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);  // spôsob výpoètu ïalších bodov (textura vacsia)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, &bmp);

}
//---------------------------------------------------------------------------
void __fastcall TForm1::Timer1Timer(TObject *Sender)
{  uholy=(uholy+1)%360;//uholx=(uholx+1)%360;
   ogl_draw();
}
//---------------------------------------------------------------------------



