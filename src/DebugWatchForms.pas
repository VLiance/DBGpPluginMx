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

unit DebugWatchForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DebugVarForms, JvComponentBase, JvDockControlForm, VirtualTrees, DbgpWinSocket,
  Menus, DebugEditWatchForms;

type
  TChangeCB = procedure(Sender: TObject; Watches: TPropertyItems) of Object;
  TDebugWatchFrom = class(TDebugVarForm)
    AddWatch1: TMenuItem;
    DeleteWatch1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure AddWatch1Click(Sender: TObject);
    procedure DeleteWatch1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    { Private declarations }
    watches: TPropertyItems;
    FOnChange: TChangeCB;
  public
    { Public declarations }
    property OnChange: TChangeCB read FOnChange write FOnChange;
    procedure DoChange;
  end;

var
  DebugWatchFrom: TDebugWatchFrom;

implementation

{$R *.dfm}

procedure TDebugWatchFrom.FormCreate(Sender: TObject);
begin
  inherited;
  SetLength(self.watches, 0);
end;

procedure TDebugWatchFrom.AddWatch1Click(Sender: TObject);
var
  ewf: TDebugEditWatchForm;
  r: integer;
begin
  ewf := TDebugEditWatchForm.Create(self);
  r := ewf.ShowModal;
  if (r = mrOk) and (Length(ewf.Expression.Text)>0) then
  begin
    SetLength(self.watches, Length(self.watches)+1);
    self.watches[Length(self.watches)-1].fullname := ewf.Expression.Text;
  end;
  ewf.Free;
  self.DoChange;
end;

procedure TDebugWatchFrom.DeleteWatch1Click(Sender: TObject);
var
  i: integer;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  for i:=self.VirtualStringTree1.FocusedNode^.Index to Length(self.watches)-2 do
  begin
    self.watches[i] := self.watches[i+1];
  end;
  SetLength(self.watches, Length(self.watches)-1);
  self.DoChange;
end;

procedure TDebugWatchFrom.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  self.DeleteWatch1.Enabled := false;
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  if (self.VirtualStringTree1.FocusedNode^.Parent = self.VirtualStringTree1.RootNode) then self.DeleteWatch1.Enabled := true;
end;

procedure TDebugWatchFrom.DoChange;
begin
  if (Assigned(FOnChange)) then self.FOnChange(self, self.watches);
end;

end.
