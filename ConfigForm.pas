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

unit ConfigForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, NppForms, DbgpWinSocket, JvDockTree,
  JvDockControlForm, JvDockVCStyle, JvComponentBase, Spin;

type
  TConfigForm1 = class(TNppForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    DeleteButton: TButton;
    StringGrid1: TStringGrid;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Button3: TButton;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    SpinEdit1: TSpinEdit;
    Label1: TLabel;
    SpinEdit2: TSpinEdit;
    Label2: TLabel;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    Label3: TLabel;
    SpinEdit3: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigForm1: TConfigForm1;

implementation

uses DbgpNppPlugin;
{$R *.dfm}

procedure TConfigForm1.Button1Click(Sender: TObject);
begin
  self.StringGrid1.RowCount := self.StringGrid1.RowCount + 1;
end;

procedure TConfigForm1.DeleteButtonClick(Sender: TObject);
var i: Integer;
begin
  if self.StringGrid1.RowCount = 2 then exit;
  for i := self.StringGrid1.Row to self.StringGrid1.RowCount-2 do
    self.StringGrid1.Rows[i].Assign(self.StringGrid1.Rows[i+1]);
  self.StringGrid1.RowCount := self.StringGrid1.RowCount - 1;
  self.StringGrid1.Refresh;
end;

procedure TConfigForm1.FormCreate(Sender: TObject);
var
  maps: TMaps;
  i: integer;
begin
  self.StringGrid1.RowCount := 2;
  self.StringGrid1.ColCount := 4;
  self.StringGrid1.Cells[0,0] := 'Remote Server IP';
  self.StringGrid1.Cells[1,0] := 'IDE KEY';
  self.StringGrid1.Cells[2,0] := 'Remote Path';
  self.StringGrid1.Cells[3,0] := 'Local Path';

  (self.Npp as TDbgpNppPlugin).ReadMaps(maps);

  self.StringGrid1.RowCount := Length(maps)+2;

  for i:=0 to Length(maps)-1 do
  begin
    self.StringGrid1.Rows[i+1] := maps[i];
  end;

  self.CheckBox1.Checked := (self.Npp as TDbgpNppPlugin).config.refresh_local;
  self.CheckBox2.Checked := (self.Npp as TDbgpNppPlugin).config.refresh_global;
  self.CheckBox3.Checked := (self.Npp as TDbgpNppPlugin).config.use_source;
  self.CheckBox4.Checked := (self.Npp as TDbgpNppPlugin).config.start_closed;
  self.CheckBox5.Checked := (self.Npp as TDbgpNppPlugin).config.break_first_line;
  self.SpinEdit1.Value := (self.Npp as TDbgpNppPlugin).config.max_depth;
  self.SpinEdit2.Value := (self.Npp as TDbgpNppPlugin).config.max_children;
  self.CheckBox6.Checked := (self.Npp as TDbgpNppPlugin).config.local_setup;
  self.SpinEdit3.Value := (self.Npp as TDbgpNppPlugin).config.max_data;

  //self.StringGrid1.Enabled := not self.CheckBox3.Visible;

  // kill the DLG... don't hide it...
  self.DefaultCloseAction := caFree;
end;


procedure TConfigForm1.Button3Click(Sender: TObject);
var
  maps: TMaps;
  i: integer;
  conf: TDbgpNppPluginConfig;
begin
  // save maps
  SetLength(maps, self.StringGrid1.RowCount-1);
  for i:=0 to Length(maps)-1 do
  begin
    maps[i] := TStringList.Create;
    maps[i].AddStrings(self.StringGrid1.Rows[i+1]);
  end;

  conf.maps := maps;
  conf.refresh_local := self.CheckBox1.Checked;
  conf.refresh_global := self.CheckBox2.Checked;
  conf.use_source := self.CheckBox3.Checked;
  conf.start_closed := self.CheckBox4.Checked;
  conf.break_first_line := self.CheckBox5.Checked;
  conf.max_depth := self.SpinEdit1.Value;
  conf.max_children := self.SpinEdit2.Value;
  conf.local_setup := self.CheckBox6.Checked;
  conf.max_data := self.SpinEdit3.Value;

  (self.Npp as TDbgpNppPlugin).WriteMaps(conf);

  self.ModalResult := mrOK;
end;

end.
