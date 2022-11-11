object Form1: TForm1
  Left = 192
  Top = 107
  Width = 344
  Height = 302
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
    Width = 336
    Height = 275
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Align = alClient
    BackgroundColor = clBlack
    Camera = GLCamera1
    Monitor = True
    AfterRender = GLSceneViewer1AfterRender
  end
  object GLScene1: TGLScene
    Left = 8
    Top = 8
    object DummyCube1: TDummyCube
      CubeSize = 10
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {0000C842000048420000C8420000803F}
      SpotCutOff = 180
      SpotDirection.Coordinates = {0000000000000000000080BF00000000}
    end
    object GLCamera1: TGLCamera
      DepthOfView = 500
      FocalLength = 50
      TargetObject = DummyCube1
      Position.Coordinates = {000048420000C8410000C8420000803F}
    end
  end
  object Timer1: TTimer
    Interval = 4000
    OnTimer = Timer1Timer
    Left = 8
    Top = 40
  end
end
