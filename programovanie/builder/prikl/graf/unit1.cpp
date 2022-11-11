//---------------------------------------------------------------------------

#include <vcl.h>
#include <math.h>
#pragma hdrstop

#include "Unit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;
int pu;
double xx,yy;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::Button1Click(TObject *Sender)
{  pu=StrToInt(Edit1->Text);
   StringGrid1->ColCount = pu+1;
   StringGrid1->RowCount = pu+1;
   for (int i=1; i<=pu; i++)
   {  StringGrid1->Cells[0][i]=i;
      StringGrid1->Cells[i][0]=i;
      xx=300 + 200*cos(2*3.14/pu*i);
      yy=300 + 200*sin(2*3.14/pu*i);
      Image1->Canvas->Ellipse(xx-10,yy-10,xx+10,yy+10);
   }
   for (int i=1; i<=pu; i++)
     for (int j=1;j<=pu;j++)
        StringGrid1->Cells[i][j] = 0;


}
//---------------------------------------------------------------------------
 