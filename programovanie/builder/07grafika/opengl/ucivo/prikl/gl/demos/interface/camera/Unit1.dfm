object Form1: TForm1
  Left = 208
  Top = 107
  Width = 377
  Height = 308
  BorderWidth = 6
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnKeyPress = FormKeyPress
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 357
    Height = 269
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Align = alClient
    BackgroundColor = clBlack
    Camera = GLCamera1
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
  end
  object GLScene1: TGLScene
    Left = 8
    Top = 8
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {0000204100002041000020410000803F}
      SpotCutOff = 180
      SpotDirection.Coordinates = {0000000000000000000080BF00000000}
    end
    object Teapot1: TTeapot
      Direction.Coordinates = {0000803F000000000000000000000000}
      Scale.Coordinates = {00000040000000400000004000000000}
      Up.Coordinates = {00000080000000000000803F00000000}
      Material.FrontProperties.Diffuse.Color = {9493133F0000803F9291113F0000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
    end
    object DummyCube1: TDummyCube
      CubeSize = 1
      VisibleAtRunTime = True
      object GLCamera1: TGLCamera
        DepthOfView = 1000
        FocalLength = 400
        TargetObject = DummyCube1
        Position.Coordinates = {00009041000080410000C0400000803F}
        Direction.Coordinates = {2EF964BF2EF9E43E0000000000000000}
        Up.Coordinates = {00000000000000000000803F00000000}
      end
    end
  end
end
