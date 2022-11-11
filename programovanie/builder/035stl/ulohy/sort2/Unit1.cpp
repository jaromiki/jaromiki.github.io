//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
#include <vector>
#include <algorithm>

using namespace std;
TForm1 *Form1;
typedef struct
        { char meno[6];
          int skok1,skok2;} Tpretekar;
vector <Tpretekar> p;
Tpretekar pp;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
bool mf1(Tpretekar p1,Tpretekar p2)
{ int m=strcmp(p1.meno,p2.meno);  return (m<0); }
bool mf2(Tpretekar p1,Tpretekar p2)
{ int m1=max(p1.skok1,p1.skok2);
   int m2=max(p2.skok1,p2.skok2);
  return (m1<m2); }

void __fastcall TForm1::FormCreate(TObject *Sender)
{ Memo1->Clear();
  for (int i=0;i<10;i++)
  { for (int j=0; j<5; j++) pp.meno[j]=random(26)+97;
    pp.skok1=500+random(150);
    pp.skok2=500+random(150);
    p.push_back(pp);
    Memo1->Lines->Append(Format("meno:%6s   skoky; %3d %3d",ARRAYOFCONST((pp.meno,pp.skok1,pp.skok2))));

  }        }
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{ Memo2->Clear();
  sort(p.begin(),p.end(),mf1);
  for (int i=0;i<10;i++)
  {     Memo2->Lines->Append(Format("meno:%6s skoky; %3d %3d",ARRAYOFCONST((p[i].meno,p[i].skok1,p[i].skok2))));

  }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::Button2Click(TObject *Sender)
{  Memo2->Clear();
  sort(p.begin(),p.end(),mf2);
  for (int i=0;i<10;i++)
  {     Memo2->Lines->Append(Format("meno:%6s skoky; %3d %3d",ARRAYOFCONST((p[i].meno,p[i].skok1,p[i].skok2))));

  }


}
//---------------------------------------------------------------------------
