{: GLVectorFileObjects

	Vector File related objects for GLScene<p>

	<b>Historique : </b><font size=-1><ul>
	   <li>09/02/00 - Egg - Creation from split of GLObjects,
                           fixed class registrations and formats unregistration
	</ul></font>
}
unit GLVectorFileObjects;

interface

uses Classes, GLScene, GLObjects, OpenGL12, Geometry, AsyncTimer, SysUtils,
     // 3DS Support
	  File3DS, Types3DS,
     // MD2 Support
	  FileMD2, TypeMD2;

type

      TFreeForm = class;

      // TVectorFile is an abstract base class for different vector file
      // formats like 3DS, DXF. The actual implementation for these
      // files must be done seperately. The concept for TVectorFile
      // is very similar to TGraphic (see there)
      TVectorFile = class(TPersistent)
      private
        FOwner : TFreeForm;
      public
        constructor Create(AOwner: TFreeForm); virtual;

        procedure BuildMeshObjects(Version: TReleaseLevel; Materials: TMaterialList; Objects: TObjectList); virtual; abstract;
        procedure LoadFromFile(const FileName: String); virtual; abstract;
        procedure LoadFromStream(Stream: TStream); virtual; abstract;

        property Owner: TFreeForm read FOwner;
      end;

      TVectorFileClass = class of TVectorFile;

      // TGL3DSVectorFile
      //
      // The 3DStudio vector file
      TGL3DSVectorFile = class(TVectorFile)
      public
        procedure BuildMeshObjects(Version: TReleaseLevel; Materials: TMaterialList; Objects: TObjectList); override;
        procedure LoadFromFile(const FileName: String); override;
        procedure LoadFromStream(Stream: TStream); override;
      end;

      // TGLMD2VectorFile
      //
      //: The md2 vector file
      TGLMD2VectorFile = class(TVectorFile)
      public
        function ConvertMD2Structure(MD2File: TFileMD2; frame: Integer): PMeshObject;
        procedure LoadFromFile(const FileName: String); override;
        //procedure LoadFromStream(Stream: TStream); override;
      end;

      TFreeForm = class(TGLSceneObject)
      private
        FObjects: TList;     // a list of mesh objects
        FWinding: TGLEnum;
        FCenter: TAffineVector; // used when autocentering externally loaded data
      public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        function AddMeshObject(AObject: PMeshObject): Integer; virtual;
        procedure Assign(Source: TPersistent); override;
        procedure BuildList; override;
        procedure Clear;
        procedure LoadFromFile(const Filename: string);

        property Winding: TGLEnum read FWinding;
      end;


      TActor = class(TFreeForm)
      private
        FNumberFrame: Integer;
        FStartFrame,
        FEndFrame: Integer;
        FCurrentFrame: Integer;

        FTimer: TAsyncTimer;
        FAction: Boolean;
        FInterval: Integer;

        procedure SetInterval(Value: Integer);
        procedure SetAction(Value: Boolean);

        procedure ActionOnTimer(Sender: TObject);

        procedure SetCurrentFrame(Value: Integer);
        procedure SetStartFrame(Value: Integer);
        procedure SetEndFrame(Value: Integer);
      public
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

        procedure Assign(Source: TPersistent); override;
        procedure BuildList; override;
        procedure LoadFromFile(const Filename: string);

        procedure NextFrame(N: Integer);
        procedure PrevFrame(N: Integer);

        property Winding: TGLEnum read FWinding;
      published
        property NumberFrame: Integer read FNumberFrame;
        property StartFrame: Integer read FStartFrame write SetStartFrame;
        property EndFrame: Integer read FEndFrame write SetEndFrame;
        property CurrentFrame: Integer read FCurrentFrame write SetCurrentFrame;

        property Action: Boolean read FAction write SetAction;
        property Interval: Integer read FInterval write SetInterval;
      end;


     PVectorFileFormat = ^TVectorFileFormat;
     TVectorFileFormat = record
       VectorFileClass : TVectorFileClass;
       Extension       : String;
       Description     : String;
       DescResID       : Integer;
     end;


     TVectorFileFormatsList = class(TList)
     public
       destructor Destroy; override;
       procedure Add(const Ext, Desc: String; DescID: Integer; AClass: TVectorFileClass);
       function FindExt(Ext: string): TVectorFileClass;
       procedure Remove(AClass: TVectorFileClass);
       procedure BuildFilterStrings(VectorFileClass: TVectorFileClass; var Descriptions, Filters: string);
     end;

     EInvalidVectorFile = class(Exception);


function GetVectorFileFormats: TVectorFileFormatsList;
procedure RegisterVectorFileFormat(const AExtension, ADescription: String; AClass: TVectorFileClass);
procedure UnregisterVectorFileClass(AClass: TVectorFileClass);

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses GLStrings, consts, GLTexture;

var
   vVectorFileFormats : TVectorFileFormatsList;

function GetVectorFileFormats: TVectorFileFormatsList;
begin
   if not Assigned(vVectorFileFormats)then
      vVectorFileFormats := TVectorFileFormatsList.Create;
   Result := vVectorFileFormats;
end;

procedure RegisterVectorFileFormat(const AExtension, ADescription: String; AClass: TVectorFileClass);
begin
  GetVectorFileFormats.Add(AExtension, ADescription, 0, AClass);
end;

procedure UnregisterVectorFileClass(AClass: TVectorFileClass);
begin
   if Assigned(vVectorFileFormats) then
      vVectorFileFormats.Remove(AClass);
end;

//----------------- vector format support --------------------------------------

destructor TVectorFileFormatsList.Destroy;

var I: Integer;

begin
  for I := 0 to Count - 1 do Dispose(PVectorFileFormat(Items[I]));
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TVectorFileFormatsList.Add(const Ext, Desc: String; DescID: Integer;
                                     AClass: TVectorFileClass);

var NewRec: PVectorFileFormat;

begin
  New(NewRec);
  with NewRec^ do
  begin
    Extension := AnsiLowerCase(Ext);
    VectorFileClass := AClass;
    Description := Desc;
    DescResID := DescID;
  end;
  inherited Add(NewRec);
end;

//------------------------------------------------------------------------------

function TVectorFileFormatsList.FindExt(Ext: string): TVectorFileClass;

var I: Integer;

begin
  Ext := AnsiLowerCase(Ext);
  for I := Count-1 downto 0 do
    with PVectorFileFormat(Items[I])^ do
      if Extension = Ext then
      begin
        Result := VectorFileClass;
        Exit;
      end;
  Result := nil;
end;

//------------------------------------------------------------------------------

procedure TVectorFileFormatsList.Remove(AClass: TVectorFileClass);

var I : Integer;
    P : PVectorFileFormat;

begin
  for I := Count-1 downto 0 do
  begin
    P := PVectorFileFormat(Items[I]);
    if P^.VectorFileClass.InheritsFrom(AClass) then
    begin
      Dispose(P);
      Delete(I);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TVectorFileFormatsList.BuildFilterStrings(VectorFileClass: TVectorFileClass;
                                                    var Descriptions, Filters: string);

var C, I : Integer;
    P    : PVectorFileFormat;

begin
  Descriptions := '';
  Filters := '';
  C := 0;
  for I := Count-1 downto 0 do
  begin
    P := PVectorFileFormat(Items[I]);
    if P^.VectorFileClass.InheritsFrom(VectorFileClass) and (P^.Extension <> '') then
      with P^ do
      begin
        if C <> 0 then
        begin
          Descriptions := Descriptions+'|';
          Filters := Filters+';';
        end;
        if (Description = '') and (DescResID <> 0) then Description := LoadStr(DescResID);
        FmtStr(Descriptions, '%s%s (*.%s)|*.%2:s', [Descriptions, Description, Extension]);
        FmtStr(Filters, '%s*.%s', [Filters, Extension]);
        Inc(C);
      end;
  end;
  if C > 1 then FmtStr(Descriptions, '%s (%s)|%1:s|%s', [sAllFilter, Filters, Descriptions]);
end;

//----------------- TVectorFile ------------------------------------------------

constructor TVectorFile.Create(AOwner: TFreeForm);

begin
  FOwner := AOwner;
  inherited Create;
end;

//----------------- TGL3DSVectorFile -------------------------------------------

procedure TGL3DSVectorFile.BuildMeshObjects(Version: TReleaseLevel; Materials: TMaterialList; Objects: TObjectList);

type
  TSmoothIndexEntry = array[0..31] of Cardinal;

  PSmoothIndexArray = ^TSmoothIndexArray;
  TSmoothIndexArray = array[0..0] of TSmoothIndexEntry;

var
  Marker: PByteArray;
  CurrentVertexCount: Cardinal;
  SmoothIndices: PSmoothIndexArray;
  Mesh: PMeshObject;

  //--------------- local functions -------------------------------------------

  function FacePropsFromMaterial(const Name: String): TGLFaceProperties;

  var
    material: PMaterial3DS;

  begin
    material := Materials.MaterialByName[Name];
    Assert(Assigned(material));
    Result := TGLFaceProperties.Create(nil);
    with Result do begin
      Ambient.Color := MakeVector([Material.Ambient.R, Material.Ambient.G, Material.Ambient.B, 1]);
      Diffuse.Color := MakeVector([Material.Diffuse.R, Material.Diffuse.G, Material.Diffuse.B, 1]);
      Specular.Color := MakeVector([Material.Specular.R, Material.Specular.G, Material.Specular.B, 1]);
      VectorScale(Specular.Color, 1 - Material.Shininess);
      Shininess := Round((1 - Material.ShinStrength) * 128);
    end;
  end;

  //----------------------------------------------------------------------

  function IsVertexMarked(P: Pointer; Index: Integer): Boolean; assembler;

  // tests the Index-th bit, returns True if set else False

  asm
                     BT [EAX], EDX
                     SETC AL
  end;

  //---------------------------------------------------------------------------

  function MarkVertex(P: Pointer; Index: Integer): Boolean; assembler;

  // sets the Index-th bit and return True if it was already set else False

  asm
                     BTS [EAX], EDX
                     SETC AL
  end;

  //---------------------------------------------------------------------------

  procedure StoreSmoothIndex(ThisIndex, SmoothingGroup, NewIndex: Cardinal; P: Pointer);

  // Stores new vertex index (NewIndex) into the smooth index array of vertex ThisIndex
  // using field SmoothingGroup, which must not be 0.
  // For each vertex in the vertex array (also for duplicated vertices) an array of 32 cardinals
  // is maintained (each for one possible smoothing group. If a vertex must be duplicated because
  // it has no smoothing group or a different one then the index of the newly created vertex is
  // stored in the SmoothIndices to avoid loosing the conjunction between not yet processed vertices
  // and duplicated vertices.
  // Note: Only one smoothing must be assigned per vertex. Some available models break this rule and
  //       have more than one group assigned to a face. To make the code fail safe the group ID
  //       is scanned for the lowest bit set.

  asm
                   PUSH EBX
                   BSF EBX, EDX                  // determine smoothing group index (convert flag into an index)
                   MOV EDX, [P]                  // get address of index array
                   SHL EAX, 7                    // ThisIndex * SizeOf(TSmoothIndexEntry)
                   ADD EAX, EDX
                   LEA EDX, [4 * EBX + EAX]      // Address of array + vertex index + smoothing group index
                   MOV [EDX], ECX
                   POP EBX
  end;

  //---------------------------------------------------------------------------

  function GetSmoothIndex(ThisIndex, SmoothingGroup: Cardinal; P: Pointer): Cardinal;

  // Retrieves the vertex index for the given index and smoothing group.
  // This redirection is necessary because a vertex might have been duplicated.

  asm
                   PUSH EBX
                   BSF EBX, EDX                  // determine smoothing group index
                   SHL EAX, 7                    // ThisIndex * SizeOf(TSmoothIndexEntry)
                   ADD EAX, ECX
                   LEA ECX, [4 * EBX + EAX]      // Address of array + vertex index + smoothing group index
                   MOV EAX, [ECX]
                   POP EBX
  end;
  
  //---------------------------------------------------------------------------

  procedure DuplicateVertex(Index: Integer);

  // extends the vector and normal array by one entry and duplicates the vertex data given by Index
  // the marker and texture arrays will be extended too, if necessary

  begin
    // enhance vertex array
    ReallocMem(Mesh.Vertices, (CurrentVertexCount + 1) * SizeOf(TVector3f));
    Mesh.Vertices[CurrentVertexCount] := Mesh.Vertices[Index];

    // enhance normal array
    ReallocMem(Mesh.Normals, (CurrentVertexCount + 1) * SizeOf(TVector3f));
    Mesh.Normals[CurrentVertexCount] := NullVector;

    // enhance smooth index array
    ReallocMem(SmoothIndices, (CurrentVertexCount + 1) * SizeOf(TSmoothIndexEntry));
    FillChar(SmoothIndices[CurrentVertexCount], SizeOf(TSmoothIndexEntry), $FF);

    // enhance marker array
    if (CurrentVertexCount div 8) <> ((CurrentVertexCount + 1) div 8) then
    begin
      ReallocMem(Marker, ((CurrentVertexCount + 1) div 8) + 1);
      Marker[(CurrentVertexCount div 8) + 1] := 0;
    end;

    // enhance texture coordinates array
    if assigned(Mesh.TexCoords) then
    begin
      ReallocMem(Mesh.TexCoords, (CurrentVertexCount + 1) * SizeOf(TTexVert3DS));
      Mesh.TexCoords[CurrentVertexCount] := Mesh.TexCoords[Index];
    end;

    Inc(CurrentVertexCount);
  end;

  //--------------- end local functions ---------------------------------------

var
  Size: Cardinal;
  Material,
  I, J: Integer;
  FaceGroup: PFaceGroup;
  V1, V2: TAffineVector;
  Face,
  SubFace,
  Vertex,
  TargetVertex: Integer;
  SmoothingGroup: Cardinal;
  CurrentIndex: Word;
  Vector1,
  Vector2,
  Normal: TAffineVector;
  TotalCount: Cardinal;

begin
  // determine front face winding
  if Version >= rlRelease3 then FOwner.FWinding := GL_CCW
                           else FOwner.FWinding := GL_CW;
  TotalCount := 0;

  for I := 0 to Objects.MeshCount - 1 do
  with PMesh3DS(Objects.Mesh[I])^ do
  begin
    if IsHidden or (NVertices < 3) then Continue;

    // New() just calls GetMem, but I want the memory cleared
    Mesh := AllocMem(SizeOf(TMeshObject));
    Mesh.Mode := mmTriangles;
    // make a copy of the vertex data, this must always be available
    CurrentVertexCount := NVertices;
    Size := NVertices * SizeOf(TPoint3DS);
    // allocate memory, we do not need to clear it
    GetMem(Mesh.Vertices, Size);
    // we don't need to consider the local mesh matrix here, since all vertices are already
    // transformed into their final positions
    Move(VertexArray^, Mesh.Vertices^, Size);

    // texturing data available (optional)?
    if NTextVerts > 0 then
    begin
      Size := NTextVerts * SizeOf(TTexVert3DS);
      GetMem(Mesh.TexCoords, Size);
      Move(TextArray^, Mesh.TexCoords^, Size);
    end;

    // allocate memory for the face normal array, the final normal array and the marker array
    Mesh.Normals := AllocMem(NVertices * SizeOf(TVector3f));
    Marker := AllocMem((NVertices div 8) + 1); // one bit for each vertex
    GetMem(SmoothIndices, NVertices * SizeOf(TSmoothIndexEntry));

    if SmoothArray = nil then
    begin
      // no smoothing groups to consider
      for Face := 0 to NFaces - 1 do
      with FaceArray[Face], Mesh^ do
      begin
        // normal vector for the face
        Vector1 := VectorAffineSubtract(Vertices[V1], Vertices[V2]);
        Vector2 := VectorAffineSubtract(Vertices[V3], Vertices[V2]);
        if Version < rlRelease3 then Normal := VectorCrossProduct(Vector1, Vector2)
                                 else Normal := VectorCrossProduct(Vector2, Vector1);
        // go for each vertex in the current face
        for Vertex := 0 to 2 do
        begin
          // copy current index for faster access
          CurrentIndex := FaceRec[Vertex];
          // already been touched?
          if IsVertexMarked(Marker, CurrentIndex) then
          begin
            // already touched vertex must be duplicated
            DuplicateVertex(CurrentIndex);
            FaceRec[Vertex] := CurrentVertexCount - 1;
            Normals[CurrentVertexCount - 1] := Normal;
          end
          else
          begin
            // not yet touched, so just store the normal
            Normals[CurrentIndex] := Normal;
            MarkVertex(Marker, CurrentIndex);
          end;
        end;
      end;
    end
    else
    begin
      // smoothing groups are to be considered
      for Face := 0 to NFaces - 1 do
      with FaceArray[Face], Mesh^ do
      begin
        // normal vector for the face
        Vector1 := VectorAffineSubtract(Vertices[V1], Vertices[V2]);
        Vector2 := VectorAffineSubtract(Vertices[V3], Vertices[V2]);
        if Version < rlRelease3 then Normal := VectorCrossProduct(Vector1, Vector2)
                                else Normal := VectorCrossProduct(Vector2, Vector1);
        SmoothingGroup := SmoothArray[Face];

        // go for each vertex in the current face
        for Vertex := 0 to 2 do
        begin
          // copy current index for faster access
          CurrentIndex := FaceRec[Vertex];
          // Has vertex already been touched?
          if IsVertexMarked(Marker, CurrentIndex) then
          begin
            // check smoothing group
            if SmoothingGroup = 0 then
            begin
              // no smoothing then just duplicate vertex
              DuplicateVertex(CurrentIndex);
              FaceRec[Vertex] := CurrentVertexCount - 1;
              Normals[CurrentVertexCount - 1] := Normal;
              // mark new vertex also as touched
              MarkVertex(Marker, CurrentVertexCount - 1);
            end
            else
            begin
              // this vertex must be smoothed, check if there's already a (duplicated) vertex
              // for this smoothing group
              TargetVertex := GetSmoothIndex(CurrentIndex, SmoothingGroup, SmoothIndices);
              if TargetVertex < 0 then
              begin
                // vertex has not yet been duplicated for this smoothing group, so do it now
                DuplicateVertex(CurrentIndex);
                FaceRec[Vertex] := CurrentVertexCount - 1;
                Normals[CurrentVertexCount - 1] := Normal;
                StoreSmoothIndex(CurrentIndex, SmoothingGroup, CurrentVertexCount - 1, SmoothIndices);
                StoreSmoothIndex(CurrentVertexCount - 1, SmoothingGroup, CurrentVertexCount - 1, SmoothIndices);
                // mark new vertex also as touched
                MarkVertex(Marker, CurrentVertexCount - 1);
              end
              else
              begin
                // vertex has already been duplicated, so just add normal vector to other vertex...
                Normals[TargetVertex] := VectorAffineAdd(Normals[TargetVertex], Normal);
                // ...and tell which new vertex has to be used from now on
                FaceRec[Vertex] := TargetVertex;
              end;
            end;
          end
          else
          begin
            // vertex not yet touched, so just store the normal
            Normals[CurrentIndex] := Normal;
            // initialize smooth indices for this vertex
            FillChar(SmoothIndices[CurrentIndex], SizeOf(TSmoothIndexEntry), $FF);
            if SmoothingGroup <> 0 then StoreSmoothIndex(CurrentIndex, SmoothingGroup, CurrentIndex, SmoothIndices);
            MarkVertex(Marker, CurrentIndex);
          end;
        end;
      end;
    end;
    FreeMem(Marker);
    FreeMem(SmoothIndices);

    // sum up all vertices to do auto centering
    Inc(TotalCount, CurrentVertexCount);
    with Mesh^, FOwner do
    begin
      for J := 0 to CurrentVertexCount - 1 do
        FCenter := VectorAffineAdd(FCenter, Vertices[J]);
    end;

    // finally normalize the Normals array
    with Mesh^ do
      for J := 0 to CurrentVertexCount - 1 do VectorNormalize(Normals[J]);

    // now go for each material group
    Mesh.FaceGroups := TFaceGroups.Create;
    // if there's no face to material assignment then just copy the
    // face definitions and rely on the default texture of the scene object
    if NMats = 0 then
    begin
      New(FaceGroup);
      with FaceGroup^ do
      begin
        FaceProperties := TGLFaceProperties.Create(nil);
        IndexCount := 3 * NFaces;
        GetMem(Indices, IndexCount * SizeOf(Integer));
        // copy the face list
        for J := 0 to NFaces - 1 do
        begin
          Indices[3 * J + 0] := FaceArray[J].V1;
          Indices[3 * J + 1] := FaceArray[J].V2;
          Indices[3 * J + 2] := FaceArray[J].V3;
        end;
      end;
      Mesh.FaceGroups.Add(FaceGroup);
    end
    else
    begin
      for Material := 0 to NMats - 1 do
      begin
        New(FaceGroup);
        with FaceGroup^ do
        begin
          FaceProperties := FacePropsFromMaterial(MatArray[Material].Name);
          IndexCount := 3 * MatArray[Material].NFaces;
          GetMem(Indices, IndexCount * SizeOf(Integer));
          // copy all vertices belonging to the current face into our index array, 
          // there won't be redundant vertices since this would mean a face has more than one
          // material
          with MatArray[Material] do
            for J := 0 to NFaces - 1 do // NFaces is the one from FaceGroup
            begin
              Indices[3 * J + 0] := FaceArray[FaceIndex[J]].V1;
              Indices[3 * J + 1] := FaceArray[FaceIndex[J]].V2;
              Indices[3 * J + 2] := FaceArray[FaceIndex[J]].V3;
            end;
        end;
        Mesh.FaceGroups.Add(FaceGroup);
      end;
    end;
    FOwner.AddMeshObject(Mesh);
  end;
  if TotalCount > 0 then VectorScale(FOwner.FCenter, 1 / TotalCount);
end;

//------------------------------------------------------------------------------

procedure TGL3DSVectorFile.LoadFromFile(const FileName: String);

begin
  with TFile3DS.CreateFromFile(FileName) do
  try
    BuildMeshObjects(DatabaseRelease, Materials, Objects);
  finally
    Free;
  end;
end;

//------------------------------------------------------------------------------

procedure TGL3DSVectorFile.LoadFromStream(Stream: TStream);

begin
  with TFile3DS.Create do
  try
    LoadFromStream(Stream);
    BuildMeshObjects(DatabaseRelease, Materials, Objects);
  finally
    Free;
  end;
end;

//----------------- TFreeForm --------------------------------------------------

constructor TFreeForm.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FObjects := TList.Create;
end;

//------------------------------------------------------------------------------

destructor TFreeForm.Destroy;

begin
  Clear;
  FObjects.Free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TFreeForm.BuildList;

var I, J : Integer;
    Mesh : PMeshObject;

begin
  inherited BuildList;
  glPushAttrib(GL_POLYGON_BIT);
  glFrontFace(FWinding);
  // move scene so that its geometric center is at origin
  glTranslatef(-FCenter[0], -FCenter[1], -FCenter[2]);

  // go through all loaded meshs
  for I := 0 to FObjects.Count-1 do
  begin
    Mesh := FObjects[I];

    // there must always be a list of vertices
    glVertexPointer(3, GL_FLOAT, 0, Mesh.Vertices);
    glEnableClientState(GL_VERTEX_ARRAY);

    // enable the normal array if available
    if assigned(Mesh.Normals) then
    begin
      glNormalPointer(GL_FLOAT, 0, Mesh.Normals);
      glEnableClientState(GL_NORMAL_ARRAY);
    end
    else glDisableCLientState(GL_NORMAL_ARRAY);

    // enable the texture coordinates array if available
    if assigned(Mesh.TexCoords) then
    begin
      glTexCoordPointer(2, GL_FLOAT, 0, Mesh.TexCoords);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      {Scene.CurrentViewer.RequestedState([stTexture2D]);
      Material.Texture.Apply;}
    end
    else
    begin
      glDisableCLientState(GL_TEXTURE_COORD_ARRAY);
      //Scene.CurrentViewer.UnnecessaryState([stTexture2D]);
    end;

    for J := 0 to Mesh.FaceGroups.Count - 1 do
      with Mesh.FaceGroups[J]^ do
      begin
         Material.FrontProperties.Apply(GL_FRONT);
//        FaceProperties.Apply(GL_FRONT);
        case Mesh.Mode of
          mmTriangleStrip:
            glDrawElements(GL_TRIANGLE_STRIP, IndexCount, GL_UNSIGNED_INT, Indices);
          mmTriangleFan:
            glDrawElements(GL_TRIANGLE_FAN, IndexCount, GL_UNSIGNED_INT, Indices);
          mmTriangles:
            glDrawElements(GL_TRIANGLES, IndexCount, GL_UNSIGNED_INT, Indices);
          mmQuadStrip:
            glDrawElements(GL_QUAD_STRIP, IndexCount, GL_UNSIGNED_INT, Indices);
          mmQuads:
            glDrawElements(GL_QUADS, IndexCount, GL_UNSIGNED_INT, Indices);
          mmPolygon:
            glDrawElements(GL_POLYGON, IndexCount, GL_UNSIGNED_INT, Indices);
        end;
      end;
  end;
  glPopAttrib;
end;

//------------------------------------------------------------------------------

procedure TFreeForm.Clear;

var Mesh : PMeshObject;
    I    : Integer;

begin
  for I := 0 to FObjects.Count - 1 do
  begin
    Mesh := FObjects[I];
    if assigned(Mesh.Vertices) then FreeMem(Mesh.Vertices);
    if assigned(Mesh.Normals) then FreeMem(Mesh.Normals);
    if assigned(Mesh.TexCoords) then FreeMem(Mesh.TexCoords);
    Mesh.FaceGroups.Free;
    Dispose(Mesh);
  end;
  FObjects.Clear;
  FCenter := NullVector;
end;

//------------------------------------------------------------------------------

procedure TFreeForm.LoadFromFile(const Filename: String);

var Ext           : String;
    NewVectorFile : TVectorFile;
    VectorFileClass : TVectorFileClass;

begin
  if FileName <> '' then
  begin
    Clear;
    Ext := ExtractFileExt(Filename);
    Delete(Ext, 1, 1);
    VectorFileClass := GetVectorFileFormats.FindExt(Ext);
    if VectorFileClass = nil then
      raise EInvalidVectorFile.CreateFmt(SUnknownExtension, [Ext]);
    NewVectorFile := VectorFileClass.Create(Self);
    try
      if assigned(Scene) then Scene.BeginUpdate;
      NewVectorFile.LoadFromFile(Filename);
      if assigned(Scene) then Scene.EndUpdate;
    except
      NewVectorFile.Free;
      raise;
    end;
  end;
  StructureChanged;
end;

//------------------------------------------------------------------------------

function TFreeForm.AddMeshObject(AObject: PMeshObject): Integer;

begin
  Result := FObjects.Add(AObject);
end;

//------------------------------------------------------------------------------

procedure TFreeForm.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TMesh) then
  begin
{    FVertices.Assign(TMesh(Source).Vertices);
    FMode := TMesh(Source).FMode;}
  end;
  inherited Assign(Source);
end;

//----------------- TActor -----------------------------------------------------

constructor TActor.Create(AOwner:TComponent);

begin
  inherited Create(AOwner);
  FNumberFrame := 0;
  FStartFrame := 0;
  FEndFrame := 0;
  FCurrentFrame := 0;

  // 20 frames per second
  FInterval := 100;
  FTimer := TAsyncTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := FInterval;
  FTimer.OnTimer := ActionOnTimer;
  //First, we should keep the scene move smoothly, not the actor
  FTimer.TimerThreadPriority := tpNormal;
  FTimer.TakerThreadPriority := tpIdle;
  FAction := False;
end;

//------------------------------------------------------------------------------

destructor TActor.Destroy;
begin
  FTimer.Enabled := False;
  FTimer.free;
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TActor.SetInterval(Value: Integer);
begin
  if Value<>FInterval then
    FInterval := Value;
  if FInterval=0 then
  begin
    FTimer.Enabled := False;
    FTimer.Interval := 0;
    FAction := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TActor.SetAction(Value: Boolean);
begin
  if FInterval=0 then
    exit;
  if Value<>FAction then
  begin
    FAction := Value;
    FTimer.Enabled := FAction;
  end;
end;

//------------------------------------------------------------------------------

procedure TActor.ActionOnTimer(Sender: TObject);
begin
  if (FNumberFrame>1) and (FStartFrame<>FEndFrame) then
    NextFrame(1);
end;


//------------------------------------------------------------------------------
procedure TActor.SetCurrentFrame(Value: Integer);
begin
  if Value<>FCurrentFrame then
  begin
    if Value>NumberFrame-1 then
      FCurrentFrame := NumberFrame-1
    else
      if Value<0 then
        FCurrentFrame := 0
      else
        FCurrentFrame := Value;
    StructureChanged;
  end;
end;

//------------------------------------------------------------------------------
procedure TActor.SetStartFrame(Value: Integer);
begin
  if (Value>=0) and (Value<NumberFrame) and (Value<>FStartFrame) then
    FStartFrame := Value;
  if FEndFrame<FStartFrame then
    FEndFrame := FStartFrame;
  if FCurrentFrame<FStartFrame then
    CurrentFrame := FStartFrame;
end;

//------------------------------------------------------------------------------
procedure TActor.SetEndFrame(Value: Integer);
begin
  if (Value>=0) and (Value<NumberFrame) and (Value<>FEndFrame) then
    FEndFrame := Value;
  if FCurrentFrame>FEndFrame then
    CurrentFrame := FEndFrame;
end;

//------------------------------------------------------------------------------
procedure TActor.NextFrame(N: Integer);
var
  Value: Integer;
begin
  Value := FCurrentFrame + N;
  if Value>FEndFrame then
  begin
    Value := FStartFrame + (Value - FEndFrame);
    if Value>FEndFrame then
      Value := FEndFrame;
  end;
  CurrentFrame := Value;
end;

//------------------------------------------------------------------------------
procedure TActor.PrevFrame(N: Integer);
var
  Value: Integer;
begin
  Value := FCurrentFrame - N;
  if Value<FStartFrame then
  begin
    Value := FEndFrame - (FStartFrame - Value);
    if Value<FStartFrame then
      Value := FStartFrame;
  end;
  CurrentFrame := Value;
end;


//------------------------------------------------------------------------------
procedure TActor.BuildList;

var
  Mesh : PMeshObject;
  I: Integer;
  FaceGroup: PFaceGroup;

begin
  // Build List can not inherited from TFreeForm, so apply it direct
  glListBase(0);

  // go through all loaded meshs
  if FObjects.Count=0 then
  begin
//    glPopAttrib;
    exit;
  end;


  glFrontFace(FWinding);

  Mesh := FObjects[FCurrentFrame];
  glShadeModel(GL_SMOOTH);

  glBegin(GL_TRIANGLES);
  FaceGroup := Mesh.FaceGroups[0];
  for I:=0 to (FaceGroup.IndexCount div 3)-1 do
  begin
    glTexCoord2f(Mesh.TexCoords[3*I+0].s, Mesh.TexCoords[3*I+0].t);
    glVertex3f(Mesh.Vertices[FaceGroup.Indices[3*I+0]][0],
      Mesh.Vertices[FaceGroup.Indices[3*I+0]][1],
      Mesh.Vertices[FaceGroup.Indices[3*I+0]][2]);
    glTexCoord2f(Mesh.TexCoords[3*I+1].s, Mesh.TexCoords[3*I+1].t);
    glVertex3f(Mesh.Vertices[FaceGroup.Indices[3*I+1]][0],
      Mesh.Vertices[FaceGroup.Indices[3*I+1]][1],
      Mesh.Vertices[FaceGroup.Indices[3*I+1]][2]);
    glTexCoord2f(Mesh.TexCoords[3*I+2].s, Mesh.TexCoords[3*I+2].t);
    glVertex3f(Mesh.Vertices[FaceGroup.Indices[3*I+2]][0],
      Mesh.Vertices[FaceGroup.Indices[3*I+2]][1],
      Mesh.Vertices[FaceGroup.Indices[3*I+2]][2]);
  end;
  {
  for I:=0 to (Mesh.FaceGroups[0].IndexCount div 3)-1 do
  begin
    glTexCoord2f(Mesh.TexCoords[3*I+0].s, Mesh.TexCoords[3*I+0].t);
    glVertex3f(Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+0]][0],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+0]][1],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+0]][2]);
    glTexCoord2f(Mesh.TexCoords[3*I+1].s, Mesh.TexCoords[3*I+1].t);
    glVertex3f(Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+1]][0],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+1]][1],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+1]][2]);
    glTexCoord2f(Mesh.TexCoords[3*I+2].s, Mesh.TexCoords[3*I+2].t);
    glVertex3f(Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+2]][0],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+2]][1],
      Mesh.Vertices[Mesh.FaceGroups[0].Indices[3*I+2]][2]);
  end;
  }
  glEnd;

//  glPopAttrib;
end;

//------------------------------------------------------------------------------

procedure TActor.LoadFromFile(const Filename: String);

var Ext           : String;
    NewVectorFile : TVectorFile;
    VectorFileClass : TVectorFileClass;

begin
  if FileName <> '' then
  begin
    FStartFrame := 0;
    FEndFrame := 0;
    FCurrentFrame := 0;
    FNumberFrame := 0;
    Clear;
    Ext := ExtractFileExt(Filename);
    Delete(Ext, 1, 1);
    VectorFileClass := GetVectorFileFormats.FindExt(Ext);
    if VectorFileClass = nil then
      raise EInvalidVectorFile.CreateFmt(SUnknownExtension, [Ext]);
    NewVectorFile := VectorFileClass.Create(Self);
    try
      if assigned(Scene) then Scene.BeginUpdate;
      NewVectorFile.LoadFromFile(Filename);
      if assigned(Scene) then Scene.EndUpdate;
    except
      NewVectorFile.Free;
      raise;
    end;
  end;
  FNumberFrame := FObjects.Count;
  FStartFrame := 0;
  FEndFrame := FObjects.Count-1;
  FCurrentFrame := 0;
  StructureChanged;
end;

//------------------------------------------------------------------------------

procedure TActor.Assign(Source:TPersistent);

begin
  if assigned(Source) and (Source is TActor) then
  begin
{    FVertices.Assign(TMesh(Source).Vertices);
    FMode := TMesh(Source).FMode;}
  end;
  inherited Assign(Source);
end;

//----------------- TGLMD2VectorFile -------------------------------------------

function TGLMD2VectorFile.ConvertMD2Structure(MD2File: TFileMD2; frame: Integer): PMeshObject;
var
  I: Integer;
  Mesh: PMeshObject;
  FaceGroup: PFaceGroup;
begin
  New(Mesh);
  FillChar(Mesh^, SizeOf(Mesh^), 0);
  Mesh^.Mode := mmTriangles;
  with Mesh^, MD2File do
  begin
    GetMem(Vertices, m_iVertices * sizeof(TAffineVector));
    GetMem(TexCoords, 3* m_iTriangles * sizeof(TTexPoint));

    FaceGroups := TFaceGroups.Create;
    with FaceGroups do
    begin
      New(FaceGroup);
      with FaceGroup^ do
      begin
        FaceProperties := TGLFaceProperties.Create(nil);
        IndexCount := 3 * m_iTriangles;
        GetMem(Indices, IndexCount * SizeOf(Integer));
        // copy the face list
        for I := 0 to m_iTriangles - 1 do
        begin
          TexCoords[I*3].S := IndexList(m_index_list)[i].a_s;
          TexCoords[I*3].t := IndexList(m_index_list)[i].a_t;
          Indices[I*3] := IndexList(m_index_list)[i].a;

          TexCoords[I*3+1].S := IndexList(m_index_list)[i].b_s;
          TexCoords[I*3+1].t := IndexList(m_index_list)[i].b_t;
          Indices[I*3+1] := IndexList(m_index_list)[i].b;

          TexCoords[I*3+2].S := IndexList(m_index_list)[i].c_s;
          TexCoords[I*3+2].t := IndexList(m_index_list)[i].c_t;
          Indices[I*3+2] := IndexList(m_index_list)[i].c;
        end;
      end;
      Add(FaceGroup);
    end;

    for I:=0 to m_iVertices-1 do
    begin
      Vertices[I][0] := VertList(frameList(m_frame_list)[frame].vertex)[I].x;
      Vertices[I][1] := VertList(frameList(m_frame_list)[frame].vertex)[I].y;
      Vertices[I][2] := VertList(frameList(m_frame_list)[frame].vertex)[I].z;
    end;
  end;
  Result := Mesh;
end;

//------------------------------------------------------------------------------

procedure TGLMD2VectorFile.LoadFromFile(const FileName: String);
var
  I: Integer;
  MD2File: TFileMD2;
  Mesh: PMeshObject;
begin
  MD2File := TFileMD2.Create;
  MD2File.LoadFromFile(FileName);
  try
    for I:=0 to MD2File.m_iFrames-1 do
    begin
      Mesh := ConvertMD2Structure(MD2File, I);
      FOwner.AddMeshObject(Mesh);
    end;
  finally
    MD2File.Free;
  end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

  RegisterVectorFileFormat('md2', 'Quake II model files', TGLMD2VectorFile);
  RegisterVectorFileFormat('3ds', '3D Studio files', TGL3DSVectorFile);
  RegisterVectorFileFormat('prj', '3D Studio project files', TGL3DSVectorFile);

  RegisterClasses([TFreeForm, TActor]);

finalization

  vVectorFileFormats.Free;
  UnregisterVectorFileClass(TGL3DSVectorFile);
  UnregisterVectorFileClass(TGLMD2VectorFile);

end.

