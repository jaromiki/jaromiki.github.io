object Form1: TForm1
  Left = 188
  Top = 101
  Width = 457
  Height = 343
  Caption = 'Form1'
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 320
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 8
    Top = 8
    Width = 433
    Height = 273
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Anchors = [akLeft, akTop, akRight, akBottom]
    BackgroundColor = clGray
    Camera = GLCamera1
    Monitor = True
  end
  object TrackBar: TTrackBar
    Left = 56
    Top = 288
    Width = 385
    Height = 25
    Anchors = [akLeft, akRight, akBottom]
    Max = 360
    Orientation = trHorizontal
    PageSize = 10
    Frequency = 10
    Position = 0
    SelEnd = 0
    SelStart = 0
    TabOrder = 1
    ThumbLength = 15
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = TrackBarChange
  end
  object CBPlay: TCheckBox
    Left = 8
    Top = 292
    Width = 41
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Play'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object StaticText1: TStaticText
    Left = 16
    Top = 16
    Width = 45
    Height = 17
    BorderStyle = sbsSingle
    Caption = '??? FPS'
    TabOrder = 3
  end
  object GLScene1: TGLScene
    Left = 16
    Top = 48
    object Cube1: TCube
      Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
      Material.FrontProperties.Diffuse.Color = {0000000000000000000000000000803F}
      Material.FrontProperties.Emission.Color = {0000803F0000803F000000000000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
    end
    object Cube2: TCube
      Position.Coordinates = {0000404000000000000000000000803F}
      Material.FrontProperties.Diffuse.Color = {8786063F8786063F0000803F0000803F}
      Material.FrontProperties.Emission.Color = {0000000000000000A1A0203F0000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      CubeSize = {0000003F0000003F0000003F}
    end
    object Cube3: TCube
      Position.Coordinates = {000040400000803F000000000000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      CubeSize = {CDCC4C3ECDCC4C3ECDCC4C3E}
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      SpotCutOff = 180
      SpotDirection.Coordinates = {0000000000000000000080BF00000000}
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 100
      TargetObject = Cube1
      Position.Coordinates = {000020410000A040000020410000803F}
    end
  end
  object Timer1: TAsyncTimer
    Enabled = True
    Interval = 1
    OnTimer = Timer1Timer
    Left = 16
    Top = 88
  end
end
