#include <iostream>
#include <vector>
#include <queue>
using namespace std;
//a ... matica susednosti
//z ... zatopene=1
//p ... zoznam vybavovanych
//s... vzdialenost krizovatky od start
//d ... vzd. od krizovatky 0
vector < vector <int> > a(100000);
vector <int> z(100000,0);
queue <int> p;
int n,m,k,i,j,k1,k2,kk,ni;
char s[100000];
int d[100000];

int main(int argc, char* argv[])
//***************vstup********************************
{ cin >>n>>m>>k;
  for (i=0; i<n; i++) cin >>z[i];
  cout <<endl;
  z[n-1]=0;
  for (i=0; i<m; i++)
  { cin >>k1>>k2;
    a[k1].push_back(k2); a[k2].push_back(k1);
  }
//*************rusenie nepodstatnych zatopeni**********
  p.push(n-1); s[n-1]= 1; kk=n-1; z[n-1]=0;  //ciel nebude zatopeny
  while ( !p.empty() && (kk=p.front(),s[kk]<=k))
  { p.pop();
    ni=a[kk].size();         //pocet susedov
    for (j=0; j<ni; j++)
    { k1=a[kk][j];           //meno suseda
      if (!s[k1])            //este nenajdeny
      {  z[k1]=0; p.push(k1); s[k1]=s[kk]+1; //dlzka cesty o 1 viac
      }
    }
  }
//*************vyprazdnenie fronty***********************
  while ( !p.empty()) p.pop();   
  for (i=0; i<n; i++) s[i]=0;
//***********klasicke hladanie min cesty, len po nezatopenych************
  p.push(0); s[0]= 1; kk=n-1;
  while ( !p.empty() && !s[n-1])
  { kk=p.front();
    p.pop();
    ni=a[kk].size();
    if (!z[kk])
    for (j=0; j<ni; j++)
    { k1=a[kk][j];
      if (!s[k1])
      {  p.push(k1); s[k1]=s[kk]+1;
      }
    }
  }
  cout << (s[n-1]? s[n-1]-1:-1) <<endl;
  system("pause");
        return 0;
}
//---------------------------------------------------------------------------
 