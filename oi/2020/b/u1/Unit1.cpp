#include <iostream>
using namespace std;
typedef  struct
{ int pred, za;
} Tkor;
typedef  struct
{ int spod, vrch;
} Tpol;

Tkor kor[300000];
int p,q,n,i,j,k  ,ki,pi,xi,  pp;
Tpol policka[10000];

int main(int argc, char* argv[])
{   cin >> n>>p >>q;

    for(i=1,j=0; i<=n; i++)
    { cin >>k;
      if (i==1)policka[1].spod=k;
      if (i==n)policka[1].vrch =k;
      kor[k].pred=j;
      kor[j].za=k;
      j=k;
    }
    for (i=1;i<=q;i++)
    { cin >> ki>>pi>>xi;
      k=kor[ki].pred;
      kor[k].za=0; kor[ki].pred=policka[pi+xi].vrch; kor[policka[pi+xi].vrch].za=ki;
      policka[pi+xi].vrch=policka[pi].vrch;
      if (policka[pi+xi].spod ==0) policka[pi+xi].spod =ki;
      policka[pi].vrch=k;
      if (k==0) policka[pi].spod=0;
    }
    for(i=1;i<=p;i++)
    { j=policka[i].spod;
      pp=0;
      for(int ii=j; ii;ii=kor[ii].za) pp++;
      cout <<pp;
      while (j)
      { cout <<' '<<j;
        j=kor[j].za;
      }
      cout <<endl;
    }   system("pause");
        return 0;
}
//---------------------------------------------------------------------------
