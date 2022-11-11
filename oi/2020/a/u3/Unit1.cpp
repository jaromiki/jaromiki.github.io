#include <iostream>
using namespace std;
int m,p,s,i,lav,pra,lavmax,d,dmax,n,k,a[1000000];
int main(int argc, char* argv[])
{   cin >>n>>k;
    for (i=1; i<=n; i++)  {cin>>a[i]; if (!m &&a[i]<k) m=i;}
    if (!m) {cout >>"0 0\n";system("pause");return 0;}
    lav=m;pra=m;s=a[m];p=1;
    while ( s+a[pra+1]<=k) pra++,p++,s+=a[pra];
    lavmax=lav;dmax=pra-lav+1;

    system("pause");
        return 0;
}
//---------------------------------------------------------------------------
 