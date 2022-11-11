unit ctvertex_f;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OpenGL, ExtCtrls;

const Velikost = 256;

type
  TForm1 = class(TForm)
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; DX,
      DY: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    
    hRC : HGLRC;
    Model : integer;
    buffer : array[1..Velikost,1..Velikost] of record
                                             blue : byte;
                                             green : byte;
                                             red : byte
                                           end;
    procedure Ctverec;
    procedure SetDCPixelFormat(DC : HDC);
    procedure NastaveniProstoru;
    procedure VlastnostiObjektu;
    procedure LoadBitmap(Path : string);
    procedure VymazatPlochu(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
    X,Y,Z: real;
    UhelX,UhelY,UhelZ: integer;
    bool, stisknuto: boolean;
    oldx, oldy: integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


const PFDError = 'Chyba pøi nastavení PFD.';


procedure TForm1.FormCreate(Sender: TObject);
begin
  UhelX := 0;
  UhelY := 0;
  UhelZ := 0;
  X := 0.0; Y := 0; Z := -4.0;
  SetcursorPos(left+round(width/2),top+70);
  bool:=true;
  Model := 1;

  //inicializace OpenGL
  SetDCPixelFormat(Canvas.Handle);
  hRC := wglCreateContext(Canvas.Handle);
  wglMakeCurrent(Canvas.Handle,hRC);
  glClearColor(0.0,0.0,0.0,0.0);
  glShadeModel(GL_FLAT);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_Texture_2D);
  glPixelStorei(GL_Unpack_Alignment,2);
  glTexParameterf(GL_Texture_2D,GL_Texture_Wrap_S,GL_Repeat);
  glTexParameterf(GL_Texture_2D,GL_Texture_Wrap_T,GL_Repeat);
  glTexParameterf(GL_Texture_2D,GL_Texture_Mag_Filter,GL_Linear);
  glTexParameterf(GL_Texture_2D,GL_Texture_Min_Filter,GL_Linear);
  glTexEnvf(GL_Texture_Env, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  Ctverec;
  NastaveniProstoru;
  wglMakeCurrent(0,0)
end;



procedure TForm1.SetDCPixelFormat(DC : HDC);
var PFD : TPixelFormatDescriptor;
    nPixelFormat : integer;
begin
  FillChar(PFD,SizeOf(PFD),0);
  with PFD do
    begin
       nSize := SizeOf(TPixelFormatDescriptor);
       nVersion := 1;
       dwFlags := PFD_DRAW_TO_WINDOW or
                  PFD_SUPPORT_OPENGL or
                  PFD_DOUBLEBUFFER;
       iPixelType := PFD_TYPE_RGBA;
       cColorBits := 24;
       cDepthBits   := 32;
       iLayerType   := PFD_MAIN_PLANE;
    end;
  nPixelFormat := ChoosePixelFormat(DC,@PFD);
  Assert(nPixelFormat <> 0,PFDError);
  SetPixelFormat(DC,nPixelFormat,@PFD)
end;


procedure TForm1.Ctverec;
var Cesta : string;
begin
  Cesta := ExtractFilePath(Application.ExeName);

  glNewList(Model,GL_COMPILE_AND_EXECUTE);
  LoadBitmap(Cesta + 'Image1.bmp');
  glTexImage2d(GL_Texture_2D,0,3,Velikost,Velikost,0,GL_RGB,GL_Unsigned_byte,@buffer);
  glBegin(GL_POLYGON);
    glTexCoord2f(0,0);
    glVertex3f( 0.5,-0.5,0.0);
    glTexCoord2f(1,0);
    glVertex3f(-0.5,-0.5,0.0);
    glTexCoord2f(1,1);
    glVertex3f(-0.5, 0.5,0.0);
    glTexCoord2f(0,1);
    glVertex3f( 0.5, 0.5,0.0);
  glEnd;
  glEndList
end;



procedure TForm1.NastaveniProstoru;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(30.0,ClientWidth / ClientHeight,0.01,50.0);
  glViewport(0,0,ClientWidth,ClientHeight);
end;



procedure TForm1.VlastnostiObjektu;
begin
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glTranslatef(X,Y,Z);				//pozice kamery
  glTranslatef(0,0,0);				//støed rotace objektu
  glRotatef(UhelX, 1, 0, 0);			//rotace objektu v ose X
  glRotatef(UhelY, 0, 1, 0);			//rotace objektu v ose Y
  glRotatef(UhelZ, 0, 0, 1);			//rotace objektu v ose Z
end;




procedure TForm1.LoadBitmap(Path : string);
//  naète bitmapu o velikosti 256 x 256 pixelu ze souboru
//  prohodi èervenou a modrou složku
//  bitmapu jiné velikosti je nutno upravit tak, aby
//  jeji šíøka a výška byla mocninou dvou
var
 X : TImage;
 bih : TBitmapInfoHeader;
 bi : TBitmapInfo;
 b : byte;
 i,j : word;
begin
  X := TImage.Create(Self);
  X.Picture.LoadFromFile(Path);
  with bih do
    begin
      biSize := SizeOf(bih);
      biWidth := Velikost;
      biHeight := Velikost;
      biPlanes := 1;
      biBitCount := 24;
      biCompression := BI_RGB;
      biSizeImage := Velikost;
      biXPelsPerMeter := 0;
      biYPelsPerMeter := 0;
      biClrImportant := 0;
      biClrUsed := 0;
    end;
  bi.bmiHeader := bih;
  GetDIBits(X.Picture.Bitmap.Canvas.Handle,X.Picture.Bitmap.Handle,
            0,Velikost,@buffer,bi,dib_rgb_colors);
  for i := 1 to Velikost do
    for j := 1 to Velikost do
      begin
        b := buffer[i,j].red;
        buffer[i,j].red := buffer[i,j].blue;
        buffer[i,j].blue := b;
      end;
  X.Free
end;





procedure TForm1.VymazatPlochu(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1
end;



procedure TForm1.FormDestroy(Sender: TObject);
begin
  wglDeleteContext(hRC)
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle,hRC);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  VlastnostiObjektu;
  glCallList(Model);
  glFlush;
  SwapBuffers(Canvas.Handle);
  wglMakeCurrent(0,0)
end;

procedure TForm1.TimerTimer(Sender: TObject);
begin
  Repaint
end;



procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; DX,
  DY: Integer);
begin
if bool then begin oldx:=dx;oldy:=dy;bool:=false;end;

if not stisknuto then begin
x:=x+((oldx-dx)/100);
z:=z+((oldy-dy)/10);
end;

if stisknuto then uhely:=uhely+round((oldx-dx));
if stisknuto then uhelx:=uhelx+round((oldy-dy));

oldx:=dx;oldy:=dy;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
stisknuto:=true;
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
stisknuto:=false;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  wglMakeCurrent(Canvas.Handle,hRC);
  NastaveniProstoru;

  wglMakeCurrent(0,0);
  SetcursorPos(left+round(width/2),top+70);
  bool:=true;
end;

end.
