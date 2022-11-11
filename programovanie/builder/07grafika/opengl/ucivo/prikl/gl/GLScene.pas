{: GLTexture<p>

	Handles all the color and texture stuff.<p>

	<b>Historique : </b><font size=-1><ul>
      <li>26/03/00 - Egg - Added TagFloat to TGLCustomSceneObject,
                           Parent is now longer copied in "Assign"
		<li>22/03/00 - Egg - TGLStates moved to GLMisc,
                           Removed TGLCamera.FModified stuff,
                           Fixed position bug in TGLScene.SetupLights
		<li>20/03/00 - Egg - PickObjects now uses "const" and has helper funcs,
                           Dissolved TGLRenderOptions into material and face props (RIP),
                           Joystick stuff moved to a separate unit and component
      <li>19/03/00 - Egg - Added ProgressBy method and event
		<li>18/03/00 - Egg - Fixed a few "Assign" I forgot to update after adding props,
									Added bmAdditive blending mode
		<li>14/03/00 - Egg - Added RegisterGLBaseSceneObjectNameChangeEvent,
									Added BarycenterXxx and SqrDistance funcs,
									Fixed (?) AbsolutePosition,
                           Added ResetPerformanceMonitor
		<li>14/03/00 - Egg - Added SaveToFile, LoadFromFile to GLScene,
		<li>03/03/00 - Egg - Disabled woTransparent handling
		<li>12/02/00 - Egg - Added Material Library
		<li>10/02/00 - Egg - Added Initialize to TGLCoordinates
      <li>09/02/00 - Egg - All GLScene objects now begin with 'TGL',
                           OpenGL now initialized upon first create of a TGLSceneViewer
		<li>07/02/00 - Egg - Added ImmaterialSceneObject,
									Added Camera handling funcs : MoveAroundTarget,
									AdjustDistanceToTarget, DistanceToTarget,
									ScreenDeltaToVector, TGLCoordinates.Translate,
                           Deactivated "specials" (ain't working yet),
                           Scaling now a TGLCoordinates
      <li>06/02/00 - Egg - balanced & secured all context activations,
                           added Assert & try..finally & default galore,
                           OpenGLError renamed to EOpenGLError,
                           ShowErrorXxx funcs renamed to RaiseOpenGLError,
                           fixed CreateSceneObject (was wrongly requiring a TCustomForm),
                           fixed DoJoystickCapture error handling,
                           added TGLUpdateAbleObject
		<li>05/02/00 - Egg - Javadocisation, fixes and enhancements :<br>
                           TGLSceneViewer.SetContextOptions,
									TActiveMode -> TJoystickDesignMode,
                           TGLCamera.TargetObject and TGLCamera.AutoLeveling,
                           TGLBaseSceneObject.CoordinateChanged
	</ul></font>
}
unit GLScene;
// TGLScene    - An encapsulation of the OpenGL API
// Version     - 0.5.8
// 30-DEC-99 ml: adjustments for Delphi 5

interface

{$R-}

uses Windows, Classes, Controls, GLScreen, GLMisc, GLTexture, SysUtils,
	Graphics, Messages, OpenGL12, Geometry;

type
  TObjectHandle = TGLUInt; // a display list name or GL_LIGHTx constant

  TNormalDirection = (ndInside, ndOutside);
  TTransformationMode = (tmLocal, tmParentNoPos, tmParentWithPos);

  // used to decribe only the changes in an object, which have to be reflected in the scene
  TObjectChange = (ocSpot, ocAttenuation, ocTransformation, ocStructure);
  TObjectChanges = set of TObjectChange;

  // flags for design notification
  TSceneOperation = (soAdd, soRemove, soMove, soRename, soSelect, soBeginUpdate, soEndUpdate);

  // flags for allocated buffers
  TBuffer = (buColor, buDepth, buStencil, buAccum);
  TBuffers = set of TBuffer;

  // options for the rendering context
  TContextOption = (roDoubleBuffer, roRenderToWindow, roTwoSideLighting);
  TContextOptions = set of TContextOption;

  // IDs for limit determination
  TLimitType = (limClipPlanes, limEvalOrder, limLights, limListNesting,
                limModelViewStack, limNameStack, limPixelMapTable, limProjectionStack,
                limTextureSize, limTextureStack, limViewportDims, limAccumAlphaBits,
                limAccumBlueBits, limAccumGreenBits, limAccumRedBits, limAlphaBits,
                limAuxBuffers, limBlueBits, limGreenBits, limRedBits, limIndexBits,
                limStereo, limDoubleBuffer, limSubpixelBits, limDepthBits, limStencilBits);

  TBoundingBox = record
    LeftLowerBack,
    RightUpperFront: TAffineVector;
  end;

  TGLBaseSceneObject = class;
  TGLSceneObjectClass = class of TGLBaseSceneObject;
  TGLCustomSceneObject = class;
  TGLScene = class;

	// TGLCoordinates
	//
	TGLCoordinates = class(TGLUpdateAbleObject)
		private
			FCoords, FDefaultCoords: TVector;
			procedure SetAsVector(const value: TVector);
			procedure SetCoordinate(Index: Integer; AValue: TGLFloat);

		protected
			procedure DefineProperties(Filer: TFiler); override;
			procedure ReadData(Stream: TStream);
			procedure WriteData(Stream: TStream);

		public
         procedure Initialize(const value : TVector);
			procedure NotifyChange; override;

			procedure Translate(const translationVector : TVector);

         function AsAddress : PGLFloat;

			property AsVector: TVector read FCoords write SetAsVector;
			property W: TGLFloat index 3 read FCoords[3] write SetCoordinate;

		published
			property X: TGLFloat index 0 read FCoords[0] write SetCoordinate stored False;
			property Y: TGLFloat index 1 read FCoords[1] write SetCoordinate stored False;
			property Z: TGLFloat index 2 read FCoords[2] write SetCoordinate stored False;

  	end;

   // TGLObjectsSorting
   //
   {: Determines if objects are sorted, and how.<p>
      Sorting is done level by level (and not for all entities), values are :<br>
      osInherited : use inherited sorting mode, defaults to osRenderFarthestFirst;
      osNone : do not sort objects.<br>
      osRenderFarthestFirst : render objects whose Position is the farthest from
         the camera first.<br>
      osRenderBlendedLast : opaque objects are not sorted and rendered
         first, blended ones are rendered afterwards and depth sorted. }
   TGLObjectsSorting = (osInherited, osNone, osRenderFarthestFirst, osRenderBlendedLast);

   // TGLProgressEvent
   //
   {: Progression event for time-base animations/simulations.<p>
      deltaTime is the time delta since last progress and newTime is the new
      time after the progress event is completed. }
   TGLProgressEvent = procedure (Sender : TObject; const deltaTime, newTime : Double) of object;

   // TGLBaseSceneObject
   //
   {: Base class for all scene objects.<p> }
	TGLBaseSceneObject = class (TGLUpdateAbleComponent)
      private
         FPosition : TGLCoordinates;
         FDirection, FUp : TGLCoordinates;
         FScaling : TGLCoordinates;
         FChanges : TObjectChanges;
         FParent : TGLBaseSceneObject;
         FScene : TGLScene;
         FChildren : TList;
         FVisible : Boolean;
         FLocalMatrix, FGlobalMatrix: TMatrix;
         FMatrixDirty : Boolean;
         FUpdateCount : Integer;
			FShowAxes : Boolean;
         FRollAngle, FPitchAngle, FTurnAngle: Single; // absolute rotation in degrees
         FIsCalculating: Boolean;
         FTransMode: TTransformationMode;
			FObjectsSorting : TGLObjectsSorting;
         FOnProgress : TGLProgressEvent;

         FBoundingBox: TBoundingBox;
         function Get(Index: Integer): TGLBaseSceneObject;
         function GetCount: Integer;
         function GetIndex: Integer;
         function GetMatrix: TMatrix;
         procedure SetIndex(AValue: Integer);
         procedure SetDirection(AVector: TGLCoordinates);
         procedure SetUp(AVector: TGLCoordinates);
         procedure SetMatrix(AValue: TMatrix);
         procedure SetPosition(APosition: TGLCoordinates);
         procedure SetPitchAngle(AValue: Single);
         procedure SetRollAngle(AValue: Single);
         procedure SetShowAxes(AValue: Boolean);
         procedure SetScaling(AValue: TGLCoordinates);
         procedure SetTurnAngle(AValue: Single);
			procedure SetVisible(AValue: Boolean);
         procedure SetObjectsSorting(const val : TGLObjectsSorting);

		protected
			procedure DrawAxes(Pattern: TGLushort);
			procedure GetChildren(AProc: TGetChildProc; Root: TComponent); override;
			function GetHandle: TObjectHandle; virtual;
			procedure GetOrientationVectors(var Up, Direction: TAffineVector);
			procedure RebuildMatrix;
			procedure SetName(const NewName: TComponentName); override;
			procedure SetParentComponent(Value: TComponent); override;
			//: Recalculate an orthonormal system
			procedure CoordinateChanged(Sender: TGLCoordinates); virtual;
         procedure DoProgress(const deltaTime, newTime : Double); virtual;

			property LocalMatrix : TMatrix read FLocalMatrix;
			property GlobalMatrix : TMatrix read FGlobalMatrix;

         property PitchAngle: Single read FPitchAngle write SetPitchAngle;
         property RollAngle: Single read FRollAngle write SetRollAngle;
         property TransformationMode: TTransformationMode read FTransMode write FTransMode default tmLocal;
         property TurnAngle: Single read FTurnAngle write SetTurnAngle;

		public
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;
			procedure Assign(Source: TPersistent); override;

         procedure RestoreMatrix;
			{: Calculates the object's absolute coordinates.<p>
				The current implem is probably buggy and  slow... }
			function AbsolutePosition : TVector;
			{: Calculates the object's square distance to a point.<p>
				AbsolutePosition is considered being the object position. }
			function SqrDistanceTo(const pt : TVector) : Single;
			{: Calculates the object's barycenter in absolute coordinates.<p>
				Default behaviour is to consider Barycenter=AbsolutePosition
				(whatever the number of children).<br>
				SubClasses where AbsolutePosition is not the barycenter should
				override this method as it is used for distance calculation, during
				rendering for instance, and may lead to visual inconsistencies. }
			function BarycenterAbsolutePosition : TVector; virtual;
			{: Calculates the object's barycenter distance to a point.<p> }
			function BarycenterSqrDistanceTo(const pt : TVector) : Single;

			//: Create a new scene object and add it to this object as new child
			function AddNewChild(AChild: TGLSceneObjectClass): TGLBaseSceneObject; virtual;
         procedure AddChild(AChild: TGLBaseSceneObject); virtual;
			procedure DeleteChildren; virtual;
			procedure Insert(AIndex: Integer; AChild: TGLBaseSceneObject); virtual;
			{: Takes a scene object out of the child list, but doesn't destroy it.<p>
				If 'KeepChildren' is true its children will be kept as new children
				in this scene object. }
			procedure Remove(AChild: TGLBaseSceneObject; KeepChildren: Boolean); virtual;
         function IndexOfChild(AChild: TGLBaseSceneObject) : Integer;
         procedure MoveChildUp(anIndex : Integer);
         procedure MoveChildDown(anIndex : Integer);

         procedure MoveTo(NewParent: TGLBaseSceneObject); virtual;
         procedure MoveUp;
         procedure MoveDown;
			procedure BeginUpdate; virtual;
			procedure EndUpdate; virtual;
			{: Make object-specific geometry description here.<p>
				Subclasses should MAINTAIN OpenGL states (restore the states if
				they were altered). }
			procedure BuildList; virtual;
			procedure DestroyList; virtual;
         procedure FinishObject; virtual;
			function GetParentComponent: TComponent; override;
         function HasParent: Boolean; override;
         function  IsUpdating: Boolean;
         procedure Lift(ADistance: Single);
         procedure Loaded; override;
         procedure Move(ADistance: Single);
         procedure Pitch(Angle: Single);
         procedure PrepareObject; virtual;
         procedure Render(objectsSorting : TGLObjectsSorting;
								  const cameraPosition : TVector;
								  var currentStates : TGLStates); virtual;
			procedure Roll(Angle: Single);
         procedure Slide(ADistance: Single);
         procedure StructureChanged;
         procedure Translate(Tx, Ty, Tz: TGLFloat); virtual;
         procedure TransformationChanged;
			procedure Turn(Angle: Single);
			procedure NotifyChange; override;
			//: Calculate own global matrix and let the children do the same with their's
			procedure ValidateTransformation; virtual;

         property ShowAxes: Boolean read FShowAxes write SetShowAxes default False;
         property BoundingBox: TBoundingBox read FBoundingBox;
         property Changes: TObjectChanges read FChanges;
         property Children[Index: Integer]: TGLBaseSceneObject read Get; default;
         property Count: Integer read GetCount;
         property Handle: TObjectHandle read GetHandle;
         property Index: Integer read GetIndex write SetIndex;
			property Matrix: TMatrix  read GetMatrix write SetMatrix;
         property Parent: TGLBaseSceneObject read FParent write MoveTo;
         property Position: TGLCoordinates read FPosition write SetPosition;
         property Direction: TGLCoordinates read FDirection write SetDirection;
         property Up: TGLCoordinates read FUp write SetUp;
         property Scale: TGLCoordinates read FScaling write SetScaling;
         property Scene: TGLScene read FScene;
         property Visible: Boolean read FVisible write SetVisible default True;
         property ObjectsSorting : TGLObjectsSorting read FObjectsSorting write SetObjectsSorting default osInherited;
         property OnProgress : TGLProgressEvent read FOnProgress write FOnProgress;
   end;

   // TGLCustomSceneObject
   //
   //: Extended base class with material and rendering options
   TGLCustomSceneObject = class(TGLBaseSceneObject)
      private
	      FBoundingBox: TBoundingBox;
			FMaterial: TGLMaterial;
			FTagFloat: TGLFloat;
         procedure SetGLMaterial(AValue: TGLMaterial);

      protected
         FHandle: TObjectHandle;
         function GetHandle: TObjectHandle; override;

      public
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;

         procedure Assign(Source: TPersistent); override;
         procedure BuildList; override;
         procedure DestroyList; override;
         procedure ReloadTexture;
			procedure Render(objectsSorting : TGLObjectsSorting;
								  const cameraPosition : TVector;
								  var currentStates : TGLStates); override;

			property BoundingBox: TBoundingBox read FBoundingBox;
			property Handle: TObjectHandle read GetHandle;
			property Material: TGLMaterial read FMaterial write SeTGLMaterial;
			property Visible: Boolean read FVisible write SetVisible default True;
			
		published
			property TagFloat: TGLFLoat read FTagFloat write FTagFloat;
   end;

   // TGLImmaterialSceneObject
   //
   TGLImmaterialSceneObject = class(TGLCustomSceneObject)
      published
	      property ObjectsSorting;
         property Direction;
         property PitchAngle;
         property Position;
         property RollAngle;
         property Scale;
         property ShowAxes;
         property TransformationMode;
         property TurnAngle;
         property Up;
         property OnProgress;
   end;

   // TGLSceneObject
   //
   TGLSceneObject = class(TGLImmaterialSceneObject)
      published
	      property Material;
	      property Visible;
   end;

  // TGLLightSource
  //
  TGLLightSource = class(TGLBaseSceneObject)
  private
    FLightID: TObjectHandle;
    FSpotDirection: TGLCoordinates;
    FSpotExponent,
    FSpotCutOff, 
    FConstAttenuation, 
    FLinearAttenuation, 
    FQuadraticAttenuation: TGLFloat;
    FShining: Boolean;
    FAmbient, FDiffuse, FSpecular: TGLColor;
    procedure SetAmbient(AValue: TGLColor);
    procedure SetDiffuse(AValue: TGLColor);
    procedure SetSpecular(AValue: TGLColor);
    procedure SetConstAttenuation(AValue: TGLFloat);
    procedure SetLinearAttenuation(AValue: TGLFloat);
    procedure SetQuadraticAttenuation(AValue: TGLFloat);
    procedure SetShining(AValue: Boolean);
    procedure SetSpotDirection(AVector: TGLCoordinates);
    procedure SetSpotExponent(AValue: TGLFloat);
    procedure SetSpotCutOff(AValue: TGLFloat);
  protected
    //: light sources have different handle types than normal scene objects
    function GetHandle: TObjectHandle; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DestroyList; override;
    procedure CoordinateChanged(Sender: TGLCoordinates); override;
//    procedure RenderLensFlares(from, at: TAffineVector; near_clip: TGLFloat);
    procedure ValidateTransformation; override;

  published
    property Ambient: TGLColor read FAmbient write SetAmbient;
    property ConstAttenuation: TGLFloat read FConstAttenuation write SetConstAttenuation;
    property Diffuse: TGLColor read FDiffuse write SetDiffuse;
    property LinearAttenuation: TGLFloat read FLinearAttenuation write SetLinearAttenuation;
    property QuadraticAttenuation: TGLFloat read FQuadraticAttenuation write SetQuadraticAttenuation;
    property Position;
    property Shining: Boolean read FShining write SetShining default True;
    property Specular: TGLColor read FSpecular write SetSpecular;
    property SpotCutOff: TGLFloat read FSpotCutOff write SetSpotCutOff;
    property SpotDirection: TGLCoordinates read FSpotDirection write SetSpotDirection;
    property SpotExponent: TGLFloat read FSpotExponent write SetSpotExponent;
    property OnProgress;
  end;

   // TGLCamera
   //
   TGLCamera = class(TGLBaseSceneObject)
      private
         { Private Declarations }
         FFocalLength: Single;
         FDepthOfView: Single;
         FNearPlane: Single;                  // nearest distance to the camera
         FTargetObject : TGLBaseSceneObject;
         FLastTargetObjectPosition : TVector; // Not persistent

         procedure SetDepthOfView(AValue: Single);
			procedure SetFocalLength(AValue: Single);

		protected
			{ Protected Declarations }
			procedure Notification(AComponent: TComponent; Operation: TOperation); override;
			procedure SetTargetObject(const val : TGLBaseSceneObject);

		public
			{ Public Declarations }
			constructor Create(AOwner: TComponent); override;
			destructor Destroy; override;

			//: Apply camera transformation
			procedure Apply;
			procedure ApplyPerspective(Viewport: TRectangle; Width, Height: Integer; DPI: Integer);
			procedure AutoLeveling(Factor: Single);
			procedure Reset;
			//: Position the camera so that the whole scene can be seen
			procedure ZoomAll;
			{: Change camera's position to make it move around its target.<p>
				If TargetObject is nil, nothing happens. This method helps in quickly
				implementing camera controls. Camera's Up and Direction properties
				are unchanged.<br>
				Angle deltas are in degrees, camera parent's coordinates should be identity.<p>
				Tip : make the camera a child of a "target" dummycube and make
				it a target the dummycube. Now, to pan across the scene, just move
				the dummycube, to change viewing angle, use this method. }
			procedure MoveAroundTarget(pitchDelta, turnDelta : Single);
			{: Adjusts distance from camera to target by applying a ratio.<p>
				If TargetObject is nil, nothing happens. This method helps in quickly
				implementing camera controls. Only the camera's position is changed.<br>
				Camera parent's coordinates should be identity. }
			procedure AdjustDistanceToTarget(distanceRatio : Single);
			{: Returns the distance from camera to target.<p>
				If TargetObject is nil, returns 1. }
			function DistanceToTarget : Single;
			{: Calculate an absolute translation vector from a screen vector.<p>
				Ratio is applied to both screen delta, planeNormal should be the
				translation plane's normal. }
			function ScreenDeltaToVector(deltaX, deltaY : Integer; ratio : Single;
												  const planeNormal : TVector) : TVector;
			{: Same as ScreenDeltaToVector but optimized for XY plane. }
			function ScreenDeltaToVectorXY(deltaX, deltaY : Integer; ratio : Single) : TVector;

		published
			{ Published Declarations }
			property DepthOfView: Single read FDepthOfView write SetDepthOfView;
			property FocalLength: Single read FFocalLength write SetFocalLength;
			{: If set, camera will point to this object.<p>
				When camera is pointing an object, the Direction vector is ignored
				and the Up vector is used as an absolute vector to the up. }
			property TargetObject : TGLBaseSceneObject read FTargetObject write SetTargetObject;

			property Position;
			property Direction;
			property Up;
         property OnProgress;
	end;

  TGLSceneViewer = class;

   // TGLScene
	//
   TGLScene = class(TGLUpdateAbleComponent)
      private
         FUpdateCount: Integer;
         FObjects: TGLCustomSceneObject;
         FCameras: TGLBaseSceneObject;
         FBaseContext: HGLRC;
         FLights, FViewers: TList;
         FLasTGLCamera, FCurrenTGLCamera: TGLCamera;
         FCurrentViewer: TGLSceneViewer;
         FObjectsSorting : TGLObjectsSorting;
         FOnProgress : TGLProgressEvent;

      protected
         procedure AddLight(ALight: TGLLightSource);
         procedure SetupLights(Maximum: Integer);
         procedure DoAfterRender;
         procedure GetChildren(AProc: TGetChildProc; Root: TComponent); override;
         procedure Loaded; override;
         procedure RemoveLight(ALight: TGLLightSource);
         procedure SetChildOrder(AChild: TComponent; Order: Integer); override;
         procedure SetObjectsSorting(const val : TGLObjectsSorting);

      public
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;

         procedure AddViewer(AViewer: TGLSceneViewer);
         procedure BeginUpdate;
         procedure RenderScene(AViewer: TGLSceneViewer);
         procedure EndUpdate;
         function  IsUpdating: Boolean;
         procedure NotifyChange; override;
         procedure RemoveViewer(AViewer: TGLSceneViewer);
			procedure ValidateTransformation(ACamera: TGLCamera);
         procedure Progress(const deltaTime, newTime : Double);

         {: Saves the scene to a file (recommended extension : .GLS) }
			procedure SaveToFile(const fileName : String);
         {: Load the scene from a file.<p>
            Existing objects/lights/cameras are freed, then the file is loaded.<br>
            Delphi's IDE is not handling this behaviour properly yet, ie. if
            you load a scene in the IDE, objects will be properly loaded, but
            no declare will be placed in the code. }
			procedure LoadFromFile(const fileName : String);

         property Cameras: TGLBaseSceneObject read FCameras;
			property CurrentGLCamera: TGLCamera read FCurrentGLCamera;
         property Lights: TList read FLights;
         property Objects: TGLCustomSceneObject read FObjects;
         property CurrentViewer: TGLSceneViewer read FCurrentViewer;

      published
         property ObjectsSorting : TGLObjectsSorting read FObjectsSorting write SetObjectsSorting default osRenderBlendedLast;
         property OnProgress : TGLProgressEvent read FOnProgress write FOnProgress;

   end;

  PPickRecord = ^TPickRecord;
  TPickRecord = record
    AObject: TGLBaseSceneObject;
    ZMin, ZMax: Single;
  end;

  TPickSortType = (psDefault, psName, psMinDepth, psMaxDepth);

  // list class for object picking
  TGLPickList =  class(TList)
  private
    function GetFar(AValue: Integer): Single;
    function GetHit(AValue: Integer): TGLBaseSceneObject;
    function GetNear(AValue: Integer): Single;
  protected
  public
    constructor Create(SortType: TPickSortType);
    destructor Destroy; override;
    procedure AddHit(Obj: TGLBaseSceneObject; ZMin, ZMax: Single);
    procedure Clear; override;
    function FindObject(AObject: TGLBaseSceneObject): Integer;
    property FarDistance[Index: Integer]: Single read GetFar;
	 property Hit[Index: Integer]: TGLBaseSceneObject read GetHit; default;
    property NearDistance[Index: Integer]: Single read GetNear;
  end;

  TDrawState = (dsNone, dsRendering, dsPicking, dsPrinting);

  TFogMode = (fmLinear, fmExp, fmExp2);
  TGLFogEnvironment = class (TGLUpdateAbleObject)
  private
    FSceneViewer: TGLSceneViewer;
    FFogColor: TGLColor;       // alpha value means the fog density
    FFogStart,
    FFogEnd: TGLfloat;
    FFogMode: TFogMode;
    FChanged: Boolean;
    procedure SetFogColor(Value: TGLColor);
    procedure SetFogStart(Value: TGLfloat);
    procedure SetFogEnd(Value: TGLfloat);
    procedure SetFogMode(Value: TFogMode);

  public
    constructor Create(Owner : TPersistent); override;
	 destructor Destroy; override;

    procedure NotifyChange; override;
    procedure ApplyFog;
    procedure Assign(Source: TPersistent); override;
  published

    property FogColor: TGLColor read FFogColor write SetFogColor;
    property FogStart: TGLfloat read FFogStart write SetFogStart;
    property FogEnd: TGLfloat read FFogEnd write SetFogEnd;
    property FogMode: TFogMode read FFogMode write SetFogMode; 
  end;

  TSpecial = (spLensFlares, spLandScape);
  TSpecials = set of TSpecial;

  TGLSceneViewer = class(TWinControl)
  private
	 // handle
	 FRenderingContext: HGLRC;

	 // OpenGL properties
	 FMaxLightSources: Integer;
	 FDoubleBuffered, FDepthTest, FFaceCulling, FFogEnable, FLighting: Boolean;
	 FCurrentStates, FSaveStates: TGLStates;
	 FBackgroundColor: TColor;
	 FBackground: TGLTexture;

	 // private variables
	 FCanvas: TCanvas;
	 FFrames: Longint;              // used to perform monitoring
	 FTicks: TLargeInteger;        // used to perform monitoring
	 FState: TDrawState;
    FMonitor: Boolean;
    FFramesPerSecond: TGLFloat;
    FViewPort: TRectangle;
    FBuffers: TBuffers;
    FDisplayOptions: TDisplayOptions;
    FContextOptions: TContextOptions;
    FOwnRefresh: Boolean;
    FCamera: TGLCamera;
//    FSpecials: TSpecials;
    FFogEnvironment: TGLFogEnvironment;

    FBeforeRender: TNotifyEvent;
    FAfterRender: TNotifyEvent;
    procedure SetBackgroundColor(AColor: TColor);
    function  GetLimit(Which: TLimitType): Integer;
    procedure SeTGLCamera(ACamera: TGLCamera);
    procedure SetContextOptions(Options: TContextOptions);
    procedure SetDepthTest(AValue: Boolean);
	 procedure SetFaceCulling(AValue: Boolean);
	 procedure SetLighting(AValue: Boolean);
	 procedure SetFogEnable(AValue: Boolean);
	 procedure SeTGLFogEnvironment(AValue: TGLFogEnvironment);
//	 procedure SetSpecials(Value: TSpecials);

	 procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); Message WM_ERASEBKGND;
	 procedure WMPaint(var Message: TWMPaint); Message WM_PAINT;
	 procedure WMSize(var Message: TWMSize); Message WM_SIZE;

  protected
	 procedure CreateParams(var Params: TCreateParams); override;
	 procedure CreateWnd; override;
	 {: Clear all allocated OpenGL buffers.<p>
		 The color buffer is a special case, because transparency must be
		 simulated if required. }
	 procedure ClearBuffers;
    procedure DestroyWnd; override;
    procedure Loaded; override;
    function ObjectInScene(Obj: TGLBaseSceneObject): Boolean;
	 procedure ReadContextProperties;
	 procedure SetupRenderingContext;

  public
	 constructor Create(AOwner: TComponent); override;
	 destructor  Destroy; override;

	 procedure Notification(AComponent: TComponent; Operation: TOperation); override;
	 //: Fills the PickList with objects in Rect area
	 procedure PickObjects(const Rect: TRect; PickList: TGLPickList; ObjectCountGuess: Integer);
	 {: Returns a PickList with objects in Rect area.<p>
		 Returned list should be freed by caller.<br>
		 Objects are sorted by depth (nearest objects first). }
	 function GetPickedObjects(const Rect: TRect; objectCountGuess : Integer = 64) : TGLPickList;
	 //: Returns the nearest object at x, y coordinates or nil if there is none
	 function GetPickedObject(x, y : Integer) : TGLBaseSceneObject;
	 procedure Render;
    procedure RenderToBitmap(ABitmap: TBitmap; DPI: Integer);
    procedure RequestedState(States: TGLStates);
    procedure RenderToFile(const AFile: String; DPI: Integer);
    procedure Invalidate; override;
	 procedure SetViewPort(X, Y, W, H: Integer);
    procedure ShowInfo;
    procedure UnnecessaryState(States: TGLStates);
    procedure ResetPerformanceMonitor;

//    function GetLandsHeight(X, Y: TGLfloat): TGLfloat;

    property Buffers: TBuffers read FBuffers;
    property Canvas: TCanvas read FCanvas;
    property CurrentStates: TGLStates read FCurrentStates;
    property DoubleBuffered: Boolean read FDoubleBuffered;
    property FramesPerSecond: TGLFloat read FFramesPerSecond;
    property LimitOf[Which: TLimitType]: Integer read GetLimit;
    property MaxLightSources: Integer read FMaxLightSources;
    property RenderingContext: HGLRC read FRenderingContext;
    property State: TDrawState read FState;

  published
    property FogEnvironment: TGLFogEnvironment read FFogEnvironment write SeTGLFogEnvironment;
    property Align;
    property Anchors;
	 property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clBtnFace;
    property Camera: TGLCamera read FCamera write SeTGLCamera;
    property Constraints;
    property ContextOptions: TContextOptions read FContextOptions write SetContextOptions default [roDoubleBuffer, roRenderToWindow];
    property DepthTest: Boolean read FDepthTest write SetDepthTest default True;
    property DisplayOptions: TDisplayOptions read FDisplayOptions write FDisplayOptions;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FaceCulling: Boolean read FFaceCulling write SetFaceCulling default True;
    property HelpContext;
    property Hint;
    property FogEnable: Boolean read FFogEnable write SetFogEnable default False;
    property Lighting: Boolean read FLighting write SetLighting default True;
    property Monitor: Boolean read FMonitor write FMonitor default False;
    property PopupMenu;
//    property Specials: TSpecials read FSpecials write SetSpecials default [];
    property Visible;

	 // events
	 property AfterRender: TNotifyEvent read FAfterRender write FAfterRender;
	 property BeforeRender: TNotifyEvent read FBeforeRender write FBeforeRender;
	 property OnClick;
	 property OnDragDrop;
	 property OnDragOver;
	 property OnMouseDown;
	 property OnMouseMove;
	 property OnMouseUp;
  end;

  EOpenGLError = class(Exception);

procedure CheckOpenGLError;
procedure RaiseOpenGLError(const msg : String);

{: Register an event handler triggered by any TGLBaseSceneObject Name change.<p>
	*INCOMPLETE*, currently allows for only 1 (one) event, and is used by
	GLSceneEdit in the IDE. }
procedure RegisterGLBaseSceneObjectNameChangeEvent(notifyEvent : TNotifyEvent);
{: Deregister an event handler triggered by any TGLBaseSceneObject Name change.<p>
	See RegisterGLBaseSceneObjectNameChangeEvent. }
procedure DeRegisterGLBaseSceneObjectNameChangeEvent(notifyEvent : TNotifyEvent);

//------------------------------------------------------------------------------

implementation

uses
  Consts, Dialogs, ExtDlgs, Forms, GLStrings, Info, Math; //GLSpecials

const
  GLAllStates = [stAlphaTest..stStencilTest];

var
  CounterFrequency: TLargeInteger;

//------------------ external global routines ----------------------------------

procedure CheckOpenGLError;

// Gets the oldest error from OpenGL engine and tries to clear the error queue.
// Because under some circumstances reading the error code creates a new error
// and thus hanging up the thread, we limit the loop to 6 reads.

var GLError: TGLEnum;
    Count: Word;

begin
   GLError := glGetError;
   if GLError <> GL_NO_ERROR then begin
      Count := 0;
      try
         while (glGetError <> GL_NO_ERROR) and (Count < 6) do Inc(Count);
      except
         // Egg : ignore exceptions here, will perhaps avoid problem expressed before
		end;
      raise EOpenGLError.Create(gluErrorString(GLError));
	end;
end;

procedure RaiseOpenGLError(const msg : String);
begin
	raise EOpenGLError.Create(msg);
end;

//------------------ internal global routines ----------------------------------

{: Creates a new component with unique name.<p>
	This function is internally used by functions
	which need to create new scene objects (AddNewChild...). }
function CreateSceneObject(AScene: TGLScene; AObject: TGLSceneObjectClass): TGLBaseSceneObject;
begin
	Result := AObject.Create(AScene.Owner);
end;

var
	vGLBaseSceneObjectNameChangeEvent : TNotifyEvent;

// RegisterGLBaseSceneObjectNameChangeEvent
//
procedure RegisterGLBaseSceneObjectNameChangeEvent(notifyEvent : TNotifyEvent);
begin
	vGLBaseSceneObjectNameChangeEvent:=notifyEvent;
end;

//
//
procedure DeRegisterGLBaseSceneObjectNameChangeEvent(notifyEvent : TNotifyEvent);
begin
	vGLBaseSceneObjectNameChangeEvent:=nil;
end;

//----------------- TGLPickList -------------------------------------------------

var
  SortFlag: TPickSortType;
                                                       
constructor TGLPickList.Create(SortType: TPickSortType);

begin
  SortFlag := SortType;
  inherited Create;
end;

//------------------------------------------------------------------------------

destructor TGLPickList.Destroy;

begin
  Clear;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function CompareFunction(Item1, Item2: Pointer): Integer;

var
  Diff: Single;

begin
  Result := 0;
  case SortFlag of
    psName:
      Result := CompareText(PPickRecord(Item1).AObject.Name, PPickRecord(Item2).AObject.Name);
    psMinDepth:
      begin
        Diff := PPickRecord(Item1).ZMin - PPickRecord(Item2).ZMin;
        if Diff < 0 then Result := -1
                    else
          if Diff > 0 then Result := 1
                      else Result := 0;
      end;
    psMaxDepth:
      begin
        Diff := Round(PPickRecord(Item1).ZMax - PPickRecord(Item2).ZMax);
        if Diff < 0 then Result := -1
                    else
          if Diff > 0 then Result := 1
                      else Result := 0;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLPickList.AddHit(Obj: TGLBaseSceneObject; ZMin, ZMax: Single);

var
  NewRecord: PPickRecord;

begin
  New(NewRecord);
  try
    NewRecord.AObject := Obj;
    NewRecord.ZMin := ZMin;
    NewRecord.ZMax := ZMax;
    Add(NewRecord);
    if SortFlag <> psDefault then Sort(CompareFunction);
  except
    Dispose(NewRecord);
    raise;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLPickList.Clear;

var
  I: Integer;

begin
  for I := 0 to Count-1 do
    Dispose(PPickRecord(Items[I]));
  inherited Clear;
end;

//------------------------------------------------------------------------------

function TGLPickList.FindObject(AObject: TGLBaseSceneObject): Integer;

var
  I: Integer;

begin
  Result := -1;
  if assigned(AObject) then
    for I := 0 to Count - 1 do
      if Hit[I] = AObject then
      begin
        Result := I;
        Break;
      end;
end;

//------------------------------------------------------------------------------

function TGLPickList.GetFar(AValue: Integer): Single;

begin
  Result := PPickRecord(Items[AValue]).ZMax;
end;

//------------------------------------------------------------------------------

function TGLPickList.GetHit(AValue: Integer): TGLBaseSceneObject;

begin
  Result := PPickRecord(Items[AValue]).AObject;
end;

//------------------------------------------------------------------------------

function TGLPickList.GetNear(AValue: Integer): Single;

begin
  Result := PPickRecord(Items[AValue]).ZMin;
end;

//----------------- TGLCoordinates ---------------------------------------------

procedure TGLCoordinates.Initialize(const value : TVector);
begin
   FCoords:=value;
   FDefaultCoords:=value;
end;

procedure TGLCoordinates.DefineProperties(Filer: TFiler);
begin
	inherited;
	Filer.DefineBinaryProperty('Coordinates', ReadData, WriteData,
                              not VectorEquals(FDefaultCoords, FCoords));
end;

procedure TGLCoordinates.ReadData(Stream: TStream);
begin
	Stream.Read(FCoords, SizeOf(FCoords));
end;

procedure TGLCoordinates.WriteData(Stream: TStream);
begin
	Stream.Write(FCoords, SizeOf(FCoords));
end;

// NotifyChange
//
procedure TGLCoordinates.NotifyChange;
begin
	if (Owner is TGLBaseSceneObject) then
		TGLBaseSceneObject(Owner).CoordinateChanged(Self)
	else inherited NotifyChange;
end;

// Translate
//
procedure TGLCoordinates.Translate(const translationVector : TVector);
begin
	FCoords[0]:=FCoords[0]+translationVector[0];
	FCoords[1]:=FCoords[1]+translationVector[1];
	FCoords[2]:=FCoords[2]+translationVector[2];
	NotifyChange;
end;

// AsAddress
//
function TGLCoordinates.AsAddress : PGLFloat;
begin
   Result:=@FCoords;
end;

// SetAsVector
//
procedure TGLCoordinates.SetAsVector(const value: TVector);
begin
	FCoords:=Value;
	NotifyChange;
end;

// SetCoordinate
//
procedure TGLCoordinates.SetCoordinate(Index: Integer; AValue: TGLFloat);
begin
	FCoords[Index] := AValue;
	NotifyChange;
end;

//------------------ TGLBaseSceneObject ----------------------------------------------

constructor TGLBaseSceneObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChanges := [ocTransformation, ocStructure];
  FPosition := TGLCoordinates.Create(Self);
  FPosition.Initialize(NullHmgPoint);
  FDirection := TGLCoordinates.Create(self);
  FDirection.Initialize(ZHmgVector);
  FUp := TGLCoordinates.Create(self);
  FUp.Initialize(YHmgVector);
  FScaling := TGLCoordinates.Create(Self);
  FScaling.Initialize(XYZHmgVector);
  FGlobalMatrix := IdentityMatrix;
  FLocalMatrix := IdentityMatrix;
  FChildren := TList.Create;
  FVisible := True;
  FMatrixDirty := True;
  FObjectsSorting:=osInherited;
end;

// Destroy
//
destructor TGLBaseSceneObject.Destroy;
begin
  DestroyList;
  FPosition.Free;
  FDirection.Free;
  FUp.Free;
  if FChildren.Count > 0 then DeleteChildren;
  FChildren.Free;
  if Assigned(FParent) then FParent.Remove(Self, False);
  if Assigned(FScene) then FScene.NotifyChange;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.DestroyList;

var I: Integer;

begin
  Include(FChanges, ocStructure);
  for I := 0 to FChildren.Count-1 do
    TGLBaseSceneObject(FChildren[I]).DestroyList;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.BeginUpdate;

begin
  Inc(FUpdateCount);
end;

// BuildList
//
procedure TGLBaseSceneObject.BuildList;
begin
  glListBase(0);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.DeleteChildren;
var
   child : TGLBaseSceneObject;
begin
   // children remove themself from child list
   while FChildren.Count>0 do begin
      child:=TGLBaseSceneObject(FChildren.Items[FChildren.Count-1]);
      FChildren.Delete(FChildren.Count-1);
      child.Free;
   end;
end;

procedure TGLBaseSceneObject.DrawAxes(Pattern: TGLushort);
var
  AxisLen: TGLFloat;
begin
  AxisLen := FScene.CurrentViewer.FCamera.FDepthOfView;
  glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LIGHTING_BIT or GL_LINE_BIT or GL_COLOR_BUFFER_BIT);
  glDisable(GL_LIGHTING);
  glEnable(GL_LINE_STIPPLE);
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glLineWidth(1);
  glLineStipple(1, Pattern);
  glBegin(GL_LINES);
    glColor3f(0, 0, 0); glVertex3f(0, 0, 0); glVertex3f(-AxisLen, 0, 0);
    glColor3f(1, 0, 0); glVertex3f(0, 0, 0); glVertex3f(AxisLen, 0, 0);
    glColor3f(0, 0, 0); glVertex3f(0, 0, 0); glVertex3f(0, -AxisLen, 0);
    glColor3f(0, 1, 0); glVertex3f(0, 0, 0); glVertex3f(0, AxisLen, 0);
    glColor3f(0, 0, 0); glVertex3f(0, 0, 0); glVertex3f(0, 0, -AxisLen);
    glColor3f(0, 0, 1); glVertex3f(0, 0, 0); glVertex3f(0, 0, AxisLen);
  glEnd;
  glPopAttrib;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.GetChildren(AProc: TGetChildProc; Root: TComponent);

var
  I: Integer;

begin
  for I := 0 to Count - 1 do AProc(FChildren[I]);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.RebuildMatrix;
var
  LeftVector: TAffineVector;
begin
  if FMatrixDirty then begin
    LeftVector := VectorCrossProduct(MakeAffineVector(FUp.FCoords), MakeAffineVector(FDirection.FCoords));
    VectorNormalize(LeftVector);
	 FLocalMatrix[0] := MakeVector(LeftVector); VectorScale(FLocalMatrix[0], Scale.X);
	 FLocalMatrix[1] := FUp.FCoords;            VectorScale(FLocalMatrix[1], Scale.Y);
    FLocalMatrix[2] := FDirection.FCoords;     VectorScale(FLocalMatrix[2], Scale.Z);
    FLocalMatrix[3] := FPosition.FCoords;
    FMatrixDirty := False;
  end;
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.Get(Index: Integer): TGLBaseSceneObject;
begin
  Result := FChildren[Index];
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.GetCount: Integer;

begin
  Result := FChildren.Count;
end;

// AddChild
//
procedure TGLBaseSceneObject.AddChild(AChild: TGLBaseSceneObject);
begin
	if Assigned(FScene) and (AChild is TGLLightSource) then
		FScene.AddLight(TGLLightSource(AChild));
	FChildren.Add(AChild);
   AChild.FParent := Self;
	AChild.FScene := FScene;
	TransformationChanged;
end;

// AddNewChild
//
function TGLBaseSceneObject.AddNewChild(AChild: TGLSceneObjectClass): TGLBaseSceneObject;
begin
	Result := CreateSceneObject(FScene, AChild);
	AddChild(Result);
end;

// RestoreMatrix
//
procedure TGLBaseSceneObject.RestoreMatrix;
begin
	glLoadMatrixf(@FGlobalMatrix);
end;

// AbsolutePosition
//
function TGLBaseSceneObject.AbsolutePosition : TVector;
var
	myMatrix : THomogeneousFltMatrix;
begin
	if (Parent<>nil) and (Parent is TGLBaseSceneObject) then begin
		with TGLBaseSceneObject(Parent) do begin
			RebuildMatrix;
			myMatrix:=FLocalMatrix;
			myMatrix[3]:=AbsolutePosition;
		end;
		Result:=VectorTransform(Position.AsVector, myMatrix);
	end else Result:=Position.AsVector;
end;

// BarycenterAbsolutePosition
//
function TGLBaseSceneObject.BarycenterAbsolutePosition : TVector;
begin
	Result:=AbsolutePosition;
end;

// SqrDistanceTo
//
function TGLBaseSceneObject.SqrDistanceTo(const pt : TVector) : Single;
var
	d : TVector;
begin
	d:=AbsolutePosition;
	Result:=Sqr(d[0]-pt[0])+Sqr(d[1]-pt[1])+Sqr(d[2]-pt[2]);
end;

// BarycenterSqrDistanceTo
//
function TGLBaseSceneObject.BarycenterSqrDistanceTo(const pt : TVector) : Single;
var
	d : TVector;
begin
	d:=BarycenterAbsolutePosition;
	Result:=Sqr(d[0]-pt[0])+Sqr(d[1]-pt[1])+Sqr(d[2]-pt[2]);
end;

// Assign
//
procedure TGLBaseSceneObject.Assign(Source: TPersistent);
var
   i : Integer;
begin
   if Source is TGLBaseSceneObject then begin
      FPosition.FCoords := TGLBaseSceneObject(Source).FPosition.FCoords;
      FChanges := [ocTransformation, ocStructure];
      FVisible := TGLBaseSceneObject(Source).FVisible;
		FGlobalmatrix := TGLBaseSceneObject(Source).FGLobalMatrix;
		SetMatrix(TGLCustomSceneObject(Source).FLocalMatrix);
		FObjectsSorting:=TGLBaseSceneObject(Source).FObjectsSorting;
      DeleteChildren;
      if Assigned(Scene) then Scene.BeginUpdate;
      for i:=0 to TGLBaseSceneObject(Source).Count-1 do
         AddChild(TGLBaseSceneObject(Source)[I]);
      if Assigned(Scene) then Scene.EndUpdate;
      OnProgress:=TGLBaseSceneObject(Source).OnProgress;
   end else inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Insert(AIndex: Integer; AChild: TGLBaseSceneObject);

begin
  with FChildren do
  begin
    if assigned(AChild.FParent) then AChild.FParent.Remove(AChild, False);
    Insert(AIndex, AChild);
  end;
  AChild.FParent := Self;
  if AChild.FScene <> FScene then AChild.DestroyList;
  AChild.FScene := FScene;
  if assigned(FScene) then
  begin
    if AChild is TGLLightSource then FScene.AddLight(TGLLightSource(AChild));
  end;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.IsUpdating: Boolean;

begin
  Result := (FUpdateCount <> 0) or (csReading in ComponentState);
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.GetIndex: Integer;

begin
  Result := -1;
  if assigned(FParent) then Result := FParent.FChildren.IndexOf(Self);
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.GetHandle: TObjectHandle;

begin
  Result := 0;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.GetOrientationVectors(var Up, Direction: TAffineVector);

// returns Up and Direction vectors depending on the transformation mode

begin
  if (FTransMode <> tmLocal) and assigned(FParent) then
  begin
    Up := MakeAffineVector(FParent.FUp.FCoords);
    Direction := MakeAffineVector(FParent.FDirection.FCoords);
  end
  else
  begin
    Up := MakeAffineVector(FUp.FCoords);
    Direction := MakeAffineVector(FDirection.FCoords);
  end;
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.GetParentComponent: TComponent;

begin
  Result := FParent;
end;

//------------------------------------------------------------------------------

function TGLBaseSceneObject.HasParent: Boolean;

begin
  Result := assigned(FParent);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Lift(ADistance: Single);

// moves object along the Up vector (move up/down)

var
  Up, Dir: TAffineVector;

begin
  if FTransMode = tmParentWithPos then
  begin
    GetOrientationVectors(Up, Dir);
    FPosition.X := FPosition.X + ADistance * Up[0];
    FPosition.Y := FPosition.Y + ADistance * Up[1];
    FPosition.Z := FPosition.Z + ADistance * Up[2];
  end
  else
  begin
    FPosition.X := FPosition.X + ADistance * FUp.FCoords[0];
    FPosition.Y := FPosition.Y + ADistance * FUp.FCoords[1];
    FPosition.Z := FPosition.Z + ADistance * FUp.FCoords[2];
  end;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Loaded;

begin
  inherited;
  if FPosition.W = 0 then FPosition.W := 1;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Move(ADistance: Single);

// moves object along the direction vector

var
  Len: Single;
  Up, Dir: TAffineVector;

begin
  if FTransMode = tmParentWithPos then
  begin
    GetOrientationVectors(Up, Dir);
    Len := 1 / Vectorlength(Dir);
    FPosition.AsVector := MakeVector([FPosition.X + ADistance * Dir[0] * Len, 
                                      FPosition.Y + ADistance * Dir[1] * Len,
                                      FPosition.Z + ADistance * Dir[2] * Len, 1]);
  end
  else
  begin
    Len := 1 / Vectorlength(FDirection.FCoords);
    FPosition.AsVector := MakeVector([FPosition.X + ADistance * FDirection.X * Len,
                                      FPosition.Y + ADistance * FDirection.Y * Len,
                                      FPosition.Z + ADistance * FDirection.Z * Len, 1]);
  end;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Pitch(Angle: Single);

var
  RightVector: TAffineVector;
  Up, Dir: TAffineVector;

begin
  GetOrientationVectors(Up, Dir);
  RightVector := VectorCrossProduct(Dir, Up);
  Angle := DegToRad(Angle);
  VectorRotate(FUp.FCoords, RightVector, -Angle);
  VectorNormalize(FUp.FCoords);
  VectorRotate(FDirection.FCoords, RightVector, -Angle);
  VectorNormalize(FDirection.FCoords);
  if FTransMode = tmParentWithPos then VectorRotate(FPosition.FCoords, RightVector, Angle);
  // Direction is automatically updated

  FPitchAngle := -RadToDeg(arctan2(FDirection.Y, Sqrt(Sqr(FDirection.X) + Sqr(FDirection.Z))));
  if FDirection.X < 0 then
    if FDirection.Y < 0 then FPitchAngle := 180 - FPitchAngle
                        else FPitchAngle := -180 - FPitchAngle;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetPitchAngle(AValue: Single);

var
  RightVector: TAffineVector;
  Up, Dir: TAffineVector;
  Diff: Extended;

begin
  if AValue <> FPitchAngle then
  begin
    GetOrientationVectors(Up, Dir);
    if not (csLoading in ComponentState) then
    begin
      Diff := DegToRad(FPitchAngle - AValue);
      RightVector := VectorCrossProduct(MakeAffineVector(Dir), MakeAffineVector(Up));
      VectorRotate(FUp.FCoords, RightVector, Diff);
      VectorNormalize(FUp.FCoords);
      VectorRotate(FDirection.FCoords, RightVector, Diff);
      VectorNormalize(FDirection.FCoords);
      if FTransMode = tmParentWithPos then VectorRotate(FPosition.FCoords, RightVector, Diff);
      TransformationChanged;
    end;
    FPitchAngle := NormalizeAngle(AValue);
  end;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Roll(Angle: Single);

var
  RightVector: TAffineVector;
  Up, Dir: TAffineVector;

begin
  GetOrientationVectors(Up, Dir);
  Angle := DegToRad(Angle);
  VectorRotate(FUp.FCoords, Dir, Angle);
  VectorNormalize(FUp.FCoords);
  VectorRotate(FDirection.FCoords, Dir, Angle);
  VectorNormalize(FDirection.FCoords);
  if FTransMode = tmParentWithPos then VectorRotate(FPosition.FCoords, Dir, Angle);

  // calculate new rotation angle from vectors
  RightVector := VectorCrossProduct(MakeAffineVector(FDirection.FCoords), MakeAffineVector(FUp.FCoords));
  FRollAngle := -RadToDeg(arctan2(Rightvector[1], Sqrt(Sqr(RightVector[0]) + Sqr(RightVector[2]))));
  if RightVector[0] < 0 then
    if RightVector[1] < 0 then FRollAngle := 180 - FRollAngle
                          else FRollAngle := -180 - FRollAngle;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetRollAngle(AValue: Single);

var
  Up, Dir: TAffineVector;
  Diff: Extended;

begin
  if AValue <> FRollAngle then
  begin
    GetOrientationVectors(Up, Dir);
    if not (csLoading in ComponentState) then
    begin
      Diff := DegToRad(FRollAngle - AValue);
      VectorRotate(FUp.FCoords, Dir, Diff);
      VectorNormalize(FUp.FCoords);
      VectorRotate(FDirection.FCoords, Dir, Diff);
      VectorNormalize(FDirection.FCoords);
      if FTransMode = tmParentWithPos then VectorRotate(FPosition.FCoords, Dir, Diff);
      TransformationChanged;
    end;
    FRollAngle := NormalizeAngle(AValue);
  end;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Slide(ADistance: Single);

// moves camera along the right vector (move left and right)

var
  RightVector: TAffineVector;
  Up, Dir: TAffineVector;

begin
  if FTransMode = tmParentWithPos then GetOrientationVectors(Up, Dir)
                                  else
  begin
    Up := MakeAffineVector(FUp.FCoords);
    Dir := MakeAffineVector(FDirection.FCoords);
  end;
  RightVector := VectorCrossProduct(MakeAffineVector(Dir), MakeAffineVector(Up));
  VectorNormalize(RightVector);
  FPosition.FCoords := MakeVector([FPosition.X + ADistance * RightVector[0], 
                                   FPosition.Y + ADistance * RightVector[1],
                                   FPosition.Z + ADistance * RightVector[2], 1]);
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.Turn(Angle: Single);

var
  Up, Dir: TAffineVector;

begin
  GetOrientationVectors(Up, Dir);
  Angle := DegToRad(Angle);
  VectorRotate(FUp.FCoords, Up, Angle);
  VectorNormalize(FUp.FCoords);
  VectorRotate(FDirection.FCoords, Up, Angle);
  VectorNormalize(FDirection.FCoords);
  if FTransMode = tmParentWithPos then VectorRotate(FPosition.FCoords, Up, Angle);
  FTurnAngle := -RadToDeg(arctan2(FDirection.X, Sqrt(Sqr(FDirection.Y) + Sqr(FDirection.Z))));
  if FDirection.X < 0 then
    if FDirection.Y < 0 then FTurnAngle := 180 - FTurnAngle
                        else FTurnAngle := -180 - FTurnAngle;
  TransformationChanged;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetTurnAngle(AValue: Single);
var
   Up, Dir: TAffineVector;
   Diff: Extended;
begin
   if AValue <> FTurnAngle then begin
      GetOrientationVectors(Up, Dir);
      if not (csLoading in ComponentState) then begin
         Diff := DegToRad(FTurnAngle - AValue);
         VectorRotate(FUp.FCoords, Up, Diff);
         VectorNormalize(FUp.FCoords);
         VectorRotate(FDirection.FCoords, Up, Diff);
         VectorNormalize(FDirection.FCoords);
         if FTransMode = tmParentWithPos then
            VectorRotate(FPosition.FCoords, Up, Diff);
         TransformationChanged;
      end;
      FTurnAngle := NormalizeAngle(AValue);
   end;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetShowAxes(AValue: Boolean);

begin
  if FShowAxes <> AValue then
  begin
    FShowAxes := AValue;
    NotifyChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetScaling(AValue: TGLCoordinates);
begin
   FScaling.Assign(AValue);
   TransformationChanged;
end;

// SetName
//
procedure TGLBaseSceneObject.SetName(const NewName: TComponentName);
begin
	if Name <> NewName then begin
		inherited SetName(NewName);
		if Assigned(vGLBaseSceneObjectNameChangeEvent) then
			vGLBaseSceneObjectNameChangeEvent(Self);
	end;
end;

// GetMatrix
//
function TGLBaseSceneObject.GetMatrix: TMatrix;
begin
	// update local matrix if necessary
	RebuildMatrix;
  	Result := FLocalMatrix;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetIndex(AValue: Integer);

var
  Count: Integer;
  AParent: TGLBaseSceneObject;

begin
  if assigned(FParent) then
  begin
    Count := FParent.Count;
    AParent := FParent;
    if AValue < 0 then AValue :=  0;
    if AValue >= Count then AValue :=  Count - 1;
    if AValue <> Index then
    begin
      if assigned(FScene) then FScene.BeginUpdate;
      FParent.Remove(Self, False);
      AParent.Insert(AValue, Self);
      if assigned(FScene) then FScene.EndUpdate;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetParentComponent(Value: TComponent);
begin
	if assigned(FParent) then begin
		FParent.Remove(Self, False);
		FParent := nil;
	end;
	// first level object?
	if Value is TGLScene then
		if Self is TGLCamera then
			TGLScene(Value).Cameras.AddChild(Self)
		else TGLScene(Value).Objects.AddChild(Self)
	else TGLBaseSceneObject(Value).AddChild(Self);  // normal parent-child relation
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.StructureChanged;
begin
   Include(FChanges, ocStructure);
   NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.TransformationChanged;

begin
  FMatrixDirty := True;
  Include(FChanges, ocTransformation);
  NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.MoveTo(NewParent: TGLBaseSceneObject);
begin
   if assigned(FParent) then begin
      FParent.Remove(Self, False);
      FParent := nil;
   end;
   if assigned(NewParent) then
      NewParent.AddChild(Self)
   else FScene := nil;
end;

// MoveUp
//
procedure TGLBaseSceneObject.MoveUp;
begin
   if Assigned(parent) then
      parent.MoveChildUp(parent.IndexOfChild(Self));
end;

// MoveDown
//
procedure TGLBaseSceneObject.MoveDown;
begin
   if Assigned(parent) then
      parent.MoveChildDown(parent.IndexOfChild(Self));
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.EndUpdate;

begin
   if FUpdateCount > 0 then Dec(FUpdateCount);
   if FUpdateCount = 0 then NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.FinishObject;
begin
  	Exclude(FChanges, ocTransformation);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.CoordinateChanged(Sender: TGLCoordinates);
var
   rightVector : TVector;
begin
  if FIsCalculating then Exit;
  FIsCalculating := True;
  try
      if Sender = FDirection then begin
         if VectorLength(FUp.FCoords) = 0 then
            FUp.FCoords := YHmgVector;
         VectorNormalize(FDirection.FCoords);
         // adjust up vector
         rightVector := VectorCrossProduct(FDirection.FCoords, FUp.FCoords);
         // Rightvector is zero if direction changed exactly by 90 degrees,
         // in this case assume a default vector
         if VectorLength(rightVector) = 0 then with FDirection do
            rightVector:=MakeVector(X+1, Y+2, Z+3);
         FUp.FCoords:=VectorCrossProduct(RightVector, FDirection.FCoords);
         VectorNormalize(FUp.FCoords);
      end else begin
         if VectorLength(FDirection.FCoords) = 0 then
            FDirection.FCoords := ZHmgVector;
         VectorNormalize(FUp.FCoords);
         // adjust up vector
         rightVector := VectorCrossProduct(FDirection.FCoords, FUp.FCoords);
         // Rightvector is zero if direction changed exactly by 90 degrees,
         // in this case assume a default vector
         if VectorLength(rightVector) = 0 then with FUp do
            rightVector:=MakeVector([X+1, Y+2, Z+3]);
         FDirection.FCoords:=VectorCrossProduct(FUp.FCoords, RightVector);
         VectorNormalize(FDirection.FCoords);
      end;
      TransformationChanged;
   finally
      FIsCalculating := False;
   end;
end;

// DoProgress
//
procedure TGLBaseSceneObject.DoProgress(const deltaTime, newTime : Double);
var
   i : Integer;
begin
	for i:=Count-1 downto 0 do
      Children[i].DoProgress(deltaTime, newTime);
   if Assigned(FOnProgress) then
		FOnProgress(Self, deltaTime, newTime);
end;

// PrepareObject
//
procedure TGLBaseSceneObject.PrepareObject;
begin
	glLoadMatrixf(@FGLobalMatrix);
	if FScene.FCurrentViewer.State=dsPicking then
		glLoadName(Integer(Self));
end;

// Remove
//
procedure TGLBaseSceneObject.Remove(AChild: TGLBaseSceneObject; KeepChildren: Boolean);
begin
	if Assigned(FScene) and (AChild is TGLLightSource) then
		FScene.RemoveLight(TGLLightSource(AChild));
	FChildren.Remove(AChild);
	AChild.FParent:=nil;
	if KeepChildren then begin
		BeginUpdate;
		with AChild do while Count>0 do
			Children[0].MoveTo(Self);
		EndUpdate;
	end else NotifyChange;
end;

// IndexOfChild
//
function TGLBaseSceneObject.IndexOfChild(AChild: TGLBaseSceneObject) : Integer;
begin
	Result:=FChildren.IndexOf(AChild);
end;

// MoveChildUp
//
procedure TGLBaseSceneObject.MoveChildUp(anIndex : Integer);
begin
   if anIndex>0 then
      FChildren.Exchange(anIndex, anIndex-1);
end;

// MoveChildDown
//
procedure TGLBaseSceneObject.MoveChildDown(anIndex : Integer);
begin
   if anIndex<FChildren.Count-1 then
      FChildren.Exchange(anIndex, anIndex+1);
end;

//------------------------------------------------------------------------------

procedure QuickSortObjectsByDist(startIndex, endIndex : Integer;
											distList, objList : TList);
var
	I, J : Integer;
	P : single;
begin
	if endIndex-startIndex>1 then begin
		repeat
			I:=startIndex; J:=endIndex;
			P:=Single(distList[(I + J) shr 1]);
			repeat
				while Single(distList[I])<P do Inc(I);
				while Single(distList[J])>P do Dec(J);
				if I <= J then begin
					distList.Exchange(i, J);
					objList.Exchange(i, j);
					Inc(I); Dec(J);
				end;
			until I > J;
			if startIndex < J then
				QuickSortObjectsByDist(startIndex, J, distList, objList);
			startIndex := I;
		until I >= endIndex;
	end else if endIndex-startIndex>0 then begin
		p:=Single(distList[startIndex]);
		if Single(distList[endIndex])<p then begin
			distList.Exchange(startIndex, endIndex);
			objList.Exchange(startIndex, endIndex);
		end;
	end;
end;

// Render
//
procedure TGLBaseSceneObject.Render(objectsSorting : TGLObjectsSorting;
												const cameraPosition : TVector;
												var currentStates : TGLStates);
var
	i : Integer;
	distList, objList : TList;
	obj : TGLBaseSceneObject;
begin
	PrepareObject;
	if (FVisible) then
		//if FScene.FCurrentViewer.ObjectInScene(Self) then
		glCallList(Handle);
	if FShowAxes then
		DrawAxes($CCCC);
	if Self.ObjectsSorting<>osInherited then
		objectsSorting:=Self.ObjectsSorting;
	if Count>1 then case objectsSorting of
		osNone : begin
			for i:=0 to Count-1 do
				Self[i].Render(objectsSorting, cameraPosition, currentStates);
		end;
		osRenderFarthestFirst, osRenderBlendedLast : begin
			distList:=TList.Create;
			objList:=TList.Create;
			try
				if objectsSorting=osRenderBlendedLast then begin
					// render opaque stuff
					for i:=0 to Count-1 do begin
						obj:=Get(i);
						if (not (obj is TGLCustomSceneObject)) or (TGLCustomSceneObject(obj).Material.BlendingMode=bmOpaque) then
							obj.Render(objectsSorting, cameraPosition, currentStates)
						else begin
							objList.Add(obj);
							distList.Add(Pointer(obj.BarycenterSqrDistanceTo(cameraPosition)));
						end;
					end;
				end else for i:=0 to Count-1 do begin
					obj:=Get(i);
					objList.Add(obj);
					distList.Add(Pointer(obj.BarycenterSqrDistanceTo(cameraPosition)));
				end;
				if distList.Count>1 then
					QuickSortObjectsByDist(0, distList.Count-1, distList, objList);
				for i:=objList.Count-1 downto 0 do
					TGLBaseSceneObject(objList[i]).Render(objectsSorting, cameraPosition, currentStates);
			finally
				distList.Free;
				objList.Free;
			end;
		end;
	else
      Assert(False);
   end else if Count>0 then
      Get(0).Render(objectsSorting, cameraPosition, currentStates);
   FinishObject;
   {$ifdef DEBUG} CheckOpenGLError; {$endif}
end;

// NotifyChange
//
procedure TGLBaseSceneObject.NotifyChange;
begin
   if Assigned(FScene) and (not IsUpdating) then
      FScene.NotifyChange;
end;

// ValidateTransformation
//
procedure TGLBaseSceneObject.ValidateTransformation;
var
  I: Integer;
begin
  // determine predecessor in transformation pipeline
  if (FParent = nil) then
  begin
    if (Scene.FLasTGLCamera <> Scene.FCurrenTGLCamera) or (ocTransformation in Scene.FCurrenTGLCamera.FChanges) then
    begin
      FGlobalMatrix := Scene.CurrenTGLCamera.FGLobalMatrix;
      Include(FChanges, ocTransformation);
    end;
  end
  else
    if ocTransformation in FChanges + FParent.FChanges then
    begin
      if ocTransformation in FChanges then RebuildMatrix;
      FGlobalMatrix := MatrixMultiply(FLocalMatrix, FParent.FGlobalMatrix);
      Include(FChanges, ocTransformation);
    end;

  for I := 0 to Count - 1 do Self[I].ValidateTransformation;
  Exclude(FChanges, ocTransformation);
end;

//------------------------------------------------------------------------------

procedure TGLBaseSceneObject.SetMatrix(AValue: TMatrix);

var
  Temp: TAffineVector;

begin
  FLocalMatrix := AValue;
  FDirection.FCoords := FLocalMatrix[2];
  FUp.FCoords := FLocalMatrix[1];
  Temp := MakeAffineVector(FLocalMatrix[0]);
  Scale.AsVector:=MakeVector(VectorLength(Temp),
                             VectorLength(FUp.FCoords),
                             VectorLength(FDirection.FCoords));
  FPosition.FCoords := FLocalMatrix[3];
  FMatrixDirty := False;
  Include(FChanges, ocTransformation);
  NotifyChange;
end;

procedure TGLBaseSceneObject.SetPosition(APosition: TGLCoordinates);
begin
   FPosition.FCoords := APosition.FCoords;
   TransformationChanged;
end;

procedure TGLBaseSceneObject.SetDirection(AVector: TGLCoordinates);
begin
   FDirection.FCoords := AVector.FCoords;
   TransformationChanged;
end;

procedure TGLBaseSceneObject.SetUp(AVector: TGLCoordinates);
begin
   FUp.FCoords := AVector.FCoords;
   TransformationChanged;
end;

procedure TGLBaseSceneObject.SetVisible(AValue: Boolean);
begin
   if FVisible <> AValue then begin
      FVisible := AValue;
      NotifyChange;
   end;
end;

// SetObjectsSorting
//
procedure TGLBaseSceneObject.SetObjectsSorting(const val : TGLObjectsSorting);
begin
   if FObjectsSorting<>val then begin
      FObjectsSorting:=val;
      NotifyChange;
   end;
end;

procedure TGLBaseSceneObject.Translate(Tx, Ty, Tz: TGLFloat);
begin
   FPosition.FCoords := MakeVector([Tx, Ty, Tz, FPosition.W]);
end;

//------------------ TGLCustomSceneObject ----------------------------------------------

// Create
//
constructor TGLCustomSceneObject.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FHandle := 0;
   FMaterial := TGLMaterial.Create(Self);
end;

// Destroy
//
destructor TGLCustomSceneObject.Destroy;
begin
   FMaterial.Free;
   inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLCustomSceneObject.DestroyList;

begin
  if FHandle > 0 then
  begin
    glDeleteLists(FHandle, 1);
    FHandle := 0;
  end;
  inherited DestroyList;
end;

// Assign
//
procedure TGLCustomSceneObject.Assign(Source: TPersistent);
begin
	if Source is TGLCustomSceneObject then begin
		FBoundingBox:=TGLCustomSceneObject(Source).FBoundingBox;
		FMaterial.Assign(TGLCustomSceneObject(Source).FMaterial);
		FTagFloat:=TGLCustomSceneObject(Source).FTagFloat;
	end;
	inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TGLCustomSceneObject.BuildList;
begin
	inherited BuildList;
end;

// GetHandle
//
function TGLCustomSceneObject.GetHandle: TObjectHandle;
begin
   if ocStructure in FChanges then begin
      if FHandle = 0 then begin
         FHandle := glGenLists(1);
         Assert(FHandle<>0, 'Handle=0 for '+ClassName);
      end;
      glNewList(FHandle, GL_COMPILE);
      try
         BuildList;
      finally
         glEndList;
      end;
      Exclude(FChanges, ocStructure);
   end;
   Result := FHandle;
end;

//------------------------------------------------------------------------------

procedure TGLCustomSceneObject.SetGLMaterial(AValue: TGLMaterial);
begin
   FMaterial.Assign(AValue);
   NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLCustomSceneObject.ReloadTexture;

var
  I: Integer;

begin
  FMaterial.Texture.ReloadImage;
  for I := 0 to Count - 1 do
    if Self[I] is TGLCustomSceneObject then TGLCustomSceneObject(Self[I]).ReloadTexture;
end;

//------------------------------------------------------------------------------

procedure TGLCustomSceneObject.Render(objectsSorting : TGLObjectsSorting;
												  const cameraPosition : TVector;
												  var currentStates : TGLStates);
begin
	FMaterial.Apply(currentStates);
   inherited Render(objectsSorting, cameraPosition, currentStates);
end;

//----------------- TGLCamera ----------------------------------------------------

constructor TGLCamera.Create(AOwner: TCOmponent);
begin
   inherited;
   FFocalLength := 50;
   FDepthOfView := 100;
   FDirection.Initialize(MakeVector([0, 0, -1, 0]));
end;

destructor TGLCamera.Destroy;
begin
   inherited;
end;

procedure TGLCamera.Apply;
var
	v, d : TVector;
	absPos : TVector;
begin
	if Assigned(FTargetObject) then begin
		// get our target's absolute coordinates
		v:=TargetObject.AbsolutePosition;
		d:=VectorSubtract(v, Position.FCoords);
		VectorNormalize(d);
		// check if target moved
		if (ocTransformation in FChanges) or (VectorSpacing(d, FLastTargetObjectPosition)>0) then begin
			absPos:=AbsolutePosition;
			FLastTargetObjectPosition:=d;
			// if direction changed, we need to call gluLookAt
			gluLookAt(absPos[0], absPos[1], absPos[2], //Position.X, Position.Y, Position.Z,
						 v[0], v[1], v[2],
						 Up.X, Up.Y, Up.Z);
			glGetFloatv(GL_MODELVIEW_MATRIX, @FGLobalMatrix);
		end;
	end else begin
		if ocTransformation in FChanges then begin
			gluLookAt(Position.X, Position.Y, Position.Z,
						 Position.X + Direction.X,
						 Position.Y + Direction.Y,
						 Position.Z + Direction.Z,
						 FUp.X, FUp.Y, FUp.Z);
			glGetFloatv(GL_MODELVIEW_MATRIX, @FGLobalMatrix);
		end;
	end;
end;

procedure TGLCamera.ApplyPerspective(Viewport: TRectangle; Width, Height: Integer; DPI: Integer);
var
	Left, Right, Top, Bottom, zFar, MaxDim, Ratio: Double;
begin
   // determine biggest dimension and resolution (height or width)
   MaxDim := Width;
   if Height > MaxDim then
      MaxDim := Height;

  // calculate near plane distance and extensions;
  // Scene ratio is determined by the window ratio. The viewport is just a
  // specific part of the entire window and has therefore no influence on the
  // scene ratio. What we need to know, though, is the ratio between the window
  // borders (left, top, right and bottom) and the viewport borders.
  // Note: viewport.top is actually bottom, because the window (and viewport) origin
  // in OGL is the lower left corner

  // calculate window/viewport ratio for right extent
  Ratio := (2 * Viewport.Width + 2 * Viewport.Left - Width) / Width;
  // calculate aspect ratio correct right value of the view frustum and take
  // the window/viewport ratio also into account
  Right := Ratio * Width / (2 * MaxDim);

  // the same goes here for the other three extents
  // left extent:
  Ratio := (Width - 2 * Viewport.Left) / Width;
  Left := -Ratio * Width / (2 * MaxDim);

  // top extent (keep in mind the origin is left lower corner):
  Ratio := (2 * Viewport.Height + 2 * Viewport.Top - Height) / Height;
  Top := Ratio * Height / (2 * MaxDim);

  // bottom extent:
  Ratio := (Height - 2 * Viewport.Top) / Height;
  Bottom := -Ratio * Height / (2 * MaxDim);

  FNearPlane := FFocalLength * 2 * DPI / (25.4 * MaxDim);
  zFar := FNearPlane + FDepthOfView;

  // finally create view frustum
  glFrustum(Left, Right, Bottom, Top, FNearPlane, zFar);
end;

//------------------------------------------------------------------------------

procedure TGLCamera.AutoLeveling(Factor: Single);
var
  rightVector, rotAxis: TVector;
  angle: Single;
begin
   angle := RadToDeg(arccos(VectorAffineDotProduct(MakeAffineVector(FUp.FCoords), YVector)));
   rotAxis := VectorCrossProduct(YHmgVector, FUp.FCoords);
   if (angle > 1) and (VectorLength(rotAxis) > 0) then begin
      rightVector := VectorCrossProduct(FDirection.FCoords, FUp.FCoords);
      VectorRotate(FUp.FCoords, MakeAffineVector(rotAxis), Angle / 10 / Factor);
      VectorNormalize(FUp.FCoords);
      // adjust local coordinates
      FDirection.FCoords := VectorCrossProduct(FUp.FCoords, rightVector);
      FRollAngle := -RadToDeg(arctan2(Rightvector[1], Sqrt(Sqr(RightVector[0]) + Sqr(RightVector[2]))));
      TransformationChanged;
   end;
end;

procedure TGLCamera.Notification(AComponent: TComponent; Operation: TOperation);
begin
   inherited;
   if (Operation = opRemove) and (AComponent = FTargetObject) then
      TargetObject:=nil;
end;

// SetTargetObject
//
procedure TGLCamera.SetTargetObject(const val : TGLBaseSceneObject);
begin
   if (FTargetObject<>val) then begin
      FTargetObject:=val;
      FLastTargetObjectPosition:=Direction.AsVector;
      if not (csLoading in Scene.ComponentState) then
         TransformationChanged;
   end;
end;

procedure TGLCamera.Reset;
var
   Extent: Single;
begin
	FRollAngle := 0;
   FFocalLength := 50;
   with FScene.CurrentViewer do begin
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      ApplyPerspective(FViewport, Width, Height, GetDeviceCaps(Canvas.Handle, LOGPIXELSX));
      FUp.FCoords := MakeVector([0, 1]);
      Extent := MinIntValue([FViewport.Height, FViewport.Width]) / 4;
	end;
   FPosition.FCoords := MakeVector(0, 0, FNearPlane * Extent, 1);
   FDirection.FCoords := MakeVector(0, 0, -1);
   TransformationChanged;
end;

// ZoomAll
//
procedure TGLCamera.ZoomAll;
var
	extent: Single;
begin
	with Scene.CurrentViewer do begin
		Extent := MinIntValue([FViewport.Height, FViewport.Width]) / 4;
		FPosition.FCoords := NullHmgPoint;
		Move(-FNearPlane * Extent);
		// let the camera look at the scene center
		FDirection.FCoords := MakeVector([-FPosition.X, -FPosition.Y, -FPosition.Z]);
  	end;
end;

// MoveAroundTarget
//
procedure TGLCamera.MoveAroundTarget(pitchDelta, turnDelta : Single);
var
	vectAbsoluteFromTargetToCamera : TVector;
	vectLocalX, vectLocalZ, vectLocalY, vect, temp : TVector;
	mat : TMatrix;
	dist : Single;
begin
	if Assigned(FTargetObject) then begin
		// This stuff can probably be made shorter...
		//
		// calculate vector from target to camera in absolute coordinates
		vectAbsoluteFromTargetToCamera:=VectorSubtract(AbsolutePosition, TargetObject.AbsolutePosition);
		dist:=VectorLength(vectAbsoluteFromTargetToCamera);
		// calculate a local x vector (points right in camera's view)
		vectLocalX:=VectorCrossProduct(Up.AsVector, vectAbsoluteFromTargetToCamera);
		VectorNormalize(vectLocalX);
		// calculate local Z direction (points up)
		vectLocalZ:=VectorCrossProduct(vectAbsoluteFromTargetToCamera, vectLocalX);
		VectorNormalize(vectLocalZ);
		// complete with local Y (points to target)
		vectLocalY:=VectorCrossProduct(vectLocalZ, vectLocalX);
		// express new vector in local coordinates and rotate it
		vect:=MakeVector(0, -dist, 0, 0);
		turnDelta:=turnDelta*PI/180;
		mat:=CreateRotationMatrixZ(Sin(turnDelta), Cos(turnDelta));
		vect:=VectorTransform(vect, mat);
		pitchDelta:=pitchDelta*PI/180;
		mat:=CreateRotationMatrixX(Sin(pitchDelta), Cos(pitchDelta));
		vect:=VectorTransform(vect, mat);
		// express in absolute coordinates
		temp:=vect;
		vect[0]:=vectLocalX[0]*temp[0]+vectLocalY[0]*temp[1]+vectLocalZ[0]*temp[2];
		vect[1]:=vectLocalX[1]*temp[0]+vectLocalY[1]*temp[1]+vectLocalZ[1]*temp[2];
		vect[2]:=vectLocalX[2]*temp[0]+vectLocalY[2]*temp[1]+vectLocalZ[2]*temp[2];
		// camera translation
		temp:=VectorSubtract(vect, vectAbsoluteFromTargetToCamera);
		Position.AsVector:=VectorAdd(Position.AsVector, temp);
	end;
end;

// AdjustDistanceToTarget
//
procedure TGLCamera.AdjustDistanceToTarget(distanceRatio : Single);
var
	vect : TVector;
begin
	if Assigned(FTargetObject) then begin
		// calculate vector from target to camera in absolute coordinates
		vect:=VectorSubtract(AbsolutePosition, TargetObject.AbsolutePosition);
		// ratio -> translation vector
		VectorScale(vect, -(1-distanceRatio));
		Position.AsVector:=VectorAdd(Position.AsVector, vect);
	end;
end;

// DistanceToTarget
//
function TGLCamera.DistanceToTarget : Single;
var
	vect : TVector;
begin
	if Assigned(FTargetObject) then begin
		vect:=VectorSubtract(AbsolutePosition, TargetObject.AbsolutePosition);
		Result:=VectorLength(vect);
	end else Result:=1;
end;

// ScreenDeltaToVector
//
function TGLCamera.ScreenDeltaToVector(deltaX, deltaY : Integer; ratio : Single;
												 const planeNormal : TVector) : TVector;
var
	screenY, screenX : TVector;
	screenYoutOfPlaneComponent : Single;
begin
	// calculate projection of direction vector on the plane
	if Assigned(FTargetObject) then
		screenY:=VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
	else screenY:=Direction.AsVector;
	screenYoutOfPlaneComponent:=VectorDotProduct(screenY, planeNormal);
	screenY:=VectorCombine(screenY, planeNormal, 1, -screenYoutOfPlaneComponent);
	VectorNormalize(screenY);
	// calc the screenX vector
	screenX:=VectorCrossProduct(screenY, planeNormal);
	// and here, we're done
	Result:=VectorCombine(screenX, screenY, deltaX*ratio, deltaY*ratio);
end;

// ScreenDeltaToVectorXY
//
function TGLCamera.ScreenDeltaToVectorXY(deltaX, deltaY : Integer; ratio : Single) : TVector;
var
	screenY : TVector;
	dxr, dyr, d : Single;
begin
	// calculate projection of direction vector on the plane
	if Assigned(FTargetObject) then
		screenY:=VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
	else screenY:=Direction.AsVector;
	d:=sqrt(sqr(screenY[0])+sqr(screenY[1]));
	if d<=1e-10 then d:=ratio else d:=ratio/d;
	// and here, we're done
	dxr:=deltaX*d;
	dyr:=deltaY*d;
	Result[0]:=screenY[1]*dxr+screenY[0]*dyr;
	Result[1]:=screenY[1]*dyr-screenY[0]*dxr;
	Result[2]:=0;
	Result[3]:=0;
end;

// SetDepthOfView
//
procedure TGLCamera.SetDepthOfView(AValue: Single);
begin
  if FDepthOfView <> AValue then
  begin
	 FDepthOfView := AValue;
	 if not (csLoading in Scene.ComponentState) then
      TransformationChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLCamera.SetFocalLength(AValue: Single);

begin
  if AValue < 1 then AValue := 1;
  if FFocalLength <> AValue  then
  begin
	 FFocalLength := AValue;
    if not (csLoading in Scene.ComponentState) then
      TransformationChanged;
  end;
end;

//------------------ TGLLightSource ----------------------------------------------

constructor TGLLightSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShining := True;
  FSpotDirection := TGLCoordinates.Create(Self);
  FSpotDirection.FCoords := MakeVector([0, 0, -1]);
  FConstAttenuation := 1;
  FLinearAttenuation := 0;
  FQuadraticAttenuation := 0;
  FSpotCutOff := 180;
  FSpotExponent := 0;
  FAmbient := TGLColor.Create(Self);
  FDiffuse := TGLColor.Create(Self);
  FDiffuse.Initialize(clrWhite);
  FSpecular := TGLColor.Create(Self);
  FVisible := False;
  FChanges := [];
end;

//------------------------------------------------------------------------------

destructor TGLLightSource.Destroy;

begin
  FSpotDirection.Free;
  FAmbient.Free;
  FDiffuse.Free;
  FSpecular.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.DestroyList;

begin
end;

// CoordinateChanged
//
procedure TGLLightSource.CoordinateChanged(Sender: TGLCoordinates);
begin
   inherited;
   if Sender = FSpotDirection then
      Include(FChanges, ocSpot);
   TransformationChanged;
end;

// GetHandle
//
function TGLLightSource.GetHandle: TObjectHandle;
begin
   Result := 0;
end;

// SetShining
//
procedure TGLLightSource.SetShining(AValue: Boolean);
begin
   if AValue<>FShining then begin
      FShining := AValue;
      NotifyChange;
   end;
end;

// SetSpotDirection
//
procedure TGLLightSource.SetSpotDirection(AVector: TGLCoordinates);
begin
   FSpotDirection.FCoords := AVector.FCoords;
   Include(FChanges, ocSpot);
   NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetSpotExponent(AValue: TGLFloat);

begin
  if FSpotExponent <> AValue then
  begin
    FSpotExponent := AValue;
    Include(FChanges, ocSpot);
    NotifyChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetSpotCutOff(AValue: TGLFloat);

begin
  if FSpotCutOff <> AValue then
  begin
    FSpotCutOff := AValue;
    Include(FChanges, ocSpot);
    NotifyChange;
  end;  
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetAmbient(AValue: TGLColor);

begin
  FAmbient.Color := AValue.Color;
  NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetDiffuse(AValue: TGLColor);

begin
  FDiffuse.Color := AValue.Color;
  NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetSpecular(AValue: TGLColor);

begin
  FSpecular.Color := AValue.Color;
  NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetConstAttenuation(AValue: TGLFloat);

begin
  if FConstAttenuation <> AValue then
  begin
    FConstAttenuation := AValue;
    Include(FChanges, ocAttenuation);
    NotifyChange;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetLinearAttenuation(AValue: TGLFloat);

begin
  if FLinearAttenuation <> AValue then
  begin
    FLinearAttenuation := AValue;
    Include(FChanges, ocAttenuation);
    NotifyChange;
  end;  
end;

//------------------------------------------------------------------------------

procedure TGLLightSource.SetQuadraticAttenuation(AValue: TGLFloat);

begin
  if FQuadraticAttenuation <> AValue then
  begin
    FQuadraticAttenuation := AValue;
    Include(FChanges, ocAttenuation);
    NotifyChange;
  end;
end;

//------------------------------------------------------------------------------

{procedure TGLLightSource.RenderLensFlares(from, at: TAffineVector; near_clip: TGLFloat);
const
  global_scale = 0.5;
  MinDot = 1e-20;
var
   view_dir, tmp, light_dir, pos, LightPos : TAffineVector;
   dx, dy, center, axis, sx, sy: TAffineVector;
   dot: Extended;
   I: Integer;
   NewFrom, NewAt: TAffineVector;
   LightColor: TAffineVector;
begin
   // determine current light position
   LightPos := MakeAffineVector([FGLobalMatrix[3, 0], FGLobalMatrix[3, 1], FGLobalMatrix[3, 2]]);
   // take out camera influence
   Newat := VectorAffineSubtract(at, from);
   Newfrom := NullVector;

   // view_dir = normalize(at-from)
   view_dir := VectorAffineSubtract(Newat, NewFrom);
   VectorNormalize(view_dir);

   // center = from + near_clip * view_dir
   tmp := view_dir;
   VectorScale(tmp, near_clip);
   center := VectorAffineAdd(Newfrom, tmp);

   // light_dir = normalize(light-from)
   light_dir := VectorAffineSubtract(LightPos, Newfrom);
   VectorNormalize(light_dir);

   // light = from + dot(light, view_dir) * near_clip * light_dir
   dot := VectorAffineDotProduct(light_dir, view_dir);
   tmp := light_dir;
   if Abs(Dot) < MinDot then
      if Dot < 0 then Dot := -MinDot else Dot := MinDot;
	VectorScale(tmp, near_clip / dot);
	LightPos := VectorAffineAdd(Newfrom, tmp);

	// axis = light - center
	axis := VectorAffineSubtract(LightPos, center);

	// dx = normalize(axis)
	dx := axis;
	VectorNormalize(dx);

	// dy = cross(dx, view_dir)
	dy := VectorCrossProduct(dx, view_dir);

	//glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LIGHTING_BIT or GL_LINE_BIT
	//  or GL_COLOR_BUFFER_BIT or GL_TEXTURE_BIT);
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	Scene.CurrentViewer.UnnecessaryState([stDepthTest, stLighting]);
	Scene.CurrentViewer.RequestedState([stBlend, sTGLTexture2D]);
	glBlendFunc(GL_ONE, GL_ONE);
	glLoadIdentity;

	for I := 0 to LensFlares.Count - 1 do with LensFlares do begin
		sx := dx;
		VectorScale(sx, Flare[I].Scale * global_scale*10);
		sy := dy;
		VectorScale(sy, Flare[I].Scale * global_scale*10);
		//sx:=MakeAffineVector(1, 0, 0);
		//sy:=MakeAffineVector(0, 1, 0);

      //glColor3fv(LensFlares.Flare[I].ColorAddr);
      LightColor := MakeAffineVector(Diffuse.Color);
      LightColor := VectorAffineAdd(LightColor, LensFlares.Flare[I].Color);;
      VectorScale(LightColor, 0.5);
      glColor3fv(@LightColor);
       glEnable(GL_TEXTURE_2D);;
      if Flare[I].FlareType < 0 then begin
         glBindTexture(GL_TEXTURE_2D, ShineTexture[FlareTic]);
         FlareTic := (FlareTic + 1) mod 10;
      end else glBindTexture(GL_TEXTURE_2D, FlareTexture[Flare[I].FlareType]);

      // position = center + flare[i].loc * axis
      tmp := axis;
      VectorScale(tmp, Flare[I].Location);
      Pos := VectorAffineAdd(center, tmp);

      glBegin(GL_QUADS);
        glTexCoord2f(0, 0);
        tmp := VectorAffineCombine3(Pos, sx, sy, 1, -1, -1);
        glVertex3fv(@tmp);

        glTexCoord2f(128, 0);
        tmp := VectorAffineCombine3(Pos, sx, sy, 1, 1, -1);
        glVertex3fv(@tmp);

        glTexCoord2f(128, 128);
        tmp := VectorAffineCombine3(Pos, sx, sy, 1, 1, 1);
        glVertex3fv(@tmp);

        glTexCoord2f(0, 128);
        tmp := VectorAffineCombine3(Pos, sx, sy, 1, -1, 1);
        glVertex3fv(@tmp);
      glEnd;
   end;
   Scene.CurrentViewer.RequestedState([stDepthTest, stLighting]);
   Scene.CurrentViewer.UnnecessaryState([stBlend, sTGLTexture2D]);
   glPopAttrib;
end;
}
//------------------------------------------------------------------------------

procedure TGLLightSource.ValidateTransformation;

// calculate own global matrix and let the children do the same with their's

begin
  // check the predecessor and its transformation state
  if assigned(FParent) then
    // has the object or its parent a new local/global matrix?
    if ocTransformation in FChanges + FParent.FChanges then
    begin
      FGlobalMatrix := MatrixMultiply(CreateTranslationMatrix(FPosition.FCoords), FParent.FGlobalMatrix);
      Include(FChanges, ocTransformation);
    end else
  else
  begin
    FGlobalMatrix := CreateTranslationMatrix(FPosition.FCoords);
    Include(FChanges, ocTransformation);
  end;
  // now let the children validate their matrices
  inherited ValidateTransformation;
end;

//------------------ TGLScene --------------------------------------------------

constructor TGLScene.Create(AOwner: TComponent);
begin
  inherited;
  // root creation
  FObjects := TGLCustomSceneObject.Create(Self);
  FObjects.Name := 'ObjectRoot';
  FObjects.FScene := Self;
  FCameras := TGLBaseSceneObject.Create(Self);
  FCameras.Name := 'CameraRoot';
  FCameras.FScene := Self;
  FLights := TList.Create;
  FObjectsSorting := osRenderBlendedLast;
  // actual maximum number of lights is stored in TGLSceneViewer
  FLights.Count := 8;
end;

//------------------------------------------------------------------------------

destructor TGLScene.Destroy;
begin
  FCameras.Free;
  FLights.Free;
  FObjects.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLScene.AddLight(ALight: TGLLightSource);
var
   i : Integer;
begin
   for i := 0 to FLights.Count - 1 do
		if FLights[i] = nil then begin
			FLights[i] := ALight;
         ALight.FLightID := GL_LIGHT0 + i;
         Break;
      end;
end;

//------------------------------------------------------------------------------

procedure TGLScene.AddViewer(AViewer: TGLSceneViewer);
begin
   if FViewers = nil then FViewers := TList.Create;
   if FViewers.IndexOf(AViewer) < 0 then FViewers.Add(AViewer);
   if FBaseContext = 0 then begin
      FBaseContext := TGLSceneViewer(FViewers[0]).RenderingContext;
      // the following initialization should be conditionally made to avoid adding
      // unnecessary overhead to the application
//      if spLensFlares in TGLSceneViewer(FViewers[0]).Specials then InitLensFlares;
//      if spLandScape in TGLSceneViewer(FViewers[0]).Specials then InitLandScape;
   end;
   if FViewers.Count > 1 then
      wglShareLists(FBaseContext, AViewer.RenderingContext);
end;

//------------------------------------------------------------------------------

procedure TGLScene.GetChildren(AProc: TGetChildProc; Root: TComponent);

begin
  FObjects.GetChildren(AProc, Root);
  FCameras.GetChildren(AProc, Root);
end;

//------------------------------------------------------------------------------

procedure TGLScene.RemoveLight(ALight: TGLLightSource);

var LIndex: Integer;

begin
  LIndex := FLights.IndexOf(ALight);
  if LIndex > -1 then FLights[LIndex] := nil;
end;

//------------------------------------------------------------------------------

procedure TGLScene.SetChildOrder(AChild: TComponent; Order: Integer);

begin
  (AChild as TGLBaseSceneObject).Index := Order;
end;

//------------------------------------------------------------------------------

procedure TGLScene.Loaded;

begin
  inherited Loaded;
end;

// IsUpdating
//
function TGLScene.IsUpdating: Boolean;
begin
  Result := (FUpdateCount <> 0) or (csLoading in ComponentState) or (csDestroying in ComponentState);
end;

// BeginUpdate
//
procedure TGLScene.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

// EndUpdate
//
procedure TGLScene.EndUpdate;
begin
   Assert(FUpdateCount>0);
   Dec(FUpdateCount);
   if FUpdateCount = 0 then NotifyChange;
end;

// SetObjectsSorting
//
procedure TGLScene.SetObjectsSorting(const val : TGLObjectsSorting);
begin
   if FObjectsSorting<>val then begin
      FObjectsSorting:=val;
      NotifyChange;
   end;
end;

// RenderScene
//
procedure TGLScene.RenderScene(AViewer: TGLSceneViewer);
begin
   ResetGLPolygonMode;
   ResetGLMaterialColors;
   FCurrentViewer := AViewer;
   FObjects.Render(FObjectsSorting, AViewer.Camera.AbsolutePosition, AViewer.FCurrentStates);
end;

procedure TGLScene.RemoveViewer(AViewer: TGLSceneViewer);
begin
  if assigned(FViewers) then
  begin
    // we need a new base context to share with if the previous base context
    // is about to be destroyed
    if (FViewers.IndexOf(AViewer) = 0) and (FViewers.Count > 1) then
       FBaseContext := TGLSceneViewer(FViewers[1]).RenderingContext;
    // if AViewer is the last one in the list then remove other
    // shared stuff before (!) the viewer is deleted
{    if FViewers.Count = 1 then
    begin
      LensFlares.Free;
      LandScape.Free;
    end;}
    FViewers.Remove(AViewer);
    if FViewers.Count = 0 then
    begin
      FViewers.Free;
      FViewers := nil;
      FBaseContext := 0;
      if not (csDestroying in ComponentState) then
      begin
        FObjects.DestroyList;
        FObjects.ReloadTexture;
      end;  
    end;  
  end;
end;

//------------------------------------------------------------------------------

procedure TGLScene.ValidateTransformation(ACamera: TGLCamera);

begin
  FCurrenTGLCamera := ACamera;
  ACamera.Apply;
  FObjects.ValidateTransformation;
  Exclude(ACamera.FChanges, ocTransformation);
  FLastGLCamera := FCurrentGLCamera;
end;

// Progress
//
procedure TGLScene.Progress(const deltaTime, newTime : Double);
begin
   FObjects.DoProgress(deltaTime, newTime);
   FCameras.DoProgress(deltaTime, newTime);
end;

// SaveToFile
//
procedure TGLScene.SaveToFile(const fileName : String);
begin
	WriteComponentResFile(fileName, Self);
end;

// LoadFromFile
//
procedure TGLScene.LoadFromFile(const fileName : String);
begin
	Cameras.DeleteChildren;
	Objects.DeleteChildren;
{ TODO : Camera Targets are lost, some persistence upgraded is needed here }   
	ReadComponentResFile(fileName, Self);
end;

//------------------------------------------------------------------------------

procedure TGLScene.NotifyChange;
var
   i : Integer;
begin
   if (not IsUpdating) and assigned(FViewers) then
      for i:=0 to FViewers.Count-1 do
         TGLSceneViewer(FViewers[i]).Invalidate;
end;

//------------------------------------------------------------------------------

procedure TGLScene.SetupLights(Maximum: Integer);
var
   I: Integer;
   LS: TGLLightSource;
   Max: Integer;
begin
   // start searching through all light sources
   if Maximum < FLights.Count then
      Max := Maximum
   else Max := FLights.Count;
   for I := 0 to Max - 1 do begin
      LS := TGLLightSource(FLights[I]);
		if Assigned(LS) and LS.Shining then with LS do begin
         glEnable(FLightID);
         glLoadMatrixf(@FGlobalMatrix);
         glLightfv(FLightID, GL_POSITION, Position.AsAddress);
         with FAmbient  do glLightfv(FLightID, GL_AMBIENT, AsAddress);
         with FDiffuse  do glLightfv(FLightID, GL_DIFFUSE, AsAddress);
         with FSpecular do glLightfv(FLightID, GL_SPECULAR, AsAddress);
         if ocSpot in FChanges then begin
            if FSpotCutOff<>180 then begin
               glLightfv(FLightID, GL_SPOT_DIRECTION, @FSpotDirection.FCoords);
               glLightfv(FLightID, GL_SPOT_EXPONENT, @FSpotExponent);
            end;
            glLightfv(FLightID, GL_SPOT_CUTOFF, @FSpotCutOff);
            Exclude(FChanges, ocSpot);
         end;
         if ocAttenuation in FChanges then begin
            glLightfv(FLightID, GL_CONSTANT_ATTENUATION, @FConstAttenuation);
            glLightfv(FLightID, GL_LINEAR_ATTENUATION, @FLinearAttenuation);
            glLightfv(FLightID, GL_QUADRATIC_ATTENUATION, @FQuadraticAttenuation);
            Exclude(FChanges, ocAttenuation);
         end;
      end else glDisable(GL_LIGHT0 + I);
   end;
end;

//------------------------------------------------------------------------------

procedure TGLScene.DoAfterRender;
{var
   i : Integer;
   light : TGLLightSource;}
begin
{   for I := 0 to FLights.Count-1 do begin
      light:=TGLLightSource(FLights[I]);
      if Assigned(light) and light.Shining then
         light.RenderLensFlares(MakeAffineVector(CurrenTGLCamera.Position.FCoords),
                                MakeAffineVector(CurrenTGLCamera.FDirection.FCoords),
                                CurrentViewer.FCamera.FNearPlane);
   end;}
end;

//------------------ TGLFogEnvironment ------------------------------------------------

// Note: The fog implementation is not conformal with the rest of the scene management
//       because it is viewer bound not scene bound.

constructor TGLFogEnvironment.Create(Owner : TPersistent);
begin
   inherited;
   FSceneViewer := (Owner as TGLSceneViewer);
   FFogColor :=  TGLColor.Create(Self);
	FFogColor.Initialize(clrBlack);
   FFogMode :=  fmLinear;
   FFogStart :=  10;
   FFogEnd :=  1000;
end;

//------------------------------------------------------------------------------

destructor TGLFogEnvironment.Destroy;

begin
  FFogColor.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLFogEnvironment.NotifyChange;
begin
   FChanged := True;
   FSceneViewer.Invalidate;
end;

procedure TGLFogEnvironment.SetFogColor(Value: TGLColor);
begin
   if Assigned(Value) then begin
      FFogColor.Assign(Value);
      NotifyChange;
   end;
end;

procedure TGLFogEnvironment.SetFogStart(Value: TGLfloat);
begin
   if Value <> FFogStart then begin
      FFogStart :=  Value;
      NotifyChange;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLFogEnvironment.SetFogEnd(Value: TGLfloat);
begin
   if Value <> FFogEnd then begin
      FFogEnd :=  Value;
      NotifyChange;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLFogEnvironment.Assign(Source: TPersistent);

begin
  if Source is TGLFogEnvironment then
  begin
    FFogColor.Assign(TGLFogEnvironment(Source).FFogColor);
    FFogStart :=  TGLFogEnvironment(Source).FFogStart;
    FFogEnd :=  TGLFogEnvironment(Source).FFogEnd;
    FFogMode :=  TGLFogEnvironment(Source).FFogMode;
    FChanged := True;
  end
  else
    inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TGLFogEnvironment.SetFogMode(Value: TFogMode);
begin
   if Value <> FFogMode then begin
      FFogMode :=  Value;
      NotifyChange;
   end;
end;

// ApplyFog
//
procedure TGLFogEnvironment.ApplyFog;
begin
   if FChanged then with FSceneViewer do begin
      if FRenderingContext > 0 then begin
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            case FFogMode of
               fmLinear : glFogi(GL_FOG_MODE, GL_LINEAR);
               fmExp : begin
                  glFogi(GL_FOG_MODE, GL_EXP);
                  glFogf(GL_FOG_DENSITY, FFogColor.Alpha);
               end;
               fmExp2 : begin
                  glFogi(GL_FOG_MODE, GL_EXP2);
                  glFogf(GL_FOG_DENSITY, FFogColor.Alpha);
               end;
            end;
            glFogfv(GL_FOG_COLOR, FFogColor.AsAddress);
            glFogf(GL_FOG_START, FFogStart);
            glFogf(GL_FOG_END, FFogEnd);
         finally
            DeactivateRenderingContext;
            FChanged:=False;
         end;
      end;
   end;
end;

//------------------ TGLSceneViewer --------------------------------------------------

constructor TGLSceneViewer.Create(AOwner: TComponent);
begin
  InitOpenGL;
  inherited Create(AOwner);
  ControlStyle := [csClickEvents, csDoubleClicks, csOpaque, csCaptureMouse];
  if csDesigning in ComponentState then ControlStyle := ControlStyle + [csFramed];
  FCanvas := TCanvas.Create;
  Width:=100;
  Height:=100;
  FDisplayOptions := TDisplayOptions.Create;
  FBackground := TGLTexture.Create(nil);

  // initialize private state variables
  FFogEnvironment :=  TGLFogEnvironment.Create(Self);
  FBackgroundColor :=  clBtnFace;
  FDepthTest :=  True;
  FFaceCulling :=  True;
  FLighting :=  True;
  FFogEnable :=  False;

  FContextOptions := [roDoubleBuffer, roRenderToWindow];

  // performance check off
  FMonitor := False;
  ResetPerformanceMonitor;
  FState := dsNone;
end;

//------------------------------------------------------------------------------
 
destructor TGLSceneViewer.Destroy;
begin
   // clean up and terminate
   if assigned (FCamera) and assigned (FCamera.FScene) then begin
      FCamera.FScene.RemoveViewer(Self);
      FCamera := nil;
   end;
   FBackground.Free;
   FDisplayOptions.Free;
   DestroyHandle;
   FFogEnvironment.free;
   //FLandScapeOption.free;
   FCanvas.Free;
   inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.CreateParams(var Params: TCreateParams);

begin
  inherited CreateParams(Params);
  with Params do
  begin
    if (not (csDesigning in ComponentState) and (woDesktop in FDisplayOptions.WindowAttributes)) or
       (not assigned(Parent) and (ParentWindow = 0)) then
    begin
      WndParent := 0;
      Style := WS_POPUP or WS_VISIBLE;
    end;
    //else Style := WS_CHILD;
    Style := Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
    if woTransparent in FDisplayOptions.WindowAttributes then
         ExStyle := ExStyle or WS_EX_TRANSPARENT;
    WindowClass.Style :=  CS_VREDRAW or CS_HREDRAW; // or CS_OWNDC;
  end;
end;

//------------------------------------------------------------------------------

function TGLSceneViewer.ObjectInScene(Obj: TGLBaseSceneObject): Boolean;

var
  ModelMatrix: THomogeneousDblMatrix;
  ProjectMatrix: THomogeneousDblMatrix;
  VP: THomogeneousIntVector;
  WinX, WinY, WinZ: Double;
  R: TRect;
  P: TPoint;
  
begin
  Result :=  True;
  glGetDoublev(GL_MODELVIEW_MATRIX, @ModelMatrix);
  glGetDoublev(GL_PROJECTION_MATRIX, @ProjectMatrix);
  glGetIntegerv(GL_VIEWPORT, @VP);
  gluProject(Obj.Position.X, Obj.Position.Y, Obj.Position.Z, ModelMatrix, ProjectMatrix, VP, @WinX, @WinY, @WinZ);
  R :=  Rect(Vp[0], Vp[1], Vp[2], Vp[3]);
  P.x :=  Round(WinX);
  P.y :=  Round(WinY);
  if (not PtInRect(R, P)) then
    Result :=  False;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.ReadContextProperties;
begin
  FMaxLightSources := LimitOf[limLights];
  FDoubleBuffered := LimitOf[limDoubleBuffer] > 0;
  if glIsEnabled(GL_DEPTH_TEST) > 0 then Include(FCurrentStates, stDepthTest);
  if glIsEnabled(GL_CULL_FACE) > 0 then Include(FCurrentStates, stCullFace);
  if glIsEnabled(GL_LIGHTING) > 0 then Include(FCurrentStates, stLighting);
  if glIsEnabled(GL_FOG) > 0 then Include(FCurrentStates, stFog);
end;

procedure TGLSceneViewer.SetupRenderingContext;
var
   ColorDepth: Cardinal;
   NewStates: TGLStates;
begin
   ColorDepth := GetDeviceCaps(Canvas.Handle, BITSPIXEL) * GetDeviceCaps(Canvas.Handle, PLANES);
   if roTwoSideLighting in FContextOptions then
      glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE)
   else glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE);
   NewStates := [stNormalize];
   if DepthTest then Include(NewStates, stDepthTest);
   if FaceCulling then Include(NewStates, stCullFace);
   if Lighting then Include(NewStates, stLighting);
   if FogEnable then Include(NewStates, stFog);
   if ColorDepth < 24 then
      Include(NewStates, stDither)
   else Exclude(NewStates, stDither);
   RequestedState(NewStates);
   glDepthFunc(GL_LESS);
   glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
end;

//------------------------------------------------------------------------------

function TGLSceneViewer.GetLimit(Which: TLimitType): Integer;

// determine the limit of the given kind from OpenGL implementation

var
  VP: array[0..1] of Double;

begin
  case Which of
    limClipPlanes:
      glGetIntegerv(GL_MAX_CLIP_PLANES, @Result);
    limEvalOrder:
      glGetIntegerv(GL_MAX_EVAL_ORDER, @Result);
    limLights:
      glGetIntegerv(GL_MAX_LIGHTS, @Result);
    limListNesting:
      glGetIntegerv(GL_MAX_LIST_NESTING, @Result);
    limModelViewStack:
      glGetIntegerv(GL_MAX_MODELVIEW_STACK_DEPTH, @Result);
    limNameStack:
      glGetIntegerv(GL_MAX_NAME_STACK_DEPTH, @Result);
    limPixelMapTable:
      glGetIntegerv(GL_MAX_PIXEL_MAP_TABLE, @Result);
    limProjectionStack:
      glGetIntegerv(GL_MAX_PROJECTION_STACK_DEPTH, @Result);
    limTextureSize:
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @Result);
    limTextureStack:
      glGetIntegerv(GL_MAX_TEXTURE_STACK_DEPTH, @Result);
    limViewportDims:
      begin
        glGetDoublev(GL_MAX_VIEWPORT_DIMS, @VP);
        Result := Round(MaxValue(VP));
      end;
    limAccumAlphaBits:
      glGetIntegerv(GL_ACCUM_ALPHA_BITS, @Result);
    limAccumBlueBits:
      glGetIntegerv(GL_ACCUM_BLUE_BITS, @Result);
    limAccumGreenBits:
      glGetIntegerv(GL_ACCUM_GREEN_BITS, @Result);
    limAccumRedBits:
      glGetIntegerv(GL_ACCUM_RED_BITS, @Result);
    limAlphaBits:
      glGetIntegerv(GL_ALPHA_BITS, @Result);
    limAuxBuffers:
      glGetIntegerv(GL_AUX_BUFFERS, @Result);
    limDepthBits:
      glGetIntegerv(GL_DEPTH_BITS, @Result);
    limStencilBits:
      glGetIntegerv(GL_STENCIL_BITS, @Result);
    limBlueBits:
      glGetIntegerv(GL_BLUE_BITS, @Result);
    limGreenBits:
      glGetIntegerv(GL_GREEN_BITS, @Result);
    limRedBits:
      glGetIntegerv(GL_RED_BITS, @Result);
    limIndexBits:
      glGetIntegerv(GL_INDEX_BITS, @Result);
    limStereo:
      glGetIntegerv(GL_STEREO, @Result);
    limDoubleBuffer:
      glGetIntegerv(GL_DOUBLEBUFFER, @Result);
    limSubpixelBits:
      glGetIntegerv(GL_SUBPIXEL_BITS, @Result);
  else
    Result := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.Loaded;

var
  NewMode: Integer;

begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
    // set display mode depending on the different screen options
    // full screen requested?
    if DisplayOptions.FullScreen then
    begin
      // full screen mode, so check for window fitting
      case DisplayOptions.WindowFitting of
        wfFitWindowToScreen: // set screen to the specified size
          begin
            NewMode := DisplayOptions.ScreenResolution;
            if NewMode <> 0 then SetFullScreenMode(NewMode);
          end;
        wfFitScreenToWindow: // adjust screen size to window size
          begin
            NewMode := GetIndexFromResolution(Width, Height, VideoModes[0].ColorDepth);
            SetFullScreenMode(NewMode);
          end;
      end;
      Left := 0;
      Top := 0;
      ShowWindow(Handle, SW_SHOWMAXIMIZED);
    end
    else
      // no full screen mode for the application, but perhaps
      // a specific resolution or color depth?
      if DisplayOptions.ScreenResolution <> 0 then
        SetFullScreenMode(DisplayOptions.ScreenResolution);
  // initiate first draw
  FOwnRefresh := False;
  // initiate window creation
  HandleNeeded;
  if assigned(FCamera) and assigned(FCamera.FScene) then FCamera.FScene.AddViewer(Self);
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.WMSize(var Message: TWMSize);
//var
//   aPoint : TPoint;
begin
	inherited;
	{ !!!!!!!!!!!!!! Disabled !!!!!!!!!!!!!!!
	if (woTransparent in DisplayOptions.WindowAttributes) then begin
		aPoint.X := Left;
		aPoint.Y := Top;
		if (not (woDesktop in DisplayOptions.WindowAttributes))
				or (csDesigning in ComponentState) then
			aPoint := Parent.ClientToScreen(aPoint);
		with FBackground.Image do begin
			TGLCaptureImage(FBackground.Image).Left := aPoint.X;
			TGLCaptureImage(FBackground.Image).Top := aPoint.Y;
			Width := RoundUpToPowerOf2(Message.Width);
			Height := RoundUpToPowerOf2(Message.Height);
		end;
	end; }
	// define viewport
	if FRenderingContext <> 0 then begin
		ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
      try
         with FViewPort do begin
            Width := Message.Width;
            Height := Message.Height;
				if Height = 0 then Height := 1;
				glViewport(0, 0, Width, Height);
			end;
		finally
			DeactivateRenderingContext;
		end;
	end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.WMPaint(var Message: TWMPaint);
var
   PS : TPaintStruct;
begin
   BeginPaint(Handle, PS);
   try
      Render;
   finally
      EndPaint(Handle, PS);
      Message.Result := 0;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.RenderToFile(const AFile: String; DPI: Integer);

var
  ABitmap: TBitmap;
  SaveDialog: TSavePictureDialog;
  SaveAllowed: Boolean;
  FName: String;

begin
  if FState = dsNone then
  begin
    SaveDialog := nil;
    ABitmap := TBitmap.Create;
    try
      ABitmap.Width := Width;
      ABitmap.Height := Height;
      ABitmap.PixelFormat := pf24Bit;
      RenderToBitmap(ABitmap, DPI);
      FState := dsRendering;
      FName := AFile;
      SaveAllowed := True;
      if FName = '' then
      begin
        SaveDialog := TSavePictureDialog.Create(Application);
        with SaveDialog do
        begin
          Options := [ofHideReadOnly, ofNoReadOnlyReturn];
          SaveAllowed := Execute;
        end;
      end;
      if SaveAllowed then
      begin
        if FName = '' then
        begin
          FName := SaveDialog.FileName;
          if (FileExists(SaveDialog.FileName)) then
            SaveAllowed := MessageDlg(Format('Overwrite file %s?', [SaveDialog.FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes;
        end;
        if SaveAllowed then ABitmap.SaveToFile(FName);
      end;
    finally
      SaveDialog.Free;
      ABitmap.Free;
      FState := dsNone;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.Invalidate;

begin
  FOwnRefresh := True;
  inherited Invalidate;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SetViewPort(X, Y, W, H: Integer);

begin
  with FViewPort do
  begin
    Left := X;
    Top := Y;
    Width := W;
    Height := H;
  end;
  Perform(WM_SIZE, SIZE_RESTORED, MakeLong(Width, Height));
  if not (csReading in ComponentState) then Invalidate;
end;

//------------------------------------------------------------------------------

procedure SetupStates(NeededStates: TGLStates);

begin
  if stAlphaTest      in NeededStates then
    glEnable(GL_ALPHA_TEST);
  if stAutoNormal     in NeededStates then
    glEnable(GL_AUTO_NORMAL);
  if stBlend          in NeededStates then
    glEnable(GL_BLEND);
  if stColorMaterial  in NeededStates then
    glEnable(GL_COLOR_MATERIAL);
  if stCullFace       in NeededStates then
    glEnable(GL_CULL_FACE);
  if stDepthTest      in NeededStates then
    glEnable(GL_DEPTH_TEST);
  if stDither         in NeededStates then
    glEnable(GL_DITHER);
  if stFog            in NeededStates then
    glEnable(GL_FOG);
  if stLighting       in NeededStates then
    glEnable(GL_LIGHTING);
  if stLineSmooth     in NeededStates then
    glEnable(GL_LINE_SMOOTH);
  if stLineStipple    in NeededStates then
    glEnable(GL_LINE_STIPPLE);
  if stLogicOp        in NeededStates then
    glEnable(GL_LOGIC_OP);
  if stNormalize      in NeededStates then
    glEnable(GL_NORMALIZE);
  if stPointSmooth    in NeededStates then
    glEnable(GL_POINT_SMOOTH);
  if stPolygonSmooth  in NeededStates then
    glEnable(GL_POLYGON_SMOOTH);
  if stPolygonStipple in NeededStates then
    glEnable(GL_POLYGON_STIPPLE);
  if stScissorTest    in NeededStates then
    glEnable(GL_SCISSOR_TEST);
  if stStencilTest    in NeededStates then
    glEnable(GL_STENCIL_TEST);
  if stTexture1D      in NeededStates then
	 glEnable(GL_TEXTURE_1D);
  if stTexture2D      in NeededStates then
    glEnable(GL_TEXTURE_2D);
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.RenderToBitmap(ABitmap: TBitmap; DPI: Integer);
var
   BitmapContext: HGLRC;
   BackColor: TColorVector;
   ColorBits: Integer;
   Viewport: TRectangle;
   LastStates: TGLStates;
   Resolution: Integer;
begin
   Assert(FState=dsNone);
   FState := dsPrinting;
   try
      case ABitmap.PixelFormat of
         pfCustom, pfDevice :  // use current color depth
            ColorBits := VideoModes[CurrentVideoMode].ColorDepth;
         pf1bit, pf4bit : // OpenGL needs at least 4 bits
            ColorBits := 4;
         pf8bit : ColorBits := 8;
         pf15bit : ColorBits := 15;
         pf16bit : ColorBits := 16;
         pf24bit : ColorBits := 24;
         pf32bit : ColorBits := 32;
      else
         ColorBits := 24;
      end;
      BitmapContext := CreateRenderingContext(ABitmap.Canvas.Handle, [], ColorBits, 0, 0, 0, 0);
      Assert(BitmapContext<>0);
      try
         lastStates := FCurrentStates;
         ActivateRenderingContext(ABitmap.Canvas.Handle, BitmapContext);
         try
            // save current window context states
            SetupStates(FCurrentStates);
            if roTwoSideLighting in FContextOptions then
               glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE)
            else glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE);
            glEnable(GL_NORMALIZE);
            BackColor := ConvertWinColor(FBackgroundColor);
            glClearColor(BackColor[0], BackColor[1], BackColor[2], BackColor[3]);
            if (woTransparent in DisplayOptions.WindowAttributes) then
               FBackground.ReloadImage;
            // set the desired viewport and limit output to this rectangle
            with Viewport do begin
               Left := 0;
               Top := 0;
               Width := ABitmap.Width;
               Height := ABitmap.Height;
               glViewport(Left, Top, Width, Height);
            end;
            ClearBuffers;
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity;
            Resolution := DPI;
            if Resolution = 0 then
               Resolution := GetDeviceCaps(ABitmap.Canvas.Handle, LOGPIXELSX);
            FCamera.ApplyPerspective(Viewport, ABitmap.Width, ABitmap.Height, Resolution);
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity;
            // start rendering
            if Assigned(FBeforeRender) then FBeforeRender(Self);
            if Assigned(FCamera) and Assigned(FCamera.FScene) then with FCamera.FScene do begin
               ValidateTransformation(Camera);
               SetupLights(FMaxLightSources);
               Objects.ReloadTexture;
               Objects.DestroyList;
               FogEnvironment.ApplyFog;
               RenderScene(Self);
               Objects.DestroyList;
            end;
            if assigned(FAfterRender) then FAfterRender(Self);
            glFinish;
         finally
            DeactivateRenderingContext;
            FCurrentStates := LastStates;
         end;
      finally
         DestroyRenderingContext(BitmapContext);
      end;
   finally
      FState := dsNone;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.RequestedState(States: TGLStates);

var
  NeededStates: TGLStates;

begin
  // create window and rendering context if not yet done
  HandleNeeded;

  // get all states, which are requested but not yet set
  NeededStates := States - FCurrentStates;
  if NeededStates <> [] then
  begin
    SetupStates(NeededStates);
    FCurrentStates := FCurrentStates + NeededStates;
  end;
end;

// ShowInfo
//
procedure TGLSceneViewer.ShowInfo;
var
   infoForm: TInfoForm;
begin
   Application.CreateForm(TInfoForm, infoForm);
   try
      ActivateRenderingContext(Canvas.Handle, FRenderingContext);
      // most info is available with active context only
      try
         infoForm.GetInfoFrom(Self);
      finally
         DeactivateRenderingContext;
      end;
      infoForm.ShowModal;
   finally
      infoForm.Free;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.UnnecessaryState(States: TGLStates);

var
  TakeOutStates: TGLStates;

begin
  // create window and rendering context if not yet done
  HandleNeeded;

  // get all states, which are to be taken out, but still set
  TakeOutStates := States * FCurrentStates;
  if TakeOutStates <> [] then
  begin
    // now reset all these states
    if stAlphaTest      in TakeOutStates then
      glDisable(GL_ALPHA_TEST);
    if stAutoNormal     in TakeOutStates then
      glDisable(GL_AUTO_NORMAL);
    if stBlend          in TakeOutStates then
      glDisable(GL_BLEND);
    if stColorMaterial  in TakeOutStates then
      glDisable(GL_COLOR_MATERIAL);
    if stCullFace       in TakeOutStates then
      glDisable(GL_CULL_FACE);
    if stDepthTest      in TakeOutStates then
      glDisable(GL_DEPTH_TEST);
    if stDither         in TakeOutStates then
      glDisable(GL_DITHER);
    if stFog            in TakeOutStates then
      glDisable(GL_FOG);
    if stLighting       in TakeOutStates then
      glDisable(GL_LIGHTING);
    if stLineSmooth     in TakeOutStates then
      glDisable(GL_LINE_SMOOTH);
    if stLineStipple    in TakeOutStates then
      glDisable(GL_LINE_STIPPLE);
    if stLogicOp        in TakeOutStates then
      glDisable(GL_LOGIC_OP);
    if stNormalize      in TakeOutStates then
      glDisable(GL_NORMALIZE);
    if stPointSmooth    in TakeOutStates then
      glDisable(GL_POINT_SMOOTH);
    if stPolygonSmooth  in TakeOutStates then
      glDisable(GL_POLYGON_SMOOTH);
    if stPolygonStipple in TakeOutStates then
      glDisable(GL_POLYGON_STIPPLE);
    if stScissorTest    in TakeOutStates then
      glDisable(GL_SCISSOR_TEST);
    if stStencilTest    in TakeOutStates then
      glDisable(GL_STENCIL_TEST);
	 if stTexture1D      in TakeOutStates then
		glDisable(GL_TEXTURE_1D);
    if stTexture2D      in TakeOutStates then
      glDisable(GL_TEXTURE_2D);

    FCurrentStates := FCurrentStates - TakeOutStates;
  end;
end;

// ResetPerformanceMonitor
//
procedure TGLSceneViewer.ResetPerformanceMonitor;
begin
  FFramesPerSecond := 0;
  FFrames := 0;
  FTicks := 0;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.ClearBuffers;

type
  PPixelArray  = ^TByteVector;

var
  BufferBits: TGLBitfield;

begin
  // handle transparency simulation
  if (woTransparent in DisplayOptions.WindowAttributes) then
  begin
    glPushAttrib(GL_ENABLE_BIT);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
    glDisable(GL_DITHER);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    // Invalidate initiated by the scene itself?
//    if not FOwnRefresh then FBackground.Image.Invalidate;
    FBackground.DisableAutoTexture;
    FBackground.Apply;
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix;
    glLoadIdentity;
    glMatrixMode(GL_PROJECTION);
    glPushMatrix;
    glLoadIdentity;
    glOrtho(0, Width - 1, 0, Height - 1, 0, 100);
    glFrontFace(GL_CCW);
    glBegin(GL_QUADS);
      glTexCoord2f(0, 1 - Height / FBackground.Image.Height);
      glVertex3f(0, 0, 0);

      glTexCoord2f(Width / FBackground.Image.Width, 1 - Height / FBackground.Image.Height);
      glVertex3f(Width - 1, 0, 0);

      glTexCoord2f(Width/FBackground.Image.Width, 1);
      glVertex3f(Width - 1, Height - 1, 0);

      glTexCoord2f(0, 1);
      glVertex3f(0, Height - 1, 0);
    glEnd;
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix;
    glMatrixMode(GL_PROJECTION);
    glPopMatrix;
    glPopAttrib;
  end;
  FOwnRefresh := False;

  BufferBits := 0;
  if (buColor in Buffers) and not (woTransparent in DisplayOptions.WindowAttributes) then
    BufferBits := GL_COLOR_BUFFER_BIT;
  if buDepth in Buffers then BufferBits :=  BufferBits or GL_DEPTH_BUFFER_BIT;
  if buStencil in Buffers then BufferBits :=  BufferBits or GL_STENCIL_BUFFER_BIT;
  if buAccum   in Buffers then BufferBits := BufferBits or GL_ACCUM_BUFFER_BIT;
  if BufferBits <> 0 then glClear(BufferBits);
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FCamera) then Camera := nil;
end;

// PickObjects
//
procedure TGLSceneViewer.PickObjects(const Rect: TRect; PickList: TGLPickList;
												 objectCountGuess: Integer);
var
   buffer : PCardinalVector;
   hits : Integer;
   i : Integer;
   current, next : Cardinal;
   szmin, szmax : Single;
begin
	Assert((FState = dsNone));
   Assert(Assigned(PickList));
   ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
   FState := dsPicking;
   try
      glMatrixMode(GL_PROJECTION);
      glPushMatrix;
      buffer := nil;
      try
			glLoadIdentity;
			gluPickMatrix(Rect.Left, Height - Rect.Top,
							  Abs(Rect.Right - Rect.Left), Abs(Rect.Bottom - Rect.Top),
							  TVector4i(FViewport));
			FCamera.ApplyPerspective(FViewport, Width, Height,
											 GetDeviceCaps(Canvas.Handle, LOGPIXELSX));
			// check countguess, memory waste is not an issue here
         if objectCountGuess<8 then objectCountGuess:=8;
         hits:=-1;
         repeat
				if hits < 0 then begin
               // Allocate 4 integers per row (Egg : dunno why 4)
               // Add 32 integers of slop (an extra cache line) to end for buggy
					// hardware that uses DMA to return select results but that sometimes
               // overrun the buffer.  Yuck.
               ReallocMem(buffer, objectCountGuess * 4 * SizeOf(Integer) + 32 * 4);
               // increase buffer by 50% if we get nothing
               Inc(objectCountGuess, objectCountGuess shr 1);
            end;
            // pass buffer to opengl and prepare render
            glSelectBuffer(objectCountGuess*4, @Buffer^);
            glRenderMode(GL_SELECT);
				glInitNames;
            glPushName(0);
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity;
            // render the scene (in select mode, nothing is drawn)
            if Assigned(FCamera) and Assigned(FCamera.FScene) then
               with FCamera.FScene do begin
                  ValidateTransformation(Camera);
                  RenderScene(Self);
               end;
            glFlush;
            Hits := glRenderMode(GL_RENDER);
			until Hits > -1; // try again with larger selection buffer
         Next := 0;
			PickList.Clear;
         PickList.Capacity := Hits;
         for I := 0 to Hits-1 do begin
            Current := Next;
            Next := Current + Buffer[Current] + 3;
            szmin := (Buffer[current + 1] shr 1) / MaxInt;
            szmax := (Buffer[current + 2] shr 1) / MaxInt;
				PickList.AddHit(TGLCustomSceneObject(Buffer[Current + 3]), szmin, szmax);
         end;
      finally
         FreeMem(Buffer);
         glMatrixMode(GL_PROJECTION);
         glPopMatrix;
      end;
   finally
      FState := dsNone;
      DeactivateRenderingContext;
   end;
end;

// GetPickedObjects
//
function TGLSceneViewer.GetPickedObjects(const Rect: TRect; objectCountGuess : Integer = 64) : TGLPickList;
begin
	Result:=TGLPickList.Create(psMinDepth);
	PickObjects(Rect, Result, objectCountGuess);
end;

// GetPickedObject
//
function TGLSceneViewer.GetPickedObject(x, y : Integer) : TGLBaseSceneObject;
var
	pkList : TGLPickList;
begin
	pkList:=GetPickedObjects(Rect(x-1, y-1, x+1, y+1));
	try
		if pkList.Count>0 then
			Result:=pkList.Hit[0]
		else Result:=nil;
	finally
		pkList.Free;
	end;
end;

//------------------------------------------------------------------------------

{function TGLSceneViewer.GetLandsHeight(X, Y: TGLfloat): TGLfloat;

begin
  Result :=  LandScape.Get_Height(X, Y);
end;}

//------------------------------------------------------------------------------

procedure TGLSceneViewer.Render;
var
   Counter1, Counter2: TLargeInteger;
begin
	if (not visible) or (FState<>dsNone) then Exit;
   ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
   FState := dsRendering;
   try
      // performance data demanded?
      if FMonitor then QueryPerformanceCounter(Counter1);
      // clear the buffers
      ClearBuffers;
      // setup rendering stuff
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      if assigned(FCamera) then
         FCamera.ApplyPerspective(FViewport, Width, Height,
                                  GetDeviceCaps(Canvas.Handle, LOGPIXELSX));
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity;
      // rendering
      if Assigned(FBeforeRender) then FBeforeRender(Self);
      if Assigned(FCamera) and Assigned(FCamera.FScene) then with FCamera.FScene do begin
         ValidateTransformation(FCamera);
//         if spLandScape in FSpecials then
//            LandScape.RenderLandScape(FCamera);
         SetupLights(FMaxLightSources);
         FogEnvironment.ApplyFog;
         RenderScene(Self);
{ TODO : lensFlares rendering : two different "afterrender" events will be needed }
         if Assigned(FAfterRender) then FAfterRender(Self);
//         if spLensFlares in FSpecials then
//            Camera.Scene.DoAfterRender;
      end;
      glFlush;
      if FDoubleBuffered then SwapBuffers(Canvas.Handle);
      {$ifdef DEBUG} CheckOpenGLError; {$endif}

      // performance data demanded?
      if FMonitor then begin
         // yes, calculate average frames per second...
         Inc(FFrames);
         if FFrames > 1 then begin // ...but leave out the very first frame
            QueryPerformanceCounter(Counter2);
            // in second run take an 'average' value for the first run into account
            // by simply using twice the time from this run
            if FFrames = 2 then
               FTicks := FTicks + 2 * (Counter2 - Counter1)
            else FTicks := FTicks + Counter2 - Counter1;
            if FTicks > 0 then
               FFramesPerSecond := FFrames * CounterFrequency / FTicks;
         end;
      end;
   finally
      FState := dsNone;
      DeactivateRenderingContext;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.CreateWnd;
var
   BackColor: TColorVector;
   Options: TRCOptions;
begin
	inherited CreateWnd;
	FCanvas.Handle := GetDC(Handle);
	// initialize and activate the OpenGL rendering context
	// need to do this only once per window creation as we have a private DC
	FState := dsRendering;
	try
		Options := [];
		if roDoubleBuffer in ContextOptions then Include(Options, opDoubleBuffered);
		// will be freed in DestroyWnd
		FRenderingContext := CreateRenderingContext(Canvas.Handle, Options, 32, 0, 0, 0, 0);
		Assert(FRenderingContext<>0);
		ActivateRenderingContext(Canvas.Handle, FRenderingContext);
		try
			// this one should not be replaced with an assert
			if not GL_VERSION_1_1 then
				raise EOpenGLError.Create(glsWrongVersion);
			FBuffers := [buColor, buDepth];
			// define viewport, this is necessary because the first WM_SIZE message
			// is posted before the rendering context has been created
			with FViewPort do begin
				Left := 0;
				Top := 0;
				Width := Self.Width;
				Height := Self.Height;
            glViewport(0, 0, Width, Height);
         end;
         // set up initial context states
         if FSaveStates <> [] then begin
            // might be a recreated window, so reset all states which where
            // activated when the window was destroyed
            SetupStates(FSaveStates);
            FCurrentStates := FSaveStates;
            FSaveStates := [];
         end else begin
            ReadContextProperties;
            SetupRenderingContext;
         end;
         BackColor := ConvertWinColor(FBackgroundColor);
         glClearColor(BackColor[0], BackColor[1], BackColor[2], BackColor[3]);
      finally
         DeactivateRenderingContext;
         if woStayOnTop in DisplayOptions.WindowAttributes then
				SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
                         SWP_NOCOPYBITS or SWP_NOMOVE or SWP_NOSIZE);
         FOwnRefresh := False;
      end;
   finally
      FState := dsNone;
   end;
end;

procedure TGLSceneViewer.DestroyWnd;
begin
  FSaveStates := FCurrentStates;
  FBackground.DestroyHandle;
  // free the rendering context
  DestroyRenderingContext(FRenderingContext);
  FRenderingContext := 0;
  inherited DestroyWnd;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SetBackgroundColor(AColor: TColor);
var
   backColor: TColorVector;
begin
   if FBackgroundColor <> AColor then begin
      FBackgroundColor := AColor;
      if not (csReading in ComponentState) then begin
         backColor := ConvertWinColor(FBackgroundColor);
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            glClearColor(BackColor[0], BackColor[1], BackColor[2], BackColor[3]);
         finally
            DeactivateRenderingContext;
         end;
         Invalidate;
      end;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SeTGLCamera(ACamera: TGLCamera);

begin
  if FCamera <> ACamera then
  begin
    if assigned(FCamera) then
    begin
      if assigned(FCamera.FScene) then
        FCamera.FScene.RemoveViewer(Self);
      FCamera := nil;
    end;
    if assigned(ACamera) and assigned(ACamera.FScene) then
    begin
      FCamera := ACamera;
      Include(FCamera.FChanges, ocTransformation);
      if not (csLoading in ComponentState) then
      begin
        RecreateWnd;
        HandleNeeded;
        ACamera.FScene.AddViewer(Self);
      end;
    end;
    Invalidate;
  end;
end;

procedure TGLSceneViewer.SetContextOptions(Options: TContextOptions);
begin
   if FContextOptions<>Options then begin
      FContextOptions:=Options;
      Invalidate;
   end;
end;

procedure TGLSceneViewer.SetDepthTest(AValue: Boolean);
begin
   if FDepthTest <> AValue then begin
      FDepthTest := AValue;
      if not (csReading in ComponentState) then begin
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            if AValue then
               RequestedState([stDepthTest])
            else UnnecessaryState([stDepthTest]);
         finally
            DeactivateRenderingContext;
         end;
         Invalidate;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SetFaceCulling(AValue: Boolean);
begin
   if FFaceCulling <> AValue then begin
      FFaceCulling := AValue;
      if not (csReading in ComponentState) then begin
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            if AValue then
               RequestedState([stCullFace])
            else UnnecessaryState([stCullFace]);
         finally
            DeactivateRenderingContext;
         end;
         Invalidate;
      end;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SetLighting(AValue: Boolean);
begin
   if FLighting <> AValue then begin
      FLighting := AValue;
      if not (csReading in ComponentState) then begin
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            if AValue then
               RequestedState([stLighting])
            else UnnecessaryState([stLighting]);
         finally
            DeactivateRenderingContext;
         end;
         Invalidate;
      end;
   end;
end;

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SetFogEnable(AValue: Boolean);
begin
   if FFogEnable <> AValue then begin
      FFogEnable := AValue;
      if not (csReading in ComponentState) then begin
         ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
         try
            FFogEnvironment.NotifyChange;
            if AValue then
               RequestedState([stFog])
            else UnnecessaryState([stFog]);
         finally
            DeactivateRenderingContext;
         end;
         Invalidate;
      end;
   end;
end;

//------------------------------------------------------------------------------

{procedure TGLSceneViewer.SetSpecials(Value: TSpecials);
begin
   if FSpecials <> Value then begin
      FSpecials :=  Value;
      Invalidate;
   end;
end; }

//------------------------------------------------------------------------------

procedure TGLSceneViewer.SeTGLFogEnvironment(AValue: TGLFogEnvironment);
begin
   ActivateRenderingContext(FCanvas.Handle, FRenderingContext);
   try
      FFogEnvironment.Assign(AValue);
      FFogEnvironment.NotifyChange;
   finally
      DeactivateRenderingContext;
   end;
   Invalidate;
end;

//------------------------------------------------------------------------------


initialization

  RegisterClasses([TGLLightSource, TGLCamera]);

  // preparation for high resolution timer
  if not QueryPerformanceFrequency(CounterFrequency) then CounterFrequency := 0;

finalization

end.
