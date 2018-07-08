object AboutForm1: TAboutForm1
  Left = 391
  Top = 326
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 1
  Caption = 'About'
  ClientHeight = 328
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 8
    Top = 8
    Width = 240
    Height = 13
    Caption = 'DBGP Plugin v%d.%d.%d.%d for Notepad++  v4.1+'
  end
  object Label8: TLabel
    Left = 8
    Top = 32
    Width = 34
    Height = 13
    Caption = 'Author:'
  end
  object Label9: TLabel
    Left = 8
    Top = 48
    Width = 22
    Height = 13
    Caption = 'Mail:'
  end
  object Label18: TLabel
    Left = 63
    Top = 32
    Width = 101
    Height = 13
    Caption = 'Damjan Zobo Cvetko'
  end
  object Label19: TLabel
    Left = 64
    Top = 48
    Width = 88
    Height = 13
    Caption = 'zobo@users.sf.net'
  end
  object Label20: TLabel
    Left = 8
    Top = 72
    Width = 222
    Height = 13
    Caption = 'Thanks go out to Don for this editor and all that'
  end
  object Label21: TLabel
    Left = 8
    Top = 88
    Width = 140
    Height = 13
    Caption = 'helped in one way or another.'
  end
  object Label22: TLabel
    Left = 8
    Top = 280
    Width = 213
    Height = 13
    Caption = 'Read the README file for more information...'
  end
  object Button1: TButton
    Left = 88
    Top = 296
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 112
    Width = 233
    Height = 161
    Caption = 'Menu entries'
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 24
      Width = 47
      Height = 13
      Caption = 'Debugger'
    end
    object Label2: TLabel
      Left = 8
      Top = 40
      Width = 43
      Height = 13
      Caption = 'Step Into'
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 48
      Height = 13
      Caption = 'Step Over'
    end
    object Label4: TLabel
      Left = 8
      Top = 72
      Width = 42
      Height = 13
      Caption = 'Step Out'
    end
    object Label5: TLabel
      Left = 8
      Top = 88
      Width = 20
      Height = 13
      Caption = 'Run'
    end
    object Label6: TLabel
      Left = 8
      Top = 120
      Width = 39
      Height = 13
      Caption = 'Config...'
    end
    object Label10: TLabel
      Left = 80
      Top = 24
      Width = 93
      Height = 13
      Caption = 'Starts the debugger'
    end
    object Label11: TLabel
      Left = 80
      Top = 40
      Width = 119
      Height = 13
      Caption = 'Steps into next statement'
    end
    object Label12: TLabel
      Left = 80
      Top = 56
      Width = 123
      Height = 13
      Caption = 'Steps over next statement'
    end
    object Label13: TLabel
      Left = 80
      Top = 72
      Width = 125
      Height = 13
      Caption = 'Steps out of current scope'
    end
    object Label14: TLabel
      Left = 80
      Top = 88
      Width = 140
      Height = 13
      Caption = 'Continue until next breakpoint'
    end
    object Label15: TLabel
      Left = 80
      Top = 120
      Width = 121
      Height = 13
      Caption = 'Open configuration dialog'
    end
    object Label16: TLabel
      Left = 8
      Top = 136
      Width = 37
      Height = 13
      Caption = 'About...'
    end
    object Label17: TLabel
      Left = 80
      Top = 136
      Width = 77
      Height = 13
      Caption = 'Show this dialog'
    end
    object Label23: TLabel
      Left = 8
      Top = 104
      Width = 51
      Height = 13
      Caption = 'Breakpoint'
    end
    object Label24: TLabel
      Left = 80
      Top = 104
      Width = 86
      Height = 13
      Caption = 'Toggle breakpoint'
    end
  end
end
