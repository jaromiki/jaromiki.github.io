#include <iostream>
#include <vector>
using namespace std;

vector < vector <int> > o(1000000);
int n,k,i,j,p,c;
void chod(int pc, int &c)
{ if (o[pc][0]<0)
    o[pc].push_back(c++);
  else for (int i=1; i<=o[pc][0] ; i++)
          chod(o[pc][i],c);
}

int main(int argc, char* argv[])
{    cin >>n>>k;
     for (i=1; i<=n ;i++)
     { cin >>p;
       if (p>0)
       { o[i].resize(p+1);
         o[i][0]=p;
         for (j=1; j<=p; j++) cin>>o[i][j];
       }
       else
       { o[i].resize(1); o[i][0]=-1; }
    }
    c=1;
    chod(1,c);
    cout <<c<<endl;
        system ("pause");
        return 0;
}
//---------------------------------------------------------------------------
 