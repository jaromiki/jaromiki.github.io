//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
#include <vector>
using namespace std;
vector <int> xx,yy;
vector <int> ff;
int mdole=0,akt;
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{   int x,y,f;
    DoubleBuffered=1;
    Image1->Canvas->Pen->Style= psClear;
    Image1->Canvas->Pen->Width=3;
    for (int i=0;i<10;i++)
    {  x=random(Image1->Width-40)+20; y=random(Image1->Height-40)+20;
       f=RGB(random(150),random(150),random(150));
       xx.push_back(x);
       yy.push_back(y);
       ff.push_back(f);
       Image1->Canvas->Brush->Color=f;
       Image1->Canvas->Ellipse(x-20,y-20,x+20,y+20);
    }
}
//---------------------------------------------------------------------------

void __fastcall TForm1::move(TObject *Sender, TShiftState Shift, int X,
      int Y)
{  if (mdole==1)
   {  xx[akt]=X;yy[akt]=Y;
   }
   Image1->Canvas->Brush->Color=clWhite;
   Image1->Canvas->FillRect(Image1->ClientRect);
   for (int i=0;i<10;i++)
   {  if (abs(X-xx[i])<12 &&abs(Y-yy[i])<12) {Image1->Canvas->Pen->Style= psSolid; akt=i;}
      else Image1->Canvas->Pen->Style= psClear;
       Image1->Canvas->Brush->Color=ff[i];
       Image1->Canvas->Ellipse(xx[i]-20,yy[i]-20,xx[i]+20,yy[i]+20);

   }

}
//---------------------------------------------------------------------------
void __fastcall TForm1::dole(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{  mdole=1;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::hore(TObject *Sender, TMouseButton Button,
      TShiftState Shift, int X, int Y)
{
  mdole=0;
}
//---------------------------------------------------------------------------
