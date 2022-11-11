object Form1: TForm1
  Left = 192
  Top = 120
  Width = 696
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 112
    Top = 24
    Width = 412
    Height = 265
    ColCount = 4
    DefaultColWidth = 100
    RowCount = 2
    GridLineWidth = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColMoving, goEditing]
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyPress = pis
    OnMouseUp = triedim
  end
  object MainMenu1: TMainMenu
    Left = 40
    Top = 416
    object File1: TMenuItem
      Caption = 'File'
      object Load1: TMenuItem
        Caption = 'Load'
        ShortCut = 114
        OnClick = Load1Click
      end
      object Save1: TMenuItem
        Caption = 'Save'
        ShortCut = 113
        OnClick = Save1Click
      end
      object Saveas1: TMenuItem
        Caption = 'Saveas'
        ShortCut = 16467
        OnClick = Saveas1Click
      end
    end
    object Edit1: TMenuItem
      Caption = 'Edit'
      object Delete1: TMenuItem
        Caption = 'Delete'
        ShortCut = 16469
        OnClick = Delete1Click
      end
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      ShortCut = 16472
      OnClick = Exit1Click
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'data|*.dat'
    Left = 624
    Top = 16
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'dat'
    Filter = 'data|*.dat'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofEnableSizing]
    Left = 624
    Top = 56
  end
end
