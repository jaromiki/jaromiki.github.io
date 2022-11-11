program Muj;

uses
  Forms,
  main in 'main.pas' {GLForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TGLForm, GLForm);
  Application.Run;
end.

