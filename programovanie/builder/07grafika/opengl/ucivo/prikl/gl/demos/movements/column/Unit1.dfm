object Form1: TForm1
  Left = 157
  Top = 110
  Width = 219
  Height = 369
  BorderWidth = 5
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 201
    Height = 315
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Align = alClient
    BackgroundColor = clBlack
    Camera = GLCamera1
    Monitor = True
    AfterRender = GLSceneViewer1AfterRender
  end
  object StaticText1: TStaticText
    Left = 0
    Top = 315
    Width = 201
    Height = 17
    Align = alBottom
    Alignment = taCenter
    AutoSize = False
    BorderStyle = sbsSingle
    Caption = '???.? FPS'
    TabOrder = 1
  end
  object GLScene1: TGLScene
    Left = 16
    Top = 24
    object DummyCube1: TDummyCube
      CubeSize = 1
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 100
      TargetObject = DummyCube1
      Position.Coordinates = {0000A04100002041000020410000803F}
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 64
  end
end
