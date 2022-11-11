//intervalovy strom - intervaly su od a po b
//vlastnosti
//1 - > koren
//i - > deti na adrese 2*i, 2*i+1
//i - > rodic na adrese i div 2
//i - parne je lave dieta, neparne je prave dieta
// listy su na adresach n..2n-1
program Project2;

{$APPTYPE CONSOLE}

uses
  SysUtils;

var
a,b,c,i,n,m,l,p,h,index,s: integer;
pp: array [1..1048576] of smallint;
begin
 writeln('zadaj zakladny interval');
 readln(a,b); c:=b-a+1+2;
 n:=1;
 while n<c do n:=n*2;
 write('zadaj pocet intervalov: ');
 readln(m);
 for i:=1 to m do
 begin
   write('interval c.:',i, 'yadaj l,p,h: ');
   readln (l,p,h);
   l:=l-a+n; p:=p-a+n+2;
   while l+1<p do
   begin
     if l mod 2 =0 then pp[l+1]:=pp[l+1]+h;
     if p mod 2 =1 then pp[p-1]:=pp[p-1]+h;
     l:=l div 2; p:=p div 2;
   end;
 end;
 write('index:'); readln(index);
 while  index>0 do
 begin
 s:=0;
 index:=index-a+n+1;
 while index>1 do
 begin s:=s+pp[index];
 index:=index div 2; end;
 writeln ('sucet:',s);
 readln (index);
 end
end.
 