{: GLTexture<p>

	Handles all the color and texture stuff.<p>

	<b>Historique : </b><font size=-1><ul>
      <li>26/03/00 - Egg - Finally fixed nasty bug in TGLMaterial.Free
		<li>22/03/00 - Egg - Added BeginUpdate/EndUpdate to TGLPictureImage,
									Made use of [Un]SetGLState in TGLMaterial
									(gain = 7-10% on T&L intensive rendering),
                           TGLTexBaseClass is no more (RIP)
		<li>21/03/00 - Egg - TGLMaterial props are now longer stored when it is
									linked to a material library entry,
									Added TGLPictureImage (split from TGLPersistentImage),
									TGLPicFileImage has been updated and reactivated,
									ColorManager is now autocreated and non longer force-linked.
      <li>19/03/00 - Egg - Added SaveToXxxx & LoadFromXxxx to TGLMaterialLibrary
		<li>18/03/00 - Egg - Added GetGLTextureImageClassesAsStrings,
									Added FindGLTextureImageClassByFriendlyName,
									FChanges states now ignored in TGLTexture.GetHandle,
									Added SaveToFile/LoadFromFile to TextureImage
		<li>17/03/00 - Egg - Added tiaLuminance
		<li>14/03/00 - Egg - Added RegisterGLTextureImageClass stuff,
									Added ImageAlpha
		<li>13/03/00 - Egg - Changed TGLTextureImage image persistence again,
									Added "Edit" method for texture image classes, 
									TMagFilter/TMinFilter -> TGLMagFilter/TGLMinFilter
		<li>03/03/00 - Egg - Removed TImagePath,
									Started major rework of the whole TGLTextureImage stuff,
									Fixed and optimized TGLTexture.PrepareImage
		<li>12/02/00 - Egg - Added Material Library
      <li>10/02/00 - Egg - Fixed crash when texture is empty
		<li>08/02/00 - Egg - Added AsWinColor & DeclareCurrentAsDefault to TGLColor,
									fixed notification on material property setXxx methods,
									Objects now begin with 'TGL'
		<li>07/02/00 - Egg - "Update"s renamed to "NotifyChange"s
		<li>06/02/00 - Egg - RoundUpToPowerOf2, RoundDownToPowerOf2 and
                           IsPowerOf2 moved to GLMisc, added TGLPersistentImage.Assign,
                           fixed TGLMaterial.Assign,
                           disable inheritance stuff in TGLFaceProperties.Apply (needs fixing),
                           Diffuse & ambient color now default to openGL values
      <li>05/02/00 - Egg - Javadocisation, fixes and enhancements :<br>
                           TGLColor.Update, ConvertWinColor, TPicImage,
									TGLMaterial.Apply
   </ul></font>
}
unit GLTexture;

// GLTexture   - This unit handles all the color and texture stuff.
// Version     - 0.5.1
// 07-JAN-2000 ml: minor changes in TGLColor
// 04-JAN-2000 ml: minor changes in TGLColor
// 30-DEC-99 ml: bug fixes

interface

uses
  Windows, Classes, OpenGL12, Graphics, Geometry, SysUtils, GLMisc;

type

	PColorVector = ^TColorVector;
   TColorVector = TVector;

const // color definitions

      // Window's colors (must be filled at program
      // startup, since they depend on the desktop scheme)

      {$J+ - allow change of the following typed constants}

      clrScrollBar           : TColorVector = (0,0,0,1);
      clrBackground          : TColorVector = (0,0,0,1);
      clrActiveCaption       : TColorVector = (0,0,0,1);
      clrInactiveCaption     : TColorVector = (0,0,0,1);
      clrMenu                : TColorVector = (0,0,0,1);
      clrWindow              : TColorVector = (0,0,0,1);
      clrWindowFrame         : TColorVector = (0,0,0,1);
      clrMenuText            : TColorVector = (0,0,0,1);
      clrWindowText          : TColorVector = (0,0,0,1);
      clrCaptionText         : TColorVector = (0,0,0,1);
      clrActiveBorder        : TColorVector = (0,0,0,1);
      clrInactiveBorder      : TColorVector = (0,0,0,1);
      clrAppWorkSpace        : TColorVector = (0,0,0,1);
      clrHighlight           : TColorVector = (0,0,0,1);
      clrHighlightText       : TColorVector = (0,0,0,1);
      clrBtnFace             : TColorVector = (0,0,0,1);
      clrBtnShadow           : TColorVector = (0,0,0,1);
      clrGrayText            : TColorVector = (0,0,0,1);
      clrBtnText             : TColorVector = (0,0,0,1);
		clrInactiveCaptionText : TColorVector = (0,0,0,1);
      clrBtnHighlight        : TColorVector = (0,0,0,1);
      clr3DDkShadow          : TColorVector = (0,0,0,1);
      clr3DLight             : TColorVector = (0,0,0,1);
      clrInfoText            : TColorVector = (0,0,0,1);
      clrInfoBk              : TColorVector = (0,0,0,1);
      
      {$J- - disable change of other typed constants}

      // 'static' color definitions
      // sort of grays
      clrBlack               : TColorVector = (0,    0,    0,    1);
      clrGray05              : TColorVector = (0.05, 0.05, 0.05, 1);
      clrGray10              : TColorVector = (0.10, 0.10, 0.10, 1);
      clrGray15              : TColorVector = (0.15, 0.15, 0.15, 1);
      clrGray20              : TColorVector = (0.20, 0.20, 0.20, 1);
      clrGray25              : TColorVector = (0.25, 0.25, 0.25, 1);
      clrGray30              : TColorVector = (0.30, 0.30, 0.30, 1);
      clrGray35              : TColorVector = (0.35, 0.35, 0.35, 1);
      clrGray40              : TColorVector = (0.40, 0.40, 0.40, 1);
		clrGray45              : TColorVector = (0.45, 0.45, 0.45, 1);
      clrGray50              : TColorVector = (0.50, 0.50, 0.50, 1);
      clrGray55              : TColorVector = (0.55, 0.55, 0.55, 1);
      clrGray60              : TColorVector = (0.60, 0.60, 0.60, 1);
      clrGray65              : TColorVector = (0.65, 0.65, 0.65, 1);
      clrGray70              : TColorVector = (0.70, 0.70, 0.70, 1);
      clrGray75              : TColorVector = (0.75, 0.75, 0.75, 1);
      clrGray80              : TColorVector = (0.80, 0.80, 0.80, 1);
      clrGray85              : TColorVector = (0.85, 0.85, 0.85, 1);
      clrGray90              : TColorVector = (0.90, 0.90, 0.90, 1);
      clrGray95              : TColorVector = (0.95, 0.95, 0.95, 1);
      clrWhite               : TColorVector = (1,    1,    1,    1);

      // other grays
      clrDimGray             : TColorVector = (0.329412, 0.329412, 0.329412, 1);
      clrGray                : TColorVector = (0.752941, 0.752941, 0.752941, 1);
      clrLightGray           : TColorVector = (0.658824, 0.658824, 0.658824, 1);

      // colors en masse
      clrAquamarine          : TColorVector = (0.439216, 0.858824, 0.576471, 1);
		clrBlueViolet          : TColorVector = (0.62352,  0.372549, 0.623529, 1);
      clrBrown               : TColorVector = (0.647059, 0.164706, 0.164706, 1);
      clrCadetBlue           : TColorVector = (0.372549, 0.623529, 0.623529, 1);
      clrCoral               : TColorVector = (1,        0.498039, 0.0,      1);
      clrCornflowerBlue      : TColorVector = (0.258824, 0.258824, 0.435294, 1);
      clrDarkGreen           : TColorVector = (0.184314, 0.309804, 0.184314, 1);
      clrDarkOliveGreen      : TColorVector = (0.309804, 0.309804, 0.184314, 1);
      clrDarkOrchid          : TColorVector = (0.6,      0.196078, 0.8,      1);
      clrDarkSlateBlue       : TColorVector = (0.419608, 0.137255, 0.556863, 1);
      clrDarkSlateGray       : TColorVector = (0.184314, 0.309804, 0.309804, 1);
      clrDarkSlateGrey       : TColorVector = (0.184314, 0.309804, 0.309804, 1);
      clrDarkTurquoise       : TColorVector = (0.439216, 0.576471, 0.858824, 1);
      clrFirebrick           : TColorVector = (0.556863, 0.137255, 0.137255, 1);
      clrForestGreen         : TColorVector = (0.137255, 0.556863, 0.137255, 1);
      clrGold                : TColorVector = (0.8,      0.498039, 0.196078, 1);
      clrGoldenrod           : TColorVector = (0.858824, 0.858824, 0.439216, 1);
      clrGreenYellow         : TColorVector = (0.576471, 0.858824, 0.439216, 1);
      clrIndian              : TColorVector = (0.309804, 0.184314, 0.184314, 1);
      clrKhaki               : TColorVector = (0.623529, 0.623529, 0.372549, 1);
      clrLightBlue           : TColorVector = (0.74902,  0.847059, 0.847059, 1);
		clrLightSteelBlue      : TColorVector = (0.560784, 0.560784, 0.737255, 1);
      clrLimeGreen           : TColorVector = (0.196078, 0.8,      0.196078, 1);
      clrMaroon              : TColorVector = (0.556863, 0.137255, 0.419608, 1);
      clrMediumAquamarine    : TColorVector = (0.196078, 0.8,      0.6,      1);
      clrMediumBlue          : TColorVector = (0.196078, 0.196078, 0.8,      1);
      clrMediumForestGreen   : TColorVector = (0.419608, 0.556863, 0.137255, 1);
      clrMediumGoldenrod     : TColorVector = (0.917647, 0.917647, 0.678431, 1);
      clrMediumOrchid        : TColorVector = (0.576471, 0.439216, 0.858824, 1);
      clrMediumSeaGreen      : TColorVector = (0.258824, 0.435294, 0.258824, 1);
      clrMediumSlateBlue     : TColorVector = (0.498039, 0,        1,        1);
      clrMediumSpringGreen   : TColorVector = (0.498039, 1,        0,        1);
      clrMediumTurquoise     : TColorVector = (0.439216, 0.858824, 0.858824, 1);
      clrMediumViolet        : TColorVector = (0.858824, 0.439216, 0.576471, 1);
      clrMidnightBlue        : TColorVector = (0.184314, 0.184314, 0.309804, 1);
      clrNavy                : TColorVector = (0.137255, 0.137255, 0.556863, 1);
      clrNavyBlue            : TColorVector = (0.137255, 0.137255, 0.556863, 1);
      clrOrange              : TColorVector = (1,        0.5,      0.0,      1);
      clrOrangeRed           : TColorVector = (1,        0.25,     0,        1);
      clrOrchid              : TColorVector = (0.858824, 0.439216, 0.858824, 1);
      clrPaleGreen           : TColorVector = (0.560784, 0.737255, 0.560784, 1);
		clrPink                : TColorVector = (0.737255, 0.560784, 0.560784, 1);
      clrPlum                : TColorVector = (0.917647, 0.678431, 0.917647, 1);
      clrSalmon              : TColorVector = (0.435294, 0.258824, 0.258824, 1);
      clrSeaGreen            : TColorVector = (0.137255, 0.556863, 0.419608, 1);
      clrSienna              : TColorVector = (0.556863, 0.419608, 0.137255, 1);
      clrSkyBlue             : TColorVector = (0.196078, 0.6,      0.8,      1);
      clrSlateBlue           : TColorVector = (0,        0.498039, 1,        1);
      clrSpringGreen         : TColorVector = (0,        1,        0.498039, 1);
      clrSteelBlue           : TColorVector = (0.137255, 0.419608, 0.556863, 1);
      clrTan                 : TColorVector = (0.858824, 0.576471, 0.439216, 1);
      clrThistle             : TColorVector = (0.847059, 0.74902,  0.847059, 1);
      clrTurquoise           : TColorVector = (0.678431, 0.917647, 0.917647, 1);
      clrViolet              : TColorVector = (0.309804, 0.184314, 0.309804, 1);
      clrVioletRed           : TColorVector = (0.8,      0.196078, 0.6,      1);
      clrWheat               : TColorVector = (0.847059, 0.847059, 0.74902,  1);
      clrYellowGreen         : TColorVector = (0.6,      0.8,      0.196078, 1);
      clrSummerSky           : TColorVector = (0.22,     0.69,     0.87,     1);
      clrRichBlue            : TColorVector = (0.35,     0.35,     0.67,     1);
      clrBrass               : TColorVector = (0.71,     0.65,     0.26,     1);
      clrCopper              : TColorVector = (0.72,     0.45,     0.20,     1);
		clrBronze              : TColorVector = (0.55,     0.47,     0.14,     1);
      clrBronze2             : TColorVector = (0.65,     0.49,     0.24,     1);
      clrSilver              : TColorVector = (0.90,     0.91,     0.98,     1);
      clrBrightGold          : TColorVector = (0.85,     0.85,     0.10,     1);
      clrOldGold             : TColorVector = (0.81,     0.71,     0.23,     1);
      clrFeldspar            : TColorVector = (0.82,     0.57,     0.46,     1);
      clrQuartz              : TColorVector = (0.85,     0.85,     0.95,     1);
      clrNeonPink            : TColorVector = (1.00,     0.43,     0.78,     1);
      clrDarkPurple          : TColorVector = (0.53,     0.12,     0.47,     1);
      clrNeonBlue            : TColorVector = (0.30,     0.30,     1.00,     1);
      clrCoolCopper          : TColorVector = (0.85,     0.53,     0.10,     1);
      clrMandarinOrange      : TColorVector = (0.89,     0.47,     0.20,     1);
      clrLightWood           : TColorVector = (0.91,     0.76,     0.65,     1);
      clrMediumWood          : TColorVector = (0.65,     0.50,     0.39,     1);
      clrDarkWood            : TColorVector = (0.52,     0.37,     0.26,     1);
      clrSpicyPink           : TColorVector = (1.00,     0.11,     0.68,     1);
      clrSemiSweetChoc       : TColorVector = (0.42,     0.26,     0.15,     1);
      clrBakersChoc          : TColorVector = (0.36,     0.20,     0.09,     1);
      clrFlesh               : TColorVector = (0.96,     0.80,     0.69,     1);
      clrNewTan              : TColorVector = (0.92,     0.78,     0.62,     1);
		clrNewMidnightBlue     : TColorVector = (0.00,     0.00,     0.61,     1);
		clrVeryDarkBrown       : TColorVector = (0.35,     0.16,     0.14,     1);
		clrDarkBrown           : TColorVector = (0.36,     0.25,     0.20,     1);
		clrDarkTan             : TColorVector = (0.59,     0.41,     0.31,     1);
		clrGreenCopper         : TColorVector = (0.32,     0.49,     0.46,     1);
		clrDkGreenCopper       : TColorVector = (0.29,     0.46,     0.43,     1);
		clrDustyRose           : TColorVector = (0.52,     0.39,     0.39,     1);
		clrHuntersGreen        : TColorVector = (0.13,     0.37,     0.31,     1);
		clrScarlet             : TColorVector = (0.55,     0.09,     0.09,     1);
		clrMediumPurple        : TColorVector = (0.73,     0.16,     0.96,     1);
		clrLightPurple         : TColorVector = (0.87,     0.58,     0.98,     1);
		clrVeryLightPurple     : TColorVector = (0.94,     0.81,     0.99,     1);
		clrGreen               : TColorVector = (0,        1,        0,        1);
		clrOlive               : TColorVector = (0,        1,        1,        1);
		clrPurple              : TColorVector = (1,        0,        1,        1);
		clrTeal                : TColorVector = (0,        1,        1,        1);
		clrRed                 : TColorVector = (1,        0,        0,        1);
		clrLime                : TColorVector = (0,        1,        0,        1);
		clrYellow              : TColorVector = (1,        1,        0,        1);
		clrBlue                : TColorVector = (0,        0,        1,        1);
		clrFuchsia             : TColorVector = (1,        0,        1,        1);
		clrAqua                : TColorVector = (0,        1,        1,        1);

type
	PRGBColor    = ^TRGBColor;
	TRGBColor    = TAffineByteVector;

	PTexPoint    = ^TTexPoint;
	TTexPoint    = record
						  S,T : TGLFLoat;
						end;
	PTexPointArray = ^TTexPointArray;
	TTexPointArray = array[0..0] of TTexPoint;

	TGLTextureMode = (tmDecal, tmModulate, tmBlend, tmReplace);
	TGLTextureWrap = (twBoth, twNone, twVertical, twHorizontal);
	TGLMinFilter   = (miNearest, miLinear, miNearestMipmapNearest,
							miLinearMipmapNearest, miNearestMipmapLinear,
							miLinearMipmapLinear);
	TGLMagFilter   = (maNearest, maLinear);

	TGLFaceProperties = class;
	TGLTexture        = class;
	TGLMaterial       = class;

   // TGLColor
	//
   TGLColor = class(TGLUpdateAbleObject)
      private
			FColor, FDefaultColor : TColorVector;
			procedure SetColor(AColor: TColorVector);
			procedure SetColorComponent(Index: Integer; Value: TGLFloat);
			procedure SetAsWinColor(const val : TColor);
			function GetAsWinColor : TColor;

		protected
			procedure DefineProperties(Filer: TFiler); override;
			procedure ReadData(Stream: TStream);
			procedure WriteData(Stream: TStream);

		public
			constructor Create(AOwner : TPersistent); override;

			procedure Assign(Source : TPersistent); override;
			procedure Initialize(color : TColorVector);
			function AsAddress : PGLFloat;

			property Color : TColorVector read FColor write SetColor;
			property AsWinColor : TColor read GetAsWinColor write SetAsWinColor;

		published
			property Red:   TGLFloat index 0 read FColor[0] write SetColorComponent stored False;
			property Green: TGLFloat index 1 read FColor[1] write SetColorComponent stored False;
			property Blue:  TGLFloat index 2 read FColor[2] write SetColorComponent stored False;
			property Alpha: TGLFloat index 3 read FColor[3] write SetColorComponent stored False;
	end;

	TGLTextureChange  = (tcImage, tcParams);
	TGLTextureChanges = set of TGLTextureChange;

	{: Defines how and if Alpha channel is defined for a texture image.<p>
		+ tiaDefault : uses the alpha channel in the image if any<br>
		+ tiaAlphaFromIntensity : the alpha channel value is deduced from other
			RGB components intensity (the brighter, the more opaque)<br>
		+ tiaSuperBlackTransparent : pixels with a RGB color of (0, 0, 0) are
			completely transparent, others are completely opaque<br>
		+ tiaLuminance : the luminance value is calculated for each pixel
			and used for RGB and Alpha values<br>
		+ tiaLuminanceSqrt : same as tiaLuminance but with an Sqrt(Luminance)<br>
	}
	TGLTextureImageAlpha = (tiaDefault, tiaAlphaFromIntensity,
									tiaSuperBlackTransparent, tiaLuminance,
									tiaLuminanceSqrt);

	// TGLTextureImage
	//
	{: Base class for texture image data.<p>
		Basicly, subclasses are to be considered as different ways of getting
		a HBitmap (interfacing the actual source).<br>
		SubClasses should be registered using RegisterGLTextureImageClass to allow
		proper persistence and editability in the IDE experts. }
	TGLTextureImage = class(TGLUpdateAbleObject)
		private
			FOwnerTexture : TGLTexture;

		protected
			function GetHeight: Integer; virtual; abstract;
			function GetWidth: Integer; virtual; abstract;

		public
			constructor Create(AOwner : TPersistent); override;
			destructor Destroy; override;

			property OwnerTexture : TGLTexture read FOwnerTexture write FOwnerTexture;
			procedure NotifyChange; override;

			{: Request to edit the textureImage.<p>
				Returns True if changes have been made.<br>
				This method may be invoked from the IDE or at run-time. }
			function Edit : Boolean; dynamic; abstract;
			{: Save textureImage to file.<p>
				This may not save a picture, but for instance, parameters, if the
				textureImage is a procedural texture. }
			procedure SaveToFile(const fileName : String); dynamic; abstract;
			{: Load textureImage from a file.<p>
				This may not load a picture, but for instance, parameters, if the
				textureImage is a procedural texture. }
			procedure LoadFromFile(const fileName : String); dynamic; abstract;
			{: Returns a user-friendly denomination for the class.<p>
				This denomination is used for picking a texture image class
				in the IDE expert. }
			class function FriendlyName : String; virtual; abstract;
			{: Returns a user-friendly description for the class.<p>
				This denomination is used for helping the user when picking a
				texture image class in the IDE expert. If it's not overriden,
				takes its value from FriendlyName. }
			class function FriendlyDescription : String; virtual;

			{: Request reload/refresh of data upon next use. }
			procedure Invalidate; dynamic;

			{: Returns image's bitmap handle.<p>
				If the actual image is not a windows bitmap (BMP), descendants should
				take care of properly converting to bitmap. }
			function GetHBitmap: HBitmap; virtual; abstract;
			{: Request for unloading bitmapData, to free some memory.<p>
				This one is invoked when GLScene no longer needs the Bitmap data
				it got through a call to GetHBitmap.<br>
				Descendants may ignore this call if the HBitmap was obtained at
				no particular memory cost. }
			procedure ReleaseHBitmap; virtual;

			property Width: Integer read GetWidth;
			property Height: Integer read GetHeight;
	end;

	TGLTextureImageClass = class of TGLTextureImage;

	// TGLPictureImage
	//
	{: Base class for image data classes internally based on a TPicture ;}
	TGLPictureImage = class(TGLTextureImage)
		private
			FBitmap : TBitmap;
			FPicture : TPicture;
			FUpdateCounter : Integer;

		protected
			function GetHeight: Integer; override;
			function GetWidth: Integer; override;

			procedure SetPicture(const aPicture : TPicture);
			procedure PictureChanged(Sender: TObject);

		public
			constructor Create(AOwner: TPersistent); override;
			destructor Destroy; override;

			procedure Assign(Source: TPersistent); override;

			{: Use this function if you are going to modify the Picture directly.<p>
				Each invokation MUST be balanced by a call to EndUpdate. }
			procedure BeginUpdate;
			procedure EndUpdate;
			function GetHBitmap: HBitmap; override;
			procedure ReleaseHBitmap; override;

			property Picture : TPicture read FPicture write SetPicture;
	end;

	// TGLPersistentImage
	//
	{: Stores any image compatible with Delphi's TPicture mechanism.<p>
		The picture's data is actually stored into the DFM, the original
		picture name or path is not remembered. It is similar in behaviour
		to Delphi's TImage.<p>
		Not that if original image is for instance JPEG format, only the JPEG
		data will be stored in the DFM (compact) }
	TGLPersistentImage = class(TGLPictureImage)
		public
			constructor Create(AOwner: TPersistent); override;
			destructor Destroy; override;

			function Edit : Boolean; override;
			procedure SaveToFile(const fileName : String); override;
			procedure LoadFromFile(const fileName : String); override;
			class function FriendlyName : String; override;
			class function FriendlyDescription : String; override;

		published
			property Picture;
	end;

	// TGLPicFileImage
	//
	{: Uses a picture whose data is found in a file (only filename is stored). }
	TGLPicFileImage = class(TGLPictureImage)
		private
			FPictureFileName : String;

		protected
			procedure SetPictureFileName(const val : String);

		public
			constructor Create(AOwner: TPersistent); override;
			destructor Destroy; override;

			function Edit : Boolean; override;
			//: Only picture file name is saved
			procedure SaveToFile(const fileName : String); override;
			procedure LoadFromFile(const fileName : String); override;
			class function FriendlyName : String; override;
			class function FriendlyDescription : String; override;

			function GetHBitmap: HBitmap; override;
			procedure Invalidate; override;

		published
			property PictureFileName : String read FPictureFileName write SetPictureFileName;
	end;

	{ Disabled stuff


	  TGLCaptureImage = class(TGLTextureImage)
	  private
		 FBitmap : TBitmap;
		 FLeft, FTop : Integer;
	  protected
		 function GetBitmap: HBitmap; override;
		 function GetHeight: Integer; override;
		 function GetWidth: Integer; override;
		 procedure PictureChanged(Sender: TObject);
		 procedure SetHeight(AValue: Integer); override;
		 procedure SetLeft(AValue: Integer);
		 procedure SetTop(AValue: Integer);
		 procedure SetWidth(AValue: Integer); override;
	  public
		 constructor Create(AOwner: TPersistent); override;
		 destructor Destroy; override;
		 procedure DataNeeded; override;
	  published
		 property Left: Integer read FLeft write SetLeft default 32;
		 property Top: Integer read FTop write SetTop default 32;
	  end;
	  }

	// TGLTexture
	//
	TGLTexture = class (TGLUpdateAbleObject)
		private
			FHandle      : TGLuint;
			FTextureMode : TGLTextureMode;
			FTextureWrap : TGLTextureWrap;
			FMinFilter   : TGLMinFilter;
			FMagFilter   : TGLMagFilter;
			FChanges     : TGLTextureChanges;
			FDisabled    : Boolean;
			FImage       : TGLTextureImage;
			FImageAlpha  : TGLTextureImageAlpha;

		protected
			procedure SetImage(AValue: TGLTextureImage);
			procedure SetImageAlpha(const val : TGLTextureImageAlpha);
			procedure SetMagFilter(AValue: TGLMagFilter);
			procedure SetMinFilter(AValue: TGLMinFilter);
			procedure SetTextureMode(AValue: TGLTextureMode);
			procedure SetTextureWrap(AValue: TGLTextureWrap);
			procedure SetDisabled(AValue: Boolean);

			function GetHandle: TGLuint; virtual;
			//: Load texture to OpenGL subsystem
			procedure PrepareImage; virtual;
			//: Setup OpenGL texture parameters
			procedure PrepareParams; virtual;

		public
			constructor Create(AOwner: TPersistent); override;
			destructor  Destroy; override;

			procedure Apply;
			procedure Assign(Source: TPersistent); override;

			procedure DestroyHandle;
			procedure DisableAutoTexture;
			procedure InitAutoTexture(TexRep: PTexPoint);
			procedure ReloadImage;

			procedure SetImageClassName(const val : String);
			function GetImageClassName : String;

			property  Handle: TGLuint read GetHandle;

		published

			{: Image ClassName for enabling True polymorphism.<p>
				This is ugly, but since the default streaming mechanism does a
				really bad job at storing	polymorphic owned-object properties,
				and neither TFiler nor TPicture allow proper use of the built-in
				streaming, that's the only way I found to allow a user-extensible
				mechanism. }
			property ImageClassName : String read GetImageClassName write SetImageClassName;
			{: Image data for the texture.<p> }
			property Image: TGLTextureImage read FImage write SetImage;


			property ImageAlpha : TGLTextureImageAlpha read FImageAlpha write SetImageAlpha default tiaDefault;

			property MagFilter: TGLMagFilter read FMagFilter write SetMagFilter default maNearest;
			property MinFilter: TGLMinFilter read FMinFilter write SetMinFilter default miNearest;

			property TextureMode: TGLTextureMode read FTextureMode write SetTextureMode default tmDecal;
			property TextureWrap: TGLTextureWrap read FTextureWrap write SetTextureWrap default twBoth;

			property Disabled: Boolean read FDisabled write SetDisabled default True;
	end;

	TShininess = 0..128;
   TPolygonMode = (pmFill, pmLines, pmPoints);

   // TGLFaceProperties
   //
	TGLFaceProperties = class (TGLUpdateAbleObject)
	   private
         FAmbient, FDiffuse, FSpecular, FEmission  : TGLColor;
         FPolygonMode : TPolygonMode;
         FShininess : TShininess;

      protected
         procedure SetAmbient(AValue: TGLColor);
         procedure SetDiffuse(AValue: TGLColor);
         procedure SetEmission(AValue: TGLColor);
         procedure SetSpecular(AValue: TGLColor);
         procedure SetPolygonMode(AValue: TPolygonMode);
         procedure SetShininess(AValue: TShininess);

	   public
         constructor Create(AOwner: TPersistent); override;
         destructor Destroy; override;
         procedure Apply(AFace: TGLEnum);
         procedure Assign(Source: TPersistent); override;

      published
         property Ambient: TGLColor read FAmbient write SetAmbient;
         property Diffuse: TGLColor read FDiffuse write SetDiffuse;
         property Emission: TGLColor read FEmission write SetEmission;
         property Shininess: TShininess read FShininess write SetShininess default 0;
         property PolygonMode: TPolygonMode read FPolygonMode write SetPolygonMode default pmFill;
         property Specular: TGLColor read FSpecular write SetSpecular;
   end;

   TGLLibMaterialName = String;
   TGLMaterialLibrary = class;
   TGLLibMaterial = class;

   // TBlendingMode
   //
   {: Simplified blending options.<p>
      bmOpaque : disable blending<br>
      bmTransparency : uses standard alpha blending<br>
      bmAdditive : activates additive blending (with saturation) }
   TBlendingMode = (bmOpaque, bmTransparency, bmAdditive);

	// TGLMaterial
   //
	TGLMaterial = class (TGLUpdateAbleObject)
      private
	      { Private Declarations }
         FFrontProperties, FBackProperties : TGLFaceProperties;
			FBlendingMode : TBlendingMode;
         FTexture : TGLTexture;
         FMaterialLibrary : TGLMaterialLibrary;
         FLibMaterialName : TGLLibMaterialName;
         currentLibMaterial : TGLLibMaterial;

	   protected
	      { Protected Declarations }
         procedure SetBackProperties(Values: TGLFaceProperties);
         procedure SetFrontProperties(Values: TGLFaceProperties);
         procedure SetBlendingMode(const val : TBlendingMode);
         procedure SetTexture(ATexture: TGLTexture);
         procedure SetMaterialLibrary(const val : TGLMaterialLibrary);
         procedure SetLibMaterialName(const val : TGLLibMaterialName);

			procedure NotifyLibMaterialDestruction;
			//: Back, Front, Texture and blending not stored if linked to a LibMaterial
			function StoreMaterialProps : Boolean;

		public
			{ Public Declarations }
			constructor Create(AOwner: TPersistent); override;
			destructor Destroy; override;

			procedure Apply(var currentStates : TGLStates);
			procedure Assign(Source: TPersistent); override;
			procedure NotifyChange; override;

		published
			{ Published Declarations }
			property BackProperties: TGLFaceProperties read FBackProperties write SetBackProperties stored StoreMaterialProps;
			property FrontProperties: TGLFaceProperties read FFrontProperties write SetFrontProperties stored StoreMaterialProps;
			property BlendingMode : TBlendingMode read FBlendingMode write SetBlendingMode stored StoreMaterialProps default bmOpaque;
			property Texture: TGLTexture read FTexture write SetTexture stored StoreMaterialProps;

			property MaterialLibrary : TGLMaterialLibrary read FMaterialLibrary write SetMaterialLibrary;
			property LibMaterialName : TGLLibMaterialName read FLibMaterialName write SetLibMaterialName;
	  end;

	// TGLLibMaterial
	//
	TGLLibMaterial = class (TCollectionItem)
	   private
	      { Private Declarations }
         userList : TList;
         FName : TGLLibMaterialName;
         FMaterial : TGLMaterial;

	   protected
	      { Protected Declarations }
         function GetDisplayName : String; override;
         procedure SetName(const val : TGLLibMaterialName);
         procedure SetMaterial(const val : TGLMaterial);

      public
	      { Public Declarations }
	      constructor Create(Collection : TCollection); override;
	      destructor Destroy; override;

	      procedure Assign(Source: TPersistent); override;

         procedure RegisterUser(material : TGLMaterial);
			procedure UnregisterUser(material : TGLMaterial);
         procedure NotifyUsers;

	   published
	      { Published Declarations }
         property Name : TGLLibMaterialName read FName write SetName;
         property Material : TGLMaterial read FMaterial write SetMaterial;

	end;

	// TGLLibMaterials
	//
	TGLLibMaterials = class (TCollection)
	   private
	      { Protected Declarations }
	      owner : TComponent;

	   protected
	      { Protected Declarations }
	      function GetOwner: TPersistent; override;
         procedure SetItems(index : Integer; const val : TGLLibMaterial);
	      function GetItems(index : Integer) : TGLLibMaterial;

      public
	      { Public Declarations }
	      constructor Create(AOwner : TComponent);

         function Add: TGLLibMaterial;
	      function FindItemID(ID: Integer): TGLLibMaterial;
	      property Items[index : Integer] : TGLLibMaterial read GetItems write SetItems; default;
         procedure Delete(index : Integer);
         function MakeUniqueName(const nameRoot : TGLLibMaterialName) : TGLLibMaterialName;
         function GetLibMaterialByName(const name : TGLLibMaterialName) : TGLLibMaterial;
         procedure SetNamesToTStrings(aStrings : TStrings);
   end;

   // TGLMaterialLibrary
   //
   TGLMaterialLibrary = class (TComponent)
	   private
	      { Protected Declarations }
         FMaterials : TGLLibMaterials;

	   protected
			{ Protected Declarations }
         procedure SetMaterials(const val : TGLLibMaterials);

      public
	      { Public Declarations }
	      constructor Create(AOwner : TComponent); override;
         destructor Destroy; override;

	      procedure SaveToStream(aStream : TStream); dynamic;
	      procedure LoadFromStream(aStream : TStream); dynamic;
         {: Recommended extension : .GLL }
	      procedure SaveToFile(const fileName : String);
	      procedure LoadFromFile(const fileName : String);

      published
	      { Published Declarations }
         property Materials : TGLLibMaterials read FMaterials write SetMaterials;
   end;

     PColorEntry = ^TColorEntry;
	  TColorEntry = record
                     Name  : String[31];
                     Color : TColorVector;
                   end;

     TGLColorManager = class(TList)
     public
       destructor Destroy; override;
       procedure AddColor(AName: String; AColor: TColorVector);
       procedure EnumColors(Proc: TGetStrProc);
       function  FindColor(AName: String): TColorVector;
       {: Convert a clrXxxx or a '<red green blue alpha> to a color vector }
		 function  GetColor(AName: String): TColorVector;
       function  GetColorName(AColor: TColorVector): String;
       procedure RegisterDefaultColors;
       procedure RemoveColor(AName: String);
     end;

const
   NullTexPoint : TTexPoint = (S:0; T:0);

function ColorManager: TGLColorManager;

//: Converts a color vector (containing float values)
function ConvertColorVector(AColor: TColorVector): TColor;
//: Converts RGB components into a color vector with correct range
function ConvertRGBColor(AColor: array of Byte): TColorVector;
//: Converts a delphi color into its RGB fragments and correct range
function ConvertWinColor(aColor: TColor; alpha : Single = 1) : TColorVector;
procedure RegisterColor(AName: String; AColor: TColorVector);
procedure UnregisterColor(AName: String);

//: Register a TGLTextureImageClass (used for persistence and IDE purposes)
procedure RegisterGLTextureImageClass(textureImageClass : TGLTextureImageClass);
//: Finds a registerer TGLTextureImageClass using its classname
function FindGLTextureImageClass(const className : String) : TGLTextureImageClass;
//: Finds a registerer TGLTextureImageClass using its FriendlyName
function FindGLTextureImageClassByFriendlyName(const friendlyName : String) : TGLTextureImageClass;
//: Defines a TStrings with the list of registered TGLTextureImageClass.
procedure SetGLTextureImageClassesToStrings(aStrings : TStrings);
{: Creates a TStrings with the list of registered TGLTextureImageClass.<p>
	To be freed by caller. }
function GetGLTextureImageClassesAsStrings : TStrings;

//------------------------------------------------------------------------------

implementation

uses Dialogs, GLScene, GLScreen, GLStrings, ExtDlgs;

var
	vGLTextureImageClasses : TList;
	vColorManager: TGLColorManager;

// ColorManager
//
function ColorManager : TGLColorManager;
begin
	if not Assigned(vColorManager) then begin
		vColorManager:=TGLColorManager.Create;
		vColorManager.RegisterDefaultColors;
	end;
	Result:=vColorManager;
end;

// RegisterGLTextureImageClass
//
procedure RegisterGLTextureImageClass(textureImageClass : TGLTextureImageClass);
begin
	if not Assigned(vGLTextureImageClasses) then
		vGLTextureImageClasses:=TList.Create;
	vGLTextureImageClasses.Add(textureImageClass);
end;

// FindGLTextureImageClass
//
function FindGLTextureImageClass(const className : String) : TGLTextureImageClass;
var
	i : Integer;
	tic : TGLTextureImageClass;
begin
	Result:=nil;
	if Assigned(vGLTextureImageClasses) then
		for i:=0 to vGLTextureImageClasses.Count-1 do begin
			tic:=TGLTextureImageClass(vGLTextureImageClasses[i]);
			if tic.ClassName=className then begin
				Result:=tic;
				Break;
			end;
		end;

end;

// FindGLTextureImageClassByFriendlyName
//
function FindGLTextureImageClassByFriendlyName(const friendlyName : String) : TGLTextureImageClass;
var
	i : Integer;
	tic : TGLTextureImageClass;
begin
	Result:=nil;
	if Assigned(vGLTextureImageClasses) then
		for i:=0 to vGLTextureImageClasses.Count-1 do begin
			tic:=TGLTextureImageClass(vGLTextureImageClasses[i]);
			if tic.FriendlyName=friendlyName then begin
				Result:=tic;
				Break;
			end;
		end;
end;

// SetGLTextureImageClassesToStrings
//
procedure SetGLTextureImageClassesToStrings(aStrings : TStrings);
var
	i : Integer;
	tic : TGLTextureImageClass;
begin
	with aStrings do begin
		BeginUpdate;
		Clear;
		if Assigned(vGLTextureImageClasses) then
			for i:=0 to vGLTextureImageClasses.Count-1 do begin
				tic:=TGLTextureImageClass(vGLTextureImageClasses[i]);
				AddObject(tic.FriendlyName, Pointer(tic));
			end;
		EndUpdate;
	end;
end;

// GetGLTextureImageClassesAsStrings
//
function GetGLTextureImageClassesAsStrings : TStrings;
begin
	Result:=TStringList.Create;
	SetGLTextureImageClassesToStrings(Result);
end;

//---------------------- TGLColor ----------------------------------------------

constructor TGLColor.Create(AOwner: TPersistent);
begin
   inherited;
	FColor:=clrBlack;
	FDefaultColor:=FColor;
end;

procedure TGLColor.SetColor(AColor: TColorVector);
begin
   FColor:=AColor;
	NotifyChange;
end;

procedure TGLColor.SetColorComponent(Index: Integer; Value: TGLFloat);
begin
	if FColor[Index]<>Value then begin
		FColor[Index]:=Value;
		NotifyChange;
	end;
end;

// SetAsWinColor
//
procedure TGLColor.SetAsWinColor(const val : TColor);
begin
	FColor:=ConvertWinColor(val);
	NotifyChange;
end;

// GetAsWinColor
//
function TGLColor.GetAsWinColor : TColor;
begin
	Result:=ConvertColorVector(FColor);
end;

procedure TGLColor.Assign(Source: TPersistent);
begin
   if Assigned(Source) and (Source is TGLColor) then begin
		FColor:=TGLColor(Source).FColor;
      NotifyChange;
   end else inherited;
end;

procedure TGLColor.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Color', ReadData, WriteData,
                             not VectorEquals(FColor, FDefaultColor));
end;

procedure TGLColor.ReadData(Stream: TStream);
begin
  Stream.Read(FColor, SizeOf(FColor));
end;

procedure TGLColor.WriteData(Stream: TStream);
begin
  Stream.Write(FColor, SizeOf(FColor));
end;

function TGLColor.AsAddress: PGLFloat;
begin
	Result:=@FColor;
end;

procedure TGLColor.Initialize(color : TColorVector);
begin
   FColor:=color;
	FDefaultColor:=color;
end;

//----------------- TGLFaceProperties --------------------------------------------

constructor TGLFaceProperties.Create(AOwner: TPersistent);
begin
  inherited;
  // OpenGL default colors
  FAmbient:=TGLColor.Create(Self);
  FAmbient.Initialize(clrGray20);
  FDiffuse:=TGLColor.Create(Self);
  FDiffuse.Initialize(clrGray80);
  FEmission:=TGLColor.Create(Self);
  FSpecular:=TGLColor.Create(Self);
  FShininess:=0;
end;

destructor TGLFaceProperties.Destroy;
begin
   FAmbient.Free;
   FDiffuse.Free;
   FEmission.Free;
   FSpecular.Free;
   inherited Destroy;
end;

// Apply
//
procedure TGLFaceProperties.Apply(AFace: TGLEnum);
const
   cPolygonMode : array [pmFill..pmPoints] of TGLEnum = (GL_FILL, GL_LINE, GL_POINT);
begin
   SetGLMaterialColors(AFace, Emission.AsAddress, Ambient.AsAddress, Diffuse.AsAddress, Specular.AsAddress);
	glMateriali(AFace, GL_SHININESS, FShininess);
   SetGLPolygonMode(AFace, cPolygonMode[FPolygonMode]);
end;

// Assign
//
procedure TGLFaceProperties.Assign(Source: TPersistent);
begin
   if Assigned(Source) and (Source is TGLFaceProperties) then begin
      FAmbient.FColor:=TGLFaceProperties(Source).FAmbient.FColor;
      FDiffuse.FColor:=TGLFaceProperties(Source).FDiffuse.FColor;
      FSpecular.FColor:=TGLFaceProperties(Source).FSpecular.FColor;
      FShininess:=TGLFaceProperties(Source).FShininess;
      FPolygonMode:=TGLFaceProperties(Source).FPolygonMode;
      FEmission.FColor:=TGLFaceProperties(Source).FEmission.FColor;
   end;
end;

// SetAmbient
//
procedure TGLFaceProperties.SetAmbient(AValue: TGLColor);
begin
   FAmbient.FColor:=AValue.FColor;
   NotifyChange;
end;

// SetDiffuse
//
procedure TGLFaceProperties.SetDiffuse(AValue: TGLColor);
begin
   FDiffuse.FColor:=AValue.FColor;
   NotifyChange;
end;

// SetEmission
//
procedure TGLFaceProperties.SetEmission(AValue: TGLColor);
begin
   FEmission.FColor:=AValue.FColor;
   NotifyChange;
end;

// SetSpecular
//
procedure TGLFaceProperties.SetSpecular(AValue: TGLColor);
begin
   FSpecular.FColor:=AValue.FColor;
   NotifyChange;
end;

// SetPolygonMode
//
procedure TGLFaceProperties.SetPolygonMode(AValue: TPolygonMode);
begin
   if AValue<>FPolygonMode then begin
      FPolygonMode := AValue;
      NotifyChange;
   end;
end;

// SetShininess
//
procedure TGLFaceProperties.SetShininess(AValue: TShininess);
begin
	if FShininess<>AValue then begin
		FShininess:=AValue;
		NotifyChange;
	end;
end;

// ------------------
// ------------------ TGLTextureImage ------------------
// ------------------

// Create
//
constructor TGLTextureImage.Create(AOwner: TPersistent);
begin
	inherited;
	FOwnerTexture:=(AOwner as TGLTexture);
end;

// Destroy
//
destructor TGLTextureImage.Destroy;
begin
	inherited Destroy;
end;

// FriendlyDescription
//
class function TGLTextureImage.FriendlyDescription : String;
begin
	Result:=FriendlyName;
end;

// Invalidate
//
procedure TGLTextureImage.Invalidate;
begin
	ReleaseHBitmap;
	Include(FOwnerTexture.FChanges, tcImage);
end;

// ReleaseHBitmap
//
procedure TGLTextureImage.ReleaseHBitmap;
begin
	// nothing here.
end;

// NotifyChange
//
procedure TGLTextureImage.NotifyChange;
begin
	Include(FOwnerTexture.FChanges, tcImage);
	FOwnerTexture.NotifyChange;
end;

// ------------------
// ------------------ TGLPictureImage ------------------
// ------------------

// Create
//
constructor TGLPictureImage.Create(AOwner: TPersistent);
begin
	inherited;
	FPicture:=TPicture.Create;
	FPicture.OnChange:=PictureChanged;
end;

// Destroy
//
destructor TGLPictureImage.Destroy;
begin
	ReleaseHBitmap;
	FPicture.Free;
	inherited Destroy;
end;

// Assign
//
procedure TGLPictureImage.Assign(Source: TPersistent);
begin
	if Assigned(Source) and (Source is TGLPersistentImage) then begin
		FPicture.Assign(TGLPersistentImage(Source).FPicture);
	end else inherited;
end;

// BeginUpdate
//
procedure TGLPictureImage.BeginUpdate;
begin
	Inc(FUpdateCounter);
	FPicture.OnChange:=nil;
end;

// EndUpdate
//
procedure TGLPictureImage.EndUpdate;
begin
	Assert(FUpdateCounter>0, ClassName+': Unbalanced Begin/EndUpdate');
	Dec(FUpdateCounter);
	FPicture.OnChange:=PictureChanged;
	if FUpdateCounter=0 then
		PictureChanged(FPicture);
end;

// GetHeight
//
function TGLPictureImage.GetHeight: Integer;
begin
	Result:=FPicture.Height;
end;

// GetWidth
//
function TGLPictureImage.GetWidth: Integer;
begin
	Result:=FPicture.Width;
end;

// GetHBitmap
//
function TGLPictureImage.GetHBitmap: HBitmap;
begin
	if not Assigned(FBitmap) then begin
		if FPicture.Graphic is TBitmap then
			FBitmap:=FPicture.Bitmap
		else begin
			// Picture ain't no bitmap, we have to make ours !
			FBitmap:=TBitmap.Create;
			FBitmap.PixelFormat:=pf24bit;
			FBitmap.Width:=FPicture.Width;
			FBitmap.Height:=FPicture.Height;
			FBitmap.Canvas.Draw(0, 0, FPicture.Graphic);
		end;
	end;
	Result:=FBitmap.Handle;
end;

// ReleaseHBitmap
//
procedure TGLPictureImage.ReleaseHBitmap;
begin
	if Assigned(FBitmap) then begin
		if FPicture.Bitmap<>FBitmap then
			FBitmap.Free;
		FBitmap:=nil;
	end;
end;

// PictureChanged
//
procedure TGLPictureImage.PictureChanged(Sender: TObject);
begin
	Invalidate;
end;

// SetPicture
//
procedure TGLPictureImage.SetPicture(const aPicture : TPicture);
begin
	FPicture:=aPicture;
	Invalidate;
end;

// ------------------
// ------------------ TGLPersistentImage ------------------
// ------------------

// Create
//
constructor TGLPersistentImage.Create(AOwner: TPersistent);
begin
	inherited;
end;

// Destroy
//
destructor TGLPersistentImage.Destroy;
begin
	inherited Destroy;
end;

// Edit
//
function TGLPersistentImage.Edit : Boolean;
var
	opd : TOpenPictureDialog;
begin
	opd:=TOpenPictureDialog.Create(nil);
	try
		Result:=opd.Execute;
		if Result then begin
			Picture.LoadFromFile(opd.FileName);
			NotifyChange;
		end;
	finally
		opd.Free;
	end;
end;

// SaveToFile
//
procedure TGLPersistentImage.SaveToFile(const fileName : String);
begin
	Picture.SaveToFile(fileName);
end;

// LoadFromFile
//
procedure TGLPersistentImage.LoadFromFile(const fileName : String);
begin
	Picture.LoadFromFile(fileName);
end;

// FriendlyName
//
class function TGLPersistentImage.FriendlyName : String;
begin
	Result:='Persistent Image';
end;

// FriendlyDescription
//
class function TGLPersistentImage.FriendlyDescription : String;
begin
	Result:='Image data is stored in its original format with other form resources,'
			 +'ie. in the DFM at design-time, and embedded in the EXE at run-time.';
end;

// ------------------
// ------------------ TGLPicFileImage ------------------
// ------------------

// Create
//
constructor TGLPicFileImage.Create(AOwner: TPersistent);
begin
	inherited;
end;

// Destroy
//
destructor TGLPicFileImage.Destroy;
begin
	inherited;
end;

// SetPictureFileName
//
procedure TGLPicFileImage.SetPictureFileName(const val : String);
begin
	if val<>FPictureFileName then begin
		FPictureFileName:=val;
		Invalidate;
	end;
end;

// Invalidate
//
procedure TGLPicFileImage.Invalidate;
begin
	Picture.OnChange:=nil;
	try
		Picture.Assign(nil);
	finally
		Picture.OnChange:=PictureChanged;
	end;
	inherited;
end;

// GetHBitmap
//
function TGLPicFileImage.GetHBitmap: HBitmap;
begin
	if (GetWidth<=0) and (PictureFileName<>'') then begin
		Picture.OnChange:=nil;
		try
			Picture.LoadFromFile(PictureFileName);
		finally
			Picture.OnChange:=PictureChanged;
		end;
	end;
	Result:=inherited GetHBitmap;
end;

// Edit
//
function TGLPicFileImage.Edit : Boolean;
var
	newName : String;
begin
{ TODO : A better TGLPicFileImage.Edit is needed... }
	newName:=InputBox('PicFile Image', 'Enter filename', PictureFileName);
	Result:=(PictureFileName<>newName);
	if Result then
		PictureFileName:=newName
end;

// SaveToFile
//
procedure TGLPicFileImage.SaveToFile(const fileName : String);
begin
	SaveStringToFile(fileName, PictureFileName);
end;

// LoadFromFile
//
procedure TGLPicFileImage.LoadFromFile(const fileName : String);
begin
	PictureFileName:=LoadStringFromFile(fileName);
end;

// FriendlyName
//
class function TGLPicFileImage.FriendlyName : String;
begin
	Result:='PicFile Image';
end;

// FriendlyDescription
//
class function TGLPicFileImage.FriendlyDescription : String;
begin
	Result:='Image data is retrieved from a file.';
end;

{ !!!!!!!!!!! Disabled !!!!!!!!!!!!!!!!

//----------------- TGLCaptureImage ----------------------------------------------

constructor TGLCaptureImage.Create(AOwner: TPersistent);
begin
  inherited;
  FBitmap:=TBitmap.Create;
  FBitmap.Width:=32;
  FBitmap.Height:=32;
  //FBitmap.OnChange:=PictureChanged;
end;

destructor TGLCaptureImage.Destroy;
begin
   FBitmap.Free;
   inherited Destroy;
end;

function TGLCaptureImage.GetHeight: Integer;
begin
	Result:=FBitmap.Height;
end;

function TGLCaptureImage.GetWidth: Integer;
begin
  Result:=FBitmap.Width;
end;

function TGLCaptureImage.GetBitmap: HBitmap;
begin
  if not Valid then
	 raise Exception.Create(glsImageInvalid);
  Result:=FBitmap.Handle;
end;

procedure TGLCaptureImage.DataNeeded;
var
   Rect : TRectangle;
begin
   if not Valid then begin
		Rect.Left:=FLeft;
      Rect.Top:=FTop;
      Rect.Width:=FBitmap.Width;
      Rect.Height:=FBitmap.Height;
		ReadScreenImage(FBitmap.Canvas.Handle,0,0,Rect);
		Validate;
   end;
end;

procedure TGLCaptureImage.PictureChanged(Sender: TObject);
begin
	if Valid then NotifyChange;
end;

procedure TGLCaptureImage.SetHeight(AValue: Integer);
begin
	if FBitmap.Height <> AValue then begin
		FBitmap.Height:=AValue;
		Invalidate;
	end;
end;

procedure TGLCaptureImage.SetLeft(AValue: Integer);
begin
	if FLeft <> AValue then begin
		FLeft:=AValue;
		Invalidate;
	end;
end;

procedure TGLCaptureImage.SetTop(AValue: Integer);
begin
	if FTop <> AValue then begin
		FTop:=AValue;
		Invalidate;
	end;
end;

procedure TGLCaptureImage.SetWidth(AValue: Integer);
begin
	if FBitmap.Width <> AValue then begin
		FBitmap.Width:=AValue;
		Invalidate;
	end;
end;
}

// ------------------
// ------------------ TGLTexture ------------------
// ------------------

// Create
//
constructor TGLTexture.Create(AOwner: TPersistent);
begin
	inherited;
	FDisabled:=True;
	FChanges:=[tcImage, tcParams];
	FImage:=TGLPersistentImage.Create(Self);
	FImageAlpha:=tiaDefault;
	FMagFilter:=maNearest;
	FMinFilter:=miNearest;
end;

// Destroy
//
destructor TGLTexture.Destroy;
begin
	DestroyHandle;
	FImage.Free;
	inherited Destroy;
end;

// SetImage
//
procedure TGLTexture.SetImage(AValue: TGLTextureImage);
begin
	if FImage.ClassType<>AValue.ClassType then begin
		FImage.Free;
		FImage:=TGLTextureImageClass(AValue.ClassType).Create(Self);
	end;
	FImage.Assign(AValue);
	Include(FChanges, tcImage);
	NotifyChange;
end;

// SetImageClassName
//
procedure TGLTexture.SetImageClassName(const val : String);
begin
	if val<>'' then if FImage.ClassName<>val then begin
		FImage.Free;
		FImage:=TGLTextureImageClass(FindGLTextureImageClass(val)).Create(Self);
		Include(FChanges, tcImage);
		NotifyChange;
	end;
end;

// GetImageClassName
//
function TGLTexture.GetImageClassName : String;
begin
	Result:=FImage.ClassName;
end;

// SetImageAlpha
//
procedure TGLTexture.SetImageAlpha(const val : TGLTextureImageAlpha);
begin
	FImageAlpha:=val;
	Include(FChanges, tcImage);
	NotifyChange;
end;

// SetMagFilter
//
procedure TGLTexture.SetMagFilter(AValue: TGLMagFilter);
begin
	if AValue <> FMagFilter then begin
		FMagFilter:=AValue;
		Include(FChanges, tcParams);
		NotifyChange;
	end;
end;

// SetMinFilter
//
procedure TGLTexture.SetMinFilter(AValue: TGLMinFilter);
begin
	if AValue <> FMinFilter then begin
		FMinFilter:=AValue;
		Include(FChanges,tcParams);
		NotifyChange;
	end;
end;

// SetTextureMode
//
procedure TGLTexture.SetTextureMode(AValue: TGLTextureMode);
begin
	if AValue <> FTextureMode then begin
		FTextureMode:=AValue;
		Include(FChanges,tcParams);
		NotifyChange;
	end;
end;

// SetDisabled
//
procedure TGLTexture.SetDisabled(AValue: Boolean);
begin
	if AValue <> FDisabled then begin
		FDisabled:=AValue;
		NotifyChange;
	end;
end;

// SetTextureWrap
//
procedure TGLTexture.SetTextureWrap(AValue: TGLTextureWrap);
begin
	if AValue <> FTextureWrap then begin
		FTextureWrap:=AValue;
		Include(FChanges,tcParams);
		NotifyChange;
	end;
end;

// Apply
//
procedure TGLTexture.Apply;
const
	cTextureMode : array [tmDecal..tmReplace] of TGLEnum =
							( GL_DECAL, GL_MODULATE, GL_BLEND, GL_REPLACE );
begin
	glBindTexture(GL_TEXTURE_2D, Handle);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, cTextureMode[FTextureMode]);
end;

// GetHandle
//
function TGLTexture.GetHandle: TGLuint;
begin
	if (FHandle = 0) or (FChanges <> []) then begin
		if FHandle = 0 then begin
			glGenTextures(1, @FHandle);
			Assert(FHandle<>0);
		end;
		glBindtexture(GL_TEXTURE_2D, FHandle);
//		if tcImage in FChanges then
		PrepareImage;
//		if tcParams in FChanges then
		PrepareParams;
		FChanges:=[];
	end;
	Result:=FHandle;
end;

// PrepareImage
//
procedure TGLTexture.PrepareImage;
type
	PPixelArray  = ^TByteArray;
var
	i, i3, i4, imageSize, w, h, w2, h2, bytesPerPixel, r, g, b : Integer;
	data, buffer : PPixelArray;
	bMInfo : TBitmapInfo;
	temp : Byte;
	memDC : HDC;
	rgbFormat : TGLenum;
	alphaChannelRequired : Boolean;
	sqrt255Array : PSqrt255Array;
begin
	if Image.GetHBitmap=0 then Exit;
	w:=Image.Width;
	h:=Image.Height;
	imageSize:=w*h;
 	if imageSize<=0 then Exit;
	alphaChannelRequired:=(ImageAlpha<>tiaDefault);
	if alphaChannelRequired then
		bytesPerPixel:=4
	else bytesPerPixel:=3;
	// create description of the required image format (24 bits RGB)
	FillChar(BMInfo, SizeOf(TBitmapInfo), 0);
	with BMinfo.bmiHeader do begin
		biSize:=SizeOf(TBitmapInfoHeader);
		biBitCount:=24;
		biWidth:=w;
		biHeight:=h;
		biPlanes:=1;
		biCompression:=BI_RGB;
	end;
	memDC:=CreateCompatibleDC(0);
	GetMem(data, imageSize*bytesPerPixel);
	try
		// get the actual bits of the image
		GetDIBits(memDC, Image.GetHBitmap, 0, h, data, bMInfo, DIB_RGB_COLORS);
		w2:=RoundUpToPowerOf2(w);
		h2:=RoundUpToPowerOf2(h);
		GetMem(buffer, w2*h2*bytesPerPixel);
		try
			if GL_EXT_bgra then begin
				// no need to swap r and b components
				rgbFormat:=GL_BGR_EXT;
			end else begin
				//swap blue with red to go from bgr to rgb
				for i:=0 to imageSize-1 do begin
					i3:=i*3;
					temp:=data[i3];
					data[i3]:=data[i3+2];
					data[i3+2]:=temp;
				end;
				rgbFormat:=GL_RGB;
			end;
{ TODO : Alpha expansion code should be moved to an independant func }
			if alphaChannelRequired then begin
				if rgbFormat=GL_RGB then
					rgbFormat:=GL_RGBA
				else if rgbFormat=GL_BGR_EXT then
					rgbFormat:=GL_BGRA_EXT;
				// expand RGB->RGBA
				case ImageAlpha of
					tiaAlphaFromIntensity : begin
						for i:=imageSize-1 downto 0 do begin
							i3:=i*3;
							r:=data[i3];  g:=data[i3+1];  b:=data[i3+2];
							i4:=i*4;
							data[i4+3]:=((r+g+b) div 3);
							data[i4]:=r;  data[i4+1]:=g;  data[i4+2]:=b;
						end;
					end;
					tiaSuperBlackTransparent : begin
						for i:=imageSize-1 downto 0 do begin
							i3:=i*3; i4:=i*4;
							r:=data[i3]; g:=data[i3+1]; b:=data[i3+2];
							if r+g+b=0 then
								data[i4+3]:=0
							else data[i4+3]:=255;
							data[i4+2]:=b;
							data[i4+1]:=g;
							data[i4]:=r;
						end;
					end;
					tiaLuminance : begin
						for i:=imageSize-1 downto 0 do begin
							i3:=i*3; i4:=i*4;
							temp:=((data[i3]+data[i3+1]+data[i3+2]) div 3);
							data[i4]:=temp;  	data[i4+1]:=temp;
							data[i4+2]:=temp;	data[i4+3]:=temp;
						end;
					end;
					tiaLuminanceSqrt : begin
						sqrt255Array:=GetSqrt255Array;
						for i:=imageSize-1 downto 0 do begin
							i3:=i*3; i4:=i*4;
							temp:=sqrt255Array[((data[i3]+data[i3+1]+data[i3+2]) div 3)];
							data[i4]:=temp;  	data[i4+1]:=temp;
							data[i4+2]:=temp;	data[i4+3]:=temp;
						end;
					end;
				end;
			end;
			// scaling must be done AFTER RGB/BGR swap
			gluScaleImage(rgbFormat, w, h, GL_UNSIGNED_BYTE, Data, w2, h2,
							  GL_UNSIGNED_BYTE, buffer);
			case FMinFilter of
				miNearest, miLinear :
					glTexImage2d(GL_TEXTURE_2D, 0, bytesPerPixel, w2, h2, 0,
									 rgbFormat, GL_UNSIGNED_BYTE, Buffer)
			else
				gluBuild2DMipmaps(GL_TEXTURE_2D, bytesPerPixel, w2, h2,
										rgbFormat, GL_UNSIGNED_BYTE, Buffer);
			end;
		finally
			FreeMem(buffer);
		end;
	finally
		FreeMem(Data);
		DeleteDC(MemDC);
	end;
	image.ReleaseHBitmap;
end;

// PrepareParams
//
procedure TGLTexture.PrepareParams;
const
	cTextureSWrap : array [twBoth..twHorizontal] of TGLEnum =
							( GL_REPEAT, GL_CLAMP, GL_CLAMP, GL_REPEAT );
	cTextureTWrap : array [twBoth..twHorizontal] of TGLEnum =
							( GL_REPEAT, GL_CLAMP, GL_REPEAT, GL_CLAMP );
	cTextureMagFilter : array [maNearest..maLinear] of TGLEnum =
							( GL_NEAREST, GL_LINEAR );
	cTextureMinFilter : array [miNearest..miLinearMipmapLinear] of TGLEnum =
							( GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST,
							  GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR,
							  GL_LINEAR_MIPMAP_LINEAR );
begin
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
	glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, cTextureSWrap[FTextureWrap]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, cTextureTWrap[FTextureWrap]);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, cTextureMinFilter[FMinFilter]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, cTextureMagFilter[FMagFilter]);
end;

// Assign
//
procedure TGLTexture.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TGLTexture) then begin
		if Source<>Self then begin
			FImageAlpha:=TGLTexture(Source).FImageAlpha;
			FTextureMode:=TGLTexture(Source).FTextureMode;
			FTextureWrap:=TGLTexture(Source).FTextureWrap;
			FMinFilter:=TGLTexture(Source).FMinFilter;
			FMagFilter:=TGLTexture(Source).FMagFilter;
			FDisabled:=TGLTexture(Source).FDisabled;
			Image:=TGLTexture(Source).FImage;
			FChanges:=[tcParams, tcImage];
		end;
	end else inherited Assign(Source);
end;

// ReloadImage
//
procedure TGLTexture.ReloadImage;
begin
	FChanges:=[tcImage, tcParams];
end;

// DestroyHandle
//
procedure TGLTexture.DestroyHandle;
begin
	if FHandle <> 0 then begin
		glDeleteTextures(1,@FHandle);
		FHandle:=0;
		FChanges:=[tcParams,tcImage];
	end;
end;

// DisableAutoTexture
//
procedure TGLTexture.DisableAutoTexture;
begin
	glDisable(GL_TEXTURE_GEN_S);
	glDisable(GL_TEXTURE_GEN_T);
end;

// InitAutoTexture
//
procedure TGLTexture.InitAutoTexture(TexRep: PTexPoint);
var
	sGenParams, tGenParams  : TVector;
begin
	sGenParams:=XHmgVector;
	tGenParams:=YHmgVector;

	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	if Assigned(TexRep) then
		sGenparams[0]:=TexRep.S;
	glTexGenfv(GL_S, GL_OBJECT_PLANE, @SGenParams);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_OBJECT_LINEAR);
	if Assigned(TexRep) then
		tGenparams[1]:=TexRep.T;
	glTexGenfv(GL_T, GL_OBJECT_PLANE, @TGenparams);

	glEnable(GL_TEXTURE_GEN_S);
  	glEnable(GL_TEXTURE_GEN_T);
end;

//----------------- TGLMaterial --------------------------------------------------

constructor TGLMaterial.Create(AOwner: TPersistent);
begin
  inherited;
  FBackProperties:=TGLFaceProperties.Create(Self);
  FFrontProperties:=TGLFaceProperties.Create(Self);
  FTexture:=TGLTexture.Create(Self);
end;

//------------------------------------------------------------------------------

destructor TGLMaterial.Destroy;
begin
   if Assigned(currentLibMaterial) then
      currentLibMaterial.UnregisterUser(Self);
   FBackProperties.Free;
   FFrontProperties.Free;
   FTexture.Free;
   inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLMaterial.SetBackProperties(Values: TGLFaceProperties);
begin
	FBackProperties.Assign(Values);
	NotifyChange;
end;

//------------------------------------------------------------------------------

procedure TGLMaterial.SetFrontProperties(Values: TGLFaceProperties);
begin
	FFrontProperties.Assign(Values);
	NotifyChange;
end;

// SetBlendingMode
//
procedure TGLMaterial.SetBlendingMode(const val : TBlendingMode);
begin
   if val <> FBlendingMode then begin
      FBlendingMode := val;
   	NotifyChange;
   end;
end;

// SetTexture
//
procedure TGLMaterial.SetTexture(ATexture: TGLTexture);
begin
	FTexture.Assign(ATexture);
	NotifyChange;
end;

// SetMaterialLibrary
//
procedure TGLMaterial.SetMaterialLibrary(const val : TGLMaterialLibrary);
begin
   FMaterialLibrary:=val;
   SetLibMaterialName(LibMaterialName);
end;

// SetLibMaterialName
//
procedure TGLMaterial.SetLibMaterialName(const val : TGLLibMaterialName);
var
   newLibMaterial : TGLLibMaterial;
begin
   // locate new libmaterial
   if Assigned(FMaterialLibrary) then
      newLibMaterial:=MaterialLibrary.Materials.GetLibMaterialByName(val)
   else newLibMaterial:=nil;
   FLibMaterialName:=val;
   // unregister if required
   if newLibMaterial<>currentLibMaterial then begin
      if Assigned(currentLibMaterial) then
         currentLibMaterial.UnregisterUser(Self);
      currentLibMaterial:=newLibMaterial;
      // register with new
      if Assigned(currentLibMaterial) then
         currentLibMaterial.RegisterUser(Self);
      NotifyChange;
   end;
end;

// NotifyLibMaterialDestruction
//
procedure TGLMaterial.NotifyLibMaterialDestruction;
begin
   FMaterialLibrary:=nil;
   FLibMaterialName:='';
   currentLibMaterial:=nil;
end;

// StoreMaterialProps
//
function TGLMaterial.StoreMaterialProps : Boolean;
begin
	Result:=not Assigned(currentLibMaterial);
end;

// Apply
//
procedure TGLMaterial.Apply(var currentStates : TGLStates);
begin
	if Assigned(currentLibMaterial) then
		currentLibMaterial.Material.Apply(currentStates)
	else begin
		FFrontProperties.Apply(GL_FRONT);
		if not (stCullFace in currentStates) then
			FBackProperties.Apply(GL_BACK);
		case FBlendingMode of
			bmOpaque : UnSetGLState(currentStates, stBlend);
			bmTransparency : begin
				SetGLState(currentStates, stBlend);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			end;
			bmAdditive : begin
				SetGLState(currentStates, stBlend);
				glBlendFunc(GL_SRC_ALPHA, GL_ONE);
			end;
		end;
		if not FTexture.Disabled then begin
			SetGLState(currentStates, stTexture2D);
			FTexture.Apply;
		end else UnSetGLState(currentStates, stTexture2D);
	end;
end;

// Assign
//
procedure TGLMaterial.Assign(Source: TPersistent);
begin
   if Assigned(Source) and (Source is TGLMaterial) then begin
      FBackProperties.Assign(TGLMaterial(Source).FBackProperties);
      FFrontProperties.Assign(TGLMaterial(Source).FFrontProperties);
		FBlendingMode:=TGLMaterial(Source).FBlendingMode;
      FTexture.Assign(TGLMaterial(Source).FTexture);
      SetMaterialLibrary(TGLMaterial(Source).MaterialLibrary);
      SetLibMaterialName(TGLMaterial(Source).LibMaterialName);
   end else inherited;
end;

// NotifyChange
//
procedure TGLMaterial.NotifyChange;
begin
   if Assigned(Owner) then
      if Owner is TGLSceneObject then
         TGLSceneObject(Owner).StructureChanged
      else if Owner is TGLLibMaterial then
         TGLLibMaterial(Owner).NotifyUsers;
end;

// ------------------
// ------------------ TGLLibMaterial ------------------
// ------------------

// Create
//
constructor TGLLibMaterial.Create(Collection : TCollection);
begin
	inherited Create(Collection);
   userList:=TList.Create;
   FName:=TGLLibMaterials(Collection).MakeUniqueName('LibMaterial');
   FMaterial:=TGLMaterial.Create(Self);
end;

// Destroy
//
destructor TGLLibMaterial.Destroy;
var
   i : Integer;
begin
   for i:=0 to userList.Count-1 do
      TGLMaterial(userList[i]).NotifyLibMaterialDestruction;
   userList.Free;
   FMaterial.Free;
	inherited Destroy;
end;

// Assign
//
procedure TGLLibMaterial.Assign(Source: TPersistent);
begin
	if Source is TGLLibMaterial then begin
      FName:=TGLLibMaterials(Collection).MakeUniqueName(TGLLibMaterial(Source).Name);
      FMaterial.Assign(TGLLibMaterial(Source).Material);
	end else inherited;
end;

// RegisterUser
//
procedure TGLLibMaterial.RegisterUser(material : TGLMaterial);
begin
   Assert(userList.IndexOf(material)<0);
   userList.Add(material);
end;

// UnregisterUser
//
procedure TGLLibMaterial.UnregisterUser(material : TGLMaterial);
begin
   userList.Remove(material);
end;

// NotifyUsers
//
procedure TGLLibMaterial.NotifyUsers;
var
   i : Integer;
begin
   for i:=0 to userList.Count-1 do
      TGLMaterial(userList[i]).NotifyChange;
end;

// GetDisplayName
//
function TGLLibMaterial.GetDisplayName : String;
begin
	Result:=Name;
end;

// SetName
//
procedure TGLLibMaterial.SetName(const val : TGLLibMaterialName);
begin
   FName:=TGLLibMaterials(Collection).MakeUniqueName(val);
end;

// SetMaterial
//
procedure TGLLibMaterial.SetMaterial(const val : TGLMaterial);
begin
   FMaterial.Assign(val);
end;

// ------------------
// ------------------ TGLLibMaterials ------------------
// ------------------

// Create
//
constructor TGLLibMaterials.Create(AOwner : TComponent);
begin
	Owner:=AOwner;
	inherited Create(TGLLibMaterial);
end;

// GetOwner
//
function TGLLibMaterials.GetOwner: TPersistent;
begin
	Result:=Owner;
end;

// SetItems
//
procedure TGLLibMaterials.SetItems(index : Integer; const val : TGLLibMaterial);
begin
	inherited Items[index]:=val;
end;

// GetItems
//
function TGLLibMaterials.GetItems(index : Integer) : TGLLibMaterial;
begin
	Result:=TGLLibMaterial(inherited Items[index]);
end;

// Add
//
function TGLLibMaterials.Add: TGLLibMaterial;
begin
	Result:=(inherited Add) as TGLLibMaterial;
end;

// FindItemID
//
function TGLLibMaterials.FindItemID(ID: Integer): TGLLibMaterial;
begin
	Result:=(inherited FindItemID(ID)) as TGLLibMaterial;
end;

// Delete
//
procedure TGLLibMaterials.Delete(index : Integer);
var
	item : TCollectionItem;
begin
	item:=inherited Items[index];
	item.Collection:=nil; item.Free;
end;

// MakeUniqueName
//
function TGLLibMaterials.MakeUniqueName(const nameRoot : TGLLibMaterialName) : TGLLibMaterialName;
var
   i : Integer;
begin
   Result:=nameRoot;
   i:=1;
   while GetLibMaterialByName(Result)<>nil do begin
      Result:=nameRoot+IntToStr(i);
      Inc(i);
   end;
end;

// GetLibMaterialByName
//
function TGLLibMaterials.GetLibMaterialByName(const name : TGLLibMaterialName) : TGLLibMaterial;
var
   i : Integer;
   lm : TGLLibMaterial;
begin
   Result:=nil;
   for i:=0 to Count-1 do begin
      lm:=TGLLibMaterial(inherited Items[i]);
      if lm.Name=name then begin
         Result:=lm;
         Break;
      end;
   end;
end;

// SetNamesToTStrings
//
procedure TGLLibMaterials.SetNamesToTStrings(aStrings : TStrings);
var
   i : Integer;
   lm : TGLLibMaterial;
begin
   with aStrings do begin
      BeginUpdate;
      Clear;
      for i:=0 to Self.Count-1 do begin
         lm:=TGLLibMaterial(inherited Items[i]);
         AddObject(lm.Name, lm);
      end;
      EndUpdate;
   end;
end;

// ------------------
// ------------------ TGLMaterialLibrary ------------------
// ------------------

// Create
//
constructor TGLMaterialLibrary.Create(AOwner : TComponent);
begin
   inherited;
   FMaterials:=TGLLibMaterials.Create(Self);
end;

// Destroy
//
destructor TGLMaterialLibrary.Destroy;
begin
   FMaterials.Free;
   inherited;
end;

// SetMaterials
//
procedure TGLMaterialLibrary.SetMaterials(const val : TGLLibMaterials);
begin
   FMaterials.Assign(val);
end;

// SaveToStream
//
procedure TGLMaterialLibrary.SaveToStream(aStream : TStream);
var
   wr : TWriter;
begin
   wr:=TWriter.Create(aStream, 16384);
   try
      wr.WriteComponent(Self);
   finally
      wr.Free;
   end;
end;

// LoadFromStream
//
procedure TGLMaterialLibrary.LoadFromStream(aStream : TStream);
var
   rd : TReader;
begin
   rd:=TReader.Create(aStream, 16384);
   try
      rd.ReadComponent(Self);
   finally
      rd.Free;
   end;
end;

// SaveToFile
//
procedure TGLMaterialLibrary.SaveToFile(const fileName : String);
var
   fs : TFileStream;
begin
   fs:=TFileStream.Create(fileName, fmCreate);
   try
      SaveToStream(fs);
   finally
      fs.Free;
   end;
end;

// LoadFromFile
//
procedure TGLMaterialLibrary.LoadFromFile(const fileName : String);
var
   fs : TFileStream;
begin
   fs:=TFileStream.Create(fileName, fmOpenRead+fmShareDenyNone);
   try
      LoadFromStream(fs);
   finally
      fs.Free;
   end;
end;

//----------------- color manager ----------------------------------------------

function TGLColorManager.FindColor(AName: String): TColorVector;

var I : Integer;

begin
  Result:=clrBlack;
  for I:=0 to Count-1 do
    if CompareText(TColorEntry(Items[I]^).Name,AName) = 0 then
    begin
      Result:=TColorEntry(Items[I]^).Color;
      Break;
    end;
end;

//------------------------------------------------------------------------------

function TGLColorManager.GetColor(AName: String): TColorVector;
var
   WorkCopy  : String;
   Delimiter : Integer;
begin
  WorkCopy:=Trim(AName);
  if AName[1] in ['(','[','<'] then WorkCopy:=Copy(WorkCopy,2,Length(AName)-2);
  if CompareText(Copy(WorkCopy,1,3),'clr') = 0 then Result:=FindColor(WorkCopy)
                                               else
  try
    // initialize result
    Result:=clrBlack;
    WorkCopy:=Trim(WorkCopy);
    Delimiter:=Pos(' ',WorkCopy);
    if (Length(WorkCopy) > 0) and (Delimiter > 0) then
    begin
      Result[0]:=StrToFloat(Copy(WorkCopy,1,Delimiter-1));
      System.Delete(WorkCopy,1,Delimiter);
      WorkCopy:=TrimLeft(WorkCopy);
      Delimiter:=Pos(' ',WorkCopy);
      if (Length(WorkCopy) > 0) and (Delimiter > 0) then
      begin
        Result[1]:=StrToFloat(Copy(WorkCopy,1,Delimiter-1));
        System.Delete(WorkCopy,1,Delimiter);
        WorkCopy:=TrimLeft(WorkCopy);
        Delimiter:=Pos(' ',WorkCopy);
        if (Length(WorkCopy) > 0) and (Delimiter > 0) then
        begin
          Result[2]:=StrToFloat(Copy(WorkCopy,1,Delimiter-1));
          System.Delete(WorkCopy,1,Delimiter);
          WorkCopy:=TrimLeft(WorkCopy);
          Result[3]:=StrToFloat(WorkCopy);
        end
        else Result[2]:=StrToFloat(WorkCopy);
      end
      else Result[1]:=StrToFloat(WorkCopy);
    end
    else Result[0]:=StrToFloat(WorkCopy);
  except
    ShowMessage('Wrong vector format. Use: ''<red green blue alpha>''!');
    Abort;
  end;
end;

//------------------------------------------------------------------------------

function TGLColorManager.GetColorName(AColor: TColorVector): String;

const MinDiff = 1e-6;

var I : Integer;

begin
  for I:=0 to Count-1 do
    with TColorEntry(Items[I]^) do
      if (Abs(Color[0]-AColor[0]) < MinDiff) and
         (Abs(Color[1]-AColor[1]) < MinDiff) and
         (Abs(Color[2]-AColor[2]) < MinDiff) and
         (Abs(Color[3]-AColor[3]) < MinDiff) then Break;
  if I < Count then Result:=TColorEntry(Items[I]^).Name
               else
      Result:=Format('<%.3f %.3f %.3f %.3f>',[AColor[0],AColor[1],AColor[2],AColor[3]]);
end;

//------------------------------------------------------------------------------

destructor TGLColorManager.Destroy;

var I : Integer;

begin
  for I:=0 to Count-1 do FreeMem(Items[I],SizeOf(TColorEntry));
  inherited Destroy;
end;

//------------------------------------------------------------------------------

procedure TGLColorManager.AddColor(AName: String; AColor: TColorVector);

var NewEntry : PColorEntry;

begin
  New(NewEntry);
  if NewEntry = nil then raise Exception.Create('Could not allocate memory for color registration!');
  with NewEntry^ do
  begin
    Name:=AName;
    Color:=AColor;
  end;
  Add(NewEntry);
end;

//------------------------------------------------------------------------------

procedure TGLColorManager.EnumColors(Proc: TGetStrProc);

var I : Integer;

begin
  for I:=0 to Count-1 do Proc(TColorEntry(Items[I]^).Name);
end;

//------------------------------------------------------------------------------

procedure TGLColorManager.RegisterDefaultColors;

begin
  Capacity:=150;
  AddColor('clrBlack',clrBlack);
  AddColor('clrGray05',clrGray05);
  AddColor('clrGray10',clrGray10);
  AddColor('clrGray15',clrGray15);
  AddColor('clrGray20',clrGray20);
  AddColor('clrGray25',clrGray25);
  AddColor('clrGray30',clrGray30);
  AddColor('clrGray35',clrGray35);
  AddColor('clrGray40',clrGray40);
  AddColor('clrGray45',clrGray45);
  AddColor('clrGray50',clrGray50);
  AddColor('clrGray55',clrGray55);
  AddColor('clrGray60',clrGray60);
  AddColor('clrGray65',clrGray65);
  AddColor('clrGray70',clrGray70);
  AddColor('clrGray75',clrGray75);
  AddColor('clrGray80',clrGray80);
  AddColor('clrGray85',clrGray85);
  AddColor('clrGray90',clrGray90);
  AddColor('clrGray95',clrGray95);
  AddColor('clrWhite',clrWhite);
  AddColor('clrDimGray',clrDimGray);
  AddColor('clrGray',clrGray);
  AddColor('clrLightGray',clrLightGray);
  AddColor('clrAquamarine',clrAquamarine);
  AddColor('clrBakersChoc',clrBakersChoc);
  AddColor('clrBlueViolet',clrBlueViolet);
  AddColor('clrBrass',clrBrass);
  AddColor('clrBrightGold',clrBrightGold);
  AddColor('clrBronze',clrBronze);
  AddColor('clrBronze2',clrBronze2);
  AddColor('clrBrown',clrBrown);
  AddColor('clrCadetBlue',clrCadetBlue);
  AddColor('clrCoolCopper',clrCoolCopper);
  AddColor('clrCopper',clrCopper);
  AddColor('clrCoral',clrCoral);
  AddColor('clrCornflowerBlue',clrCornflowerBlue);
  AddColor('clrDarkBrown',clrDarkBrown);
  AddColor('clrDarkGreen',clrDarkGreen);
  AddColor('clrDarkOliveGreen',clrDarkOliveGreen);
  AddColor('clrDarkOrchid',clrDarkOrchid);
  AddColor('clrDarkPurple',clrDarkPurple);
  AddColor('clrDarkSlateBlue',clrDarkSlateBlue);
  AddColor('clrDarkSlateGray',clrDarkSlateGray);
  AddColor('clrDarkSlateGrey',clrDarkSlateGrey);
  AddColor('clrDarkTan',clrDarkTan);
  AddColor('clrDarkTurquoise',clrDarkTurquoise);
  AddColor('clrDarkWood',clrDarkWood);
  AddColor('clrDkGreenCopper',clrDkGreenCopper);
  AddColor('clrDustyRose',clrDustyRose);
  AddColor('clrFeldspar',clrFeldspar);
  AddColor('clrFirebrick',clrFirebrick);
  AddColor('clrFlesh',clrFlesh);
  AddColor('clrForestGreen',clrForestGreen);
  AddColor('clrGold',clrGold);
  AddColor('clrGoldenrod',clrGoldenrod);
  AddColor('clrGreenCopper',clrGreenCopper);
  AddColor('clrGreenYellow',clrGreenYellow);
  AddColor('clrHuntersGreen',clrHuntersGreen);
  AddColor('clrIndian',clrIndian);
  AddColor('clrKhaki',clrKhaki);
  AddColor('clrLightBlue',clrLightBlue);
  AddColor('clrLightPurple',clrLightPurple);
  AddColor('clrLightSteelBlue',clrLightSteelBlue);
  AddColor('clrLightWood',clrLightWood);
  AddColor('clrLimeGreen',clrLimeGreen);
  AddColor('clrMandarinOrange',clrMandarinOrange);
  AddColor('clrMaroon',clrMaroon);
  AddColor('clrMediumAquamarine',clrMediumAquamarine);
  AddColor('clrMediumBlue',clrMediumBlue);
  AddColor('clrMediumForestGreen',clrMediumForestGreen);
  AddColor('clrMediumGoldenrod',clrMediumGoldenrod);
  AddColor('clrMediumOrchid',clrMediumOrchid);
  AddColor('clrMediumPurple',clrMediumPurple);
  AddColor('clrMediumSeaGreen',clrMediumSeaGreen);
  AddColor('clrMediumSlateBlue',clrMediumSlateBlue);
  AddColor('clrMediumSpringGreen',clrMediumSpringGreen);
  AddColor('clrMediumTurquoise',clrMediumTurquoise);
  AddColor('clrMediumViolet',clrMediumViolet);
  AddColor('clrMediumWood',clrMediumWood);
  AddColor('clrMidnightBlue',clrMidnightBlue);
  AddColor('clrNavy',clrNavy);
  AddColor('clrNavyBlue',clrNavyBlue);
  AddColor('clrNeonBlue',clrNeonBlue);
  AddColor('clrNeonPink',clrNeonPink);
  AddColor('clrNewMidnightBlue',clrNewMidnightBlue);
  AddColor('clrNewTan',clrNewTan);
  AddColor('clrOldGold',clrOldGold);
  AddColor('clrOrange',clrOrange);
  AddColor('clrOrangeRed',clrOrangeRed);
  AddColor('clrOrchid',clrOrchid);
  AddColor('clrPaleGreen',clrPaleGreen);
  AddColor('clrPink',clrPink);
  AddColor('clrPlum',clrPlum);
  AddColor('clrQuartz',clrQuartz);
  AddColor('clrRichBlue',clrRichBlue);
  AddColor('clrSalmon',clrSalmon);
  AddColor('clrScarlet',clrScarlet);
  AddColor('clrSeaGreen',clrSeaGreen);
  AddColor('clrSemiSweetChoc',clrSemiSweetChoc);
  AddColor('clrSienna',clrSienna);
  AddColor('clrSilver',clrSilver);
  AddColor('clrSkyBlue',clrSkyBlue);
  AddColor('clrSlateBlue',clrSlateBlue);
  AddColor('clrSpicyPink',clrSpicyPink);
  AddColor('clrSpringGreen',clrSpringGreen);
  AddColor('clrSteelBlue',clrSteelBlue);
  AddColor('clrSummerSky',clrSummerSky);
  AddColor('clrTan',clrTan);
  AddColor('clrThistle',clrThistle);
  AddColor('clrTurquoise',clrTurquoise);
  AddColor('clrViolet',clrViolet);
  AddColor('clrVioletRed',clrVioletRed);
  AddColor('clrVeryDarkBrown',clrVeryDarkBrown);
  AddColor('clrVeryLightPurple',clrVeryLightPurple);
  AddColor('clrWheat',clrWheat);
  AddColor('clrYellowGreen',clrYellowGreen);
  AddColor('clrGreen',clrGreen);
  AddColor('clrOlive',clrOlive);
  AddColor('clrPurple',clrPurple);
  AddColor('clrTeal',clrTeal);
  AddColor('clrRed',clrRed);
  AddColor('clrLime',clrLime);
  AddColor('clrYellow',clrYellow);
  AddColor('clrBlue',clrBlue);
  AddColor('clrFuchsia',clrFuchsia);
  AddColor('clrAqua',clrAqua);

  AddColor('clrScrollBar',clrScrollBar);
  AddColor('clrBackground',clrBackground);
  AddColor('clrActiveCaption',clrActiveCaption);
  AddColor('clrInactiveCaption',clrInactiveCaption);
  AddColor('clrMenu',clrMenu);
  AddColor('clrWindow',clrWindow);
  AddColor('clrWindowFrame',clrWindowFrame);
  AddColor('clrMenuText',clrMenuText);
  AddColor('clrWindowText',clrWindowText);
  AddColor('clrCaptionText',clrCaptionText);
  AddColor('clrActiveBorder',clrActiveBorder);
  AddColor('clrInactiveBorder',clrInactiveBorder);
  AddColor('clrAppWorkSpace',clrAppWorkSpace);
  AddColor('clrHighlight',clrHighlight);
  AddColor('clrHighlightText',clrHighlightText);
  AddColor('clrBtnFace',clrBtnFace);
  AddColor('clrBtnShadow',clrBtnShadow);
  AddColor('clrGrayText',clrGrayText);
  AddColor('clrBtnText',clrBtnText);
  AddColor('clrInactiveCaptionText',clrInactiveCaptionText);
  AddColor('clrBtnHighlight',clrBtnHighlight);
  AddColor('clr3DDkShadow',clr3DDkShadow);
  AddColor('clr3DLight',clr3DLight);
  AddColor('clrInfoText',clrInfoText);
  AddColor('clrInfoBk',clrInfoBk);
end;

//------------------------------------------------------------------------------

procedure TGLColorManager.RemoveColor(AName: String);
var
  I : Integer;
begin
  for I:=0 to Count-1 do
    if CompareText(TColorEntry(Items[I]^).Name,AName) = 0 then
    begin
      Delete(I);
      Break;
	 end;
end;

// ConvertWinColor
//
function ConvertWinColor(aColor : TColor; alpha : Single = 1) : TColorVector;
var
   winColor : Integer;
begin
	// Delphi color to Windows color
   winColor:=ColorToRGB(AColor);
   // convert 0..255 range into 0..1 range
   Result[0]:=(winColor and $FF)/255;
   Result[1]:=((winColor shr 8) and $FF)/255;
   Result[2]:=((winColor shr 16) and $FF)/255;
   Result[3]:=alpha;
end;

//------------------------------------------------------------------------------

function ConvertColorVector(AColor: TColorVector): TColor;
begin
  Result := RGB(Round(255 * AColor[0]), Round(255 * AColor[1]), Round(255 * AColor[2]));
end;

//------------------------------------------------------------------------------

function ConvertRGBColor(AColor: array of Byte): TColorVector;
begin
  // convert 0..255 range into 0..1 range
  Result[0] := AColor[0] / 255;
  if High(AColor) > 0 then Result[1] := AColor[1] / 255
							 else Result[1] := 0;
  if High(AColor) > 1 then Result[2] := AColor[2] / 255
							 else Result[2] := 0;
  if High(AColor) > 2 then Result[3] := AColor[3] / 255
							 else Result[3] := 1;
end;

procedure InitWinColors;
begin
  clrScrollBar:=ConvertWinColor(clScrollBar);
  clrBackground:=ConvertWinColor(clBackground);
  clrActiveCaption:=ConvertWinColor(clActiveCaption);
  clrInactiveCaption:=ConvertWinColor(clInactiveCaption);
  clrMenu:=ConvertWinColor(clMenu);
  clrWindow:=ConvertWinColor(clWindow);
  clrWindowFrame:=ConvertWinColor(clWindowFrame);
  clrMenuText:=ConvertWinColor(clMenuText);
  clrWindowText:=ConvertWinColor(clWindowText);
  clrCaptionText:=ConvertWinColor(clCaptionText);
  clrActiveBorder:=ConvertWinColor(clActiveBorder);
  clrInactiveBorder:=ConvertWinColor(clInactiveBorder);
  clrAppWorkSpace:=ConvertWinColor(clAppWorkSpace);
  clrHighlight:=ConvertWinColor(clHighlight);
  clrHighlightText:=ConvertWinColor(clHighlightText);
  clrBtnFace:=ConvertWinColor(clBtnFace);
  clrBtnShadow:=ConvertWinColor(clBtnShadow);
  clrGrayText:=ConvertWinColor(clGrayText);
  clrBtnText:=ConvertWinColor(clBtnText);
  clrInactiveCaptionText:=ConvertWinColor(clInactiveCaptionText);
  clrBtnHighlight:=ConvertWinColor(clBtnHighlight);
  clr3DDkShadow:=ConvertWinColor(cl3DDkShadow);
  clr3DLight:=ConvertWinColor(cl3DLight);
  clrInfoText:=ConvertWinColor(clInfoText);
  clrInfoBk:=ConvertWinColor(clInfoBk);
end;

procedure RegisterColor(AName: String; AColor: TColorVector);
begin
  ColorManager.AddColor(AName,AColor);
end;

procedure UnregisterColor(AName: String);
begin
  ColorManager.RemoveColor(AName);
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

	InitWinColors;
	RegisterGLTextureImageClass(TGLPersistentImage);
	RegisterGLTextureImageClass(TGLPicFileImage);

finalization

	vColorManager.Free;
	vGLTextureImageClasses.Free;

end.
