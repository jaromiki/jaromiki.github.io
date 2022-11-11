unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure aaa(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
StringGrid1.Cells[2,1]:='ahoj';
StringGrid1.Canvas.TextRect(StringGrid1.Cellrect(2,1),1,20,'ahoj');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//
end;

procedure TForm1.aaa(Sender: TObject; ACol, ARow: Integer; Rect: TRect;  State: TGridDrawState);
begin
StringGrid1.Canvas.Ellipse(StringGrid1.CellRect(Acol,Arow));
//StringGrid1.Canvas.Ellipse(Rect);
StringGrid1.Canvas.TextRect(Rect, Rect.Left+20, Rect.Top+7, StringGrid1.Cells[ACol, ARow]);
StringGrid1.Canvas.Brush.Style:=bsClear;
StringGrid1.Canvas.Ellipse(StringGrid1.CellRect(Acol,Arow));
end;

end.
