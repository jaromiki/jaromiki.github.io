program scene;

uses
  Forms,
  scene_f in 'scene_f.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'OpenGL & Delphi';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
