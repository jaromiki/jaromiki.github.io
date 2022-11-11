object RColorEditor: TRColorEditor
  Left = 0
  Top = 0
  Width = 289
  Height = 93
  AutoSize = True
  TabOrder = 0
  object Label1: TLabel
    Left = 0
    Top = 2
    Width = 31
    Height = 19
    Caption = 'Red'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 0
    Top = 26
    Width = 46
    Height = 19
    Caption = 'Green'
    Font.Charset = ANSI_CHARSET
    Font.Color = clLime
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 0
    Top = 50
    Width = 35
    Height = 19
    Caption = 'Blue'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 0
    Top = 74
    Width = 44
    Height = 19
    Caption = 'Alpha'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  inline TBERed: TRTrackBarEdit
    Left = 48
    Width = 201
    Height = 21
    inherited TrackBar: TTrackBar
      OnChange = TBERedTrackBarChange
    end
    inherited Edit: TEdit
      Left = 160
      Hint = 'Intensity (0-255)'
    end
  end
  inline TBEGreen: TRTrackBarEdit
    Left = 48
    Top = 24
    Width = 201
    Height = 21
    TabOrder = 1
    inherited TrackBar: TTrackBar
      OnChange = TBEGreenTrackBarChange
    end
    inherited Edit: TEdit
      Left = 160
      Hint = 'Intensity (0-255)'
    end
  end
  inline TBEBlue: TRTrackBarEdit
    Left = 48
    Top = 48
    Width = 201
    Height = 21
    TabOrder = 2
    inherited TrackBar: TTrackBar
      OnChange = TBEBlueTrackBarChange
    end
    inherited Edit: TEdit
      Left = 160
      Hint = 'Intensity (0-255)'
    end
  end
  inline TBEAlpha: TRTrackBarEdit
    Left = 48
    Top = 72
    Width = 201
    Height = 21
    TabOrder = 3
    inherited TrackBar: TTrackBar
      Max = 1000
      Frequency = 100
      OnChange = TBEAlphaTrackBarChange
    end
    inherited Edit: TEdit
      Left = 160
      Hint = 'Intensity (0-1000)'
    end
  end
  object PAPreview: TPanel
    Left = 256
    Top = 0
    Width = 33
    Height = 73
    Hint = 'Double-click to select with Windows color picker'
    BevelInner = bvRaised
    BevelOuter = bvLowered
    BorderWidth = 1
    Color = clLime
    TabOrder = 4
    OnDblClick = PAPreviewDblClick
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Left = 152
    Top = 24
  end
end
