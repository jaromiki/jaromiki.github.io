object Form1: TForm1
  Left = 238
  Top = 103
  Width = 352
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
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 334
    Height = 209
    FogEnvironment.FogStart = 10
    FogEnvironment.FogEnd = 1000
    FogEnvironment.FogMode = fmLinear
    Align = alClient
    BackgroundColor = clBlack
    Camera = GLCamera1
    DepthTest = False
    Monitor = True
    AfterRender = GLSceneViewer1AfterRender
  end
  object GLScene1: TGLScene
    ObjectsSorting = osRenderFarthestFirst
    Left = 8
    Top = 24
    object DummyCube1: TDummyCube
      ObjectsSorting = osNone
      CubeSize = 1
      object Sprite2: TSprite
        Position.Coordinates = {0000A04000000000000000000000803F}
        Material.MaterialLibrary = GLMaterialLibrary1
        Material.LibMaterialName = 'BlueBall'
        Width = 2
        Height = 2
      end
    end
    object Sprite1: TSprite
      Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
      Material.FrontProperties.Diffuse.Color = {0000000000000000000000000000803F}
      Material.FrontProperties.Emission.Color = {0000803F0000803F000000000000803F}
      Material.BlendingMode = bmAdditive
      Material.Texture.ImageClassName = 'TGLPicFileImage'
      Material.Texture.Image.PictureFileName = 'Flare1.bmp'
      Material.Texture.MagFilter = maLinear
      Material.Texture.MinFilter = miLinear
      Material.Texture.TextureMode = tmModulate
      Material.Texture.Disabled = False
      Width = 4
      Height = 4
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      TargetObject = DummyCube1
      Position.Coordinates = {000020410000A040000020410000803F}
    end
  end
  object GLMaterialLibrary1: TGLMaterialLibrary
    Materials = <
      item
        Name = 'BlueBall'
        Material.FrontProperties.Ambient.Color = {0000000000000000000000000000803F}
        Material.FrontProperties.Diffuse.Color = {0000000000000000000000000000803F}
        Material.FrontProperties.Emission.Color = {F3F2F23EF3F2F23E0000803F0000803F}
        Material.BlendingMode = bmAdditive
        Material.Texture.ImageClassName = 'TGLPersistentImage'
        Material.Texture.MagFilter = maLinear
        Material.Texture.MinFilter = miLinear
        Material.Texture.TextureMode = tmModulate
        Material.Texture.Disabled = False
      end>
    Left = 8
    Top = 64
  end
  object Timer1: TTimer
    Interval = 4000
    OnTimer = Timer1Timer
    Left = 8
    Top = 104
  end
end
