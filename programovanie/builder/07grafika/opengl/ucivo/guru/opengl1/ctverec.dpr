program ctverec;

uses
  Forms,
  ctverec_f in 'ctverec_f.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
