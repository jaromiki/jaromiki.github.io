{: GLObjects<p>

   Implementation of scene objects plus some management routines.<p>

	<b>Historique : </b><font size=-1><ul>
      <li>24/03/00 - Egg - Added Rotation to TSprite, fixed sprite size
		<li>20/03/00 - Egg - Enhanced FontManager
		<li>17/03/00 - Egg - Fixed SpaceText glBaseList bug,
									TSprite now uses a transposition of the globalmatrix
		<li>16/03/00 - Egg - Enhanced TFontManager to allow lower quality 
		<li>14/03/00 - Egg - Added subobjects Barycenter support for TDummyCube
      <li>09/02/00 - Egg - ObjectManager stuff moved to GLSceneRegister,
                           FreeForm and vector file stuff moved to new GLVectorFileObjects
      <li>08/02/00 - Egg - Added TDummyCube
      <li>05/02/00 - Egg - Javadocisation, fixes and enhancements :<br>
                           TVertexList.AddVertex, "default"s to properties
   </ul></font>
}
unit GLObjects;

// GLObjects   - implementation of scene objects plus some management routines
// version     - 0.5.8
// 05-JAN-2000 ml: adjustment of loader routine for 3DS files
// 04-JAN-2000 ml: included new 3DS classes

{$R-}

interface

uses Windows, Classes, Geometry, GLScene, GLTexture, GLMisc,
	  Graphics, OpenGL12, SysUtils, extctrls;

type  PNormal    = ^TNormal;
		TNormal    = TAffineVector;

		PVertex    = ^TVertex;
		TVertex    = TAffineVector;

		// used to describe what kind of winding has a front face
		TFaceWinding       = (fwCounterClockWise, fwClockWise);

	// TDummyCube
	//
	{: A simple cube, invisible at run-time.<p>
		DummyCube's barycenter is their children's barycenter. }
	TDummyCube = class (TGLImmaterialSceneObject)
		private
			{ Private Declarations }
			FCubeSize : TGLFloat;
			FEdgeColor : TGLColor;
			FVisibleAtRunTime : Boolean;

		protected
			{ Protected Declarations }
			procedure SetCubeSize(const val : TGLFloat);
			procedure SetEdgeColor(const val : TGLColor);
			procedure SetVisibleAtRunTime(const val : Boolean);

		public
			{ Public Declarations }
			constructor Create(AOwner : TComponent); override;

			procedure BuildList; override;
			function BarycenterAbsolutePosition : TVector; override;

		published
			{ Published Declarations }
			property CubeSize : TGLFloat read FCubeSize write SetCubeSize;
			property EdgeColor : TGLColor read FEdgeColor write SetEdgeColor;
			property VisibleAtRunTime : Boolean read FVisibleAtRunTime write SetVisibleAtRunTime default False;

	end;

   // Plane
   //
	TPlane = class (TGLSceneObject)
	   private
			{ Private Declarations }
	      FXOffset, FYOffset : TGLFloat;
			FWidth, FHeight : TGLFloat;
		   FXTiles, FYTiles: Cardinal;

		protected
			{ Protected Declarations }
		   procedure SetHeight(AValue: TGLFloat);
		   procedure SetWidth(AValue: TGLFloat);
		   procedure SetXOffset(const Value: TGLFloat);
		   procedure SetXTiles(const Value: Cardinal);
		   procedure SetYOffset(const Value: TGLFloat);
		   procedure SetYTiles(const Value: Cardinal);

		public
			{ Public Declarations }
			constructor Create(AOwner: TComponent); override;

		   procedure BuildList; override;

		   procedure Assign(Source: TPersistent); override;

		published
			{ Public Declarations }
			property Height: TGLFloat read FHeight write SetHeight;
         property Width: TGLFloat read FWidth write SetWidth;
         property XOffset: TGLFloat read FXOffset write SetXOffset;
         property XTiles: Cardinal read FXTiles write SetXTiles default 1;
         property YOffset: TGLFloat read FYOffset write SetYOffset;
         property YTiles: Cardinal read FYTiles write SetYTiles default 1;
   end;

	// Sprite
	//
	{: A rectangular area, perspective projected, but always facing the camera. }
	TSprite = class (TGLSceneObject)
		private
			{ Private Declarations }
			FWidth : TGLFloat;
			FHeight : TGLFloat;
         FRotation : TGLFloat;

		protected
			{ Protected Declarations }
			//: Sprite build list is rebuilt at each render
			function GetHandle : TObjectHandle; override;
			procedure SetWidth(const val : TGLFloat);
			procedure SetHeight(const val : TGLFloat);
         procedure SetRotation(const val : TGLFloat);

		public
			{ Public Declarations }
			constructor Create(AOwner: TComponent); override;

			procedure BuildList; override;

			procedure SetSize(const width, height : TGLFloat);
			//: Set width and height to "size"
			procedure SetSquareSize(const size : TGLFloat);

		published
			{ Public Declarations }
			property Width : TGLFloat read FWidth write SetWidth;
			property Height : TGLFloat read FHeight write SetHeight;
         {: This the ON-SCREEN rotation of the sprite.<p>
            Ratotation=0 is handled faster. }
         property Rotation : TGLFloat read FRotation write SetRotation;
	end;

	TCubePart  = (cpTop, cpBottom, cpFront, cpBack, cpLeft, cpRight);
	TCubeParts = set of TCubePart;

		TCube = class (TGLSceneObject)
		private
		  FCubeWidth,
        FCubeHeight,
        FCubeDepth  : TGLFloat;
		  FParts      : TCubeParts;
        FNormalDirection : TNormalDirection;
        procedure SetCubeWidth(AValue: TGLFloat);
        procedure SetCubeHeight(AValue: TGLFloat);
        procedure SetCubeDepth(AValue: TGLFloat);
        procedure SetParts(AValue: TCubeParts);
        procedure SetNormalDirection(AValue: TNormalDirection);

      protected
         procedure DefineProperties(Filer: TFiler); override;
         procedure ReadData(Stream: TStream);
         procedure WriteData(Stream: TStream);
         
      public
		  constructor Create(AOwner: TComponent); override;
		  procedure BuildList; override;
        procedure Assign(Source: TPersistent); override;

      published
        property CubeWidth: TGLFloat read FCubeWidth write SetCubeWidth stored False;
        property CubeHeight: TGLFloat read FCubeHeight write SetCubeHeight stored False;
        property CubeDepth: TGLFloat read FCubeDepth write SetCubeDepth stored False;
        property NormalDirection: TNormalDirection read FNormalDirection write SetNormalDirection default ndOutside;
        property Parts: TCubeParts read FParts write SetParts default [cpTop, cpBottom, cpFront, cpBack, cpLeft, cpRight];
      end;

      TQuadricNormal = (qnFlat, qnSmooth, qnNone);

      TQuadricObject = class(TGLSceneObject)
      private
        FNormals : TQuadricNormal;
        FNormalDirection : TNormalDirection;
		  procedure SetNormals(AValue: TQuadricNormal);
        procedure SetNormalDirection(AValue: TNormalDirection);
        procedure SetupQuadricParams(Quadric: PGLUquadricObj);
      public
        constructor Create(AOwner: TComponent);override;
        procedure Assign(Source:TPersistent);override;
      published
        property Normals:TQuadricNormal read FNormals write SetNormals default qnSmooth;
        property NormalDirection:TNormalDirection read FNormalDirection write SetNormalDirection default ndOutside;
      end;

      TAngleLimit1 = -90..90;
      TAngleLimit2 = 0..360;
      TCapType = (ctNone, ctCenter, ctFlat);

      TSphere = class (TQuadricObject)
      private
        FRadius  : TGLFloat;
        FSlices, 
        FStacks  : TGLInt;
        FTop     : TAngleLimit1;
        FBottom  : TAngleLimit1;
        FStart   : TAngleLimit2;
        FStop    : TAngleLimit2;
        FTopCap, 
        FBottomCap : TCapType;
        procedure SetBottom(AValue: TAngleLimit1);
        procedure SetBottomCap(AValue: TCapType);
        procedure SetRadius(AValue: TGLFloat);
        procedure SetSlices(AValue: TGLInt);
        procedure SetStart(AValue: TAngleLimit2);
        procedure SetStop(AValue: TAngleLimit2);
        procedure SetStacks(AValue: TGLInt);
        procedure SetTop(AValue: TAngleLimit1);
        procedure SetTopCap(AValue: TCapType);
      public
        constructor Create(AOwner:TComponent); override;
        procedure BuildList; override;
        procedure Assign(Source:TPersistent); override;
      published
        property Bottom: TAngleLimit1 read FBottom write SetBottom default -90;
        property BottomCap: TCapType read FBottomCap write SetBottomCap default ctNone;
        property Radius: TGLFloat read FRadius write SetRadius;
        property Slices: TGLInt read FSlices write SetSlices default 16;
        property Stacks: TGLInt read FStacks write SetStacks default 16;
        property Start: TAngleLimit2 read FStart write SetStart default 0;
        property Stop: TAngleLimit2 read FStop write SetStop default 360;
        property Top: TAngleLimit1 read FTop write SetTop default 90;
        property TopCap: TCapType read FTopCap write SetTopCap default ctNone;
      end;

      TDisk = class(TQuadricObject)
      private
        FStartAngle, 
        FSweepAngle, 
        FOuterRadius,
        FInnerRadius : TGLFloat;
        FSlices,
        FLoops       : TGLInt;
        procedure SetOuterRadius(AValue: TGLFloat);
        procedure SetInnerRadius(AValue: TGLFloat);
        procedure SetSlices(AValue: TGLInt);
        procedure SetLoops(AValue: TGLInt);
        procedure SetStartAngle(AValue: TGLFloat);
        procedure SetSweepAngle(AValue: TGLFloat);
      public
        constructor Create(AOwner: TComponent); override;
        procedure BuildList; override;
        procedure Assign(Source: TPersistent); override;
      published
        property InnerRadius: TGLFloat read FInnerRadius write SetInnerRadius;
        property Loops: TGLInt read FLoops write SetLoops default 16;
        property OuterRadius: TGLFloat read FOuterRadius write SetOuterRadius;
        property Slices: TGLInt read FSlices write SetSlices default 16;
        property StartAngle: TGLFloat read FStartAngle write SetStartAngle;
        property SweepAngle: TGLFloat read FSweepAngle write SetSweepAngle;
      end;

      TCylinderBase = class(TQuadricObject)
      private
        FBottomRadius : TGLFloat;
        FSlices, 
        FStacks  : TGLInt;
        FHeight  : TGLFloat;
        procedure SetBottomRadius(AValue: TGLFloat);
        procedure SetHeight(AValue: TGLFloat);
        procedure SetSlices(AValue: TGLInt);
        procedure SetStacks(AValue: TGLInt);
      public
        constructor Create(AOwner: TComponent); override;
        procedure Assign(Source: TPersistent); override;
      published
        property BottomRadius: TGLFloat read FBottomRadius write SetBottomRadius;
        property Height: TGLFloat read FHeight write SetHeight;
        property Slices: TGLInt read FSlices write SetSlices default 16;
        property Stacks: TGLInt read FStacks write SetStacks default 16;
      end;

      TConePart  = (coSides, coBottom);
      TConeParts = set of TConePart;

      TCone = class(TCylinderBase)
      private
        FParts : TConeParts;
        procedure SetParts(AValue: TConeParts);
      public
        constructor Create(AOwner: TComponent); override;
        procedure BuildList; override;
        procedure Assign(Source: TPersistent); override;
      published
        property Parts:TConeParts read FParts Write SetParts default [coSides, coBottom];
      end;

      TCylinderPart = (cySides, cyBottom, cyTop);
      TCylinderParts = set of TCylinderPart;

      TCylinder = class(TCylinderBase)
      private
        FParts     : TCylinderparts;
        FTopRadius : TGLFloat;
        procedure SetTopRadius(AValue: TGLFloat);
        procedure SetParts(AValue: TCylinderParts);
      public
        constructor Create(AOwner: TComponent); override;
        procedure BuildList; override;
        procedure Assign(Source: TPersistent); override;
      published
        property TopRadius: TGLFloat read FTopRadius write SetTopRadius;
        property Parts: TCylinderParts read FParts Write SetParts default [cySides, cyBottom, cyTop];
      end;

   TVertexList = class(TGLUpdateAbleObject)
      private
         FValues : PFloatVector;
         FSize   : Integer;
         FOwnerScene : TGLSceneObject;
         FEntrySize : Integer;

         function GetCount: Integer;
         function GetFirstEntry: PGLFloat;
         function GetFirstColor: PGLFLoat;
         function GetFirstNormal: PGLFLoat;
         function GetFirstVertex: PGLFLoat;
         procedure ReadItems(Reader: TReader);
         procedure WriteItems(Writer: TWriter);

      protected
         procedure DefineProperties(Filer: TFiler); override;

      public
         constructor Create(AOwner: TPersistent); override;
         destructor Destroy; override;

         {: Adds a vertex to the list.<p>
            These one is faster, use the NullVector, NullHmgVector or NullTexPoint
            constants for params you don't want to set. }
         procedure AddVertex(const vertex: TVertex; const normal: TNormal;
                             const color: TColorVector; const texPoint: TTexPoint); overload;
         {: Adds a vertex to the list, no texturing ccord version.<p> }
         procedure AddVertex(const vertex: TVertex; const normal: TNormal;
                             const color: TColorVector); overload;
         procedure Assign(Source: TPersistent); override;
         procedure Clear;
         property Count: Integer read GetCount;
         property EntrySize: Integer read FEntrySize;
         property FirstColor: PGLFloat read GetFirstColor;
         property FirstEntry: PGLFLoat read GetFirstEntry;
         property FirstNormal: PGLFloat read GetFirstNormal;
         property FirstVertex: PGLFloat read GetFirstVertex;
         property Size: Integer read FSize;
   end;

      TMeshMode = (mmTriangleStrip, mmTriangleFan, mmTriangles,
                   mmQuadStrip, mmQuads, mmPolygon);
      TVertexMode = (vmV, vmVN, vmVNC, vmVNCT);

      TMesh = class(TGLSceneObject)
      private
        FVertices   : TVertexList;
        FMode       : TMeshMode;
        FVertexMode : TVertexMode;
        procedure SetMode(AValue: TMeshMode);
        procedure SetVertices(AValue: TVertexList);
        procedure SetVertexMode(AValue: TVertexMode);
        function  CalcPlaneNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3: TGLFloat): TAffineFltVector;
      public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;
        procedure Assign(Source: TPersistent); override;
        procedure BuildList; override;
        procedure CalcNormals(Frontface: TFaceWinding);
        property Vertices: TVertexList read FVertices write SetVertices;
      published
        property Mode: TMeshMode read FMode write SetMode;
        property VertexMode: TVertexMode read FVertexMode write SetVertexMode default vmVNCT;
      end;

      TVertexStorage = (vsCopy, vsReference, vsHandOver);

      PFaceGroup = ^TFaceGroup;
      TFaceGroup = record
                    FaceProperties : TGLFaceProperties;
                    IndexCount     : Cardinal;
                    Indices        : PIntegerArray;
                  end;

      TFaceGroups = class(TList)
      private
        function GetFaceGroup(Index: Integer): PFaceGroup;
      public
        procedure Clear; override;
        property Items[Index: Integer]: PFaceGroup read GetFaceGroup; default;
      end;

      PMeshObject = ^TMeshObject;
      TMeshObject = record
        Mode: TMeshMode;      // currently only mmTriangles are supported
        Vertices: PVectorArray;   // comprises all vertices of the object in no particular order
        Normals: PVectorArray;
        TexCoords: PTexPointArray;
        FaceGroups: TFaceGroups;    // a list of face groups, each comprising a material description and
                                    // a list of indices into the VerticesArray array
      end;

      TTorus = class(TGLSceneObject)
      private
        FRings,
        FSides        : Cardinal;
        FMinorRadius,
        FMajorRadius  : Single;
        procedure SetMajorRadius(AValue: Single);
		  procedure SetMinorRadius(AValue: Single);
        procedure SetRings(AValue: Cardinal);
        procedure SetSides(AValue: Cardinal);
        
      public
        constructor Create(AOwner: TComponent); override;
        procedure BuildList; override;

      published
        property MajorRadius: Single read FMajorRadius write SetMajorRadius;
        property MinorRadius: Single read FMinorRadius write SetMinorRadius;
        property Rings: Cardinal read FRings write SetRings default 25;
        property Sides: Cardinal read FSides write SetSides default 15;
		end;

		TSpaceTextCharRange = (stcrAlphaNum, stcrNumbers, stcrAll);

		TSpaceText = class(TGLSceneObject)
      private
        FFont       : TFont;
		  FText       : String;
		  FExtrusion  : Single;
		  FAllowedDeviation : Single;
		  FCharacterRange : TSpaceTextCharRange;
		  procedure SetCharacterRange(const val : TSpaceTextCharRange);
		  procedure SetAllowedDeviation(const val : Single);
		  procedure SetExtrusion(AValue: Single);
		  procedure SetFont(AFont: TFont);
		  procedure SetText(AText: String);
		protected
		  BaseList    : TGLuint;
		  FontChanged : Boolean;
		public
		  constructor Create(AOwner: TComponent); override;
		  destructor Destroy; override;
		  procedure BuildList; override;
		  procedure PrepareObject; override;
		published
		  property Extrusion: Single read FExtrusion write SetExtrusion;
		  property Font: TFont read FFont write SetFont;
		  property Text: String read FText write SetText;
		  {: Quality related, see Win32 help for wglUseFontOutlines }	
		  property AllowedDeviation : Single read FAllowedDeviation write SetAllowedDeviation;
		  {: Character range to convert.<p>
		  	  Converting less characters saves time and memory... }
		  property CharacterRange : TSpaceTextCharRange read FCharacterRange write SetCharacterRange default stcrAll;
		end;

		TTeapot = class(TGLSceneObject)
		private
		  FGrid : Cardinal;
		public
		  constructor Create(AOwner: TComponent); override;
        procedure BuildList; override;
      end;

      TDodecahedron = class(TGLSceneObject)
      public
        procedure BuildList; override;
      end;

      TRotationSolid = class(TGLSceneObject)
      public
        procedure BuildList; override;
      end;

//------------------------------------------------------------------------------

implementation

uses Consts, Dialogs, Forms, GLStrings, Math, PlugInIntf;

type // holds an entry in the font manager list (used in TSpaceText)
     PFontEntry        = ^TFontEntry;
     TFontEntry        = record
									Name      : String;
									Styles    : TFontStyles;
									Extrusion : Single;
									Base      : TGLuint;
									RefCount  : Integer;
									allowedDeviation : Single;
									firstChar, lastChar : Integer;
								 end;

	  // manages a list of fonts for which display lists were created
	  TFontManager = class(TList)
	  public
		 destructor Destroy; override;
		 function FindFont(AName: String; FStyles: TFontStyles; FExtrusion: Single;
								 FAllowedDeviation : Single;
								 FFirstChar, FLastChar : Integer) : PFontEntry;
		 function FindFontByList(AList: TGLuint): PFontEntry;
		 function GetFontBase(AName: String; FStyles: TFontStyles; FExtrusion: Single;
									 allowedDeviation : Single;
									 firstChar, lastChar : Integer) : TGLuint;
       procedure Release(List: TGLuint);
     end;

var
   FontManager       : TFontManager;

//----------------- TFontManager -----------------------------------------------

destructor TFontManager.Destroy;

var I : Integer;

begin
  for I := 0 to Count-1 do
  begin
    if TFontEntry(Items[I]^).Base <> 0 then glDeleteLists(TFontEntry(Items[I]^).Base, 255);
    FreeMem(Items[I], SizeOf(TFontEntry));
  end;
  inherited Destroy;
end;

// FindFond
//
function TFontManager.FindFont(AName: String; FStyles: TFontStyles; FExtrusion: Single;
										 FAllowedDeviation : Single;
										 FFirstChar, FLastChar : Integer) : PFontEntry;
var
	i : Integer;
begin
	Result := nil;
	// try to find an entry with the required attributes
	for I  := 0 to Count-1 do with TFontEntry(Items[I]^) do
		if (CompareText(Name, AName) = 0) and (Styles = FStyles)
				and (Extrusion = FExtrusion) and (allowedDeviation=FAllowedDeviation)
				and (firstChar=FFirstChar)	and (lastChar=FLastChar) then begin
			// entry found
			Result := Items[I];
			Exit;
		end;
end;

//------------------------------------------------------------------------------

function TFontManager.FindFontByList(AList: TGLuint): PFontEntry;

var I : Integer;

begin
  Result := nil;
  // try to find an entry with the required attributes
  for I  := 0 to Count-1 do
    with TFontEntry(Items[I]^) do
      if Base = AList then
      begin // entry found
        Result := Items[I];
        Exit;
      end;
end;

//------------------------------------------------------------------------------

function TFontManager.GetFontBase(AName: String; FStyles: TFontStyles; FExtrusion: Single;
											 allowedDeviation : Single;
											 firstChar, lastChar : Integer) : TGLuint;

var NewEntry : PFontEntry;
	 MemDC    : HDC;
	 AFont    : TFont;

begin
  NewEntry := FindFont(AName, FStyles, FExtrusion, allowedDeviation, firstChar, lastChar);
  if assigned(NewEntry) then
  begin
	 Inc(NewEntry^.RefCount);
    Result := NewEntry^.Base;
    Exit;
  end;  
  // no entry found, so create one
  New(NewEntry);
  try
    NewEntry^.Name := AName;
    NewEntry^.Styles := FStyles;
    NewEntry^.Extrusion := FExtrusion;
	 NewEntry^.RefCount := 1;
	 NewEntry^.firstChar := firstChar;
	 NewEntry^.lastChar := lastChar;
	 NewEntry^.allowedDeviation:=allowedDeviation;

    // create a font to be used while display list creation
    AFont := TFont.Create;
    MemDC := CreateCompatibleDC(0);
    try
      AFont.Name := AName;
      AFont.Style := FStyles;
      SelectObject(MemDC, AFont.Handle);
      NewEntry^.Base := glGenLists(255);
		if NewEntry^.Base = 0 then
			raise Exception.Create('FontManager: no more display lists available');
		if not wglUseFontOutlines(MemDC, firstChar, lastChar, NewEntry^.Base,
										  allowedDeviation, FExtrusion, WGL_FONT_POLYGONS, nil) then
		  	raise Exception.Create('FontManager: font creation failed');
    finally
		AFont.Free;
      DeleteDC(MemDC);
    end;
    Add(NewEntry);
    Result := NewEntry^.Base;
  except
    if NewEntry^.Base <> 0 then glDeleteLists(NewEntry^.Base, 255);
    Dispose(NewEntry);
    raise;
  end;
end;

//------------------------------------------------------------------------------

procedure TFontManager.Release(List: TGLuint);

var Entry : PFontEntry;

begin
  Entry := FindFontByList(List);
  if assigned(Entry) then
  begin
    Dec(Entry^.RefCount);
    if Entry^.RefCount = 0 then
    begin
      glDeleteLists(Entry^.Base, 255);
      Remove(Entry);
    end;
  end;
end;

//----------------- TDummyCube -----------------------------------------------------

// Create
//
constructor TDummyCube.Create(AOwner : TComponent);
begin
	inherited;
	FCubeSize:=1;
	FEdgeColor:=TGLColor.Create(Self);
	FEdgeColor.Initialize(clrWhite);
end;

// BuildList
//
procedure TDummyCube.BuildList;
var
	mi, ma : Single;
begin
	if (csDesigning in ComponentState) or (FVisibleAtRunTime) then begin
		glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LIGHTING_BIT or GL_LINE_BIT or GL_COLOR_BUFFER_BIT);
		glDisable(GL_LIGHTING);
		glEnable(GL_LINE_STIPPLE);
		glEnable(GL_LINE_SMOOTH);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glLineWidth(1);
		glLineStipple(1, $CCCC);
		ma:=FCubeSize*0.5;
		mi:=-ma;
		with EdgeColor do glColor3f(Color[0], Color[1], Color[2]);
		glBegin(GL_LINE_STRIP);
			// front face
			glVertex3f(ma, mi, mi); glVertex3f(ma, ma, mi);
			glVertex3f(ma, ma, ma); glVertex3f(ma, mi, ma);
			glVertex3f(ma, mi, mi);
			// partial up back fac
			glVertex3f(mi, mi, mi); glVertex3f(mi, mi, ma);
			glVertex3f(mi, ma, ma); glVertex3f(mi, ma, mi);
			// right side low
			glVertex3f(ma, ma, mi);
		glEnd;
		glBegin(GL_LINES);
			// right high
			glVertex3f(ma, ma, ma);	glVertex3f(mi, ma, ma);
			// back low
			glVertex3f(mi, mi, mi); glVertex3f(mi, ma, mi);
			// left high
			glVertex3f(ma, mi, ma); glVertex3f(mi, mi, ma);
		glEnd;
		glPopAttrib;
	end;
end;

// BarycenterSqrDistanceTo
//
function TDummyCube.BarycenterAbsolutePosition : TVector;
var
	i : Integer;
begin
	if Count>0 then begin
		Result:=Children[0].BarycenterAbsolutePosition;
		for i:=1 to Count-1 do
			Result:=VectorAdd(Result, Children[i].BarycenterAbsolutePosition);
		VectorScale(Result, 1/Count);
	end else Result:=AbsolutePosition;
end;

// SetCubeSize
//
procedure TDummyCube.SetCubeSize(const val : TGLFloat);
begin
	if val<>FCubeSize then begin
		FCubeSize:=val;
		StructureChanged;
	end;
end;

// SetEdgeColor
//
procedure TDummyCube.SetEdgeColor(const val : TGLColor);
begin
	if val<>FEdgeColor then begin
		FEdgeColor.Assign(val);
		StructureChanged;
	end;
end;

// SetVisibleAtRunTime
//
procedure TDummyCube.SetVisibleAtRunTime(const val : Boolean);
begin
	if val<>FVisibleAtRunTime then begin
		FVisibleAtRunTime:=val;
		StructureChanged;
	end;
end;

//----------------- TPlane -----------------------------------------------------

constructor TPlane.Create(AOwner:Tcomponent);

begin
  inherited Create(AOwner);
  FWidth := 1;
  FHeight := 1;
  FXTiles := 1;
  FXOffset := 0;
  FYTiles := 1;
  FYOffset := 0;
end;

//------------------------------------------------------------------------------

procedure TPlane.BuildList;
var
   hw, hh : TGLFloat;
begin
   inherited BuildList;
   hw :=  FWidth*0.5;
   hh :=  FHeight*0.5;

   glBegin(GL_QUADS);
      glNormal3f(  0,  0, 1);
      glTexCoord2f(FXTiles+FXOffset, FYTiles+FYOffset);
      glVertex2f( hw, hh);
      glTexCoord2f(0, FYTiles+FYOffset);
      glVertex2f(-hw, hh);
      glTexCoord2f(0, 0);
      glVertex2f(-hw, -hh);
      glTexCoord2f(FXTiles+FXOffset, 0);
      glVertex2f( hw, -hh);
   glEnd;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetWidth(AValue : TGLFloat);

begin
  if AValue <> FWidth then
  begin
    FWidth := AValue;
	 StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetHeight(AValue:TGLFloat);

begin
  if AValue <> FHeight then
  begin
    FHeight := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetXOffset(const Value: TGLFloat);

begin
  if Value <> FXOffset then
  begin
    FXOffset := Value;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetXTiles(const Value: Cardinal);

begin
  if Value <> FXTiles then
  begin
    FXTiles := Value;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetYOffset(const Value: TGLFloat);

begin
  if Value <> FYOffset then
  begin
    FYOffset := Value;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.SetYTiles(const Value: Cardinal);

begin
  if Value <> FYTiles then
  begin
    FYTiles := Value;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TPlane.Assign(Source: TPersistent);

begin
  if assigned(Source) and (Source is TCube) then
  begin
    FWidth := TPlane(Source).FWidth;
    FHeight := TPlane(Source).FHeight;
  end;
  inherited Assign(Source);
end;


//----------------- TSprite ----------------------------------------------------

// Create
//
constructor TSprite.Create(AOwner:Tcomponent);
begin
	inherited Create(AOwner);
	FWidth:=1;
	FHeight:=1;
end;

// GetHandle
//
function TSprite.GetHandle : TObjectHandle;
begin
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
	Result:=FHandle;
end;

// BuildList
//
procedure TSprite.BuildList;
var
	vx, vy, vx1, vy1 : TVector;
	i : Integer;
   w, h, c, s : Single;
   ec, es, er : Extended;
begin
	inherited BuildList;
	glBegin(GL_QUADS);
		// on extrait les vecteurs directeurs de la matrice de projection
		// (dunno how they are named in english)
      w:=FWidth*0.5;
      h:=FHeight*0.5;
		for i:=0 to 2 do begin
			vx[i]:=GlobalMatrix[i][0]*w;
			vy[i]:=GlobalMatrix[i][1]*h;
		end;
      if FRotation=0 then begin
         // no rotation, use fast, direct projection
   		glTexCoord2f(1, 1);  glVertex3f( vx[0]+vy[0], vx[1]+vy[1], vx[2]+vy[2]);
	   	glTexCoord2f(0, 1);  glVertex3f(-vx[0]+vy[0],-vx[1]+vy[1],-vx[2]+vy[2]);
		   glTexCoord2f(0, 0);  glVertex3f(-vx[0]-vy[0],-vx[1]-vy[1],-vx[2]-vy[2]);
   		glTexCoord2f(1, 0);  glVertex3f( vx[0]-vy[0], vx[1]-vy[1], vx[2]-vy[2]);
      end else begin
         // we need to compose main vectors...
         er:=FRotation*(PI/180);
         SinCos(er, es, ec);
   		for i:=0 to 2 do begin
            vx1[i]:=vx[i]+vy[i];
            vy1[i]:=vy[i]-vx[i];
         end;
         // ...and apply rotation... way slower
         c:=ec; s:=es;
   		glTexCoord2f(1, 1);  glVertex3f( c*vx1[0]+s*vy1[0], c*vx1[1]+s*vy1[1], c*vx1[2]+s*vy1[2]);
	   	glTexCoord2f(0, 1);  glVertex3f(-s*vx1[0]+c*vy1[0],-s*vx1[1]+c*vy1[1],-s*vx1[2]+c*vy1[2]);
		   glTexCoord2f(0, 0);  glVertex3f(-c*vx1[0]-s*vy1[0],-c*vx1[1]-s*vy1[1],-c*vx1[2]-s*vy1[2]);
   		glTexCoord2f(1, 0);  glVertex3f( s*vx1[0]-c*vy1[0], s*vx1[1]-c*vy1[1], s*vx1[2]-c*vy1[2]);
      end;
	glEnd;
end;

// SetWidth
//
procedure TSprite.SetWidth(const val : TGLFloat);
begin
	if FWidth<>val then begin
		FWidth:=val;
		StructureChanged;
	end;
end;

// SetHeight
//
procedure TSprite.SetHeight(const val : TGLFloat);
begin
	if FHeight<>val then begin
		FHeight:=val;
		StructureChanged;
	end;
end;

// SetRotation
//
procedure TSprite.SetRotation(const val : TGLFloat);
begin
	if FRotation<>val then begin
		FRotation:=val;
		StructureChanged;
	end;
end;

// SetSize
//
procedure TSprite.SetSize(const width, height : TGLFloat);
begin
	FWidth:=width;
	FHeight:=height;
	StructureChanged;
end;

// SetSquareSize
//
procedure TSprite.SetSquareSize(const size : TGLFloat);
begin
	FWidth:=size;
	FHeight:=size;
	StructureChanged;
end;

//----------------- TCube ------------------------------------------------------

constructor TCube.Create(AOwner:Tcomponent);
begin
  inherited Create(AOwner);
  FCubeWidth := 1;
  FCubeHeight := 1;
  FCubeDepth := 1;
  FParts := [cpTop, cpBottom, cpFront, cpBack, cpLeft, cpRight];
  FNormalDirection := ndOutside;
end;

//------------------------------------------------------------------------------

procedure TCube.BuildList;
var
	hw, hh, hd, nd  : TGLFloat;
begin
	inherited BuildList;
   if FNormalDirection = ndInside then
      nd := -1
   else nd := 1;
   hw :=  FCubeWidth*0.5;
   hh :=  FCubeHeight*0.5;
   hd :=  FCubeDepth*0.5;

   if cpFront in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(  0,  0, nd);
         glTexCoord2f(1, 1);  glVertex3f( hw, hh, hd);
         glTexCoord2f(0, 1);  glVertex3f(-hw, hh, hd);
         glTexCoord2f(0, 0);  glVertex3f(-hw, -hh, hd);
         glTexCoord2f(1, 0);  glVertex3f( hw, -hh, hd);
      glEnd;
   end;
   if cpBack in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(  0,  0, -nd);
         glTexCoord2f(0, 1);  glVertex3f( hw, hh, -hd);
         glTexCoord2f(0, 0);  glVertex3f( hw, -hh, -hd);
         glTexCoord2f(1, 0);  glVertex3f(-hw, -hh, -hd);
         glTexCoord2f(1, 1);  glVertex3f(-hw, hh, -hd);
      glEnd;
   end;
   if cpLeft in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(-nd,  0,  0);
         glTexCoord2f(1, 1);  glVertex3f(-hw, hh, hd);
         glTexCoord2f(0, 1);  glVertex3f(-hw, hh, -hd);
         glTexCoord2f(0, 0);  glVertex3f(-hw, -hh, -hd);
         glTexCoord2f(1, 0);  glVertex3f(-hw, -hh, hd);
      glEnd;
   end;
   if cpRight in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(nd,  0,  0);
         glTexCoord2f(0, 1);  glVertex3f(hw, hh, hd);
         glTexCoord2f(0, 0);  glVertex3f(hw, -hh, hd);
         glTexCoord2f(1, 0);  glVertex3f(hw, -hh, -hd);
         glTexCoord2f(1, 1);  glVertex3f(hw, hh, -hd);
      glEnd;
   end;
   if cpTop in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(  0, nd,  0);
         glTexCoord2f(0, 1);  glVertex3f(-hw, hh, -hd);
         glTexCoord2f(0, 0);  glVertex3f(-hw, hh, hd);
         glTexCoord2f(1, 0);  glVertex3f( hw, hh, hd);
         glTexCoord2f(1, 1);  glVertex3f( hw, hh, -hd);
      glEnd;
   end;
   if cpBottom in FParts then begin
      glBegin(GL_QUADS);
         glNormal3f(  0, -nd,  0);
         glTexCoord2f(0, 0);  glVertex3f(-hw, -hh, -hd);
         glTexCoord2f(1, 0);  glVertex3f( hw, -hh, -hd);
         glTexCoord2f(1, 1);  glVertex3f( hw, -hh, hd);
         glTexCoord2f(0, 1);  glVertex3f(-hw, -hh, hd);
      glEnd;
   end;
end;

//------------------------------------------------------------------------------

procedure TCube.SetCubeWidth(AValue : TGLFloat);

begin
  if AValue <> FCubeWidth then
  begin
    FCubeWidth := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCube.SetCubeHeight(AValue:TGLFloat);

begin
  if AValue <> FCubeHeight then
  begin
    FCubeHeight := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCube.SetCubeDepth(AValue: TGLFloat);

begin
  if AValue <> FCubeDepth then
  begin
    FCubeDepth := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCube.SetParts(AValue:TCubeParts);

begin
 if AValue <> FParts then
 begin
   FParts := AValue;
   StructureChanged;
 end;
end;

//------------------------------------------------------------------------------

procedure TCube.SetNormalDirection(AValue: TNormalDirection);

begin
  if AValue <> FNormalDirection then
  begin
    FNormalDirection := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCube.Assign(Source: TPersistent);

begin
  if assigned(Source) and (Source is TCube) then
  begin
    FCubeWidth := TCube(Source).FCubewidth;
    FCubeHeight := TCube(Source).FCubeHeight;
    FCubeDepth := TCube(Source).FCubeDepth;
    FParts := TCube(Source).FParts;
    FNormalDirection := TCube(Source).FNormalDirection;
  end;
  inherited Assign(Source);
end;

procedure TCube.DefineProperties(Filer: TFiler);
begin
   inherited;
   Filer.DefineBinaryProperty('CubeSize', ReadData, WriteData,
                              (FCubeWidth<>1) or (FCubeHeight<>1) or (FCubeDepth<>1));
end;

procedure TCube.ReadData(Stream: TStream);
begin
   with Stream do begin
      Read(FCubeWidth, SizeOf(FCubeWidth));
      Read(FCubeHeight, SizeOf(FCubeHeight));
      Read(FCubeDepth, SizeOf(FCubeDepth));
   end;
end;

procedure TCube.WriteData(Stream: TStream);
begin
   with Stream do begin
      Write(FCubeWidth, SizeOf(FCubeWidth));
      Write(FCubeHeight, SizeOf(FCubeHeight));
      Write(FCubeDepth, SizeOf(FCubeDepth));
   end;
end;

//----------------- TQuadricObject ---------------------------------------------

constructor TQuadricObject.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FNormals := qnSmooth;
  FNormalDirection := ndOutside;
end;

//------------------------------------------------------------------------------

procedure TQuadricObject.SetNormals(AValue:TQuadricNormal);

begin
  if AValue <> FNormals then
  begin
    FNormals := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TQuadricObject.SetNormalDirection(AValue:TNormalDirection);

begin
  if AValue <> FNormalDirection then
  begin
    FNormalDirection := AValue;
    StructureChanged;
  end;
end;


//------------------------------------------------------------------------------

procedure TQuadricObject.SetupQuadricParams(Quadric:PGLUquadricObj);

var WithTexture : Boolean;

begin
  gluQuadricDrawStyle(Quadric, GLU_FILL);
  gluQuadricNormals(Quadric, GLU_SMOOTH);
  gluQuadricOrientation(Quadric, GLU_OUTSIDE);
  {case Options.FrontPolygonMode of
    pmFill   : gluQuadricDrawStyle(Quadric, GLU_FILL);
    pmLines  : gluQuadricDrawStyle(Quadric, GLU_LINE);
    pmPoints : gluQuadricDrawStyle(Quadric, GLU_POINT);
  end;

  case FNormalDirection of
    ndInside  : gluQuadricOrientation(Quadric, GLU_INSIDE);
    ndOutside : gluQuadricOrientation(Quadric, GLU_OUTSIDE);
  end;


  case FNormals of
    qnSmooth : gluQuadricNormals(Quadric, GLU_SMOOTH);
    qnFlat   : gluQuadricNormals(Quadric, GLU_FLAT);
    qnNone   : gluQuadricNormals(Quadric, GLU_NONE);
  end;}
  {WithTexture := (stTexture1D in Scene.CurrentStates) or
               (stTexture2D in Scene.CurrentStates);}
  WithTexture := True;
  gluQuadricTexture(Quadric, Ord(WithTexture));
end;

//------------------------------------------------------------------------------

procedure TQuadricObject.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TQuadricObject) then
  begin
    FNormals := TQuadricObject(Source).FNormals;
    FNormalDirection := TQuadricObject(Source).FNormalDirection;
  end;
  inherited Assign(Source);
end;

//----------------- TSphere ----------------------------------------------------

constructor TSphere.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FRadius := 0.5;
  FSlices := 16;
  FStacks := 16;
  FTop := 90;
  FBottom := -90;
  FStart := 0;
  FStop := 360;
end;

//------------------------------------------------------------------------------

procedure TSphere.BuildList;

var
  V1, V2, N1 : TAffineVector;
  AngTop, AngBottom,
  AngStart, AngStop,
  StepV, StepH,
  SinP, CosP,
  SinP2, CosP2,
  SinT, CosT,
  Phi, Phi2,
  Theta: Extended;
  I, J: Integer;
  DoReverse: Boolean;

begin
  inherited BuildList;
  DoReverse := FNormalDirection = ndInside;
  if DoReverse then glFrontFace(GL_CW)
               else glFrontFace(GL_CCW);

  // common settings
  AngTop := DegToRad(FTop);
  AngBottom := DegToRad(FBottom);
  AngStart := DegToRad(FStart);
  AngStop := DegToRad(FStop);
  StepH := (AngStop - AngStart) / FSlices;
  StepV := (AngTop - AngBottom) / FStacks;
  glScalef(Radius, Radius, Radius);

  // top cap
  if (FTop < 90) and (FTopCap in [ctCenter, ctFlat]) then
  begin
    glBegin(GL_TRIANGLE_FAN);
    SinCos(AngTop, SinP, CosP);
    glTexCoord2f(0.5, 0.5);
    if DoReverse then glNormal3f(0, -1, 0)
                 else glNormal3f(0, 1, 0);
    if FTopCap = ctCenter then glVertex3f(0, 0, 0)
                          else
    begin
      glVertex3f(0, SinP, 0);
      if DoReverse then N1 := MakeAffineVector([0, -1, 0])
                   else N1 := MakeAffineVector([0, 1, 0]);
    end;
    V1[1] := SinP;
    Theta := AngStart;
    for I := 0 to FSlices do
    begin
      SinCos(Theta, SinT, CosT);
      V1[0] := CosP * SinT;
      V1[2] := CosP * CosT;
      if FTopCap = ctCenter then
      begin
        N1 := VectorPerpendicular(MakeAffineVector([0, 1, 0]), V1);
        if DoReverse then VectorNegate(N1);
      end;
      glTexCoord2f(SinT / 2 + 0.5, CosT / 2 + 0.5);
      glNormal3fv(@N1);
      glVertex3fv(@V1);
      Theta := Theta + StepH;
    end;
    glEnd;
  end;

  // main body
  Phi := AngTop;
  Phi2 := Phi - StepV;
  for J := 0 to FStacks - 1 do
  begin
    Theta := AngStart;
    SinCos(Phi, SinP, CosP);
    SinCos(Phi2, SinP2, CosP2);
    V1[1] := SinP;
    V2[1] := SinP2;
    glBegin(GL_TRIANGLE_STRIP);
    for I := 0 to FSlices do
    begin
      SinCos(Theta, SinT, CosT);
      V1[0] := CosP * SinT;
      V2[0] := CosP2 * SinT;
      V1[2] := CosP * CosT;
      V2[2] := CosP2 * CosT;
      glTexCoord2f(I / FSlices, J / (FStacks - 1));
      if DoReverse then
      begin
        N1 := V1;
        VectorNegate(N1);
        glNormal3fv(@N1);
      end
      else glNormal3fv(@V1);
      glVertex3fv(@V1);

      glTexCoord2f(I / FSlices, (J + 1) / (FStacks - 1));
            if DoReverse then
      begin
        N1 := V2;
        VectorNegate(N1);
        glNormal3fv(@N1);
      end
      else glNormal3fv(@V2);
      glVertex3fv(@V2);

      Theta := Theta+StepH;
    end;
    glEnd;
    Phi := Phi2;
    Phi2 := Phi2 - StepV;
  end;

  // bottom cap
  if (FBottom > -90) and (FBottomCap in [ctCenter, ctFlat]) then
  begin
    glBegin(GL_TRIANGLE_FAN);
    SinCos(AngBottom, SinP, CosP);
    glTexCoord2f(0.5, 0.5);
    if DoReverse then glNormal3f(0, 1, 0)
                 else glNormal3f(0, -1, 0);
    if FBottomCap = ctCenter then glVertex3f(0, 0, 0)
                             else
    begin
      glVertex3f(0, SinP, 0);
      if DoReverse then N1 := MakeAffineVector([0, -1, 0])
                   else N1 := MakeAffineVector([0, 1, 0]);
    end;
    V1[1] := SinP;
    Theta := AngStop;
    for I := 0 to FSlices do
    begin
      SinCos(Theta, SinT, CosT);
      V1[0] := CosP * SinT;
      V1[2] := CosP * CosT;
      if FTopCap = ctCenter then
      begin
        N1 := VectorPerpendicular(MakeAffineVector([0, -1, 0]), V1);
        if DoReverse then VectorNegate(N1);
      end;
      glTexCoord2f(SinT / 2 + 0.5, CosT / 2 + 0.5);
      glNormal3fv(@N1);
      glVertex3fv(@V1);
      Theta := Theta - StepH;
    end;
    // restore face winding
    glEnd;
  end;
  glFrontFace(GL_CCW);
end;

//------------------------------------------------------------------------------

procedure TSphere.SetBottom(AValue: TAngleLimit1);
begin
   if FBottom <> AValue then begin
      Assert(FTop >= AValue);
      FBottom := AValue;
      StructureChanged;
   end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetBottomCap(AValue: TCapType);

begin
  if FBottomCap <> AValue then
  begin
    FBottomCap := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetRadius(AValue:TGLFloat);

begin
  if AValue <> FRadius then
  begin
    FRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetSlices(AValue:TGLInt);

begin
  if AValue <> FSlices then
  begin
    FSlices := AValue;
    if FSlices = 0 then FSlices := 1;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetStacks(AValue:TGLInt);

begin
  if AValue <> FStacks then
  begin
    FStacks := AValue;
    if FStacks = 0 then FStacks := 1;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetStart(AValue: TAngleLimit2);
begin
   if FStart <> AValue then begin
      Assert(AValue <= FStop);
      FStart := AValue;
      StructureChanged;
   end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetStop(AValue: TAngleLimit2);
begin
   if FStop <> AValue then begin
      Assert(AValue >= FStart);
      FStop := AValue;
      StructureChanged;
   end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetTop(AValue: TAngleLimit1);
begin
   if FTop <> AValue then begin
      Assert(AValue >= FBottom);
      FTop := AValue;
      StructureChanged;
   end;
end;

//------------------------------------------------------------------------------

procedure TSphere.SetTopCap(AValue: TCapType);

begin
  if FTopCap <> AValue then
  begin
    FTopCap := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TSphere.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TSphere) then
  begin
    FRadius := TSphere(Source).FRadius;
    FSlices := TSphere(Source).FSlices;
    FStacks := TSphere(Source).FStacks;
    FBottom := TSphere(Source).FBottom;
    FTop := TSphere(Source).FTop;
    FStart := TSphere(Source).FStart;
    FStop := TSphere(Source).FStop;
  end;
  inherited Assign(Source);
end;

//----------------- TDisk ------------------------------------------------------

constructor TDisk.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FOuterRadius := 0.5;
  FInnerRadius := 0;
  FSlices := 16;
  FLoops := 16;
  FStartAngle := 0;
  FSweepAngle := 360;
end;

//------------------------------------------------------------------------------

procedure TDisk.BuildList;

var Quadric: PGLUquadricObj;

begin
  inherited BuildList;
  Quadric := gluNewQuadric();
  SetupQuadricParams(Quadric);
  gluPartialDisk(Quadric, FInnerRadius, FOuterRadius, FSlices, FLoops, FStartAngle, FSweepAngle);
  gluDeleteQuadric(Quadric);
end;

//------------------------------------------------------------------------------

procedure TDisk.SetOuterRadius(AValue:TGLFloat);

begin
  if AValue <> FOuterRadius then
  begin
    FOuterRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.SetInnerRadius(AValue:TGLFloat);

begin
  if AValue <> FInnerRadius then
  begin
    FInnerRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.SetSlices(AValue:TGLInt);

begin
  if AValue <> FSlices then
  begin
    FSlices := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.SetLoops(AValue:TGLInt);

begin
  if AValue <> FLoops then
  begin
    FLoops := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.SetStartAngle(AValue:TGLFloat);

begin
  if AValue <> FStartAngle then
  begin
    FStartAngle := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.SetSweepAngle(AValue:TGLFloat);

begin
  if AValue <> FSweepAngle then
  begin
    FSweepAngle := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TDisk.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TDisk) then
  begin
    FOuterRadius := TDisk(Source).FOuterRadius;
    FInnerRadius := TDisk(Source).FInnerRadius;
    FSlices := TDisk(Source).FSlices;
    FLoops := TDisk(Source).FLoops;
    FStartAngle := TDisk(Source).FStartAngle;
    FSweepAngle := TDisk(Source).FSweepAngle;
  end;
  inherited Assign(Source);
end;

//----------------- TCylinderBase ----------------------------------------------

constructor TCylinderBase.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FBottomRadius := 0.5;
  FHeight := 1;
  FSlices := 16;
  FStacks := 16;
end;

//------------------------------------------------------------------------------

procedure TCylinderBase.SetBottomRadius(AValue:TGLFloat);

begin
  if AValue <> FBottomRadius then
  begin
    FBottomRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCylinderBase.SetHeight(AValue:TGLFloat);

begin
  if AValue <> FHeight then
  begin
    FHeight := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCylinderBase.SetSlices(AValue:TGLInt);

begin
  if AValue <> FSlices then
  begin
    FSlices := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCylinderBase.SetStacks(AValue:TGLInt);

begin
  if AValue <> FStacks then
  begin
    FStacks := AValue;
    StructureChanged;
  end;
end;


//------------------------------------------------------------------------------

procedure TCylinderBase.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TCylinderBase) then
  begin
    FBottomRadius := TCylinderBase(Source).FBottomRadius;
    FSlices := TCylinderBase(Source).FSlices;
    FStacks := TCylinderBase(Source).FStacks;
    FHeight := TCylinderBase(Source).FHeight;
  end;
  inherited Assign(Source);
end;

//----------------- TCone ------------------------------------------------------

constructor TCone.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FParts := [coSides, coBottom];
end;

//------------------------------------------------------------------------------

procedure TCone.BuildList;

var Quadric: PGLUquadricObj;

begin
  inherited BuildList;
  Quadric := gluNewQuadric();
  SetupQuadricParams(Quadric);
  glRotated(-90, 1, 0, 0);
  glTranslated(0, 0, -FHeight*0.5);
  if coSides in FParts then gluCylinder(Quadric, BottomRadius, 0, Height, Slices, Stacks);
  if coBottom in FParts then
  begin
    case FNormalDirection of
      ndInside  : gluQuadricOrientation(Quadric, GLU_OUTSIDE);  //swap orientation because top of a disk is defined as outside
      ndOutside : gluQuadricOrientation(Quadric, GLU_INSIDE);
    end;
    gluDisk(Quadric, 0, BottomRadius, Slices, Round(FStacks/FHeight*FBottomRadius));
  end;
  gluDeleteQuadric(Quadric);
end;

//------------------------------------------------------------------------------

procedure TCone.SetParts(AValue:TConeParts);

begin
  if AValue <> FParts then
  begin
    FParts := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCone.Assign(Source: TPersistent);

begin
  if assigned(Source) and (Source is TCone) then
  begin
    FParts := TCone(Source).FParts;
  end;
  inherited Assign(Source);
end;

//----------------- TCylinder --------------------------------------------------

constructor TCylinder.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FTopRadius := 0.5;
  FParts := [cySides, cyBottom, cyTop];
end;

//------------------------------------------------------------------------------

procedure TCylinder.BuildList;

var Quadric : PGLUquadricObj;

begin
  inherited BuildList;
  Quadric := gluNewQuadric;
  SetupQuadricParams(Quadric);
  glRotatef(-90, 1, 0, 0);
  glTranslated(0, 0, -FHeight*0.5);
  if cySides in FParts then gluCylinder(Quadric, FBottomRadius, FTopRadius, FHeight, FSlices, FStacks);
  if cyTop in FParts then
  begin
    glPushMatrix;
    glTranslatef(0, 0, FHeight);
    gluDisk(Quadric, 0, FTopRadius, FSlices, Round(FStacks/FHeight*FTopRadius));
    glPopMatrix;
  end;
  if cyBottom in FParts then
  begin
    //swap orientation because top of a disk is defined as outside
    case FNormalDirection of
      ndInside  : gluQuadricOrientation(Quadric, GLU_OUTSIDE);
      ndOutside : gluQuadricOrientation(Quadric, GLU_INSIDE);
    end;
    gluDisk(Quadric, 0, FBottomRadius, FSlices, Round(FStacks/FHeight*FBottomRadius));
  end;
  gluDeleteQuadric(Quadric);
end;

//------------------------------------------------------------------------------

procedure TCylinder.SetTopRadius(AValue: TGLFloat);

begin
  if AValue <> FTopRadius then
  begin
    FTopRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCylinder.SetParts(AValue: TCylinderParts);

begin
  if AValue <> FParts then
  begin
    FParts := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TCylinder.Assign(Source: TPersistent);

begin
  if assigned(SOurce) and (Source is TCylinder) then
  begin
    FParts := TCylinder(Source).FParts;
    FTopRadius := TCylinder(Source).FTopRadius;
  end;
  inherited Assign(Source);
end;

//----------------- TVertexList ------------------------------------------------

constructor TVertexList.Create(AOwner: TPersistent);

begin
  inherited;
  FOwnerScene := (AOwner as TGLSceneObject);
  FValues := nil;
  FSize := 0;
  // precalculate size of a complete vertex entry
  FEntrySize := SizeOf(TVertex)+SizeOf(TNormal)+SizeOf(TColorVector)+SizeOf(TTexPoint);
end;

//------------------------------------------------------------------------------

destructor TVertexList.Destroy;

begin
  FreeMem(FValues, FSize);
  inherited destroy;
end;

//------------------------------------------------------------------------------

function TVertexList.GetCount: Integer;

begin
  Result := FSize div FEntrySize;
end;

//------------------------------------------------------------------------------

function TVertexList.GetFirstColor: PGLFLoat;

const Entry : Integer = 2;

begin
  Result := @FValues[Entry];
end;

//------------------------------------------------------------------------------

function TVertexList.GetFirstEntry: PGLFloat;

begin
  Result := Pointer(FValues);
end;

//------------------------------------------------------------------------------

function TVertexList.GetFirstNormal: PGLFLoat;

const Entry : Integer = 6;

begin
  Result := @FValues[Entry];
end;

//------------------------------------------------------------------------------

function TVertexList.GetFirstVertex: PGLFLoat;

const Entry : Integer = 9;

begin
  Result := @FValues[Entry];
end;

procedure TVertexList.DefineProperties(Filer:TFiler);
begin
  Filer.DefineProperty('Items', ReadItems, WriteItems, Count>0);
end;

//------------------------------------------------------------------------------

procedure TVertexList.ReadItems(Reader: TReader);

begin
  Clear;
  Reader.ReadListBegin;
  //while not Reader.EndOfValues do FValues.Add(Pointer(Reader.ReadInteger));
  Reader.ReadListEnd;
end;

//------------------------------------------------------------------------------

procedure  TVertexList.WriteItems(Writer: TWriter);

//var I : Integer;

begin
  Writer.WriteListBegin;
  //for i := 0 to FValues.Count-1 do Writer.WriteInteger(LongInt(FValues[i]));
  Writer.WriteListEnd;
end;

//------------------------------------------------------------------------------

// AddVertex (texturing)
//
procedure TVertexList.AddVertex(const vertex: TVertex; const normal: TNormal;
                                const color: TColorVector; const texPoint: TTexPoint);
var
   dest : ^Byte;
begin
   // extend memory space
   { TODO -oEgg : TVertexList memory allocation needs enhancements... }
   ReallocMem(FValues, (FSize+FEntrySize));

   // calculate destination address for new vertex data
   dest := Pointer(FValues);
   Inc(dest, FSize);         // inc in Byte units
   Inc(FSize, FEntrySize);

   // store texture coordinates
   PTexPoint(dest)^:=texPoint;
   Inc(dest, SizeOf(TTexPoint));

   // store color components
   PColorVector(dest)^:=color;
   Inc(Dest, SizeOf(TColorVector));

   // store normal vector
   PVertex(dest)^:=normal;
   Inc(Dest, SizeOf(TNormal));

   // store vertex
   PVertex(dest)^:=Vertex;

   NotifyChange;
end;

// AddVertex (no texturing)
//
procedure TVertexList.AddVertex(const vertex: TVertex; const normal: TNormal;
                                const color: TColorVector);
begin
   AddVertex(vertex, normal, color, NullTexPoint);
end;

procedure TVertexList.Clear;
begin
   FreeMem(FValues, FSize);
   FSize := 0;
   FValues := nil;
   NotifyChange;
end;

procedure TVertexList.Assign(Source: TPersistent);
begin
   if assigned(Source) and (Source is TVertexList) then begin
      ReallocMem(FValues, TVertexList(Source).FSize);
      FSize := TVertexList(Source).FSize;
      Move(TVertexList(Source).FValues^, FValues^, FSize);
   end else inherited Assign(Source);
end;

//----------------- TMesh ------------------------------------------------------

constructor TMesh.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FVertices := TVertexList.Create(Self);
  FVertices.AddVertex(XVector, ZVector, NullHmgVector, NullTexPoint);
  FVertices.AddVertex(ZVector, ZVector, NullHmgVector, NullTexPoint);
  FVertices.AddVertex(YVector, ZVector, NullHmgVector, NullTexPoint);
  FVertexmode := vmVNCT; //should change this later to default to vmVN. But need to
end;                     //change GLMeshPropform so that it greys out unused vertex info

destructor TMesh.Destroy;
begin
  FVertices.Free;
  inherited Destroy;
end;

procedure TMesh.BuildList;
var
   VertexCount : Longint;
begin
  inherited BuildList;
  glPushAttrib(GL_POLYGON_BIT);
  glFrontFace(GL_CW);
  case FVertexMode of
    vmV    : glInterleavedArrays(GL_V3F, FVertices.EntrySize, FVertices.FirstVertex);
    vmVN   : glInterleavedArrays(GL_N3F_V3F, FVertices.EntrySize, FVertices.FirstNormal);
    vmVNC  : glInterleavedArrays(GL_C4F_N3F_V3F, FVertices.EntrySize, FVertices.FirstColor);
    vmVNCT : glInterleavedArrays(GL_T2F_C4F_N3F_V3F, 0, FVertices.FirstEntry);
  end;
  VertexCount := FVertices.Count;
  case FMode of
    mmTriangleStrip : glDrawArrays(GL_TRIANGLE_STRIP, 0, VertexCount);
    mmTriangleFan   : glDrawArrays(GL_TRIANGLE_FAN, 0, VertexCount);
    mmTriangles     : glDrawArrays(GL_TRIANGLES, 0, VertexCount);
    mmQuadStrip     : glDrawArrays(GL_QUAD_STRIP, 0, VertexCount);
    mmQuads         : glDrawArrays(GL_QUADS, 0, VertexCount);
    mmPolygon       : glDrawArrays(GL_POLYGON, 0, VertexCount);
  end;
  glPopAttrib;
end;

//------------------------------------------------------------------------------

procedure TMesh.SetMode(AValue: TMeshMode);

begin
  if AValue <> FMode then
  begin
    FMode := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TMesh.SetVertices(AValue: TVertexList);

begin
  if AValue <> FVertices then
  begin
    FVertices.Assign(AValue);
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TMesh.SetVertexMode(AValue: TVertexMode);

begin
  if AValue<>FVertexMode then
  begin
    FVertexMode := AValue;
    StructureChanged;
  end;
end;


//------------------------------------------------------------------------------

function TMesh.CalcPlaneNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3: TGLFloat): TAffineVector;

var V1, V2 : TAffineVector;

begin
  V1[0] := x2-x1; V1[1] := y2-y1; V1[2] := z2-z1;
  V2[0] := x3-x1; V2[1] := y3-y1; V2[2] := z3-z1;
  Result := VectorCrossProduct(V1, V2);
  VectorNormalize(Result);
end;

//------------------------------------------------------------------------------

procedure TMesh.CalcNormals(Frontface: TFaceWinding);

var x1, y1, z1, 
    x2, y2, z2, 
    x3, y3, z3  : TGLFloat;
    Vn        : TAffineFltVector;
    I         : Integer;

begin
  case FMode of
    mmTriangles:
      with Vertices do
      begin
        for I := 0 to (Size-1) div (36*SizeOf(TGLFloat)) do
        begin
          x1 := FValues[I*36+ 9]; y1 := FValues[I*36+10]; z1 := FValues[I*36+11];
          x2 := FValues[I*36+21]; y2 := FValues[I*36+22]; z2 := FValues[I*36+23];
          x3 := FValues[I*36+33]; y3 := FValues[I*36+34]; z3 := FValues[I*36+35];
          if FrontFace=fwCounterClockWise then
            Vn := CalcPlaneNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3)
          else
            Vn := CalcPlaneNormal(x3, y3, z3, x2, y2, z2, x1, y1, z1);
          FValues[I*36+ 6] := Vn[0]; FValues[I*36+ 7] := Vn[1]; FValues[I*36+ 8] := Vn[2];
          FValues[I*36+18] := Vn[0]; FValues[I*36+19] := Vn[1]; FValues[I*36+20] := Vn[2];
          FValues[I*36+30] := Vn[0]; FValues[I*36+31] := Vn[1]; FValues[I*36+32] := Vn[2];
        end;
      end;
    mmQuads:
      with Vertices do
      begin
        for I := 0 to (Size-1) div (48*SizeOf(TGLFloat))  do
        begin
          x1 := FValues[I*48+ 9]; y1 := FValues[I*48+10]; z1 := FValues[I*48+11];
          x2 := FValues[I*48+21]; y2 := FValues[I*48+22]; z2 := FValues[I*48+23];
          x3 := FValues[I*48+33]; y3 := FValues[I*48+34]; z3 := FValues[I*48+35];
          if FrontFace=fwCounterClockWise then
            Vn := CalcPlaneNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3)
          else
            Vn := CalcPlaneNormal(x3, y3, z3, x2, y2, z2, x1, y1, z1);
          FValues[I*48+ 6] := Vn[0]; FValues[I*48+ 7] := Vn[1]; FValues[I*48+ 8] := Vn[2];
          FValues[I*48+18] := Vn[0]; FValues[I*48+19] := Vn[1]; FValues[I*48+20] := Vn[2];
          FValues[I*48+30] := Vn[0]; FValues[I*48+31] := Vn[1]; FValues[I*48+32] := Vn[2];
          FValues[I*48+42] := Vn[0]; FValues[I*48+43] := Vn[1]; FValues[I*48+44] := Vn[2];
        end;
      end;
    mmPolygon:
      with Vertices do
      begin
        I := 0;
        x1 := FValues[I+ 9]; y1 := FValues[I+10]; z1 := FValues[I+11];
        x2 := FValues[I+21]; y2 := FValues[I+22]; z2 := FValues[I+23];
        x3 := FValues[I+33]; y3 := FValues[I+34]; z3 := FValues[I+35];
        if FrontFace=fwCounterClockWise then
          Vn := CalcPlaneNormal(x1, y1, z1, x2, y2, z2, x3, y3, z3)
        else
          Vn := CalcPlaneNormal(x3, y3, z3, x2, y2, z2, x1, y1, z1);
        for I := 0 to (Size-1) div (12*SizeOf(TGLFloat)) do
        begin
          FValues[I*12+6] := Vn[0];
          FValues[I*12+7] := Vn[1];
          FValues[I*12+8] := Vn[2];
        end;
      end;
  else ShowMessage('Sorry. Calculating normals only supported for mmTriangles, mmQuads and mmPolygon at present');
  end;
end;

//------------------------------------------------------------------------------

procedure TMesh.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TMesh) then
  begin
    FVertices.Assign(TMesh(Source).Vertices);
    FMode := TMesh(Source).FMode;
  end
  else inherited Assign(Source);
end;

//----------------- TFaceGroups -------------------------------------------------

procedure TFaceGroups.Clear;

var I : Integer;
    FaceGroup : PFaceGroup;

begin
  for I := 0 to Count-1 do
  begin
    FaceGroup := Get(I);
    FaceGroup.FaceProperties.Free;
    FreeMem(FaceGroup.Indices);
    Dispose(FaceGroup);
  end;
  inherited;
end;

//------------------------------------------------------------------------------

function TFaceGroups.GetFaceGroup(Index: Integer): PFaceGroup;
begin
  Result := Get(Index);
end;

//----------------- TTorus -----------------------------------------------------

constructor TTorus.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FRings := 25;
  FSides := 15;
  FMinorRadius := 0.1;
  FMajorRadius := 0.4;
end;

//------------------------------------------------------------------------------

procedure TTorus.BuildList;

var I, J         : Integer;
    Theta, Phi, 
    Theta1, 
    cosPhi, sinPhi, dist : TGLFloat;
    cosTheta, sinTheta: TGLFloat;
    cosTheta1, sinTheta1: TGLFloat;
    ringDelta, sideDelta: TGLFloat;

begin
  inherited BuildList;
  // handle texture generation
  Material.Texture.InitAutoTexture(nil);

  ringDelta := 2*Pi/FRings;
  sideDelta := 2*Pi/FSides;
  theta := 0;
  cosTheta := 1;
  sinTheta := 0;
  for I := FRings-1 downto 0 do
  begin
    theta1 := theta+ringDelta;
    cosTheta1 := cos(theta1);
    sinTheta1 := sin(theta1);
    glBegin(GL_QUAD_STRIP);
    phi := 0;
    for J := FSides downto 0 do
    begin
      phi := phi+sideDelta;
      cosPhi := cos(phi);
      sinPhi := sin(phi);
      dist := FMajorRadius+FMinorRadius*cosPhi;

      glNormal3f(cosTheta1*cosPhi, -sinTheta1*cosPhi, sinPhi);
      glVertex3f(cosTheta1*dist, -sinTheta1*dist, FMinorRadius*sinPhi);
      glNormal3f(cosTheta*cosPhi, -sinTheta*cosPhi, sinPhi);
      glVertex3f(cosTheta*dist, -sinTheta*dist, FMinorRadius*sinPhi);
    end;
    glEnd;
    theta := theta1;
    cosTheta := cosTheta1;
    sinTheta := sinTheta1;
  end;
  Material.Texture.DisableAutoTexture;
end;

//------------------------------------------------------------------------------

procedure TTorus.SetMajorRadius(AValue: Single);

begin
  if FMajorRadius <> AValue then
  begin
    FMajorRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TTorus.SetMinorRadius(AValue: Single);

begin
  if FMinorRadius <> AValue then
  begin
    FMinorRadius := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TTorus.SetRings(AValue: Cardinal);

begin
  if FRings <> AValue then
  begin
    FRings := AValue;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------

procedure TTorus.SetSides(AValue: Cardinal);

begin
  if FSides <> AValue then
  begin
    FSides := AValue;
    StructureChanged;
  end;
end;

//----------------- TTeapot ----------------------------------------------------

constructor TTeapot.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FGrid := 5;
end;

//------------------------------------------------------------------------------

procedure TTeapot.BuildList;

const PatchData : array[0..9, 0..15] of Integer =
      ((102, 103, 104, 105,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15), // rim
       ( 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27), // body
       ( 24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40), // body
       ( 96, 96, 96, 96, 97, 98, 99, 100, 101, 101, 101, 101,  0,  1,  2,  3), // lid
       (  0,  1,  2,  3, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117), // lid
       (118, 118, 118, 118, 124, 122, 119, 121, 123, 126, 125, 120, 40, 39, 38, 37), // bottom
       ( 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56), // handle
       ( 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 28, 65, 66, 67), // handle
       ( 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83), // spout
       ( 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95));// spout

      CPData : array[0..126, 0..2] of TGLFloat =
      ((0.2, 0, 2.7), (0.2, -0.112, 2.7), (0.112, -0.2, 2.7), (0, -0.2, 2.7), (1.3375, 0, 2.53125), 
       (1.3375, -0.749, 2.53125), (0.749, -1.3375, 2.53125), (0, -1.3375, 2.53125), 
       (1.4375, 0, 2.53125), (1.4375, -0.805, 2.53125), (0.805, -1.4375, 2.53125), 
       (0, -1.4375, 2.53125), (1.5, 0, 2.4), (1.5, -0.84, 2.4), (0.84, -1.5, 2.4), (0, -1.5, 2.4), 
       (1.75, 0, 1.875), (1.75, -0.98, 1.875), (0.98, -1.75, 1.875), (0, -1.75, 1.875), (2, 0, 1.35), 
       (2, -1.12, 1.35), (1.12, -2, 1.35), (0, -2, 1.35), (2, 0, 0.9), (2, -1.12, 0.9), (1.12, -2, 0.9), 
       (0, -2, 0.9), (-2, 0, 0.9), (2, 0, 0.45), (2, -1.12, 0.45), (1.12, -2, 0.45), (0, -2, 0.45), 
       (1.5, 0, 0.225), (1.5, -0.84, 0.225), (0.84, -1.5, 0.225), (0, -1.5, 0.225), (1.5, 0, 0.15), 
       (1.5, -0.84, 0.15), (0.84, -1.5, 0.15), (0, -1.5, 0.15), (-1.6, 0, 2.025), (-1.6, -0.3, 2.025), 
       (-1.5, -0.3, 2.25), (-1.5, 0, 2.25), (-2.3, 0, 2.025), (-2.3, -0.3, 2.025), (-2.5, -0.3, 2.25), 
       (-2.5, 0, 2.25), (-2.7, 0, 2.025), (-2.7, -0.3, 2.025), (-3, -0.3, 2.25), (-3, 0, 2.25), 
       (-2.7, 0, 1.8), (-2.7, -0.3, 1.8), (-3, -0.3, 1.8), (-3, 0, 1.8), (-2.7, 0, 1.575), 
       (-2.7, -0.3, 1.575), (-3, -0.3, 1.35), (-3, 0, 1.35), (-2.5, 0, 1.125), (-2.5, -0.3, 1.125), 
       (-2.65, -0.3, 0.9375), (-2.65, 0, 0.9375), (-2, -0.3, 0.9), (-1.9, -0.3, 0.6), (-1.9, 0, 0.6),
       (1.7, 0, 1.425), (1.7, -0.66, 1.425), (1.7, -0.66, 0.6), (1.7, 0, 0.6), (2.6, 0, 1.425), 
       (2.6, -0.66, 1.425), (3.1, -0.66, 0.825), (3.1, 0, 0.825), (2.3, 0, 2.1), (2.3, -0.25, 2.1), 
       (2.4, -0.25, 2.025), (2.4, 0, 2.025), (2.7, 0, 2.4), (2.7, -0.25, 2.4), (3.3, -0.25, 2.4), 
       (3.3, 0, 2.4), (2.8, 0, 2.475), (2.8, -0.25, 2.475), (3.525, -0.25, 2.49375), 
       (3.525, 0, 2.49375), (2.9, 0, 2.475), (2.9, -0.15, 2.475), (3.45, -0.15, 2.5125), 
       (3.45, 0, 2.5125), (2.8, 0, 2.4), (2.8, -0.15, 2.4), (3.2, 0.15, 2.4), (3.2, 0, 2.4), 
       (0, 0, 3.15), (0.8, 0, 3.15), (0.8, -0.45, 3.15), (0.45, -0.8, 3.15), (0, -0.8, 3.15), 
       (0, 0, 2.85), (1.4, 0, 2.4), (1.4, -0.784, 2.4), (0.784, -1.4, 2.4), (0, -1.4, 2.4), 
       (0.4, 0, 2.55), (0.4, -0.224, 2.55), (0.224, -0.4, 2.55), (0, -0.4, 2.55), (1.3, 0, 2.55), 
       (1.3, -0.728, 2.55), (0.728, -1.3, 2.55), (0, -1.3, 2.55), (1.3, 0, 2.4), (1.3, -0.728, 2.4), 
       (0.728, -1.3, 2.4), (0, -1.3, 2.4), (0, 0, 0), (1.425, -0.798, 0), (1.5, 0, 0.075), (1.425, 0, 0), 
       (0.798, -1.425, 0), (0, -1.5, 0.075), (0, -1.425, 0), (1.5, -0.84, 0.075), (0.84, -1.5, 0.075));

      Tex : array[0..1, 0..1, 0..1] of TGLFloat = (((0, 0), (1, 0)), ((0, 1), (1, 1)));

var P, Q, R, S  : array[0..3, 0..3, 0..2] of TGLFloat;
    I, J, K, L, 
    GRD      : Integer;

begin
  inherited BuildList;

  if FGrid < 2 then FGrid := 2;
  GRD := FGrid;
  glPushMatrix;
  glTranslatef(0, -0.25, 0);
  glRotatef(-90, 1, 0, 0);
  glScalef(0.15, 0.15, 0.15);
  glPushAttrib(GL_POLYGON_BIT or GL_ENABLE_BIT or GL_EVAL_BIT);
  glFrontFace(GL_CW);
  glEnable(GL_AUTO_NORMAL);
  glEnable(GL_MAP2_VERTEX_3);
  glEnable(GL_MAP2_TEXTURE_COORD_2);
  for I := 0 to 9 do
  begin
    for J := 0 to 3 do
    begin
      for K := 0 to 3 do
      begin
        for L := 0 to 2 do
        begin
          P[J, K, L] := CPData[PatchData[I, J*4+K], L];
          Q[J, K, L] := CPData[PatchData[I, J*4+(3-K)], L];
          if L = 1 then Q[J, K, L] := -Q[J, K, L];
          if I < 6 then
          begin
            R[J, K, L] := CPData[PatchData[I, J*4+(3-K)], L];
            if L = 0 then R[J, K, L] := -R[J, K, L];
            S[J, K, L] := CPData[PatchData[I, J*4+K], L];
            if L < 2 then S[J, K, L] := -S[J, K, L];
          end;
        end;
      end;
    end;
    glMapGrid2f(GRD, 0, 1, GRD, 0, 1);
    glMap2f(GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2, 0, 1, 4, 2, @Tex);
    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @P);
    glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @Q);
    glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    if I < 6 then
    begin
      glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @R);
      glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
      glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4, 0, 1, 12, 4, @S);
      glEvalMesh2(GL_FILL, 0, GRD, 0, GRD);
    end;
  end;
  glPopAttrib;
  glPopMatrix;
end;

//----------------- TSpaceText ----------------------------------------------------

constructor TSpaceText.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FFont := TFont.Create;
  FFont.Name := 'Arial';
  FontChanged := True;
  FExtrusion := 0;
  CharacterRange:=stcrAll;
end;

//------------------------------------------------------------------------------

destructor TSpaceText.Destroy;

begin
  FFont.Free;
  FontManager.Release(BaseList);
  inherited Destroy;
end;

// BuildList
//
procedure TSpaceText.BuildList;
begin
	inherited BuildList;
	if Length(FText) > 0 then begin
		// create texture coordinates if necessary
		//    if not (Material.Texture.Disabled)  and  not (Material.Texture.IsInherited) then
		Material.Texture.InitAutoTexture(nil);
		glPushAttrib(GL_POLYGON_BIT);
		case FCharacterRange of
			stcrAlphaNum :	glListBase(BaseList-32);
			stcrNumbers : glListBase(BaseList-Cardinal('0'));
		else
			glListBase(BaseList);
		end;
		glCallLists(Length(FText), GL_UNSIGNED_BYTE, PChar(FText));
		glPopAttrib;
		//Material.Texture.DisableAutoTexture;
	end;
end;

// PrepareObject
//
procedure TSpaceText.PrepareObject;
var
	firstChar, lastChar : Integer;
begin
	if FontChanged and (Length(FText) > 0) then with FFont do begin
		FontManager.Release(BaseList);
		case FCharacterRange of
			stcrAlphaNum : begin
				firstChar:=32; lastChar:=127;
			end;
			stcrNumbers : begin
				firstChar:=Integer('0'); lastChar:=Integer('9');
			end;
		else
			// stcrAll
			firstChar:=0; lastChar:=255;
		end;
		BaseList := FontManager.GetFontBase(Name, Style, FExtrusion,
														FAllowedDeviation, firstChar, lastChar);
		FontChanged := False;
	end;
	inherited PrepareObject;
end;

// SetExtrusion
//
procedure TSpaceText.SetExtrusion(AValue: Single);
begin
	if FExtrusion <> AValue then begin
		FExtrusion := AValue;
		FontChanged := True;
		StructureChanged;
	end;
end;

// SetAllowedDeviation
//
procedure TSpaceText.SetAllowedDeviation(const val : Single);
begin
	if FAllowedDeviation <> val then begin
		FAllowedDeviation := val;
		FontChanged := True;
		StructureChanged;
	end;
end;

// SetCharacterRange
//
procedure TSpaceText.SetCharacterRange(const val : TSpaceTextCharRange);
begin
	if FCharacterRange<>val then begin
		FCharacterRange:=val;
		FontChanged:=True;
		StructureChanged;
	end;
end;

//------------------------------------------------------------------------------

procedure TSpaceText.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
  FontChanged := True;
  StructureChanged;
end;

//------------------------------------------------------------------------------

procedure TSpaceText.SetText(AText: String);

begin
  if FText <> AText then
  begin
    FText := AText;
    StructureChanged;
  end;
end;

//----------------- TDodecahedron ----------------------------------------------

procedure TDodecahedron.BuildList;

const A = 1.61803398875; // (Sqrt(5)+1)/2
      B = 0.61803398875; // (Sqrt(5)-1)/2
      C = 1;

const Vertices : array[0..19, 0..2] of TGLFloat =
      ((-A, 0, B), (-A, 0, -B), (A, 0, -B), (A, 0, B), 
       (B, -A, 0), (-B, -A, 0), (-B, A, 0), (B, A, 0), 
       (0, B, -A), (0, -B, -A), (0, -B, A), (0, B, A), 
       (-C, -C, C), (-C, -C, -C), (C, -C, -C), (C, -C, C), 
       (-C, C, C), (-C, C, -C), (C, C, -C), (C, C, C));

      Polygons : array[0..11, 0..4] of TGLInt =
      (( 0, 12, 10, 11, 16),
       ( 1, 17, 8, 9, 13), 
       ( 2, 14, 9, 8, 18), 
       ( 3, 19, 11, 10, 15), 
       ( 4, 14, 2, 3, 15), 
       ( 5, 12, 0, 1, 13), 
       ( 6, 17, 1, 0, 16), 
       ( 7, 19, 3, 2, 18), 
       ( 8, 17, 6, 7, 18), 
       ( 9, 14, 4, 5, 13), 
       (10, 12, 5, 4, 15), 
       (11, 19, 7, 6, 16));

var I     : Integer;
    U, V, N : TAffineVector;

begin
  inherited BuildList;

  glScalef(0.3, 0.3, 0.3);
  for I := 0 to 11 do
  begin
    U[0] := Vertices[Polygons[I, 2], 0]-Vertices[Polygons[I, 1], 0];
    U[1] := Vertices[Polygons[I, 2], 1]-Vertices[Polygons[I, 1], 1];
    U[2] := Vertices[Polygons[I, 2], 2]-Vertices[Polygons[I, 1], 2];

    V[0] := Vertices[Polygons[I, 0], 0]-Vertices[Polygons[I, 1], 0];
    V[1] := Vertices[Polygons[I, 0], 1]-Vertices[Polygons[I, 1], 1];
    V[2] := Vertices[Polygons[I, 0], 2]-Vertices[Polygons[I, 1], 2];

    N := VectorCrossProduct(U, V);
    VectorNormalize(N);

    glBegin(GL_TRIANGLE_FAN);
    glNormal3fv(@N);
    glVertex3fv(@Vertices[Polygons[I, 0], 0]);
    glVertex3fv(@Vertices[Polygons[I, 1], 0]);
    glVertex3fv(@Vertices[Polygons[I, 2], 0]);
    glVertex3fv(@Vertices[Polygons[I, 3], 0]);
    glVertex3fv(@Vertices[Polygons[I, 4], 0]);
    glEnd;
  end;
end;

//----------------- TRotationSolid ---------------------------------------------

procedure TRotationSolid.BuildList;

begin
  inherited BuildList;
end;

//------------------------------------------------------------------------------

initialization

  FontManager := TFontManager.Create;

  // need to explicitly register these classes
  RegisterClasses([TSphere, TCube, TCylinder, TCone, TTorus, TSpaceText, TMesh,
						 TTeapot, TDodecahedron, TDisk, TPlane, TDummyCube, TSprite]);

finalization

  FontManager.Free;

end.
