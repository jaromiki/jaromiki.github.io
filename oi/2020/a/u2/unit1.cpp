#include <iostream>
using namespace std;
int n,k,kp=0,poc=0,i;
int main(int argc, char* argv[])
{ cin >>n;
  for(i=0;i<n;i++)
  { cin >>k;
    switch (k)
    {case 0 :poc++; kp=0; break;
     case -1: kp==1 ?(poc++,kp=0): kp=-1;  break;
     case  1: kp==-1?(poc++,kp=0): kp= 1;  break;
    }
  }
  cout <<poc<<endl;
  system("pause");
  return 0;
}
//---------------------------------------------------------------------------
 