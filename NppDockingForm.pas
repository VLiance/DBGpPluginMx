{
    This file is part of DBGP Plugin for Notepad++
    Copyright (C) 2007  Damjan Zobo Cvetko

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit NppDockingForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, NppPlugin, Dialogs, Controls, NppForms;

type
  TNppDockingForm = class(TNppForm) {TCustomForm}
  private
    { Private declarations }
  protected
    { Protected declarations }
    // @todo: change caption and stuff....
    procedure OnWM_NOTIFY(var msg: TWMNotify); message WM_NOTIFY;
  public
    { Public declarations }
    DlgId: Integer;
    procedure Show;
    procedure Hide;
  published
    { Published declarations }
  end;

implementation

{ TNppDockingForm }

procedure TNppDockingForm.OnWM_NOTIFY(var msg: TWMNotify);
begin
  // not good.. bols ce bi vse spremenil v TComponent in uporablal Parenta..
  if (self.Npp.NppData.NppHandle <> msg.NMHdr.hwndFrom) then
  begin
    inherited;
    exit;
  end;
  msg.Result := 0;

  if (msg.NMHdr.code = DMN_CLOSE) then
  begin
    //MessageBeep(0);
    //ShowMessage('Close');
    //self.DoClose();
    //self.Close;
  end;

 //#define DMN_FIRST 1050
 //#define DMN_CLOSE (DMN_FIRST + 1)

 // undock 263197  =  x shl 16 + 1053
 // dock r 66588               + 1052
 // dock d 197660
 // close 1501

 inherited;
end;

procedure TNppDockingForm.Show;
begin
  SendMessage(self.Npp.NppData.NppHandle, NPPM_DMMSHOW, 0, LPARAM(self.Handle));
  inherited;
end;

procedure TNppDockingForm.Hide;
begin
  SendMessage(self.Npp.NppData.NppHandle, NPPM_DMMHIDE, 0, LPARAM(self.Handle));
  inherited;
end;

end.
