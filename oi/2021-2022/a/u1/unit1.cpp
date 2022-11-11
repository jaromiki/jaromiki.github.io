#include <iostream>
#include <sstream>
using namespace std;
int a,b,i,n,k,l,p1,p2,p11,p22,p3,p,h[1002];
std::ostringstream vystup (std::ostringstream::ate);
//********************** otoci usek <a;b> *******************************
void otoc(int a, int b)
{   if (a<b)
    {    vystup << a<<' '<<b<<endl;
         for ( ;a<b; a++,b--) {h[1001]=h[a]; h[a]=h[b]; h[b]=h[1001];}
         p++;
    }
}
//*****************VLAVO vacsie ako kral posunie ku kralovi *************
void predtried1(int a, int b)
{       while (a<b)
        { while (h[a]<h[k]) a++;
          while (h[b]>h[k]) b--;
          if (a<b) otoc(a,b);
        }
}
//*****************VLAVO prisunie hodnoty ako kral posunie ku kralovi ***
void predtried3(int a, int b)
{       while (a<b)
        { while (h[a]<h[k]) a++;
          while (h[b]==h[k]) b--;
          if (a<b) otoc(a,b);
        }
}
//*****************VPRAVO vacsie ako kral posunie ku kralovi *************
void predtried2(int a, int b)
{       while (a<b)
        { while (h[a]>h[k]) a++;
          while (h[b]<h[k]) b--;
          if (a<b) otoc(a,b);
        }
}
//*****************VPRAVO hodnoty ako kral posunie ku kralovi *************
void predtried4(int a, int b)
{       while (a<b)
        { while (h[a]==h[k]) a++;
          while (h[b]<h[k]) b--;
          if (a<b) otoc(a,b);
        }
}
//********************** utriedi usek <a;b> *******************************

void utried(int a, int b)
{  int ii=a,m=h[a];
   while (a<b)
   { for (int i=a+1; i<=b; i++) if (h[i]>h[ii]) ii=i;
     if (ii<b) otoc(ii,b);
     b--;
   }
}

int main(int argc, char* argv[])
{   cin>>n>>k>>l;
    for (i=1;i<=n;i++) cin >> h[i];
    for (i=1; i<k; i++) {if (h[i]>h[k]) p1++; if (h[i]==h[k]) p11++;}
    for (i=k+1; i<=n; i++) {if (h[i]<h[k]) p2++; if (h[i]==h[k]) p22++;}
//************************ p1 == p2 ******************************************
    if (p1==p2)
    { cout <<"ANO"<<endl;;
      if (l)
      {
      if (p1)               //****ak treba prehadzovat ponad krala *********
      { predtried1(1,k-1);
        predtried2(k+1,n);
        otoc(k-p1,k+p1);
      }
      utried(1,k-1);
      utried(k+1,n);
      cout << p<<endl;
      cout << vystup.str() ;
      }
    }
//************************ p1 < p2 ******************************************
    else if (p1<p2 && p1+p11>=p2)
                 { cout <<"ANO"<<endl;
                  if (l)
                  {
                   predtried1(1,k-1);
                   predtried3(1,k-p1-1);
                   predtried2(k+1,n);
                   otoc(k-p2,k+p2);
                   utried(1,k-1);
                   utried(k+1,n);
                   cout << p<<endl;
                   cout << vystup.str() ;
                   }
         }
//************************ p1 > p2 ******************************************
         else if (p1>p2 && p2+p22>=p1)
                { cout <<"ANO"<<endl;
                  if (l)
                  {
                  predtried1(1,k-1);
                  predtried2(k+1,n);
                  predtried4(k+1+p2,n);
                  otoc(k-p1,k+p1);
                  utried(1,k-1);
                  utried(k+1,n);
                   cout << p<<endl;
                   cout << vystup.str();
                  }
         }
              else cout << "NIE"<<endl; ;
    system("pause");

        return 0;
}
//---------------------------------------------------------------------------
