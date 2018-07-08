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

unit AboutForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppDockingForm, StdCtrls;

type
  TAboutForm1 = class(TNppDockingForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure GetVersion(FileName: string; var VerMajor, VerMinor, VerRelease, VerBuild: integer);
  public
    { Public declarations }
  end;

var
  AboutForm1: TAboutForm1;

implementation

{$R *.dfm}

procedure TAboutForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TAboutForm1.FormCreate(Sender: TObject);
var
  path: string;
  i: cardinal;
  ma,mi,re,bu:integer;

begin
  i := GetModuleHandle(PChar('dbgpPlugin.dll'));
  SetLength(path, 1001);
  GetModuleFileName(i, PChar(path), 1000);
  SetLength(path, StrLen(PChar(path)));
  self.GetVersion(path,ma,mi,re,bu);
  self.Label7.Caption := Format(self.Label7.Caption, [ma,mi,re,bu]);
end;

procedure TAboutForm1.GetVersion(FileName: string; var VerMajor, VerMinor,
  VerRelease, VerBuild: integer);
var
  VerInfoSize, VerValueSize, Dummy: DWord;
  VerInfo: Pointer;
  VerValue: PVSFixedFileInfo;
begin
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo);
  if VerInfo <> nil then
  begin
    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
    with VerValue^ do
    begin
      VerMajor := dwFileVersionMS shr 16;
      VerMinor := dwFileVersionMS and $FFFF;
      VerRelease := dwFileVersionLS shr 16;
      VerBuild := dwFileVersionLS and $FFFF;
    end;
  end;
  FreeMem(VerInfo, VerInfoSize);
end;

end.
