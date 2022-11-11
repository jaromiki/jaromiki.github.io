program ctvertex;

uses
  Forms,
  ctvertex_f in 'ctvertex_f.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'OpenGL & Delphi';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
