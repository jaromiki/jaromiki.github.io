//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
#include <vector>
TForm1 *Form1;
using namespace std;
vector <int> lopta(5);
vector <vector <int> > lopty;

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::pridaj(TObject *Sender)
{
lopta[0]=50+random(200);
lopta[1]=50+random(200);
lopta[2]=1+random(5);
lopta[3]=1+random(5);
lopta[4]=RGB(random(200),random(200),random(200));
 lopty.push_back(lopta);

}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{  DoubleBuffered=1;
 Image1->Canvas->Brush->Color=RGB(180,180,255);
Image1->Canvas->FillRect(Image1->ClientRect);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Timer1Timer(TObject *Sender)
{
   Image1->Canvas->Brush->Color=RGB(180,180,255);
   Image1->Canvas->FillRect(Image1->ClientRect);
   Label1->Caption=IntToStr(lopty.size());
   for (int i=0;i<lopty.size();i++)
   { lopty[i][0]+=lopty[i][2]; lopty[i][1]+=lopty[i][3];
     if (lopty[i][0]<15 || lopty[i][0]>Image1->Width-15) lopty[i][2]=-lopty[i][2];
     if (lopty[i][1]<15 || lopty[i][1]>Image1->Height-15) lopty[i][3]=-lopty[i][3];
     for (int j=0;j<lopty.size();j++)
     if (i-j)
     {  if ( abs(lopty[i][0]-lopty[j][0])<20 && abs(lopty[i][1]-lopty[j][1])<20)
       {  if (i>j)
          {lopty.erase(lopty.begin()+i); lopty.erase(lopty.begin()+j);}
          else
          {lopty.erase(lopty.begin()+j); lopty.erase(lopty.begin()+i);}
       }
     }
     else
     {
     Image1->Canvas->Brush->Color=lopty[i][4];
     Image1->Canvas->Ellipse(lopty[i][0]-15,lopty[i][1]-15,lopty[i][0]+15,lopty[i][1]+15);
     }
  }

}
//---------------------------------------------------------------------------
