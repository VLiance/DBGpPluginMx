object ConfigForm1: TConfigForm1
  Left = 253
  Top = 132
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'DBGp configuration'
  ClientHeight = 454
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 497
    Height = 241
    Caption = 'File Mapping'
    TabOrder = 0
    object Button1: TButton
      Left = 16
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Add'
      TabOrder = 0
      OnClick = Button1Click
    end
    object DeleteButton: TButton
      Left = 104
      Top = 208
      Width = 75
      Height = 25
      Caption = 'Delete'
      TabOrder = 1
      OnClick = DeleteButtonClick
    end
    object StringGrid1: TStringGrid
      Left = 16
      Top = 40
      Width = 465
      Height = 161
      ColCount = 4
      DefaultColWidth = 110
      DefaultRowHeight = 20
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
      TabOrder = 2
    end
    object CheckBox6: TCheckBox
      Left = 16
      Top = 16
      Width = 225
      Height = 17
      Caption = 'Bypass all mapping (local windows setup)'
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 240
    Width = 497
    Height = 177
    Caption = 'Misc'
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 100
      Width = 134
      Height = 13
      Caption = 'Maximum depth of elements:'
    end
    object Label2: TLabel
      Left = 16
      Top = 124
      Width = 117
      Height = 13
      Caption = 'Maximum child elements:'
    end
    object Label3: TLabel
      Left = 16
      Top = 148
      Width = 111
      Height = 13
      Caption = 'Maximum variable data:'
    end
    object CheckBox1: TCheckBox
      Left = 16
      Top = 16
      Width = 305
      Height = 17
      Caption = 'Refresh local context on every step'
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 16
      Top = 32
      Width = 305
      Height = 17
      Caption = 'Refresh global context on every step'
      TabOrder = 1
    end
    object CheckBox3: TCheckBox
      Left = 16
      Top = 48
      Width = 305
      Height = 17
      Caption = 'Use SOURCE command for all files and bypass maps'
      TabOrder = 2
    end
    object CheckBox4: TCheckBox
      Left = 16
      Top = 64
      Width = 305
      Height = 17
      Caption = 'Start with closed socket (firewall conflicts work arround)'
      TabOrder = 3
    end
    object SpinEdit1: TSpinEdit
      Left = 160
      Top = 96
      Width = 57
      Height = 22
      MaxValue = 1000
      MinValue = 0
      TabOrder = 4
      Value = 0
    end
    object SpinEdit2: TSpinEdit
      Left = 160
      Top = 120
      Width = 57
      Height = 22
      MaxValue = 1000
      MinValue = 0
      TabOrder = 5
      Value = 0
    end
    object CheckBox5: TCheckBox
      Left = 16
      Top = 80
      Width = 209
      Height = 17
      Caption = 'Break at fist line when debugging starts'
      TabOrder = 6
    end
    object SpinEdit3: TSpinEdit
      Left = 160
      Top = 144
      Width = 57
      Height = 22
      MaxValue = 1000000
      MinValue = 0
      TabOrder = 7
      Value = 0
    end
  end
  object Button3: TButton
    Left = 16
    Top = 424
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 2
    OnClick = Button3Click
  end
end
