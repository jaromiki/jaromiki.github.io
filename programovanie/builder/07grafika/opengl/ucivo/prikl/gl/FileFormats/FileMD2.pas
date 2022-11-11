unit FileMD2;

interface

{$R-}

uses Classes, TypeMD2;

type
  TFileMD2 = class
  private
    fm_iFrames, fm_iVertices, fm_iTriangles: LongInt;
  public
    m_index_list: PMake_index_list;
    m_frame_list: PMake_frame_list;

    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromFile(fileName: string);

    property m_iFrames: LongInt read fm_iFrames;
    property m_iVertices: LongInt read fm_iVertices;
    property m_iTriangles: LongInt read fm_iTriangles;
  end;

//---------------------------------------------------------------------------------------------------------------------

implementation

uses
  SysUtils, geometry, GLTexture;

constructor TFileMD2.Create;
begin
  Inherited Create;
  m_index_list := nil;
  m_frame_list := nil;
  fm_iFrames := 0;
  fm_iVertices := 0;
  fm_iTriangles := 0;
end;

destructor TFileMD2.Destroy;
var
  I: Integer;
begin
  if Assigned(m_frame_list) then
  begin
    for i:=0 to fm_iFrames-1 do
      Dispose(FrameList(m_frame_list)[i].vertex);
    Dispose(m_frame_list);
    if Assigned(m_index_list) then
      Dispose(m_index_list);
  end;
  Inherited Destroy;
end;

procedure TFileMD2.LoadFromFile(fileName: string);
var
  ModelFile: TFileStream;
  g_skins: array[0..MAX_MD2SKINS-1, 0..63] of Char;
  base_st: array[0..MAX_VERTS-1] of Tdstvert_t;
  buffer: array[0..MAX_VERTS*4+128-1] of Byte;
  modelheader: tdmdl_t;
  tri: tdtriangle_t;
  out_t: pdaliasframe_t;
  i, j: Integer;
begin
  if Assigned(m_frame_list) then
  begin
    for i:=0 to fm_iFrames-1 do
      Dispose(FrameList(m_frame_list)[i].vertex);
    Dispose(m_frame_list);
    if Assigned(m_index_list) then
      Dispose(m_index_list);
  end;
  if (not fileExists(fileName)) then
    exit;
  ModelFile := TFileStream.Create(fileName, fmOpenRead);
  ModelFile.Read(ModelHeader, sizeof(ModelHeader));

  ////////////////////////////////////////////////////

  fm_iFrames := modelheader.num_frames;
  fm_iVertices := modelheader.num_xyz;
  fm_iTriangles := modelheader.num_tris;

  m_index_list := AllocMem(sizeof(tmake_index_list) * modelheader.num_tris);
  m_frame_list := AllocMem(Sizeof(tmake_frame_list) * modelheader.num_frames);

  for i:=0 to modelheader.num_frames-1 do
    frameList(m_frame_list)[i].vertex := AllocMem(sizeof(tmake_vertex_list) * modelheader.num_xyz);

  ////////////////////////////////////////////////////

  ModelFile.Read(g_Skins, modelheader.num_skins * MAX_SKINNAME);
  ModelFile.Read(base_st, modelheader.num_st * sizeof(base_st[0]));

  for i:=0 to modelheader.num_tris-1 do
  begin
    ModelFile.Read(Tri, sizeof(tdtriangle_t));
    IndexList(m_index_list)[i].a := tri.index_xyz[2];
    IndexList(m_index_list)[i].b := tri.index_xyz[1];
    IndexList(m_index_list)[i].c := tri.index_xyz[0];

    IndexList(m_index_list)[i].a_s := base_st[tri.index_st[2]].s/ModelHeader.skinwidth;
    IndexList(m_index_list)[i].a_t := base_st[tri.index_st[2]].t/ModelHeader.skinHeight;
    IndexList(m_index_list)[i].b_s := base_st[tri.index_st[1]].s/ModelHeader.skinwidth;
    IndexList(m_index_list)[i].b_t := base_st[tri.index_st[1]].t/ModelHeader.skinHeight;
    IndexList(m_index_list)[i].c_s := base_st[tri.index_st[0]].s/ModelHeader.skinwidth;
    IndexList(m_index_list)[i].c_t := base_st[tri.index_st[0]].t/ModelHeader.skinHeight;
  end;

  for i:=0 to modelheader.num_frames-1 do
  begin
    out_t := pdaliasframe_t(@buffer);

    ModelFile.Read(out_t^, modelheader.framesize);

    for j:=0 to modelheader.num_xyz-1 do
    begin
      VertList(FrameList(m_frame_list)[i].vertex)[j].x :=
        out_t^.verts[j].v[0] * out_t^.scale[0] + out_t^.translate[0];
      VertList(FrameList(m_frame_list)[i].vertex)[j].y :=
        out_t^.verts[j].v[1] * out_t^.scale[1] + out_t^.translate[1];
      VertList(FrameList(m_frame_list)[i].vertex)[j].z :=
        out_t^.verts[j].v[2] * out_t^.scale[2] + out_t^.translate[2];
    end;
  end;
  ModelFile.free;
end;


end.

