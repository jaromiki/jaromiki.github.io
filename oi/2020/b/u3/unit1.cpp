#include <iostream>
#include <vector>
using namespace std;

vector < vector <int> > o(1000000);
int n,k,i,j,p,c;

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
    i=1;
    while (o[i][0]!=-1)
    { p=k%o[i][0];  k=(k+o[i][0]-1)/o[i][0];
       if (p==0) p=o[i][0];
      i=o[i][p];
    }
    cout <<i<<endl;
        system ("pause");
        return 0;
}
//---------------------------------------------------------------------------


 