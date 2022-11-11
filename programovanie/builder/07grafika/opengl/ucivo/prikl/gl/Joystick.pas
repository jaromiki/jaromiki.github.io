// Joystick
{: Egg<p>

	Component for handling joystick messages<p>

	<b>Historique : </b><font size=-1><ul>
	   <li>20/03/00 - Egg - Creation from GLScene's TGLJoystick
	</ul></font>
}
unit Joystick;

interface

uses Windows, Forms, Classes, Controls, Messages;

type

   TJoystickButton = (jbButton1, jbButton2, jbButton3, jbButton4);
   TJoystickButtons = set of TJoystickButton;

   TJoystickID = (NoJoystick, Joystick1, Joystick2);
   TJoystickDesignMode = (jdmInactive, jdmActive);
   TJoyPos = (jpMin, jpCenter, jpMax);
   TJoyAxis = (jaX, jaY, jaZ, jaR, jaU, jaV);

   TJoystickEvent = procedure(Sender: TObject; JoyID: TJoystickID; Buttons: TJoystickButtons; XDeflection, YDeflection: Integer) of Object;

	// TJoystick
	//
	TJoystick = class (TComponent)
	   private
	      { Private Declarations }
         FWindowHandle : HWND;
         FNumButtons, FLastX, FLastY, FLastZ: Integer;
         FThreshold, FInterval: Cardinal;
         FCapture: Boolean;
         FJoystickID: TJoystickID;
         FDesignMode: TJoystickDesignMode;
         FMinMaxInfo: array[TJoyAxis, TJoyPos] of Integer;
         FXPosInfo, FYPosInfo: array[0..4] of Integer;
         FOnJoystickButtonChange, FOnJoystickMove: TJoystickEvent;

         procedure SetCapture(AValue: Boolean);
         procedure SetInterval(AValue: Cardinal);
         procedure SetJoystickID(AValue: TJoystickID);
         procedure SetThreshold(AValue: Cardinal);

	   protected
	      { Protected Declarations }
         procedure DoJoystickCapture(AHandle: HWND; AJoystick: TJoystickID);
         procedure DoJoystickRelease(AJoystick: TJoystickID);
         procedure DoXYMove(Buttons: Word; XPos, YPos: Integer);
         procedure DoZMove(Buttons: Word; ZPos: Integer);
         procedure ReapplyCapture(AJoystick: TJoystickID);
         procedure WndProc(var Msg: TMessage);

      public
	      { Public Declarations }
	      constructor Create(AOwner : TComponent); override;
	      destructor Destroy; override;

         procedure Assign(Source: TPersistent); override;

	   published
	      { Published Declarations }
         property Capture: Boolean read FCapture write SetCapture default False;
         property DesignMode: TJoystickDesignMode read FDesignMode write FDesignMode default jdmInactive;
         property Interval: Cardinal read FInterval write SetInterval default 100;
         property JoystickID: TJoystickID read FJoystickID write SetJoystickID default NoJoystick;
         property Threshold: Cardinal read FThreshold write SetThreshold default 100;
	      property OnJoystickButtonChange: TJoystickEvent read FOnJoystickButtonChange write FOnJoystickButtonChange;
	      property OnJoystickMove: TJoystickEvent read FOnJoystickMove write FOnJoystickMove;

	end;

procedure Register;

// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
implementation
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------

uses SysUtils, MMSystem;

const
  cJoystickIDToNative : array [NoJoystick..Joystick2] of Byte =
                        (9, JOYSTICKID1, JOYSTICKID2);

resourcestring
  glsNoJoystickDriver   = 'There''s no joystick driver present';
  glsConnectJoystick    = 'Joystick 1 is not connected to your system';
  glsJoystickError      = 'Your system reports a joystick error, can''t do anything about it';

procedure Register;
begin
  RegisterComponents('OpenGL', [TJoystick]);
end;

// ------------------
// ------------------ TJoystick ------------------
// ------------------

// Create
//
constructor TJoystick.Create(AOwner: TComponent);
begin
   inherited;
   FInterval := 100;
   FThreshold := 100;
   FDesignMode := jdmInactive;
   FJoystickID := NoJoystick;
   FLastX := -1;
   FLastY := -1;
   FLastZ := -1;
   FWindowHandle := AllocateHWnd(WndProc);
end;

// Destroy
//
destructor TJoystick.Destroy;
begin
   DeallocateHWnd(FWindowHandle);
   inherited Destroy;
end;

// Assign
//
procedure TJoystick.Assign(Source: TPersistent);
begin
   if Source is TJoystick then begin
      FInterval := TJoystick(Source).FInterval;
      FThreshold := TJoystick(Source).FThreshold;
      FCapture := TJoystick(Source).FCapture;
      FJoystickID := TJoystick(Source).FJoystickID;
      try
         ReapplyCapture(FJoystickID);
      except
         FJoystickID := NoJoystick;
         FCapture := False;
         raise;
      end;
   end else inherited Assign(Source);
end;

//------------------------------------------------------------------------------

function DoScale(AValue: Integer): Integer;

begin
  Result := Round(AValue/1);
end;

//------------------------------------------------------------------------------

procedure TJoystick.ReapplyCapture(AJoystick: TJoystickID);

var JC: TJoyCaps;

begin
  DoJoystickRelease(AJoystick);
  if FCapture then
    with JC do
    begin
      joyGetDevCaps(cJoystickIDToNative[FJoystickID], @JC, SizeOf(JC));
      FNumButtons := wNumButtons;
      FMinMaxInfo[jaX, jpMin] := DoScale(wXMin);
      FMinMaxInfo[jaX, jpCenter] := DoScale((wXMin + wXMax) div 2); FMinMaxInfo[jaX, jpMax] := DoScale(wXMax);
      FMinMaxInfo[jaY, jpMin] := DoScale(wYMin); FMinMaxInfo[jaY, jpCenter] := DoScale((wYMin + wYMax) div 2); FMinMaxInfo[jaY, jpMax] := DoScale(wYMax);
      FMinMaxInfo[jaZ, jpMin] := DoScale(wZMin); FMinMaxInfo[jaZ, jpCenter] := DoScale((wZMin + wZMax) div 2); FMinMaxInfo[jaZ, jpMax] := DoScale(wZMax);
      FMinMaxInfo[jaR, jpMin] := DoScale(wRMin); FMinMaxInfo[jaR, jpCenter] := DoScale((wRMin + wRMax) div 2); FMinMaxInfo[jaR, jpMax] := DoScale(wRMax);
      FMinMaxInfo[jaU, jpMin] := DoScale(wUMin); FMinMaxInfo[jaU, jpCenter] := DoScale((wUMin + wUMax) div 2); FMinMaxInfo[jaU, jpMax] := DoScale(wUMax);
      FMinMaxInfo[jaV, jpMin] := DoScale(wVMin); FMinMaxInfo[jaV, jpCenter] := DoScale((wVMin + wVMax) div 2); FMinMaxInfo[jaV, jpMax] := DoScale(wVMax);
      DoJoystickCapture(FWindowHandle, AJoystick)
    end;
end;

//------------------------------------------------------------------------------

procedure TJoystick.DoJoystickCapture(AHandle: HWND; AJoystick: TJoystickID);
begin
   try
      case joySetCapture(AHandle, cJoystickIDToNative[AJoystick], FInterval, False) of
         MMSYSERR_NODRIVER : raise Exception.Create(glsNoJoystickDriver);
         JOYERR_UNPLUGGED :  raise Exception.Create(glsConnectJoystick);
         JOYERR_NOCANDO :    raise Exception.Create(glsJoystickError);
         JOYERR_NOERROR :    joySetThreshold(cJoystickIDToNative[AJoystick], FThreshold);
      else
         raise Exception.Create(glsJoystickError);
      end
   except
      FCapture := False;
      raise;
   end;
end;

// DoJoystickRelease
//
procedure TJoystick.DoJoystickRelease(AJoystick: TJoystickID);
begin
   if AJoystick <> NoJoystick then
      joyReleaseCapture(cJoystickIDToNative[AJoystick]);
end;

// SetCapture
//
procedure TJoystick.SetCapture(AValue: Boolean);
begin
   if FCapture <> AValue then begin
      FCapture := AValue;
      if not (csReading in ComponentState) then begin
         try
            ReapplyCapture(FJoystickID);
         except
            FCapture := False;
            raise;
         end;
      end;
   end;
end;

// SetInterval
//
procedure TJoystick.SetInterval(AValue: Cardinal);
begin
   if FInterval <> AValue then begin
      FInterval := AValue;
      if not (csReading in ComponentState) then
         ReapplyCapture(FJoystickID);
   end;
end;

// SetJoystickID
//
procedure TJoystick.SetJoystickID(AValue: TJoystickID);
begin
   if FJoystickID <> AValue then begin
      try
         if not (csReading in ComponentState) then
            ReapplyCapture(AValue);
         FJoystickID := AValue;
      except
         on E: Exception do begin
            ReapplyCapture(FJoystickID);
            Application.ShowException(E);
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------

procedure TJoystick.SetThreshold(AValue: Cardinal);

begin
  if FThreshold <> AValue then
  begin
    FThreshold := AValue;
    if not (csReading in ComponentState) then ReapplyCapture(FJoystickID);
  end;
end;

//------------------------------------------------------------------------------

function MakeJoyButtons(Param: UINT): TJoystickButtons;

begin
  Result := [];
  if (Param and JOY_BUTTON1) > 0 then Include(Result, jbButton1);
  if (Param and JOY_BUTTON2) > 0 then Include(Result, jbButton2);
  if (Param and JOY_BUTTON3) > 0 then Include(Result, jbButton3);
  if (Param and JOY_BUTTON4) > 0 then Include(Result, jbButton4);
end;

//------------------------------------------------------------------------------

function Approximation(Data: array of Integer): Integer;

// calculate a better estimation of the last value in the given data, depending
// on the other values (used to approximate a smoother joystick movement)
//
// based on Gauss' principle of smallest squares in Maximum-Likelihood and
// linear normal equations

var
  SumX, SumY, SumXX, SumYX: Double;
  I, Comps: Integer;
  a0, a1: Double;

begin
  SumX := 0;
  SumY := 0;
  SumXX := 0;
  SumYX := 0;
  Comps := High(Data) + 1;
  for I := 0 to High(Data) do
  begin
    SumX := SumX + I;
    SumY := SumY + Data[I];
    SumXX := SumXX + I * I;
    SumYX := SumYX + I * Data[I];
  end;
  a0 := (SumY * SumXX - SumX * SumYX) / (Comps * SumXX - SumX * SumX);
  a1 := (Comps * SumYX - SumY * SumX) / (Comps * SumXX - SumX * SumX);
  Result := Round(a0 + a1 * High(Data));
end;

//------------------------------------------------------------------------------

procedure TJoystick.DoXYMove(Buttons: Word; XPos, YPos: Integer);

var
  JoyButtons: TJoystickButtons;
  I: Integer;
  dX, dY: Integer;

begin
  XPos := DoScale(XPos);
  YPos := DoScale(YPos);
  if (FLastX = -1) or (FLastY = -1) then
  begin
    FLastX := XPos;
    FLastY := YPos;
    for I := 0 to 4 do
    begin
      FXPosInfo[I] := XPos;
      FYPosInfo[I] := YPos;
    end;
  end
  else
  begin
    Move(FXPosInfo[1], FXPosInfo[0], 16);
    FXPosInfo[4] := XPos;
    XPos := Approximation(FXPosInfo);
    Move(FYPosInfo[1], FYPosInfo[0], 16);
    FYPosInfo[4] := YPos;
    YPos := Approximation(FYPosInfo);
    JoyButtons := MakeJoyButtons(Buttons);
    dX := Round((XPos-FMinMaxInfo[jaX, jpCenter]) * 100 / FMinMaxInfo[jaX, jpCenter]);
    dY := Round((YPos-FMinMaxInfo[jaY, jpCenter]) * 100 / FMinMaxInfo[jaY, jpCenter]);
    if Assigned(FOnJoystickMove) then
         FOnJoystickMove(Self, FJoystickID, JoyButtons, dX, dY);
    FLastX := XPos;
    FLastY := YPos;
  end;
end;

//------------------------------------------------------------------------------

procedure TJoystick.DoZMove(Buttons: Word; ZPos: Integer);
begin
   if FLastZ = -1 then
      FLastZ := Round(ZPos * 100 / 65536);
end;

// WndProc
//
procedure TJoystick.WndProc(var Msg: TMessage);
begin
   case Msg.Msg of
      MM_JOY1MOVE, MM_JOY2MOVE:
         DoXYMove(Msg.wParam, Msg.lParamLo, Msg.lParamHi);
      MM_JOY1ZMOVE, MM_JOY2ZMOVE:
         DoZMove(Msg.wParam, Msg.lParamLo);
   end;
end;

end.
