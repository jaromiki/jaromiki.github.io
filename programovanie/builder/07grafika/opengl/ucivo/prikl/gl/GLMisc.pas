{: GLMisc<p>

   Miscellaneous support routines.<p>

	<b>Historique : </b><font size=-1><ul>
		<li>22/03/00 - Egg - Added SetGLState/UnSetGLState
		<li>21/03/00 - Egg - Added SaveStringToFile/LoadStringFromFile 
		<li>18/03/00 - Egg - Added GetSqrt255Array
      <li>06/02/00 - Egg - Javadocisation,
                           RoundUpToPowerOf2, RoundDownToPowerOf2 and IsPowerOf2 moved in
   </ul></font>
}
unit GLMisc;

// GLMisc      - miscellaneous support routines
// version     - 0.1.0
// last change - 31. January 1999
// for more information see help file

interface

uses Classes, Geometry, SysUtils, OpenGL12;

type

	// used to reflect all relevant (binary) states of OpenGL subsystem
	TGLState = (stAlphaTest, stAutoNormal,
					stBlend, stColorMaterial, stCullFace, stDepthTest, stDither,
					stFog, stLighting, stLineSmooth, stLineStipple,
					stLogicOp, stNormalize, stPointSmooth, stPolygonSmooth,
					stPolygonStipple, stScissorTest, stStencilTest,
					stTexture1D, stTexture2D);
	TGLStates = set of TGLState;

   // TGLUpdateAbleObject
   //
   {: An abstract class describing the "update" interface.<p> }
   TGLUpdateAbleObject = class (TPersistent)
      private
         FOwner : TPersistent;

      public
         constructor Create(AOwner: TPersistent); virtual;

			procedure NotifyChange; virtual;
         function GetOwner : TPersistent; override;

         property Owner : TPersistent read FOwner;
	end;

	// TGLUpdateAbleComponent
	//
	{: An abstract class describing the "update" interface.<p> }
	TGLUpdateAbleComponent = class (TComponent)
		public
			procedure NotifyChange; virtual;
	end;

	TSqrt255Array = array [0..255] of Byte;
	PSqrt255Array = ^TSqrt255Array;

//: Copies the values of Source to Dest (converting word values to integer values)
procedure WordToIntegerArray(Source: PWordArray; Dest: PIntegerArray; Count: Cardinal);
//: Round ups to the nearest power of two, value must be positive
function RoundUpToPowerOf2(value : Integer): Integer;
//: Round down to the nearest power of two, value must be strictly positive
function RoundDownToPowerOf2(value : Integer): Integer;
//: Returns True if value is a true power of two
function IsPowerOf2(value : Integer) : Boolean;
//: Normalize and angle in degrees in the -180 +180 range
function NormalizeAngle(angle : Single) : Single;

{: Returns a pointer to an array containing the results of "255*sqrt(i/255)". }
function GetSqrt255Array : PSqrt255Array;

{: Saves "data" to "filename". }
procedure SaveStringToFile(const fileName, data : String);
{: Returns the content of "filename". }
function LoadStringFromFile(const fileName : String) : String;

//: Update the GLState machine if necessary
procedure SetGLState(var states : TGLStates; const aState : TGLState);
//: Update the GLState machine if necessary
procedure UnSetGLState(var states : TGLStates; const aState : TGLState);

//: Defines the GLPolygonMode if necessary
procedure SetGLPolygonMode(const aFace, mode : TGLEnum);
//: Reset GLPolygonMode, next calls to SetGLPolygonMode WILL do something
procedure ResetGLPolygonMode;

procedure SetGLMaterialColors(const aFace : TGLEnum;
                        const emission, ambient, diffuse, specular : PGLFloat);
procedure ResetGLMaterialColors;

//------------------------------------------------------------------------------

implementation

uses Math;

const
	cGLStateToGLEnum : array [stAlphaTest..stTexture2D] of TGLEnum =
		(GL_ALPHA_TEST, GL_AUTO_NORMAL, GL_BLEND, GL_COLOR_MATERIAL, GL_CULL_FACE,
		 GL_DEPTH_TEST, GL_DITHER, GL_FOG, GL_LIGHTING, GL_LINE_SMOOTH,
		 GL_LINE_STIPPLE, GL_LOGIC_OP, GL_NORMALIZE, GL_POINT_SMOOTH,
		 GL_POLYGON_SMOOTH, GL_POLYGON_STIPPLE, GL_SCISSOR_TEST, GL_STENCIL_TEST,
		 GL_TEXTURE_1D, GL_TEXTURE_2D);

var
	vSqrt255 : TSqrt255Array;

// GetSqrt255Array
//
function GetSqrt255Array : PSqrt255Array;
var
	i : Integer;
begin
	if vSqrt255[255]<>255 then begin
		for i:=0 to 255 do
			vSqrt255[i]:=Trunc(255*Sqrt(i/255));
	end;
	Result:=@vSqrt255;
end;

// SetGLPolygonMode
//
var
   vLastFrontMode, vLastBackMode : TGLEnum;
procedure SetGLPolygonMode(const aFace, mode : TGLEnum);
begin
   case aFace of
      GL_FRONT :
         if mode<>vLastFrontMode then begin
            glPolygonMode(aFace, mode);
            vLastFrontMode:=mode;
         end;
      GL_BACK :
         if mode<>vLastBackMode then begin
            glPolygonMode(aFace, mode);
            vLastBackMode:=mode;
         end;
      GL_FRONT_AND_BACK :
         if (mode<>vLastFrontMode) or (mode<>vLastBackMode) then begin
            glPolygonMode(aFace, mode);
            vLastFrontMode:=mode;
            vLastBackMode:=mode;
         end;
   end;
end;

// ResetGLPolygonMode
//
procedure ResetGLPolygonMode;
begin
   vLastFrontMode:=0;
   vLastBackMode:=0;
end;

// SetGLMaterialColors
//
type
   THomogeneousFltVectorArray = array [0..3] of THomogeneousFltVector;
   PHomogeneousFltVectorArray = ^THomogeneousFltVectorArray;
var
   vFrontColors, vBackColors : THomogeneousFltVectorArray;
procedure SetGLMaterialColors(const aFace : TGLEnum;
                        const emission, ambient, diffuse, specular : PGLFloat);
var
   ar : PHomogeneousFltVectorArray;
begin
   if aFace=GL_FRONT then
      ar:=@vFrontColors
   else ar:=@vBackColors;
   if not CompareMem(@ar[0], emission, SizeOf(THomogeneousFltVector)) then begin
     	glMaterialfv(aFace, GL_EMISSION, emission);
      ar[0]:=PHomogeneousFltVector(emission)^;
   end;
   if not CompareMem(@ar[1], ambient, SizeOf(THomogeneousFltVector)) then begin
     	glMaterialfv(aFace, GL_AMBIENT, ambient);
      ar[1]:=PHomogeneousFltVector(ambient)^;
   end;
   if not CompareMem(@ar[2], diffuse, SizeOf(THomogeneousFltVector)) then begin
     	glMaterialfv(aFace, GL_DIFFUSE, diffuse);
      ar[2]:=PHomogeneousFltVector(diffuse)^;
   end;
   if not CompareMem(@ar[3], specular, SizeOf(THomogeneousFltVector)) then begin
     	glMaterialfv(aFace, GL_SPECULAR, specular);
      ar[3]:=PHomogeneousFltVector(specular)^;
   end;
end;

// ResetGLMaterialColors
//
procedure ResetGLMaterialColors;
var
   i : Integer;
begin
   for i:=0 to 2 do begin
      vFrontColors[i][0]:=-2;
      vBackColors[i][0]:=-2;
   end;
end;

// SetGLState
//
procedure SetGLState(var states : TGLStates; const aState : TGLState);
begin
	if not (aState in states) then begin
		glEnable(cGLStateToGLEnum[aState]);
		Include(states, aState);
	end;
end;

// UnSetGLState
//
procedure UnSetGLState(var states : TGLStates; const aState : TGLState);
begin
	if (aState in states) then begin
		glDisable(cGLStateToGLEnum[aState]);
		Exclude(states, aState);
	end;
end;

// SaveStringToFile
//
procedure SaveStringToFile(const fileName, data : String);
var
	fs : TFileStream;
begin
	fs:=TFileStream.Create(fileName, fmCreate);
	fs.Write(data[1], Length(data));
	fs.Free;
end;

// LoadStringFromFile
//
function LoadStringFromFile(const fileName : String) : String;
var
	fs : TFileStream;
begin
	fs:=TFileStream.Create(fileName, fmOpenRead+fmShareDenyNone);
	SetLength(Result, fs.Size);
	fs.Read(Result[1], fs.Size);
	fs.Free;
end;

//---------------------- TGLUpdateAbleObject -----------------------------------------

constructor TGLUpdateAbleObject.Create(AOwner: TPersistent);
begin
	inherited Create;
	FOwner:=AOwner;
end;

procedure TGLUpdateAbleObject.NotifyChange;
begin
   if Assigned(Owner) then
      if Owner is TGLUpdateAbleObject then
         TGLUpdateAbleObject(Owner).NotifyChange
      else if Owner is TGLUpdateAbleComponent then
         TGLUpdateAbleComponent(Owner).NotifyChange;
end;

function TGLUpdateAbleObject.GetOwner : TPersistent;
begin
   Result:=Owner;
end;

//---------------------- TGLUpdateAbleObject -----------------------------------------

procedure TGLUpdateAbleComponent.NotifyChange;
begin
   if Assigned(Owner) then
      (Owner as TGLUpdateAbleComponent).NotifyChange;
end;

// WordToIntegerArray
//
procedure WordToIntegerArray(Source: PWordArray; Dest: PIntegerArray; Count: Cardinal); assembler;
// EAX contains Source
// EDX contains Dest
// ECX contains Count
asm
              JECXZ @@Finish
              PUSH ESI
              PUSH EDI
              MOV ESI,EAX
              MOV EDI,EDX
              XOR EAX,EAX
@@1:          LODSW
              STOSD
              DEC ECX
              JNZ @@1
              POP EDI
              POP ESI
@@Finish:
end;

// RoundUpToPowerOf2
//
function RoundUpToPowerOf2(value : Integer) : Integer;
var
   LogTwo : Extended;
begin
   LogTwo:=log2(Value);
   if Trunc(LogTwo) < LogTwo then
      Result:=Trunc(Power(2,Trunc(LogTwo)+1))
   else Result:=value;
end;

// RoundDownToPowerOf2
//
function RoundDownToPowerOf2(value : Integer) : Integer;
var
   LogTwo : Extended;
begin
   LogTwo:=log2(Value);
   if Trunc(LogTwo) < LogTwo then
      Result:=Trunc(Power(2,Trunc(LogTwo)))
   else Result:=Value;
end;

// IsPowerOf2
//
function IsPowerOf2(value : Integer) : Boolean;
begin
   Result:=(Trunc(log2(Value))=log2(Value));
end;

// NormalizeAngle
//
function NormalizeAngle(angle : Single) : Single;
begin
   if angle>180 then
      if angle>180+360 then
         Result:=angle-Round((angle+180)*(1/360))*360
      else Result:=angle-360
   else if angle<-180 then
      if angle<-180-360 then
         Result:=angle+Round((180-angle)*(1/360))*360
      else Result:=angle+360
   else Result:=angle;
end;

end.

