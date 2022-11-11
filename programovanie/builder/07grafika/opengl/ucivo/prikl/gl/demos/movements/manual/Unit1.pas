{: This Form demonstrates basic "manual" movements.<p>

	Positions are computed directly using Sin/Cos functions.<p>

	An asynchronous timer is used to "play" the animation, its Interval
	is 1 msec. Without hardware acceleration, this is negligible, but with
	a 3D card, this means that your FPS count will most likely stick to
	multiples of timer ticks.<br>

	Note : when using 3Dfx OPENGL and a Voodoo3 on Win9x in 24bits resolution,
	the driver always uses internal double-buffering (since it can only render
	in 16bits), and keeping the requesting double-buffering in the TGLSceneViewer
	actually results in a "quadruple-buffering"...
}
unit Unit1;

interface

uses
  Windows, Forms, GLScene, GLObjects, ComCtrls, GLMisc, ExtCtrls, StdCtrls,
  AsyncTimer, Classes, Controls;

type
  TForm1 = class(TForm)
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    TrackBar: TTrackBar;
    Cube1: TCube;
    Cube3: TCube;
    Cube2: TCube;
    GLCamera1: TGLCamera;
    GLLightSource1: TGLLightSource;
    CBPlay: TCheckBox;
    StaticText1: TStaticText;
    Timer1: TAsyncTimer;
    procedure TrackBarChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses Math, SysUtils;

procedure TForm1.TrackBarChange(Sender: TObject);
var
   t : Integer;
begin
	t:=TrackBar.Position;
	// the "sun" turns slowly around Y axis
	Cube1.TurnAngle:=t/4;
	// "earth" rotates around the sun on the Y axis
	with Cube2.Position do begin
		X:=3*cos(DegToRad(t));
		Z:=3*sin(DegToRad(t));
	end;
	// "moon" rotates around earth on the X axis
	with Cube3.Position do begin
		X:=Cube2.Position.X;
		Y:=Cube2.Position.Y+1*cos(DegToRad(3*t));
		Z:=Cube2.Position.Z+1*sin(DegToRad(3*t));
   end;
   // update FPS count
   StaticText1.Caption:=IntToStr(Trunc(GLSceneViewer1.FramesPerSecond))+' FPS';
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
	// disable the timer during rendering
	Timer1.Enabled:=False;
	if CBPlay.Checked and Visible then begin
		// simulate a user action on the trackbar...
		TrackBar.Position:=((TrackBar.Position+1) mod 360);
		// ...and do this NOW !
		Application.ProcessMessages;
	end;
	Timer1.Enabled:=True;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
	GLSceneViewer1.ResetPerformanceMonitor;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	// We need to stop playing here :
	// 	since the timer is asynchronous, if we don't stop play,
	// 	it may get triggered during the form's destruction
	CBPlay.Checked:=False;
end;

end.
