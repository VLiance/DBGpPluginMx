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

unit DebugEvalForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, NppDockingForm;

type
  TDebugEvalForm1 = class(TNppDockingForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    CheckBoxReuseResult: TCheckBox;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DebugEvalForm1: TDebugEvalForm1;

implementation

{$R *.dfm}

procedure TDebugEvalForm1.Button1Click(Sender: TObject);
begin
  self.ComboBox1.Items.Add(self.ComboBox1.Text);
end;

end.
