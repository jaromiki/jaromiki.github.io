// zjednotenie množín
#include <iostream>     // std::cout
#include <algorithm>    // std::sort
#include <vector>       // std::vector
#include <list>         // std::list
#include <set>          // std::list
using namespace std;

int pole1[] = {32,71,12,45,26,80,53,33};         // vytvoríme pole 8 int
int pole2[] = {12,11,22,80,66,75,45,63};         // vytvoríme pole 8 int
vector <int> v1(pole1, pole1+8);		//32,71,12,45,26,80,53,33
vector <int> v2(pole2, pole2+8);		//12,11,22,80,66,75,45,63
vector <int> v(20);
list <int> list1(pole1, pole1+8);			//32,71,12,45,26,80,53,33
list <int> list2(pole2, pole2+8);			//12,11,22,80,66,75,45,63
list <int> list3(20);
set <int> s1(pole1, pole1+8);			//12,26,32,33,45,53,71,80
set <int> s2(pole2, pole2+8);			//11,12,22,45,63,66,75,80
set <int> s;

int i;
int main ()
{ // zjednotenie vektorov prepisovanim
        sort(v1.begin(),v1.end()); sort(v2.begin(),v2.end());
        vector <int>::iterator it=set_union(v1.begin(),v1.end(),v2.begin(),v2.end(),v.begin());
        v.erase(it,v.end());     //odstranim prebytocne
        for (i=0; i<(int)v.size();i++)
          cout <<v[i]<<' ';     //11 12 22 26 32 33 45 53 63 66 71 75 80
        system("pause");
// zjednotenie vektorov vsuvanim v1,v2 su stale utriedene
        v.clear();              //vymazem vystupny objekt
         insert_iterator<vector<int> > iter(v,v.begin());
//  navratova hodnota ma rovnaky typ ako 5. parameter, ked chcem navratovu hodnotu potrebujem vsuvaci iterator
//  i ked v tomto pripade ani tu navratovu hodnotu nepotrebujem
        iter=set_union(v1.begin(),v1.end(),v2.begin(),v2.end(), inserter(v, v.begin()));
//alebo iter=set_union(v1.begin(),v1.end(),v2.begin(),v2.end(), iter);
        for (i=0; i<(int)v.size();i++)
          cout <<v[i]<<' ';     //11 12 22 26 32 33 45 53 63 66 71 75 80
        system("pause");

 // zjednotenie listov prepisovanim
        list1.sort(); list2.sort();
        list<int>::iterator it_list;
 /*       set_union(list1.begin(),list1.end(),list2.begin(),list2.end(),list3.begin());
        list3.erase(it_list,list3.end());     //odstranim prebytocne
        for (it_list=list3.begin(); it_list!=list3.end();it_list++)
          cout <<*it_list<<' ';     //11 12 22 26 32 33 45 53 63 66 71 75 80
        system("pause");
*/
        // zjednotenie vektorov vsuvanim v1,v2 su stale utriedene
        list3.clear();              //vymazem vystupny objekt
         insert_iterator<list<int> > iter_listi(list3,list3.begin());
//  navratova hodnota ma rovnaky typ ako 5. parameter, ked chcem navratovu hodnotu potrebujem vsuvaci iterator
//  i ked v tomto pripade ani tu navratovu hodnotu nepotrebujem
        iter_listi= set_union(list1.begin(),list1.end(),list2.begin(),list2.end(), iter_listi);
//alebo iter_list=set_union(list1.begin(),list1.end(),list2.begin(),list2.end(), iter_list);
        for (it_list=list3.begin(); it_list!=list3.end();it_list++)
          cout <<*it_list<<' ';     //11 12 22 26 32 33 45 53 63 66 71 75 80
        system("pause");

  return 0;
}


