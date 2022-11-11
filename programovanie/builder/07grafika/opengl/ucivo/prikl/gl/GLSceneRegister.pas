{: GLTexture<p>

  Registration unit for GLScene library.<p>

	<b>Historique : </b><font size=-1><ul>
		<li>18/03/00 - Egg - Added TGLImageClassProperty
		<li>13/03/00 - Egg - Updated TGLTextureImageProperty
      <li>14/02/00 - Egg - Added MaterialLibrary editor and picker
      <li>09/02/00 - Egg - ObjectManager moved in, ObjectManager is now fully
                           object-oriented and encapsulated
      <li>06/02/00 - Egg - Fixed TGLScenedEditor logic
                           (was causing Delphi IDE crashes on package unload)
      <li>05/02/00 - Egg - Added TGLColorProperty and TGLCoordinatesProperty
	</ul></font>
}
unit GLSceneRegister;

// Registration unit for GLScene library
// 30-DEC-99 ml: scene editor added, structural changes

interface

{$I DFS.inc}

uses Windows, PlugInManager, GLScene, Controls, Classes;

type

	PSceneObjectEntry = ^TGLSceneObjectEntry;
	// holds a relation between an scene object class, its global identification,
	// its location in the object stock and its icon reference
	TGLSceneObjectEntry = record
								  ObjectClass : TGLSceneObjectClass;
								  Name : String[32];    // type name of the object
								  Index,                // index into "FObjectStock"
								  ImageIndex : Integer; // index into "FObjectIcons"
								end;


	// TObjectManager
   //
   TObjectManager = class(TResourceManager)
      private
         { Private Declarations }
         FSceneObjectList : TList;
         FObjectStock : TGLSceneObject;     // a list of objects, which can be used for scene building
         FObjectIcons : TImageList;       // a list of icons for scene objects
         FOverlayIndex,                   // indices into the object icon list
         FSceneRootIndex,
         FCameraRootIndex,
         FLightsourceRootIndex,
         FObjectRootIndex,
         FStockObjectRootIndex : Integer;

      protected
			{ Protected Declarations }
         procedure CreateDefaultObjectIcons;
         procedure DestroySceneObjectList;
         function FindSceneObjectClass(AObjectClass: TGLSceneObjectClass; ASceneObject: String) : PSceneObjectEntry;

      public
         { Public Declarations }
         constructor Create(Aowner: TComponent); override;
         destructor Destroy; override;

         function GetClassFromIndex(Index: Integer): TGLSceneObjectClass;
         function GetImageIndex(ASceneObject: TGLSceneObjectClass) : Integer;
         procedure GetRegisteredSceneObjects(ObjectList: TStringList);
         //: Registers a stock object and adds it to the stock object list
         procedure RegisterSceneObject(ASceneObject: TGLSceneObjectClass; AName: String; AImage: HBitmap);
         procedure UnRegisterSceneObject(ASceneObject: TGLSceneObjectClass; AName: String);
         procedure Notify(Sender: TPlugInManager; Operation: TOperation; PlugIn: Integer); override;

         property ObjectIcons: TImageList read FObjectIcons;
         property SceneRootIndex: Integer read FSceneRootIndex;
         property LightsourceRootIndex: Integer read FLightsourceRootIndex;
			property CameraRootIndex: Integer read FCameraRootIndex;
         property ObjectRootIndex: Integer read FObjectRootIndex;

      end;

procedure Register;

//: Auto-create for object manager
function ObjectManager : TObjectManager;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
  DsgnIntf, GLScreen, GLObjects, GLTexture, SysUtils, Dialogs, GLVectorFileObjects,
  ExtDlgs, Forms, GLSceneEdit, Graphics, AsyncTimer, FVectorEditor, Geometry,
  FMaterialEditorForm, FLibMaterialPicker, TypInfo;

{$R GLObjects.Res}

var
	vObjectManager : TObjectManager;

function ObjectManager : TObjectManager;
begin
   if not Assigned(vObjectManager) then
      vObjectManager:=TObjectManager.Create(nil);
   Result:=vObjectManager;
end;

{ TODO : Moving property editors to the public interface }
type

   // TGLSceneViewerEditor
   //
   TGLSceneViewerEditor = class(TComponentEditor)
      public
			{ Public Declarations }
			procedure ExecuteVerb(Index: Integer); override;
			function GetVerb(Index: Integer): String; override;
			function GetVerbCount: Integer; override;
	end;

   // TGLSceneEditor
   //
   TGLSceneEditor = class(TComponentEditor)
      public
         { Public Declarations }
         procedure Edit; override;
   end;

  TPlugInProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: String; override;
  end;

  TResolutionProperty = class(TPropertyEditor)
	 function GetAttributes: TPropertyAttributes; override;
	 function GetValue : String; override;
	 procedure GetValues(Proc: TGetStrProc); override;
	 procedure SetValue(const Value: String); override;
  end;

  TGLTextureProperty = class(TClassProperty)
  protected
	 function GetAttributes: TPropertyAttributes; override;
  end;

  TGLTextureImageProperty = class(TClassProperty)
  protected
	 function GetAttributes: TPropertyAttributes; override;
	 procedure Edit; override;
  end;

	// TGLImageClassProperty
	//
	TGLImageClassProperty = class(TClassProperty)
		protected
			{ Protected Declarations }
			function GetAttributes : TPropertyAttributes; override;
			procedure GetValues(proc : TGetStrProc); override;

		public
			{ Public Declarations }
			function GetValue : String; override;
			procedure SetValue(const value : String); override;
	end;

  TGLColorProperty = class(TClassProperty)
  private
  protected
	 function GetAttributes: TPropertyAttributes; override;
	 procedure GetValues(Proc: TGetStrProc); override;
	 procedure Edit; override;
  public
	 {$ifdef DFS_COMPILER_5_UP}
	 procedure ListDrawValue(const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
	 procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean); override;
	 {$endif}
	 function GetValue: String; override;
	 procedure SetValue(const Value: string); override;
  end;

  TVectorFileProperty = class(TClassProperty)
  protected
	 function GetAttributes: TPropertyAttributes; override;
    function GetValue: String; override;
    procedure Edit; override;
    procedure SetValue(const Value: string); override;
  end;

   // TGLCoordinatesProperty
   //
   TGLCoordinatesProperty = class(TClassProperty)
      protected
         { Protected Declarations }
         procedure Edit; override;
   end;

   // TGLMaterialProperty
   //
   TGLMaterialProperty = class(TClassProperty)
      protected
         { Protected Declarations }
         procedure Edit; override;
   end;

   // TReuseableDefaultEditor
   //
   {: Editor copied from DsgnIntf.<p>
      Could have been avoided, if only that short-sighted guy at Borland didn't
      chose to publish only half of the stuff (and that not the only class with
      that problem, most of the subitems handling code in TGLSceneBaseObject is
      here for the same reason...), the "protected" wasn't meant just to lure
      programmers into code they can't reuse... }
   TReuseableDefaultEditor = class (TComponentEditor)
      protected
         { Protected Declarations }
         FFirst: TPropertyEditor;
			FBest: TPropertyEditor;
         FContinue: Boolean;
         procedure CheckEdit(PropertyEditor: TPropertyEditor);
         procedure EditProperty(PropertyEditor: TPropertyEditor;
                                var Continue, FreeEditor: Boolean); virtual;
      public
         { Public Declarations }
         procedure Edit; override;
   end;

   // TGLMaterialLibraryEditor
   //
   {: Editor for material library.<p> }
   TGLMaterialLibraryEditor = class(TReuseableDefaultEditor)
      protected
         procedure EditProperty(PropertyEditor: TPropertyEditor;
                                var Continue, FreeEditor: Boolean); override;
   end;

   // TGLLibMaterialNameProperty
   //
	TGLLibMaterialNameProperty = class(TStringProperty)
      protected
         { Protected Declarations }
         procedure Edit; override;
   end;

//----------------- TObjectManager -------------------------------------------------------------

constructor TObjectManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSceneObjectList := TList.Create;
  FObjectStock := TGLSceneObject.Create(nil);
  FObjectStock.Name := 'FObjectStock';
  CreateDefaultObjectIcons;
end;

destructor TObjectManager.Destroy;
begin
   DestroySceneObjectList;
   FObjectStock.Free;  // scene object instances will be freed by the destructor
   FObjectIcons.Free;
   inherited Destroy;
end;

procedure TObjectManager.Notify(Sender: TPlugInManager; Operation: TOperation; PlugIn: Integer);
begin
end;

function TObjectManager.FindSceneObjectClass(AObjectClass: TGLSceneObjectClass; ASceneObject: String) : PSceneObjectEntry;
var
   I     : Integer;
   Found : Boolean;
begin
   Result := nil;
   Found := False;
   with FSceneObjectList do begin
      for I := 0 to Count-1 do
         with TGLSceneObjectEntry(Items[I]^) do
         if (ObjectClass = AObjectClass) and (Length(ASceneObject) = 0)
               or (CompareText(Name, ASceneObject) = 0) then begin
            Found := True;
            Break;
         end;
      if Found then Result := Items[I];
   end;
end;

//------------------------------------------------------------------------------

function TObjectManager.GetClassFromIndex(Index: Integer): TGLSceneObjectClass;

begin
  if Index < 0 then Index := 0;
  if Index > FSceneObjectList.Count-1 then Index := FSceneObjectList.Count-1;
  Result := TGLSceneObjectEntry(FSceneObjectList.Items[Index+1]^).ObjectClass;
end;

//------------------------------------------------------------------------------

function TObjectManager.GetImageIndex(ASceneObject: TGLSceneObjectClass) : Integer;
var
   AClassEntry : PSceneObjectEntry;
   AName       : String;
begin
   AName := '';
   AClassEntry := FindSceneObjectClass(ASceneObject, AName);
   if assigned(AClassEntry) then
      Result := AClassEntry^.ImageIndex
   else Result := 0;
end;

//------------------------------------------------------------------------------

procedure TObjectManager.GetRegisteredSceneObjects(objectList: TStringList);
var
   i : Integer;
begin
   if Assigned(objectList) then with objectList do begin
      Clear;
      for I := 1 to FSceneObjectList.Count-1 do
         Add(TGLSceneObjectEntry(FSceneObjectList.Items[I]^).Name);
   end;
end;

//------------------------------------------------------------------------------

procedure TObjectManager.RegisterSceneObject(ASceneObject: TGLSceneObjectClass; AName: String; AImage: HBitmap);
var NewEntry  : PSceneObjectEntry;
    AInstance : TGLBaseSceneObject;
    Pic       : TPicture;

begin
  with FSceneObjectList do
  begin
    // make sure no class is registered twice
    if assigned(FindSceneObjectClass(ASceneObject, AName)) then Exit;
    New(NewEntry);
    Pic := TPicture.Create;
    try
      with NewEntry^ do
      begin
        // object stock stuff
        AInstance := ASceneObject.Create(FObjectStock);
        AInstance.Name := AName;
        FObjectStock.AddChild(AInstance);
        // registered objects list stuff
        ObjectClass := ASceneObject;
        NewEntry^.Name := AName;
        Index := AInstance.Index;
        if AImage <> 0 then
        begin
          Pic.Bitmap.Handle := AImage;
          FObjectIcons.AddMasked(Pic.Bitmap, Pic.Bitmap.Canvas.Pixels[0, 0]);
          ImageIndex := FObjectIcons.Count-1;
        end
        else ImageIndex := 0;
      end;
      Add(NewEntry);
    finally
      Pic.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TObjectManager.UnRegisterSceneObject(ASceneObject: TGLSceneObjectClass; AName: String);

// unregisters a stock object and removes it from the stock object list

var OldEntry : PSceneObjectEntry;
    AObject  : TGLBaseSceneObject;

begin
  // find the class in the scene object list
  OldEntry := FindSceneObjectClass(ASceneObject, AName);
  // found?
  if assigned(OldEntry) then
  begin
    // yes, so get its instance in "FObjectStock"
    AObject := FObjectStock[OldEntry^.Index];
    // remove its entry from the list of registered objects
    FSceneObjectList.Remove(OldEntry);
    // free the instance
    FObjectStock[OldEntry.Index].Free;
    // remove the instance entry from object stock
    FObjectStock.Remove(AObject, False);
    // finally free the memory for the entry 
    Dispose(OldEntry);
  end;
end;

//------------------------------------------------------------------------------

procedure TObjectManager.CreateDefaultObjectIcons;

var Pic : TPicture;

begin
  Pic := TPicture.Create;
  // load first pic to get size
  Pic.Bitmap.Handle := LoadBitmap(HInstance, 'GLS_CROSS_16');
  FObjectIcons := TImageList.CreateSize(Pic.Width, Pic.height);
  with FObjectIcons, Pic.Bitmap.Canvas do
  try
    // There's a more direct way for loading images into the image list, but
    // the image quality suffers too much
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FOverlayIndex := Count-1;
    Overlay(FOverlayIndex, 0); // used as indicator for disabled objects
    Pic.Bitmap.Handle := LoadBitmap(HInstance, 'GLS_UNIVERSE2_16');
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FSceneRootIndex := Count-1;
    Pic.Bitmap.Handle := LoadBitmap(HInstance, 'GLS_CAMERA2_16');
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FCameraRootIndex := Count-1;
    Pic.Bitmap.Handle := LoadBitmap(HInstance, 'GLS_LAMPS2_16');
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FLightsourceRootIndex := Count-1;
    Pic.Bitmap.Handle := LoadBitmap(HInstance, 'GLS_OBJECTS2_16');
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FObjectRootIndex := Count-1;
    AddMasked(Pic.Bitmap, Pixels[0, 0]); FStockObjectRootIndex := Count-1;
  finally
    Pic.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TObjectManager.DestroySceneObjectList;

var I : Integer;

begin
  with FSceneObjectList do
  begin
    for I := 0 to Count-1 do FreeMem(Items[I]);
    Free;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TGLSceneViewerEditor.ExecuteVerb(Index: Integer);

var
  Source: TGLSceneViewer;

begin
  Source := Component as TGLSceneViewer;
  case Index of
    0:
      Source.ShowInfo;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TGLSceneViewerEditor.GetVerb(Index: Integer): string;

begin
  case Index of
    0:
      Result := 'Show context info';
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TGLSceneViewerEditor.GetVerbCount: Integer;

begin
  Result := 1;
end;

//----------------- TGLSceneEditor -------------------------------------------------------------------------------------

procedure TGLSceneEditor.Edit;
begin
   with GLSceneEditorForm do begin
      SetScene(Self.Component as TGLScene, Self.Designer);
      Show;
   end;
end;

//----------------- TPlugInProperty ------------------------------------------------------------------------------------

procedure TPlugInProperty.Edit;

var
  Manager: TPlugInManager;

begin
  Manager := TPlugInList(GetOrdValue).Owner;
  Manager.EditPlugInList;
end;

//----------------------------------------------------------------------------------------------------------------------

function TPlugInProperty.GetAttributes: TPropertyAttributes;

begin
  Result:=[paDialog];
end;


//----------------------------------------------------------------------------------------------------------------------

function TPlugInProperty.GetValue: String;

begin
  Result := 'registered : ' + IntToStr(TStringList(GetOrdValue).Count);
end;

//----------------- TResolutionProperty --------------------------------------------------------------------------------

function TResolutionProperty.GetAttributes: TPropertyAttributes;

begin
  Result:=[paValueList];
end;

//----------------------------------------------------------------------------------------------------------------------

function TResolutionProperty.GetValue : String;

begin
  Result:=VideoModes[GetOrdValue].Description;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TResolutionProperty.GetValues(Proc: TGetStrProc);

var
  I: Integer;

begin
  for I:=0 to NumberVideoModes-1 do Proc(VideoModes[I].Description);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TResolutionProperty.SetValue(const Value: String);

const Nums = ['0'..'9'];

var XRes,YRes,BPP : Integer;
    Pos, SLength  : Integer;
    TempStr       : String;

begin
  if CompareText(Value,'default') <> 0 then
  begin
    // initialize scanning
    TempStr:=Trim(Value)+'|'; // ensure at least one delimiter
    SLength:=Length(TempStr);
    XRes:=0; YRes:=0; BPP:=0;
    // contains the string something?
    if SLength > 1 then
    begin
      // determine first number
      for Pos:=1 to SLength do
        if not (TempStr[Pos] in Nums) then Break;
      if Pos <= SLength then
      begin
        // found a number?
        XRes:=StrToInt(Copy(TempStr,1,Pos-1));
        // search for following non-numerics
        for Pos:=Pos to SLength do
          if TempStr[Pos] in Nums then Break;
        Delete(TempStr,1,Pos-1); // take it out of the String
        SLength:=Length(TempStr); // rest length of String
        if SLength > 1 then // something to scan?
        begin
          // determine second number
          for Pos:=1 to SLength do
            if not (TempStr[Pos] in Nums) then Break;
          if Pos <= SLength then
          begin
            YRes:=StrToInt(Copy(TempStr,1,Pos-1));
            // search for following non-numerics
            for Pos:=Pos to SLength do
              if TempStr[Pos] in Nums then Break;
            Delete(TempStr,1,Pos-1); // take it out of the String
            SLength:=Length(TempStr); // rest length of String
            if SLength > 1 then
            begin
              for Pos:=1 to SLength do
                if not (TempStr[Pos] in Nums) then Break;
              if Pos <= SLength then BPP:=StrToInt(Copy(TempStr,1,Pos-1));
            end;
          end;
        end;
      end;
    end;
    SetOrdValue(GetIndexFromResolution(XRes,YRes,BPP));
  end
  else SetOrdValue(0);
end;
                           
//----------------- TGLTextureProperty -----------------------------------------

function TGLTextureProperty.GetAttributes: TPropertyAttributes;

begin
  Result:=[paSubProperties];
end;

//----------------- TGLTextureImageProperty ------------------------------------

// GetAttributes
//
function TGLTextureImageProperty.GetAttributes: TPropertyAttributes;
begin
	Result:=[paDialog];
end;

// Edit
//
procedure TGLTextureImageProperty.Edit;
var
	ownerTexture : TGLTexture;
begin
	ownerTexture:=TGLTextureImage(GetOrdValue).OwnerTexture;
	if ownerTexture.Image.Edit then
		Designer.Modified;
end;

//----------------- TGLImageClassProperty --------------------------------------

// GetAttributes
//
function TGLImageClassProperty.GetAttributes: TPropertyAttributes;
begin
	Result:=[paValueList];
end;

// GetValues
//
procedure TGLImageClassProperty.GetValues(proc: TGetStrProc);
var
	i : Integer;
	sl : TStrings;
begin
	sl:=GetGLTextureImageClassesAsStrings;
	try
		for i:=0 to sl.Count-1 do proc(sl[i]);
	finally
		sl.Free;
	end;
end;

// GetValue
//
function TGLImageClassProperty.GetValue : String;
begin
	Result:=FindGLTextureImageClass(GetStrValue).FriendlyName;
end;

// SetValue
//
procedure TGLImageClassProperty.SetValue(const value : String);
var
	tic : TGLTextureImageClass;
begin
	tic:=FindGLTextureImageClassByFriendlyName(value);
	if Assigned(tic) then
		SetStrValue(tic.ClassName)
	else SetStrValue('');
	Modified;
end;

//----------------- TGLColorproperty -----------------------------------------------------------------------------------

procedure TGLColorProperty.Edit;
var
	colorDialog : TColorDialog;
   glColor : TGLColor;
begin
   colorDialog:=TColorDialog.Create(nil);
   try
      glColor:=TGLColor(GetOrdValue);
      colorDialog.Options:=[cdFullOpen];
      colorDialog.Color:=ConvertColorVector(glColor.Color);
      if colorDialog.Execute then begin
         glColor.Color:=ConvertWinColor(colorDialog.Color);
         Modified;
      end;
   finally
      colorDialog.Free;
   end;
end;

function TGLColorProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paSubProperties, paValueList];
end;

procedure TGLColorProperty.GetValues(Proc: TGetStrProc);
begin
  ColorManager.EnumColors(Proc);
end;

function TGLColorProperty.GetValue: String;
begin
  Result := ColorManager.GetColorName(TGLColor(GetOrdValue).Color);
end;

procedure TGLColorProperty.SetValue(const Value: string);
begin
  TGLColor(GetOrdValue).Color := ColorManager.GetColor(Value);
  Modified;
end;

{$ifdef DFS_COMPILER_5_UP}
// Owner draw color values, only available in D5 and higher
procedure TGLColorProperty.ListDrawValue(const Value: string; ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);

   function ColorToBorderColor(AColor: TColorVector): TColor;
   begin
      if (AColor[0] > 0.75) or (AColor[1] > 0.75) or (AColor[2] > 0.75) then
         Result := clBlack
      else if ASelected then
         Result := clWhite
      else Result := ConvertColorVector(AColor);
   end;

var
  vRight: Integer;
  vOldPenColor,
  vOldBrushColor: TColor;
  Color: TColorVector;
begin
  vRight := (ARect.Bottom - ARect.Top) + ARect.Left;
  with ACanvas do
  try
    vOldPenColor := Pen.Color;
    vOldBrushColor := Brush.Color;

    Pen.Color := Brush.Color;
    Rectangle(ARect.Left, ARect.Top, vRight, ARect.Bottom);

    Color := ColorManager.GetColor(Value);
    Brush.Color := ConvertColorVector(Color);
    Pen.Color := ColorToBorderColor(Color);

    Rectangle(ARect.Left + 1, ARect.Top + 1, vRight - 1, ARect.Bottom - 1);

    Brush.Color := vOldBrushColor;
    Pen.Color := vOldPenColor;
  finally
    inherited ListDrawValue(Value, ACanvas, Rect(vRight, ARect.Top, ARect.Right, ARect.Bottom), ASelected);
  end;
end;

procedure TGLColorProperty.PropDrawValue(ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
   // draws the small color rectangle in the object inspector
   if GetVisualValue<>'' then
      ListDrawValue(GetVisualValue, ACanvas, ARect, True)
   else inherited PropDrawValue(ACanvas, ARect, ASelected);
end;
{$endif}

//----------------- TVectorFileProperty --------------------------------------------------------------------------------

function TVectorFileProperty.GetAttributes: TPropertyAttributes;
begin
   Result := [paDialog];
end;

function TVectorFileProperty.GetValue: String;
begin
   Result := GetStrValue;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TVectorFileProperty.Edit;
var
   ODialog   : TOpenDialog;
   Component : TFreeForm;
   Desc, F    : String;
begin
   Component := GetComponent(0) as TFreeForm;
   ODialog := TOpenDialog.Create(nil);
   try
      GetVectorFileFormats.BuildFilterStrings(TVectorFile, Desc, F);
      ODialog.Filter := Desc;
      if ODialog.Execute then begin
         Component.LoadFromFile(ODialog.FileName);
         Modified;
      end;
   finally
      ODialog.Free;
   end;
end;

procedure TVectorFileProperty.SetValue(const Value: string);
begin
   SetStrValue(Value);
end;

//----------------- TGLCoordinatesProperty --------------------------------------------------------------------------------

procedure TGLCoordinatesProperty.Edit;
var
   glc : TGLCoordinates;
   x, y, z : Single;
begin
   glc:=TGLCoordinates(GetOrdValue);
   x:=glc.x;
   y:=glc.y;
   z:=glc.z;
   if VectorEditorForm.Execute(x, y, z) then begin
      glc.AsVector:=MakeVector(x, y, z);
      Modified;
   end;
end;

//----------------- TGLMaterialProperty --------------------------------------------------------------------------------

procedure TGLMaterialProperty.Edit;
begin
	if MaterialEditorForm.Execute(TGLMaterial(GetOrdValue)) then
		Modified;
end;

//----------------- TReuseableDefaultEditor --------------------------------------------------------------------------------

// CheckEdit
//
procedure TReuseableDefaultEditor.CheckEdit(PropertyEditor: TPropertyEditor);
var
  FreeEditor: Boolean;
begin
  FreeEditor := True;
  try
    if FContinue then EditProperty(PropertyEditor, FContinue, FreeEditor);
  finally
    if FreeEditor then PropertyEditor.Free;
  end;
end;

// EditProperty
//
procedure TReuseableDefaultEditor.EditProperty(PropertyEditor: TPropertyEditor;
                                               var Continue, FreeEditor: Boolean);
var
  PropName: string;
  BestName: string;

  procedure ReplaceBest;
  begin
    FBest.Free;
    FBest := PropertyEditor;
    if FFirst = FBest then FFirst := nil;
    FreeEditor := False;
  end;

begin
  if not Assigned(FFirst) and (PropertyEditor is TMethodProperty) then
  begin
    FreeEditor := False;
    FFirst := PropertyEditor;
  end;
  PropName := PropertyEditor.GetName;
  BestName := '';
  if Assigned(FBest) then BestName := FBest.GetName;
  if CompareText(PropName, 'ONCREATE') = 0 then
    ReplaceBest
  else if CompareText(BestName, 'ONCREATE') <> 0 then
    if CompareText(PropName, 'ONCHANGE') = 0 then
      ReplaceBest
    else if CompareText(BestName, 'ONCHANGE') <> 0 then
      if CompareText(PropName, 'ONCLICK') = 0 then
        ReplaceBest;
end;

// Edit
//
procedure TReuseableDefaultEditor.Edit;
var
  Components: TDesignerSelectionList;
begin
  Components := TDesignerSelectionList.Create;
  try
    FContinue := True;
    Components.Add(Component);
    FFirst := nil;
    FBest := nil;
    try
      GetComponentProperties(Components, tkAny, Designer, CheckEdit);
      if FContinue then
        if Assigned(FBest) then
          FBest.Edit
        else if Assigned(FFirst) then
          FFirst.Edit;
    finally
      FFirst.Free;
      FBest.Free;
    end;
  finally
    Components.Free;
  end;
end;

//----------------- TGLMaterialLibraryEditor --------------------------------------------------------------------------------

procedure TGLMaterialLibraryEditor.EditProperty(PropertyEditor: TPropertyEditor;
                                                var Continue, FreeEditor: Boolean);
begin
   if CompareText(PropertyEditor.GetName, 'MATERIALS') = 0 then begin
      FBest.Free;
      FBest := PropertyEditor;
      FreeEditor := False;
   end;
end;

//----------------- TGLLibMaterialNameProperty --------------------------------------------------------------------------------

procedure TGLLibMaterialNameProperty.Edit;
var
   buf : String;
   ml : TGLMaterialLibrary;
begin
   buf:=GetStrValue;
   ml:=(GetComponent(0) as TGLMaterial).MaterialLibrary;
	if not Assigned(ml) then
      ShowMessage('Select the material library first.')
   else if LibMaterialPicker.Execute(buf, ml) then
      SetStrValue(buf);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure Register;

begin
  RegisterComponents('OpenGL', [TGLScene, TGLSceneViewer, TPlugInManager,
                                TAsyncTimer, TGLMaterialLibrary]);
  RegisterComponentEditor(TGLSceneViewer, TGLSceneViewerEditor);
  RegisterComponentEditor(TGLScene, TGLSceneEditor);
  RegisterComponentEditor(TGLMaterialLibrary, TGLMaterialLibraryEditor);
  RegisterPropertyEditor(TypeInfo(TPlugInList), TPlugInManager, 'PlugIns', TPlugInProperty);
  RegisterPropertyEditor(TypeInfo(TResolution), nil, '', TResolutionProperty);
  RegisterPropertyEditor(TypeInfo(TGLColor), nil, '', TGLColorProperty);
  RegisterPropertyEditor(TypeInfo(TGLTexture), TGLMaterial, '', TGLTextureProperty);
  RegisterPropertyEditor(TypeInfo(TGLTextureImage), TGLTexture, '', TGLTextureImageProperty);
  RegisterPropertyEditor(TypeInfo(String), TGLTexture, 'ImageClassName', TGLImageClassProperty);
  RegisterPropertyEditor(TypeInfo(TGLCoordinates), nil, '', TGLCoordinatesProperty);
  RegisterPropertyEditor(TypeInfo(TGLMaterial), nil, '', TGLMaterialProperty);
  RegisterPropertyEditor(TypeInfo(TGLLibMaterialName), TGLMaterial, '', TGLLibMaterialNameProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TFreeForm, 'FileName', TVectorFileProperty);
  // this registration is solely to make those classes working with the object inspector
  RegisterNoIcon([TGLLightSource, TGLCamera, TSphere, TCube, TCylinder, TCone, TTorus,
						TSpaceText, TMesh, TFreeForm, TTeapot, TDodecahedron, TDisk, TPlane,
						TActor, TDummyCube, TSprite]);
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

  with ObjectManager do begin
    RegisterSceneObject(TGLCamera, 'Camera', LoadBitmap(HInstance, 'GLS_CAMERA_16'));
	 RegisterSceneObject(TGLLightSource, 'Lightsource', LoadBitmap(HInstance, 'GLS_LAMP_16'));
	 RegisterSceneObject(TDummyCube, 'DummyCube', LoadBitmap(HInstance, 'GLS_DUMMYCUBE_16'));
	 RegisterSceneObject(TPlane, 'Plane', LoadBitmap(HInstance, 'GLS_PLANE_16'));
	 RegisterSceneObject(TSprite, 'Sprite', LoadBitmap(HInstance, 'GLS_SPRITE_16'));
	 RegisterSceneObject(TCube, 'Cube', LoadBitmap(HInstance, 'GLS_CUBE_16'));
    RegisterSceneObject(TDisk, 'Disk', LoadBitmap(HInstance, 'GLS_DISK_16'));
    RegisterSceneObject(TSphere, 'Sphere', LoadBitmap(HInstance, 'GLS_SPHERE_16'));
    RegisterSceneObject(TCylinder, 'Cylinder', LoadBitmap(HInstance, 'GLS_CYLINDER_16'));
    RegisterSceneObject(TCone, 'Cone', LoadBitmap(HInstance, 'GLS_CONE_16'));
    RegisterSceneObject(TTorus, 'Torus', LoadBitmap(HInstance, 'GLS_TORUS_16'));
    RegisterSceneObject(TSpaceText, 'SpaceText', LoadBitmap(HInstance, 'GLS_TEXT_16'));
    RegisterSceneObject(TMesh, 'Mesh', LoadBitmap(HInstance, 'GLS_FREEFORM_16'));
    RegisterSceneObject(TFreeForm, 'FreeForm', LoadBitmap(HInstance, 'GLS_FREEFORM_16'));
    RegisterSceneObject(TActor, 'Actor', LoadBitmap(HInstance, 'GLS_FREEFORM_16'));
    RegisterSceneObject(TTeapot, 'Teapot', LoadBitmap(HInstance, 'GLS_TEAPOT_16'));
    RegisterSceneObject(TDodecahedron, 'Dodecahedron', LoadBitmap(HInstance, 'GLS_DODECAHEDRON_16'));
    //RegisterSceneObject(TRotationSolid, 'RotationSolid', 0);
  end;

finalization

  ObjectManager.Free;

end.
