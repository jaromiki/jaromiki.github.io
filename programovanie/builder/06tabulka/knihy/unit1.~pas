unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, Menus;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Load1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure pis(Sender: TObject; var Key: Char);
    procedure Exit1Click(Sender: TObject);
    procedure Load1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Saveas1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure triedim(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
 var sub:string ;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
     sub:='';
     StringGrid1.Rows[0].Text:=''#13'Názov'#13'roèník'#13'pocet';
     StringGrid1.Rows[1].Text:='1';
end;

procedure TForm1.pis(Sender: TObject; var Key: Char);
var n:integer;
begin
   n:=StringGrid1.RowCount;
  if  StringGrid1.Row=StringGrid1.RowCount-1 then
  begin
    StringGrid1.RowCount:=StringGrid1.RowCount+1;
    inc(n);
    StringGrid1.Rows[n-1].text:=inttostr(n-1);
  end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  close;
end;



procedure TForm1.Load1Click(Sender: TObject);
var f:TextFile;
    n,i:integer;
    s,s1:string;
begin
    opendialog1.FileName:=sub;
    if opendialog1.Execute then
    Begin
     for i:=1 to StringGrid1.RowCount do StringGrid1.Rows[i].Clear;
     sub:=opendialog1.FileName;
     assignFile(f,sub);
     reset(f);
     readln(f,n);
     StringGrid1.RowCount:=n+2;
     for i:=1 to n do
     begin
       s:=inttostr(i);
       readln(f,s1);
       s:=s+#13+s1;
       readln(f,s1);
       s:=s+#13+s1;
       readln(f,s1);
       s:=s+#13+s1;
       StringGrid1.Rows[i].Text:=s;
     end;
     StringGrid1.Rows[n+1].Text:=inttostr(n+1);
     closefile(f);
    end;
end;

procedure TForm1.Save1Click(Sender: TObject);
var f:TextFile;
    n,i,j,k:integer;
    s,s1:string;
begin
   if sub='' then Saveas1Click(Sender)
             else
             Begin
              assignFile(f,sub);
              rewrite(f);
              n:=StringGrid1.rowcount-2;
              writeln(f,n);
              for i:=1 to n do
              begin
                 s:=StringGrid1.Rows[i].text;
                 k:=0;
                 while s[k]<>#13 do inc(k);
                 for j:=k+2 to length(S) do
          //         if s[j]=#13 then writeln(f) else write(f,s[j]);
                     write(f,s[j]);
             end;
             closefile(f);
             End;
end;

procedure TForm1.Saveas1Click(Sender: TObject);
begin
  savedialog1.FileName:='';
  if savedialog1.Execute then
  begin
    sub:=savedialog1.FileName;
    save1Click(Sender);
  end;
end;

procedure TForm1.Delete1Click(Sender: TObject);
var i,r,p: integer;
begin
   r:= StringGrid1.Row;
   p:= StringGrid1.RowCount-2 ;
   if r<=p then
   begin
     for i:=r to p do StringGrid1.Rows[i].text:=StringGrid1.Rows[i+1].Text;
     StringGrid1.RowCount:=StringGrid1.RowCount-1;
     for i:=1 to p+1 do StringGrid1.Cells[0,i]:=inttostr(i);
   end;  
   end;

procedure TForm1.triedim(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var n,r,s,i,j:integer;
  begin
   StringGrid1.MouseToCell(x,y,s,r);
   n:=StringGrid1.RowCount-2;
   if r=0 then
   begin
     for i:= 1 to n-1 do
       for j:= 1 to n-i do
         if StringGrid1.Cells[s,j] > StringGrid1.Cells[s,j+1] then
         begin
             StringGrid1.Rows[n+1].Text:=StringGrid1.Rows[j].Text;
             StringGrid1.Rows[j].Text:=StringGrid1.Rows[j+1].Text;
             StringGrid1.Rows[j+1].Text:=StringGrid1.Rows[n+1].Text;
             StringGrid1.Rows[n+1].Clear;

         end;
   for i:=1 to n+1 do StringGrid1.Cells[0,i]:=inttostr(i);
   end;
end;

end.
