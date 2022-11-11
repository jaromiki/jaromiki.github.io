unit OvlPan_f;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Spin, StdCtrls, Buttons;

type
  TForm2 = class(TForm)
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    Label5: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SpinButton1: TSpinButton;
    SpinButton2: TSpinButton;
    SpinButton3: TSpinButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton2DownClick(Sender: TObject);
    procedure SpinButton2UpClick(Sender: TObject);
    procedure SpinButton3DownClick(Sender: TObject);
    procedure SpinButton3UpClick(Sender: TObject);
    private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses ctvertex_f;

{$R *.DFM}



procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
  Form1.Z := Form1.Z + 0.5;
end;

procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
  Form1.Z := Form1.Z - 0.5;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
begin
  Form1.X := Form1.X + 0.5;
end;

procedure TForm2.SpeedButton4Click(Sender: TObject);
begin
  Form1.X := Form1.X - 0.5;
end;

procedure TForm2.SpeedButton5Click(Sender: TObject);
begin
  Form1.Y := Form1.Y - 0.5;
end;

procedure TForm2.SpeedButton6Click(Sender: TObject);
begin
  Form1.Y := Form1.Y + 0.5;
end;

procedure TForm2.SpinButton1UpClick(Sender: TObject);
begin
  Form1.UhelX := Form1.UhelX + 10;
end;

procedure TForm2.SpinButton1DownClick(Sender: TObject);
begin
  Form1.UhelX := Form1.UhelX - 10;
end;

procedure TForm2.SpinButton2DownClick(Sender: TObject);
begin
  Form1.UhelY := Form1.UhelY - 10;
end;

procedure TForm2.SpinButton2UpClick(Sender: TObject);
begin
  Form1.UhelY := Form1.UhelY + 10;
end;

procedure TForm2.SpinButton3DownClick(Sender: TObject);
begin
  Form1.UhelZ := Form1.UhelZ - 10;
end;

procedure TForm2.SpinButton3UpClick(Sender: TObject);
begin
  Form1.UhelZ := Form1.UhelZ + 10;
end;

end.
