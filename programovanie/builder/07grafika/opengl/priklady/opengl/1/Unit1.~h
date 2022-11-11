//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
        TTimer *Timer1;
        TButton *Button1;
        TEdit *Edit1;
        void __fastcall des(TObject *Sender);
        void __fastcall res(TObject *Sender);
        void __fastcall mwd(TObject *Sender, TShiftState Shift,
          TPoint &MousePos, bool &Handled);
        void __fastcall mwu(TObject *Sender, TShiftState Shift,
          TPoint &MousePos, bool &Handled);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TForm1(TComponent* Owner);
            int     xs,ys;
    HDC     hdc;            // device context
    HGLRC   hrc;            // rendering context
    int  ogl_inicialized;
    int  ogl_init();
    void ogl_exit();
    void ogl_draw();
    void ogl_resize();
    void FormDestroy();

};
    int TForm1::ogl_init()
    {
    if (ogl_inicialized) return 1;
    hdc=0;
    hdc = GetDC(Handle);             // get device context
    PIXELFORMATDESCRIPTOR pfd;
    ZeroMemory( &pfd, sizeof( pfd ) );      // set the pixel format for the DC
    pfd.nSize = sizeof( pfd );
    pfd.nVersion = 1;
    pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType = PFD_TYPE_RGBA;
    pfd.cColorBits = 24;
    pfd.cDepthBits = 24;
    pfd.iLayerType = PFD_MAIN_PLANE;
    SetPixelFormat(hdc,ChoosePixelFormat(hdc, &pfd),&pfd);
    hrc=0;
    hrc = wglCreateContext(hdc);            // create current rendering context
    if(hrc == NULL)
            {
            ShowMessage("Could not initialize OpenGL Rendering context !!!");
            ogl_inicialized=0;
            return 0;
            }
    if(wglMakeCurrent(hdc, hrc) == false)
            {
            ShowMessage("Could not make current OpenGL Rendering context !!!");
            wglDeleteContext(hrc);          // destroy rendering context
            ogl_inicialized=0;
            return 0;
            }
    ogl_resize();
    glEnable(GL_DEPTH_TEST);                // Zbuf
    glDisable(GL_CULL_FACE);                // vynechavaj odvratene steny
    glDisable(GL_TEXTURE_2D);               // pouzivaj textury, farbu pouzivaj z textury
    glEnable(GL_BLEND);                    // priehladnost
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glShadeModel(GL_SMOOTH);                // gourard shading
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);   // background color
    ogl_inicialized=1;
    return 1;
    }
//---------------------------------------------------------------------------
void TForm1::ogl_exit()
    {
    if (!ogl_inicialized) return;
    wglMakeCurrent(NULL, NULL);     // release current rendering context
    wglDeleteContext(hrc);          // destroy rendering context
    ogl_inicialized=0;
    }
//---------------------------------------------------------------------------
void TForm1::ogl_resize()
    {
    xs=ClientWidth;
    ys=ClientHeight;
    if (xs<=0) xs = 1;                  // Prevent a divide by zero
    if (ys<=0) ys = 1;
    if (!ogl_inicialized) return;
    glViewport(0,0,xs,ys);              // Set Viewport to window dimensions
    glMatrixMode(GL_PROJECTION);        // operacie s projekcnou maticou
    glLoadIdentity();                   // jednotkova matica projekcie
  glOrtho(-8,+8,-8,+8,-30,+30);
 //   gluPerspective(40,float(xs)/float(ys),0.1,100.0); // matica=perspektiva,120 stupnov premieta z viewsize do 0.1
    glMatrixMode(GL_TEXTURE);           // operacie s texturovou maticou
    glLoadIdentity();                   // jednotkova matica textury
    glMatrixMode(GL_MODELVIEW);         // operacie s modelovou maticou
    glLoadIdentity();                   // jednotkova matica modelu (objektu)
    ogl_draw();
    }
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
 