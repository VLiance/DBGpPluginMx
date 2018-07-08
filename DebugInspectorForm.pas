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

unit DebugInspectorForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StrUtils, NppDockingForm;

type
  TDebugInspectorForm1 = class(TNppDockingForm)
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
    data: String;
  public
    { Public declarations }
    procedure SetData(x: String);
  end;

var
  DebugInspectorForm1: TDebugInspectorForm1;

implementation

{$R *.dfm}

procedure TDebugInspectorForm1.CheckBox1Click(Sender: TObject);
begin
  self.SetData(self.data);
end;

procedure TDebugInspectorForm1.SetData(x: String);
begin
  self.data := x;
  self.Memo1.Lines.Clear;

  if (self.CheckBox1.Checked) then
  begin
    self.Memo1.Lines.Add('Not implemented...');
  end
  else
  begin
    // convert newlines?
    //self.Memo1.Text := self.data;
    self.Memo1.Text := AnsiReplaceStr(self.data, #10, #13+#10);
  end;
end;

end.
