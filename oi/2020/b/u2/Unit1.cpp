#include <iostream>
#include <algorithm>
using namespace std;

int p,pm,i,j,k,n, l[1000000];
int main(int argc, char* argv[])
{  cin >>n;
   for (i=0;i<n;i++) cin>>l[i];
   sort (l+0,l+n);
   pm=0; p=3;
   for(i=0,j=1,k=2; k<n ;i++,j++,p--)
   {
      while (l[i]+l[j]>l[k] &&k<n) {k++; p++;}
      if (p>pm) pm=p-1;
   }
   cout <<pm<<endl;
   system("pause");
   return 0;
}
//---------------------------------------------------------------------------
 