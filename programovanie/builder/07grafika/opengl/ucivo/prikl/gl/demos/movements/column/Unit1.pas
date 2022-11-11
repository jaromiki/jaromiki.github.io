{: This form showcases runtime object creation and framerate independant motion.<p>

	We start with an almost empty scene. The dummy cube is used as a convenient
	way to orient the camera (using its TargetObject property). Planes are
	programmatically added to the scene in FormCreate and spinned in the
	GLSceneViewer1AfterRender event (modifying objects trigger a render, which
	triggers an AfterRender event, where objects are modified, etc...).<p>

	Framerate independance motion is obtained by using a clock reference (in
	this sample, it is the "Now" function). You can check it by resizing the
	window : whatever the framerate, the spin speed is the same.<br>
	In this sample, it is extremely simply done, but with more complex scenes
	and movements the same rule applies : for framerate independant motion, you
	need a clock measurement.<p>

	Note that measured framerates are 1 sec averages. To avoid stalling the
	TTimer (which uses the message queue), an "Application.ProcessMessages" is
	needed in GLSceneViewer1AfterRender.
}
unit Unit1;

interface

uses
  Windows, Forms, GLScene, GLMisc, GLObjects, GLTexture, Classes, Controls,
  ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
	 GLScene1: TGLScene;
	 GLSceneViewer1: TGLSceneViewer;
	 GLCamera1: TGLCamera;
	 DummyCube1: TDummyCube;
	 StaticText1: TStaticText;
	 Timer1: TTimer;
	 procedure FormCreate(Sender: TObject);
	 procedure GLSceneViewer1AfterRender(Sender: TObject);
	 procedure Timer1Timer(Sender: TObject);
  private
	 { Déclarations privées }
  public
	 { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses Geometry, SysUtils;

const
	cNbPlanes = 30;
	cStackHeight = 8;

procedure TForm1.FormCreate(Sender: TObject);
var
	i : Integer;
	plane : TPlane;
begin
	// our column is just a stack of planes
	for i:=0 to cNbPlanes-1 do begin
		// create planes as child of the dummycube
		plane:=TPlane(DummyCube1.AddNewChild(TPlane));
		// default plane size is 1x1, we want bigger planes !
		plane.Width:=2;
		plane.Height:=2;
		// orient and position then planes in the stack
		plane.Position.Y:=cStackHeight*(0.5-i/cNbPlanes);
		plane.Direction.AsVector:=YHmgVector;
		// we use the emission color, since there is no light in the scene
		// (allows 50+ FPS with software opengl on <400 Mhz CPUs ;)
		plane.Material.FrontProperties.Emission.Color:=VectorLerp(clrBlue, clrYellow, i/cNbPlanes);
	end;
end;

procedure TForm1.GLSceneViewer1AfterRender(Sender: TObject);
var
	i : Integer;
	t : Single;
begin
	// execute other pending messages
	Application.ProcessMessages;
	// t is our time reference (seconds from midnight)
	t:=Frac(Now)*24*3600;
	// for all planes (all childs of the dummycube)
	for i:=0 to DummyCube1.Count-1 do
		// roll them accordingly to our time reference and position in the stack
		(DummyCube1.Children[i] as TPlane).RollAngle:=90*cos(t+i*PI/cNbPlanes);
	// request a rendering, even if we render so fast that "Now" didn't changed
	GLSceneViewer1.Invalidate;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
	// update FPS and reset counter for the next second
	StaticText1.Caption:=Format('%.1f FPS', [GLSceneViewer1.FramesPerSecond]);
	GLSceneViewer1.ResetPerformanceMonitor;
end;

end.
