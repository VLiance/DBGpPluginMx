inherited DebugWatchFrom: TDebugWatchFrom
  Caption = 'Watches'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited PopupMenu1: TPopupMenu
    object AddWatch1: TMenuItem [0]
      Caption = 'Add watch'
      OnClick = AddWatch1Click
    end
    object DeleteWatch1: TMenuItem [1]
      Caption = 'Delete Watch'
      OnClick = DeleteWatch1Click
    end
  end
end
