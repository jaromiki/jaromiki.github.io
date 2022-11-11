object Form1: TForm1
  Left = 187
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Form1'
  ClientHeight = 191
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 5
    Top = 5
    Width = 270
    Height = 181
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Camera = GLCamera1
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
  end
  object GLScene1: TGLScene
    object DummyCube1: TDummyCube
      Position.Coordinates = {000000000000803F000000000000803F}
      CubeSize = 1
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {000048420000C842000048420000803F}
      SpotCutOff = 180
      SpotDirection.Coordinates = {0000000000000000000080BF00000000}
    end
    object Sphere: TSphere
      Position.Coordinates = {00000040000080BE000000000000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      Radius = 1
    end
    object Cylinder: TCylinder
      Position.Coordinates = {000000C0000080BE000000000000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      BottomRadius = 1
      Height = 1.5
      TopRadius = 1
    end
    object Torus: TTorus
      Direction.Coordinates = {F604B5BEF304353F70C41C3F00000000}
      PitchAngle = 45
      Position.Coordinates = {000000C0CDCC0C40000000000000803F}
      TurnAngle = -30
      Up.Coordinates = {F604B53EF304353F70C41CBF00000000}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      MajorRadius = 0.699999988079071
      MinorRadius = 0.200000002980232
    end
    object Cone: TCone
      Direction.Coordinates = {00000000F28384BEEA46773F00000000}
      PitchAngle = -15
      Position.Coordinates = {0000004000002040000000000000803F}
      Up.Coordinates = {00000000EA46773FF283843E00000000}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      BottomRadius = 1
      Height = 1.5
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      TargetObject = DummyCube1
      Position.Coordinates = {0000000000008040000020410000803F}
    end
  end
end
