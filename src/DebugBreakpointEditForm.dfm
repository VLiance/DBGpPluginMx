object DebugBreakpointEditForm1: TDebugBreakpointEditForm1
  Left = 192
  Top = 110
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Breakpoint'
  ClientHeight = 409
  ClientWidth = 248
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 40
    Width = 27
    Height = 13
    Caption = 'Type:'
  end
  object Label2: TLabel
    Left = 30
    Top = 104
    Width = 45
    Height = 13
    Caption = 'Filename:'
  end
  object Label3: TLabel
    Left = 14
    Top = 136
    Width = 61
    Height = 13
    Caption = 'Line number:'
  end
  object Label4: TLabel
    Left = 48
    Top = 72
    Width = 28
    Height = 13
    Caption = 'State:'
  end
  object Label5: TLabel
    Left = 31
    Top = 168
    Width = 44
    Height = 13
    Caption = 'Function:'
  end
  object Label6: TLabel
    Left = 22
    Top = 228
    Width = 53
    Height = 13
    Caption = 'Temporary:'
  end
  object Label7: TLabel
    Left = 25
    Top = 256
    Width = 50
    Height = 13
    Caption = 'Exception:'
  end
  object Label8: TLabel
    Left = 30
    Top = 288
    Width = 45
    Height = 13
    Caption = 'Hit value:'
  end
  object Label9: TLabel
    Left = 13
    Top = 320
    Width = 62
    Height = 13
    Caption = 'Hit condition:'
  end
  object Label10: TLabel
    Left = 56
    Top = 8
    Width = 14
    Height = 13
    Caption = 'ID:'
  end
  object Label11: TLabel
    Left = 88
    Top = 8
    Width = 20
    Height = 13
    Caption = 'N/A'
  end
  object Label12: TLabel
    Left = 47
    Top = 200
    Width = 28
    Height = 13
    Caption = 'Class:'
  end
  object Label13: TLabel
    Left = 21
    Top = 352
    Width = 54
    Height = 13
    Caption = 'Expression:'
  end
  object ComboBox1: TComboBox
    Left = 88
    Top = 32
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboBox1Change
    Items.Strings = (
      'line'
      'call'
      'return'
      'exception')
  end
  object ComboBox2: TComboBox
    Left = 88
    Top = 64
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Enabled'
    Items.Strings = (
      'Enabled'
      'Disabled')
  end
  object Edit1: TEdit
    Left = 88
    Top = 96
    Width = 145
    Height = 21
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 88
    Top = 128
    Width = 145
    Height = 21
    TabOrder = 3
  end
  object Edit3: TEdit
    Left = 88
    Top = 160
    Width = 145
    Height = 21
    TabOrder = 4
  end
  object CheckBox1: TCheckBox
    Left = 88
    Top = 224
    Width = 25
    Height = 17
    TabOrder = 5
  end
  object Edit4: TEdit
    Left = 88
    Top = 248
    Width = 145
    Height = 21
    TabOrder = 6
  end
  object Edit5: TEdit
    Left = 88
    Top = 280
    Width = 145
    Height = 21
    TabOrder = 7
  end
  object ComboBox3: TComboBox
    Left = 88
    Top = 312
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 8
    Text = '>='
    Items.Strings = (
      '>='
      '=='
      '%')
  end
  object Button1: TButton
    Left = 88
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Ok'
    Enabled = False
    ModalResult = 1
    TabOrder = 9
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 168
    Top = 376
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object Edit6: TEdit
    Left = 88
    Top = 192
    Width = 145
    Height = 21
    TabOrder = 11
  end
  object Edit7: TEdit
    Left = 88
    Top = 344
    Width = 145
    Height = 21
    TabOrder = 12
  end
end
