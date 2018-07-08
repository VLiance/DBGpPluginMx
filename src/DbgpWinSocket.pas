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

unit DbgpWinSocket;

interface

uses
  Windows, Messages, SysUtils, Classes, ScktComp, WinSock, XMLDoc, XMLDOM, XMLIntf,
  StrUtils, Dialogs, Variants, Base64, IdGlobal, Forms{$IFDEF DBGP_COMPRESSION}, zlib{$ENDIF};
type
//  TDbgpWinSocket = class;
//  TDbgpRawEvent = procedure (Sender: TObject; Socket: TDbgpWinSocket; Data:String) of object;

  TDbgpState = (dsStarting, dsStopping, dsStopped, dsRunning, dsBreak);
  TDbgpWinSocket = class;
  TRun = (Run, StepInto, StepOver, StepOut, Stop, Detach);
  TMaps = array of TStringList;
  TStackItem = record
    level: Integer;
    stacktype: String;
    filename: String;
    lineno: Integer;
    where: String;
    {...}
  end;
  PStackItem = ^TStackItem;
  TInit = record
    filename: String;
    language: String;
    appid: String;
    idekey: String;
    server: String;
  end;
  PPropertyItems = ^TPropertyItems;
  PPropertyItem = ^TPropertyItem;
  TPropertyItem = record
    name: String;
    fullname: String;
    datatype: String;
    classname: String;
    constant: Boolean;
    haschildren: Boolean;
    size: String;
    page: String;
    pagesize: String;
    address: String;
    key: String;
    numchildren: String;
    data: String; // actual decoded data;
    children: PPropertyItems;
  end;
  TPropertyItems = array of TPropertyItem;
  TBreakpointType = (btLine, btCall, btReturn, btException, btConditional, btWatch);
  PBreakpoint = ^TBreakpoint;
  TBreakpoint = record
    id: string;
    sci_handler: integer;
    breakpointtype: TBreakpointType;
    filename: string;
    lineno: integer;
    state: boolean;
    functionname: string;
    classname: string;
    temporary: boolean;
    hit_count: integer;
    hit_value: integer;
    hit_condition: string; {?}
    exception: string;
    expression: string;
  end;
  TBreakpoints = array of TBreakpoint;
  TAsyncDbgpCall = record
    TransID: string;
    CallData: string;
    XMLData: string;
  end;
//  TBreak = ();
  TStackList = array of TStackItem;
  TStackCB = procedure(Sender: TDbgpWinSocket; Stack: TStackList) of Object;
  TBreakCB = procedure(Sender: TDbgpWinSocket; Stopped: Boolean) of Object;
  TStreamCB = procedure(Sender: TDbgpWinSocket; stream, data:String) of Object;
  TInitCB = procedure(Sender: TDbgpWinSocket; init: TInit) of Object;
  TVarsCB = procedure(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems) of Object;
  TBreakpointsCB = procedure(Sender: TDbgpWinSocket; breakpoints: TBreakpoints) of Object;

  TDbgpWinSocket = class(TServerClientWinSocket)
  private
    { Private declarations }
    xml: IXMLDocument; // todo, move to parameter passing
    buffer: String;
    TransID: Integer;
    lastEval: String;
    FInit: TInit;
    remote_unix: boolean;
    last_source_request: string;
    source_files: TStringList;
    mapped_files: TStringList;
    AsyncDbgpCall: TAsyncDbgpCall;
{$IFDEF DBGP_COMPRESSION}
    compression: boolean;
{$ENDIF}
  protected
    { Protected declarations }
    FOnDbgpStack: TStackCB;
    FOnDbgpBreak: TBreakCB;
    FOnDbgpStream: TStreamCB;
    FOnDbgpInit: TInitCB;
    FOnDbgpEval: TVarsCB;
    FOnDbgpContext: TVarsCB;
    FOnDbgpBreakpoints: TBreakpointsCB;
    function MapRemoteToLocal(Remote:String): String;
    function MapLocalToRemote(Local:String): String;
    function MapSourceToLocal(Source:String): String;
    function MapLocalToSource(Local:String): String;
    procedure ProcessInit;
    procedure ProcessStream;
    procedure ProcessResponse_stack;
    procedure ProcessResponse_eval;
    procedure ProcessResponse_context_get;
    procedure ProcessResponse_breakpoint_set;
    procedure ProcessResponse_breakpoint_list;
    procedure ProcessResponse_source;
    procedure ProcessResponse_property_get;
    procedure ProcessResponse_feature_get;
    procedure ProcessResponse_feature_set;
    procedure ProcessResponse;

    procedure ProcessProperty(varxml:IXMLNodeList; var list:TPropertyItems); overload;
    procedure ProcessProperty(varxml:IXMLNodeList; var list:TPropertyItems; ParentItem: PPropertyItem); overload;
    function WaitForAsyncAnswer(call_data: string): boolean;
    function CheckForError(varxml: IXMLNodeList): string;

    function UriToFile(Remote: String): String;
  public
    { Public declarations }
    maps: TMaps;
    use_source: boolean;
    local_setup: boolean;
    debugdata: TStringList;
    stack: TStackList;
    Transaction_id: String;
    last_response_command: String;
    state: TDbgpState;
    stack_reentrant: boolean;
    constructor Create(Socket: TSocket; ServerWinSocket: TServerWinSocket);
    destructor Destroy; override;
    function ReadDBGP: String;
    procedure GetFeature(FeatureName: String);
    procedure SetFeature(FeatureName: String; Value: String);
    procedure GetStack;
    procedure GetContext(Context:integer); overload;
    procedure GetContext(Context:integer; Depth:Integer); overload;
    procedure GetBreakpoints;
    procedure SetStream(Str: string; Mode: Integer);
    procedure SetBreakpoint(Filename: String; Line:Integer); overload;
    procedure SetBreakpoint(bp: TBreakpoint); overload;
    procedure UpdateBreakpoint(bp: TBreakpoint);
    procedure RemoveBreakpoint(bp: TBreakpoint);
    procedure GetSource(filename: String);
    procedure Resume(runtype: TRun);
    procedure SendEval(data: String);
    function GetPropertyAsync(data: String): string; overload;
    function GetPropertyAsync(data: String; var list: TPropertyItems): string; overload;
    function SetFeatureAsync(FeatureName: String; Value: String): boolean;
    function GetFeatureAsync(FeatureName: String; var Value: String): boolean; overload;
    function GetFeatureAsync(FeatureName: String): boolean; overload;
    function SendCommand(Cmd: String; Args: String; Base64:String): Integer; overload;
    function SendCommand(Cmd: String; Args: String): Integer; overload;
    function SendCommand(Cmd: String): Integer; overload;
  published
    { Published declarations }
    property Init: TInit read Finit;
    property OnDbgpStack: TStackCB read FOnDbgpStack write FOnDbgpStack;
    property OnDbgpBreak: TBreakCB read FOnDbgpBreak write FOnDbgpBreak;
    property OnDbgpStream: TStreamCB read FOnDbgpStream write FOnDbgpStream;
    property OnDbgpInit: TInitCB read FOnDbgpInit write FOnDbgpInit;
    property OnDbgpEval: TVarsCB read FOnDbgpEval write FOnDbgpEval;
    property OnDbgpContext: TVarsCB read FOnDbgpContext write FOnDbgpContext;
    property OnDbgpBreakpoints: TBreakpointsCB read FOnDbgpBreakpoints write FOnDbgpBreakpoints;
  end;


procedure FreePropertyItems(list: TPropertyItems);
//procedure DuplicatePropertyItems(var list: TPropertyItems);

function GetLongPathName(lpszShortPath: PChar; lpszLongPath: PChar ; cchBuffer: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetLongPathName}
function GetLongPathNameA(lpszShortPath: PAnsiChar; lpszLongPath: PAnsiChar ; cchBuffer: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetLongPathNameA}
function GetLongPathNameW(lpszShortPath: PWideChar; lpszLongPath: PWideChar ; cchBuffer: DWORD): DWORD; stdcall;
{$EXTERNALSYM GetLongPathNameW}

implementation

{ TDbgpWinSocket }

function GetLongPathName; external kernel32 name 'GetLongPathNameA';
function GetLongPathNameA; external kernel32 name 'GetLongPathNameA';
function GetLongPathNameW; external kernel32 name 'GetLongPathNameW';


 // predvidevamo praviln XML
constructor TDbgpWinSocket.Create(Socket: TSocket;
  ServerWinSocket: TServerWinSocket);
begin
  inherited;
  self.TransID := 1; // internal counter
  self.debugdata := TStringList.Create;
  self.Transaction_id := ''; // return transaction
  self.last_response_command := '';
  self.remote_unix := true;
  self.source_files := TStringList.Create;
  self.source_files.CaseSensitive := true;
  self.mapped_files := TStringList.Create;
  self.mapped_files.CaseSensitive := true;
  self.AsyncDbgpCall.TransID := ''; // not set
  self.stack_reentrant := false;
{$IFDEF DBGP_COMPRESSION}
  self.compression := false;
{$ENDIF}
end;
destructor TDbgpWinSocket.Destroy;
var
  i: integer;
begin
  self.debugdata.Free;
  // delete the shit
  for i := 0 to self.source_files.Count-1 do
  begin
    FileSetReadOnly(self.MapSourceToLocal(self.source_files[i]),false);
    //DeleteFile(self.MapSourceToLocal(self.source_files[i]));
  end;
  self.source_files.Free;
  inherited;
end;

{-----------------------------------------------------------------------------}
{I am rewriting the mapping from scratch usin "raw" data}

// file:///D:/xxx/php/test1.php  D:\xxx\php\test1.php
// file:///var/www/spike.krneki.org/html/dbg/test1.php \\spike2\dbg\test1.php
// local_setup, dbgp:, use_source


// remote to local

// used to map straight local files: file:///D:/xxx/php/test1.php  D:\xxx\php\test1.php
function TDbgpWinSocket.UriToFile(Remote: String): String;
begin
  Result := '';
  if (LeftStr(Remote, 8)='file:///') and (Length(Remote)>9) and (Remote[10]=':') then
  begin
    Remote := Copy(Remote,9,MaxInt);
    Result := StringReplace(Remote, '/', '\', [rfReplaceAll]);
  end;
end;

function TDbgpWinSocket.MapRemoteToLocal(Remote: String): String;
var
  i: integer;
  r: string;
begin
  Remote := URLDecode(Remote);
  self.remote_unix := not ((LeftStr(Remote, 8)='file:///') and (Length(Remote)>9) and (Remote[10]=':'));

  // 1. if local_setup dont do any mapping. throw errors and fallback to source mapping
  if (self.local_setup) and (LeftStr(Remote, 5)<>'dbgp:') then
  begin
    r := self.UriToFile(Remote);
    if (r = '') then
    begin
      ShowMessage('Unable to map remote: '+Remote+' (ip: '+self.init.server+' idekey: '+self.init.idekey+' local_setup) fallback to source');
      r := self.MapSourceToLocal(Remote);
    end;
    Result := r;
    exit;
  end;

  // 2. if use_source or dbgp:, very simple it always sucseeds.
  if (LeftStr(Remote, 5)='dbgp:') or (self.use_source) then
  begin
    Result := self.MapSourceToLocal(Remote);
    exit;
  end;

  // 3. normal mapping
  for i:=0 to Length(self.maps)-1 do
  begin
    if (self.maps[i][0] <> '') and (self.maps[i][0] <> self.init.server) then continue;
    if (self.maps[i][1] <> '') and (self.maps[i][1] <> self.init.idekey) then continue;
    if (CompareText(self.maps[i][2], LeftStr(Remote, Length(self.maps[i][2])))=0) then
    begin
      // force dbgp:
      if (self.maps[i][3] = 'DBGP:') then
      begin
        Result := self.MapSourceToLocal(Remote);
        exit;
      end;
      r := Copy(Remote, Length(self.maps[i][2])+1, MaxInt);
      Result := self.maps[i][3] + StringReplace(r, '/', '\', [rfReplaceAll]);
      exit;
    end;
  end;

  // 4. No map found, try local or warn and fallback to source
  // throw exception??
  r := self.UriToFile(Remote);
  Result := r;
  if (r<>'') and (FileExists(r)) then exit;
  ShowMessage('Unable to map remote: '+Remote+' (ip: '+self.init.server+' idekey: '+self.init.idekey+') fallback to source');
  Result := self.MapSourceToLocal(Remote);
end;


function TDbgpWinSocket.MapLocalToRemote(Local: String): String;
var
  i: integer;
  r: string;
begin
  // 1. Try existing source maps
  r := self.MapLocalToSource(Local);
  if (r <> '') then
  begin
    Result := r;
    exit;
  end;
  // 2. If local setup, translate blindly
  if (self.local_setup) then
  begin
    Result := 'file:///'+URLEncode(StringReplace(Local, '\', '/', [rfReplaceAll]));
    exit;
  end;
  // 3. Use maps
  for i:=0 to Length(self.maps)-1 do
  begin
    if (self.maps[i][0] <> '') and (self.maps[i][0] <> self.init.server) then continue;
    if (self.maps[i][1] <> '') and (self.maps[i][1] <> self.init.idekey) then continue;
    if (CompareText(self.maps[i][3], LeftStr(Local, Length(self.maps[i][3])))=0) then
    begin
      r := Copy(Local, Length(self.maps[i][3])+1, MaxInt);
      r := StringReplace(r, '\', '/', [rfReplaceAll]);
      Result := self.maps[i][2] + r;
      exit;
    end;
  end;
  // 4. final try to map to filenam if local connection
  //if (not self.remote_unix and (self.Init.server = '127.0.0.1')) then   //Mx- Annoying popup (self.remote_unix true?) - Bug when reconnect ??? TODO
  if ((self.Init.server = '127.0.0.1')) then
  begin
    Result := 'file:///'+URLEncode(StringReplace(Local, '\', '/', [rfReplaceAll]));
    exit;
  end;
  ShowMessage('Unable to map filename: '+Local+' (ip: '+self.init.server+' idekey: '+self.init.idekey+') unix: '+BoolToStr(self.remote_unix,true));
  Result := '';
end;

{ mappings for source command }
function TDbgpWinSocket.MapLocalToSource(Local: String): String;
var
  i: integer;
begin
  Result := '';
  for i:=0 to self.source_files.Count-1 do
  begin
    if (Local = self.MapSourceToLocal(self.source_files[i])) then
    begin
      Result := self.source_files[i];
      exit;
    end;
  end;
end;

function TDbgpWinSocket.MapSourceToLocal(Source: String): String;
var
  s,s2: String;
  source2: String;
  r: integer;
begin
  Result := '';
  s := '';
  SetLength(s, 200);
  GetTempPath(200, PChar(s));
  SetLength(s, StrLen(PChar(s)));
  source2 := UrlEncode(Source);
  source2 := StringReplace(source2, '/', '%2f', [rfReplaceAll]);
  source2 := StringReplace(source2, ':', '%3a', [rfReplaceAll]);
  s := s + 'dbgp_' + source2;
  if (self.source_files.IndexOf(Source)=-1) then
  begin
    self.source_files.Add(Source);
    self.GetSource(Source);
  end;
  r := GetLongPathName(PChar(s), nil, 0);
  if (r>0) then
  begin
    SetLength(s2, r);
    GetLongPathName(PChar(s), Pchar(s2), r);
    SetLength(s2, r-1); // cut last null ?
    s := s2;
  end;
  Result := s;
end;

{-----------------------------------------------------------------------------}

{ procesiramo init}
procedure TDbgpWinSocket.ProcessInit;
begin
{
Data(404): <?xml version="1.0" encoding="iso-8859-1"?>
<init
        fileuri="file:///var/www/spike.krneki.org/dbgp/phpinfo.php"
        language="PHP"
        protocol_version="1.0"
        appid="13462"
        idekey="session_name">

<engine version="2.0.0RC3">
<![CDATA[Xdebug]]>
</engine><author>
<![CDATA[Derick Rethans]]></author>
<url>
<![CDATA[http://xdebug.org]]></url><copyright><![CDATA[Copyright (c) 2002-2007 by Derick Rethans]]></copyright>

</init>
}
  self.state := dsStarting;
  self.FInit.language := self.xml.ChildNodes[1].Attributes['language'];
  self.FInit.appid := self.xml.ChildNodes[1].Attributes['appid'];
  self.FInit.idekey := self.xml.ChildNodes[1].Attributes['idekey'];
  self.FInit.server := self.xml.ChildNodes[1].Attributes['proxied'];
  if (self.FInit.server = '') then self.FInit.server := self.RemoteAddress;
  self.FInit.filename := self.MapRemoteToLocal(self.xml.ChildNodes[1].Attributes['fileuri']);

{$IFDEF DBGP_COMPRESSION}
  // try to negotiate compression
  if (self.GetFeatureAsync('compression')) then
  begin
    if (self.SetFeatureAsync('compression', 'compress')) then
    begin
      self.compression := true;
    end;
  end;
{$ENDIF}

  if (Assigned(self.FOnDbgpInit)) then self.FOnDbgpInit(self, self.init);
end;

{ splisna funkcija za rekurzivno procesiranje varov}
procedure TDbgpWinSocket.ProcessProperty(varxml: IXMLNodeList;
  var list: TPropertyItems);
begin
  self.ProcessProperty(varxml, list, nil);
end;

procedure TDbgpWinSocket.ProcessProperty(varxml: IXMLNodeList;
  var list: TPropertyItems; ParentItem: PPropertyItem);
var
  i: Integer;
//  c: Integer;
  x: IXMLNode;
begin
(*
Recv(672): <?xml version="1.0" encoding="iso-8859-1"?>
<response command="context_get" transaction_id="778">

<property name="omg" fullname="$omg" address="-1215305772" type="string" size="3" encoding="base64">
<![CDATA[ZGRz]]>
</property>
<property name="a" fullname="$a" address="-1215305268" type="array" children="1" numchildren="2">
        <property name="2" fullname="$a[2]" address="-1215298680" type="string" size="3" encoding="base64">
                <![CDATA[ZGRk]]>
        </property>
        <property name="f" fullname="$a[&apos;f&apos;]" address="-1215305388" type="string" size="1" encoding="base64">
                <![CDATA[Zw==]]>
        </property>
</property>
<property name="x" fullname="$x" type="uninitialized">
</property>

</response>
*)
  SetLength(list, varxml.Count);

  for i:=0 to varxml.Count-1 do
  begin
    x := varxml[i];
    //Assert((x.NodeName = 'property'),'Property node actually not "property"!!')
    if (x.NodeName <> 'property') then
    begin
      //ShowMessage('Property node actually not "property"!!');
      exit;
    end;

    list[i].name := x.Attributes['name'];
    if (list[i].name = '') then list[i].name := '?';
    list[i].fullname := x.Attributes['fullname'];
    //if (list[i].fullname = '') then list[i].fullname := list[i].name;
    list[i].datatype := x.Attributes['type'];
    list[i].classname := x.Attributes['classname'];
    list[i].constant := (x.Attributes['constant'] = '1');
    list[i].haschildren := (x.Attributes['children'] = '1');
    list[i].size := x.Attributes['size'];
    list[i].page := x.Attributes['page'];
    list[i].pagesize := x.Attributes['pagesize'];
    list[i].address := x.Attributes['address'];
    list[i].key := x.Attributes['key'];
    list[i].numchildren := x.Attributes['numchildren'];
    list[i].data := '';

    // try to compensate for missing fullname attr...
    if (list[i].fullname = '') and (ParentItem <> nil) then
    begin
      if (ParentItem^.datatype = 'array') then list[i].fullname := ParentItem^.fullname+'["'+list[i].name+'"]';
      if (ParentItem^.datatype = 'object') then list[i].fullname := ParentItem^.fullname+'->'+list[i].name;
    end
    else if (list[i].fullname = '') and (self.lastEval <> '') and (self.lastEval[1] = '$') then
    begin
      list[i].fullname := self.lastEval;
    end;

    if (x.HasChildNodes) and (x.ChildNodes[0].NodeType in [ntText, ntCData]) then
    begin
      if (x.Attributes['encoding'] = 'base64') then
      begin
        list[i].data := Decode64(x.ChildNodes[0].Text);
      end
      else
      begin
        list[i].data := x.ChildNodes[0].Text;
      end;
    end;

    list[i].children := nil;
    if (list[i].haschildren) then
    begin
      New(list[i].children); // where to dispose?
      self.ProcessProperty(x.ChildNodes, list[i].children^, @list[i]);
    end;
  end;
end;

// Predvsem reakcije na status.. break in stop
procedure TDbgpWinSocket.ProcessResponse;
begin
  // is response.status=break?
  {Recv(131): <?xml version="1.0" encoding="iso-8859-1"?>
<response command="step_over" transaction_id="0" status="break" reason="ok"></response>
----}
  if (self.xml.ChildNodes[1].Attributes['status'] = 'break') then
  begin
    self.state := dsBreak;
    if (Assigned(self.FOnDbgpBreak)) then
      self.FOnDbgpBreak(self, false)
    else
      self.GetStack;
  end
  else
  if (self.xml.ChildNodes[1].Attributes['status'] = 'stopped') then
  begin
    self.state := dsStopped;
    if (Assigned(self.FOnDbgpBreak)) then
    begin
      // when finished...
      // send one last run so we can die?
      self.FOnDbgpBreak(self, true);
    end;
  end
  else
  if (self.xml.ChildNodes[1].Attributes['status'] = 'stopping') then
  begin
    self.state := dsStopping;
    if (Assigned(self.FOnDbgpBreak)) then
    begin
      self.FOnDbgpBreak(self, true);
    end;
  end;

end;

procedure FreePropertyItems(list: TPropertyItems);
var
  i: Integer;
begin
  for i:=0 to Length(list)-1 do
  begin
    if (list[i].children <> nil) then
    begin
      FreePropertyItems(list[i].children^);
      SetLength(list[i].children^, 0);
      Dispose(list[i].children);
    end;
  end;
end;

procedure TDbgpWinSocket.ProcessResponse_breakpoint_list;
var
  varxml: IXMLNodeList;
  i: integer;
  bps: TBreakpoints;
begin
{
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="breakpoint_list" transaction_id="33">
	<breakpoint type="line" filename="file:///home/zobo/stuff/test1.php" lineno="12" state="enabled" hit_count="0" hit_value="0" id="27980007"></breakpoint>
	<breakpoint type="return" function="phpinfo" state="enabled" hit_count="0" hit_value="0" id="27980009"></breakpoint>
	<breakpoint type="line" filename="file:///home/zobo/stuff/test1.php" lineno="14" state="enabled" hit_count="0" hit_value="0" id="27980008"></breakpoint>
	<breakpoint type="call" function="test2" class="test" state="enabled" hit_count="0" hit_value="0" id="27990002"></breakpoint>
</response>
}
  varxml := self.xml.ChildNodes[1].ChildNodes;
  if (varxml = nil) then exit;
  SetLength(bps, varxml.Count);
  for i:=0 to varxml.Count-1 do
  begin
    bps[i].id := varxml[i].Attributes['id'];
    if (varxml[i].Attributes['type'] = 'line') then bps[i].breakpointtype := btLine;
    if (varxml[i].Attributes['type'] = 'call') then bps[i].breakpointtype := btCall;
    if (varxml[i].Attributes['type'] = 'return') then bps[i].breakpointtype := btReturn;
    if (varxml[i].Attributes['type'] = 'exception') then bps[i].breakpointtype := btException;
    if (varxml[i].Attributes['type'] = 'conditional') then bps[i].breakpointtype := btConditional;
    if (varxml[i].Attributes['type'] = 'watch') then bps[i].breakpointtype := btWatch;
    bps[i].filename := '';
    if (varxml[i].Attributes['filename'] <> '') then
      bps[i].filename := self.MapRemoteToLocal(varxml[i].Attributes['filename']);
    try bps[i].lineno := StrToInt(varxml[i].Attributes['lineno']); except on EConvertError do bps[i].lineno := 0; end;
    bps[i].state := (varxml[i].Attributes['state'] <> 'disabled');
    bps[i].functionname := varxml[i].Attributes['function'];
    bps[i].classname := varxml[i].Attributes['class'];
    bps[i].temporary := (varxml[i].Attributes['state'] = 'temporary');
    try bps[i].hit_count := StrToInt(varxml[i].Attributes['hit_count']); except on EConvertError do bps[i].hit_count := 0; end;
    try bps[i].hit_value := StrToInt(varxml[i].Attributes['hit_value']); except on EConvertError do bps[i].hit_value := 0; end;
    bps[i].hit_condition := varxml[i].Attributes['hit_condition'];
    if (bps[i].hit_condition = '') then bps[i].hit_condition := '>=';
    bps[i].exception := varxml[i].Attributes['exception'];
    { unimplemented }
    if (varxml[i].HasChildNodes and (varxml[i].ChildNodes[1].NodeName = 'expression') and (varxml[i].ChildNodes[1].ChildNodes[1] <> nil)) then
      bps[i].expression := varxml[i].ChildNodes[1].ChildNodes[1].Text;
  end;
  if (Assigned(self.FOnDbgpBreakpoints)) then
    self.FOnDbgpBreakpoints(self,bps);
end;

procedure TDbgpWinSocket.ProcessResponse_breakpoint_set;
var
  id: String;
begin
  id := self.xml.ChildNodes[1].Attributes['id'];
end;

procedure TDbgpWinSocket.ProcessResponse_context_get;
var
  list: TPropertyItems;
  context: Integer;
begin
  //process context
  if (self.xml.ChildNodes[1].HasChildNodes) and (self.xml.ChildNodes[1].ChildNodes[0].NodeName = 'error') then
  begin
    ShowMessage('DBGP Error ('+self.xml.ChildNodes[1].ChildNodes[0].Attributes['code']+'): '+
      self.xml.ChildNodes[1].ChildNodes[0].ChildNodes[0].ChildNodes[0].NodeValue);
    exit;
  end;

  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  try
    context := StrToInt(self.xml.ChildNodes[1].Attributes['context']);
  except
    on EConvertError do context := 0;
  end;
  if (Assigned(self.FOnDbgpContext)) then
    self.FOnDbgpContext(self,context,list);
  //free data
  FreePropertyItems(list);
end;

procedure TDbgpWinSocket.ProcessResponse_eval;
var
  list: TPropertyItems;
begin
  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  if (Length(list)>0) and (self.lastEval <> '') then
    list[0].fullname := self.lastEval;
  if (Assigned(self.FOnDbgpEval)) then
    self.FOnDbgpEval(self,-1,list);
  FreePropertyItems(list);
end;

procedure TDbgpWinSocket.ProcessResponse_stack;
var
  i: integer;
  x: IXMLNode;
  stack: TStackList;
begin
  if (not self.xml.ChildNodes[1].HasChildNodes) then exit; // bad?
  x := nil;
  if (self.xml.ChildNodes[1].HasChildNodes) then
    x := self.xml.ChildNodes[1].ChildNodes[0];
  i := 0;
  while (x <> nil) do
  begin
    if x.NodeName<>'stack' then continue;
    inc(i);
    SetLength(stack, i);
    stack[i-1].level := StrToInt(x.Attributes['level']);
    stack[i-1].stacktype := x.Attributes['type'];
    stack[i-1].filename := self.MapRemoteToLocal(x.Attributes['filename']);
    stack[i-1].lineno := StrToInt(x.Attributes['lineno']);
    stack[i-1].where := x.Attributes['where'];
    stack[i-1].stacktype := x.Attributes['type'];
    x:= x.NextSibling;
  end;

  self.stack := stack;
  if (Assigned(self.FOnDbgpStack)) then self.FOnDbgpStack(self, stack);
end;

procedure TDbgpWinSocket.ProcessStream;
var
  str,data: String;
begin
{
<?xml version="1.0" encoding="iso-8859-1"?>
<stream type="stdout" encoding="base64">
        <![CDATA[U2V0LUNvb2tpZTogWERFQlVHX1NFU1NJT049c2Vzc2lvbl9uYW1lOyBleHBpcmVzPVN1biwgMTMtTWF5LTIwMDcgMTk6MDA6MzEgR01UOyBwYXRoPS8=]]>
</stream>
}
  str := self.xml.ChildNodes[1].Attributes['type'];
  data := self.xml.ChildNodes[1].ChildNodes[0].NodeValue;

  if (self.xml.ChildNodes[1].Attributes['encoding'] = 'base64') then
  begin
    data := Decode64(data);
  end;

  if (Assigned(self.FOnDbgpStream)) then self.FOnDbgpStream(self, str, data);

  //Result := 'Stream('+str+'): '+data;
end;

procedure TDbgpWinSocket.ProcessResponse_source;
var
  fn, ret: String;
  f: TextFile;

function phpunescape(s:string):string;
var
  r: string;
  i: integer;
  esc: boolean;
begin
  esc := false;
  for i:=1 to Length(s) do
  begin
    if (esc) then
    begin
      case s[i] of
        'n': r := r + #10;
        'r': r := r + #13;
        '\': r := r + '\';
      else
        r := r + '\';
      end;
      esc := false;
    end
    else
    if (s[i]='\') then
      esc := true
    else
      r := r + s[i];
  end;
  Result := r;
end;

function source_notchanged(filename:String; data:String):Boolean;
var
  f: File;
  a: Array[1..1024] of char;
  nr: Integer;
  tmp, old: String;
begin
  Result := false;
  if not FileExists(filename) then exit;
  AssignFile(f, filename);
  FileMode := fmOpenRead;
  Reset(f, 1);
  repeat
    BlockRead(f, a, 1024, nr);
    SetString(tmp, PChar(@a), nr);
    old := old + tmp;
  until nr=0;
  CloseFile(f);
  if old = data then Result := true;
end;

begin
{
<?xml version="1.0" encoding="iso-8859-1"?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug"
  command="source" transaction_id="77" encoding="base64">
	<![CDATA[PD9waHANCg0KZW...cCgkY29kZSk7DQo=]]>
</response>}
{
<- source -i 159 -f file:///C:/Documents and Settings/User/???
?????????/Work/tbox/lib/util.inc.php
-> <response xmlns="urn:debugger_protocol_v1"
xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="source"
transaction_id="159"><error code="1"><message><![CDATA[parse error in
command]]></message></error></response>}
  ret := '';

  if (self.xml.ChildNodes[1].HasChildNodes) and (self.xml.ChildNodes[1].ChildNodes[0]<>nil) then
    ret := self.xml.ChildNodes[1].ChildNodes[0].Text;

  if (self.xml.ChildNodes[1].Attributes['encoding'] = 'base64') then ret := Decode64(ret);

  if (self.last_source_request<>'') then
  begin
    if (LeftStr(self.last_source_request, 5)='dbgp:') then
      ret := phpunescape(ret);
    fn := self.MapSourceToLocal(self.last_source_request);
    if source_notchanged(fn, ret) then exit;
    FileSetReadOnly(fn, false);
    AssignFile(f, fn);
    Rewrite(f);
    System.Write(f, ret);
    CloseFile(f);
    FileSetReadOnly(fn, true);
    self.last_source_request := '';
  end;
end;

//
procedure TDbgpWinSocket.ProcessResponse_property_get;
var
  list: TPropertyItems;
begin
  self.ProcessProperty(self.xml.ChildNodes[1].ChildNodes, list);
  //if (Assigned(self.FOnDbgpEval)) then
  //  self.FOnDbgpEval(self,-1,list);
  FreePropertyItems(list);
end;

procedure TDbgpWinSocket.ProcessResponse_feature_get;
begin
  //
end;

procedure TDbgpWinSocket.ProcessResponse_feature_set;
begin
  //
{
<response command="feature_set"
          feature="compression"
          success="0|1"
          transaction_id="transaction_id"/>
}
{
  if (self.xml.ChildNodes[1].Attributes['feature'] = 'compression') and
     (self.xml.ChildNodes[1].Attributes['success'] = '1') then
  begin

  end;
}
end;

{-----------------------------------------------------------------------------}

function TDbgpWinSocket.CheckForError(varxml: IXMLNodeList): string;
begin
  Result := '';
  if (varxml[1].HasChildNodes) and (varxml[1].ChildNodes[0].NodeName = 'error') then
  begin
    Result := 'DBGP Error: '+
      'Response type: '+varxml[1].NodeName+' '+
      'Command: '+varxml[1].Attributes['command']+' '+
      'Error code: '+varxml[1].ChildNodes[0].Attributes['code']+' '+
      'Error: '+varxml[1].ChildNodes[0].Attributes['apperr']+' '+
      'Error message: '+varxml[1].ChildNodes[0].ChildNodes[0].ChildNodes[0].Text;
  end;
end;

// returnes the read data and does all processing...
function TDbgpWinSocket.ReadDBGP: String;
var
  res,s,s2:String;
  len:Integer;
{$IFDEF DBGP_COMPRESSION}
  zp: Pointer;
  zs: integer;
{$ENDIF}
begin
  s := self.ReceiveText;
  s := self.buffer + s;

  if (Length(s) = 0) then exit;

  if (s[Length(s)] <> #0) then // message not yet complete... return and wait for better times
  begin
    self.buffer := s;
    exit;
  end;

  try
    len := StrToInt(s);
  except
    on EConvertError do len := 0; // hum.. protocol error?
  end;

  if (Length(s)<len) then
  begin
    // Should not happen.. something is wrong with the message
    self.debugdata.Add('Error in len: '+IntToStr(Length(s))+'<'+IntToStr(len)+': '+s);
    exit;
  end;

  s2 := Copy(s, StrLen(PChar(s))+2, len);
  s := Copy(s, StrLen(PChar(s))+2+len+1, MaxInt);

  self.buffer := s; // ostanek
  s := '';

  // decompress
{$IFDEF DBGP_COMPRESSION}
  if (self.compression) then
  begin
    zlib.DecompressBuf(PChar(s2), len, len*20, zp, zs);
    s2 := Copy(PChar(zp), 1, zs);
    FreeMem(zp);
  end;
{$ENDIF}

  // for raw log
  self.debugdata.Add('Recv: '+s2);

  self.Transaction_id := '';

try
  self.xml := TXMLDocument.Create(nil);
  self.xml.Options := [];
  self.xml.XML.Add(s2);
  self.xml.Active := true;

  res := self.xml.ChildNodes[1].NodeName;
  // handle error?
  s := self.CheckForError(self.xml.ChildNodes);
  if (res = 'init') then
  begin
    self.ProcessInit;
  end
  else if (res = 'response') then
  begin
    self.last_response_command := self.xml.ChildNodes[1].Attributes['command'];
    self.Transaction_id := self.xml.ChildNodes[1].Attributes['transaction_id'];
    if (self.Transaction_id = self.AsyncDbgpCall.TransID) then
    begin
      self.AsyncDbgpCall.XMLData := s2; // save XML data
      s := ''; // clear possible errors...
    end
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'stack_get') then
      self.ProcessResponse_stack
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'eval') then
      self.ProcessResponse_eval
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'context_get') then
      self.ProcessResponse_context_get
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'breakpoint_set') then
      self.ProcessResponse_breakpoint_set
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'breakpoint_list') then
      self.ProcessResponse_breakpoint_list
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'source') then
      self.ProcessResponse_source
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'property_get') then
      self.ProcessResponse_property_get
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'feature_get') then
      self.ProcessResponse_feature_get
    else if (self.xml.ChildNodes[1].Attributes['command'] = 'feature_set') then
      self.ProcessResponse_feature_set
    else
      self.ProcessResponse;
  end
  else if (res = 'notify') then
  begin
  end
  else if (res = 'stream') then
  begin
    self.ProcessStream;
  end;

  if (s<>'') then ShowMessage(s);
finally
  if (self.xml<>nil) then self.xml.Active := false;
  self.xml := nil;
end;
  if (self.buffer<>'') then self.ReadDBGP;
end;

{-----------------------------------------------------------------------------}

procedure TDbgpWinSocket.Resume(runtype: TRun);
var
  cmd: String;
begin
  cmd := '';
  case runtype of
  Run: cmd := 'run';
  StepInto: cmd := 'step_into';
  StepOver: cmd := 'step_over';
  StepOut: cmd := 'step_out';
  Stop: cmd := 'stop';
  end;
  if (cmd = '') then exit;
  self.state := dsRunning;
  self.SendCommand(cmd);
end;

function TDbgpWinSocket.SendCommand(Cmd, Args, Base64: String): Integer;
var d:String;
begin
  Result := -1;
  if (not self.Connected) then exit;

  d := Cmd + ' -i '+IntToStr(self.TransID);
  Result := self.TransID;
  inc(self.TransID);
  if (Args <> '') then
    d := d + ' '+Args;
  if (Base64 <> '') then
    d := d + ' -- '+Encode64(Base64);
    //d := d + ' -- '+Base64Encode(Base64);
  self.SendText(d+#0);
  self.debugdata.Add('Send: '+d);
end;

function TDbgpWinSocket.SendCommand(Cmd, Args: String): Integer;
begin
  Result := self.SendCommand(Cmd, Args, '');
end;

function TDbgpWinSocket.SendCommand(Cmd: String): Integer;
begin
  Result := self.SendCommand(Cmd, '', '');
end;

{ Set a line breakpoint }
procedure TDbgpWinSocket.SendEval(data: String);
begin
  self.lastEval := data;
  self.SendCommand('eval','',data);
end;

procedure TDbgpWinSocket.SetBreakpoint(Filename: String; Line: Integer);
var
  s: string;
begin
  s := self.MapLocalToRemote(Filename);
  if (s='') then exit;
  self.SendCommand('breakpoint_set', '-t line -f '+s+' -n '+IntToStr(Line));
end;

procedure TDbgpWinSocket.SetBreakpoint(bp: TBreakpoint);
var
  cmd: String;
  s: string;
begin
  case (bp.breakpointtype) of
    btLine: cmd := '-t line';
    btCall: cmd := '-t call';
    btReturn: cmd := '-t return';
    btException: cmd := '-t exception';
  end;
  if (bp.filename <> '') then
  begin
    s := self.MapLocalToRemote(bp.filename);
    if (s='') then exit; // do not map
    cmd := cmd + ' -f '+s;
    cmd := cmd + ' -n '+IntToStr(bp.lineno);
  end;
  if (bp.state) then cmd := cmd + ' -s enabled' else cmd := cmd + ' -s disabled';
  if (bp.functionname <> '') then cmd := cmd + ' -m '+bp.functionname;
  if (bp.classname <> '') then cmd := cmd + ' -a '+bp.classname;
  if (bp.temporary) then cmd := cmd + ' -r 1';
  cmd := cmd + ' -h '+IntToStr(bp.hit_value)+' -o '+bp.hit_condition;
  if (bp.exception <> '') then cmd := cmd + ' -x '+bp.exception;
  self.SendCommand('breakpoint_set', cmd, bp.expression);
end;

procedure TDbgpWinSocket.RemoveBreakpoint(bp: TBreakpoint);
begin
  self.SendCommand('breakpoint_remove', '-d '+bp.id);
end;

procedure TDbgpWinSocket.UpdateBreakpoint(bp: TBreakpoint);
var
  cmd: String;
begin
  cmd := '-d ' + bp.id;
  if (bp.state) then cmd := cmd + ' -s enabled' else cmd := cmd + ' -s disabled';
  cmd := cmd + ' -n ' + IntToStr(bp.lineno);
  cmd := cmd + ' -h ' + IntToStr(bp.hit_value);
  cmd := cmd + ' -o ' + bp.hit_condition;

  self.SendCommand('breakpoint_update', cmd);
end;

procedure TDbgpWinSocket.SetFeature(FeatureName, Value: String);
begin
  self.SendCommand('feature_set','-n '+FeatureName+' -v '+Value);
end;

{ put stdout or stderr and 0,1,2 (disaled,copy,redirect) }
procedure TDbgpWinSocket.SetStream(Str: string; Mode: Integer);
begin
  self.SendCommand(Str,'-c '+IntToStr(Mode));
end;

procedure TDbgpWinSocket.GetSource(filename: String);
begin
  // maps?
  self.last_source_request := filename;
  self.SendCommand('source', '-f '+filename);
end;

procedure TDbgpWinSocket.GetContext(Context: integer);
begin
  self.SendCommand('context_get', '-c '+IntToStr(Context)); // todo depth
end;

procedure TDbgpWinSocket.GetBreakpoints;
begin
  self.SendCommand('breakpoint_list');
end;

procedure TDbgpWinSocket.GetContext(Context: integer; Depth: integer);
begin
  self.SendCommand('context_get', '-c '+IntToStr(Context)+' -d '+IntToStr(Depth)); // todo depth
end;

procedure TDbgpWinSocket.GetFeature(FeatureName: String);
begin
  self.SendCommand('feature_get','-n '+FeatureName);
end;

{ Maps a remote filename 'file://..' to a local file 'd:\xxx...' }
procedure TDbgpWinSocket.GetStack;
begin
  self.SendCommand('stack_get');
end;

{-----------------------------------------------------------------------------}

{ Async call handling }
function TDbgpWinSocket.WaitForAsyncAnswer(call_data: string): boolean;
begin
  Result := false;
  if (self.AsyncDbgpCall.TransID <> '') then exit;    // curenty only on async call at a time

  self.AsyncDbgpCall.TransID := IntToStr(self.TransID-1);
  self.AsyncDbgpCall.CallData := call_data;
  self.AsyncDbgpCall.XMLData := '';

  Result := true;
  while (self.AsyncDbgpCall.XMLData = '') do
  begin
    Application.ProcessMessages;
    // check for timeout!
  end;
  self.AsyncDbgpCall.TransID := ''; // cleanup
  // humm

end;

{-----------------------------------------------------------------------------}

function TDbgpWinSocket.GetPropertyAsync(data: String): string;
var
  list: TPropertyItems;
begin
  Result := self.GetPropertyAsync(data, list);
  if (Result = '') then
  begin
    if (Length(list)>0) then
    begin
      Result := data + ' = ' + list[0].datatype + ': ' + list[0].data;
    end;
    FreePropertyItems(list);
  end
  else
  begin
    Result := data + ' = ' + Result;
  end;
end;

function TDbgpWinSocket.GetPropertyAsync(data: String;
  var list: TPropertyItems): string;
var
  xml: IXMLDocument;
begin
  self.SendCommand('property_get', '-n '+data);
  Result := 'Error...';
  SetLength(list, 1);
  list[0].fullname := data;
  list[0].datatype := 'Error';
  list[0].children := nil;
  list[0].data := 'Error in request.';
  if (not self.WaitForAsyncAnswer(data)) then
  begin
    exit;
  end;

  try
    xml := TXMLDocument.Create(nil);
    xml.Options := [];
    xml.XML.Add(self.AsyncDbgpCall.XMLData);
    xml.Active := true;

    Result := self.CheckForError(xml.ChildNodes);
    if (Result = '') then
      self.ProcessProperty(xml.ChildNodes[1].ChildNodes, list)
    else
      list[0].data := Result;
  finally
    if (xml<>nil) then xml.Active := false;
    xml := nil;
  end;
end;

function TDbgpWinSocket.SetFeatureAsync(FeatureName,
  Value: String): boolean;
var
  xml: IXMLDocument;
begin
  self.SetFeature(FeatureName, Value);
  Result := false;
  if (not self.WaitForAsyncAnswer(FeatureName)) then
  begin
    exit;
  end;

  try
    xml := TXMLDocument.Create(nil);
    xml.Options := [];
    xml.XML.Add(self.AsyncDbgpCall.XMLData);
    xml.Active := true;

    if (xml.ChildNodes[1].Attributes['feature'] = FeatureName) and
       (xml.ChildNodes[1].Attributes['success'] = '1') then
      Result := true;
  finally
    if (xml<>nil) then xml.Active := false;
    xml := nil;
  end;
end;

function TDbgpWinSocket.GetFeatureAsync(FeatureName: String;
  var Value: String): boolean;
var
  xml: IXMLDocument;
begin
  self.GetFeature(FeatureName);
  Result := false;
  Value := '';
  if (not self.WaitForAsyncAnswer(FeatureName)) then
  begin
    exit;
  end;

  try
    xml := TXMLDocument.Create(nil);
    xml.Options := [];
    xml.XML.Add(self.AsyncDbgpCall.XMLData);
    xml.Active := true;

    if (xml.ChildNodes[1].Attributes['feature_name'] = FeatureName) and
       (xml.ChildNodes[1].Attributes['supported'] = '1') then
      Result := true;
    if (xml.ChildNodes[1].HasChildNodes) and (xml.ChildNodes[1].ChildNodes[0]<>nil) then
      Value := xml.ChildNodes[1].ChildNodes[0].Text;
  finally
    if (xml<>nil) then xml.Active := false;
    xml := nil;
  end;
end;

function TDbgpWinSocket.GetFeatureAsync(FeatureName: String): boolean;
var
  s: string;
begin
  Result := self.GetFeatureAsync(FeatureName, s);
end;

end.

