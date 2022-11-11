object Form1: TForm1
  Left = 193
  Top = 111
  Width = 500
  Height = 246
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
    Width = 482
    Height = 209
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Align = alClient
    BackgroundColor = clBlack
    Camera = GLCamera1
    Monitor = True
    AfterRender = GLSceneViewer1AfterRender
    OnMouseMove = GLSceneViewer1MouseMove
  end
  object GLScene1: TGLScene
    Left = 8
    Top = 40
    object Plane1: TPlane
      Position.Coordinates = {0000000000000000000000BF0000803F}
      Material.FrontProperties.Diffuse.Color = {000000000000803F000000000000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      Material.MaterialLibrary = GLMaterialLibrary1
      Material.LibMaterialName = 'Mat'
      Height = 10
      Width = 15
      object Cube2: TCube
        Position.Coordinates = {0000F0C0000000000000803E0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
        Material.MaterialLibrary = GLMaterialLibrary1
        Material.LibMaterialName = 'Edge'
        CubeSize = {0000003F000020410000003F}
      end
      object Cube1: TCube
        Position.Coordinates = {000000000000A0400000803E0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
        Material.MaterialLibrary = GLMaterialLibrary1
        Material.LibMaterialName = 'Edge'
        CubeSize = {000078410000003F0000003F}
      end
      object Cube3: TCube
        Position.Coordinates = {0000F040000000000000803E0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
        Material.MaterialLibrary = GLMaterialLibrary1
        Material.LibMaterialName = 'Edge'
        CubeSize = {0000003F000020410000003F}
      end
    end
    object Ball: TSphere
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      Material.MaterialLibrary = GLMaterialLibrary1
      Material.LibMaterialName = 'Ball'
      Radius = 0.400000005960464
    end
    object DummyCube1: TDummyCube
      CubeSize = 1
      object GLCamera1: TGLCamera
        DepthOfView = 100
        FocalLength = 50
        TargetObject = DummyCube1
        Position.Coordinates = {00000000000070C1000020410000803F}
        Direction.Coordinates = {000000000000803F0000000000000000}
        Up.Coordinates = {00000000000000000000803F00000000}
      end
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {00004040000080BF0000A0400000803F}
      Specular.Color = {0000803F0000803F0000803F0000803F}
      SpotCutOff = 180
      SpotDirection.Coordinates = {0000000000000000000080BF00000000}
    end
    object Pad: TCube
      Position.Coordinates = {00000000666696C0000080BE0000803F}
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      Material.MaterialLibrary = GLMaterialLibrary1
      Material.LibMaterialName = 'Pad'
      CubeSize = {000000400000003F0000003F}
    end
    object SpaceText1: TSpaceText
      Direction.Coordinates = {00000000EA4677BFEE83843E00000000}
      PitchAngle = 15
      Position.Coordinates = {0000C0BF00000000000060400000803F}
      Scale.Coordinates = {000000400000803F0000803F00000000}
      Up.Coordinates = {00000000EE83843EEA46773F00000000}
      Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
      Material.FrontProperties.Diffuse.Color = {0000803F0000803F000000000000803F}
      Material.FrontProperties.Emission.Color = {0000000000000000A1A0203F0000803F}
      Material.FrontProperties.Shininess = 75
      Material.Texture.ImageClassName = 'TGLPersistentImage'
      Extrusion = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Text = '000'
      AllowedDeviation = 1
      CharacterRange = stcrNumbers
    end
  end
  object GLMaterialLibrary1: TGLMaterialLibrary
    Materials = <
      item
        Name = 'Mat'
        Material.FrontProperties.Diffuse.Color = {000000000000803F000000000000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
      end
      item
        Name = 'Edge'
        Material.FrontProperties.Diffuse.Color = {0000803FBDBCBC3EF1F0F03D0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
      end
      item
        Name = 'Ball'
        Material.FrontProperties.Shininess = 75
        Material.FrontProperties.Specular.Color = {0000803F0000803F0000803F0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
      end
      item
        Name = 'Pad'
        Material.FrontProperties.Diffuse.Color = {00000000000000000000803F0000803F}
        Material.Texture.ImageClassName = 'TGLPersistentImage'
      end>
    Left = 8
    Top = 72
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
