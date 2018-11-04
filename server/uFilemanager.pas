unit uFilemanager;
interface
uses sysutils, windows, shellapi, uFunctions;

function GetDrives: string;
function ListFileDir(Path: string; enumDirs:Boolean):String;
Function DelTree(DirName : string): Boolean;

implementation
//Taken from delphi.about.com
Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..255] of char;
begin
  try
    Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
    FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
    StrPCopy(DirBuf, DirName) ;
    with SHFileOpStruct do begin
      Wnd := 0;
      pFrom := @DirBuf;
      wFunc := FO_DELETE;
      fFlags := FOF_ALLOWUNDO;
      fFlags := fFlags or FOF_NOCONFIRMATION;
      fFlags := fFlags or FOF_SILENT;
    end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
  except
    Result := False;
  end;
end;

function GetFileType(sFileName: String): String;
var
  FileInfo: TSHFileInfo;
begin
  FillChar(FileInfo, SizeOf(FileInfo), #0);
  SHGetFileInfo(PChar(sFileName), 0, FileInfo, SizeOf(FileInfo),SHGFI_TYPENAME);
  Result := FileInfo.szTypeName;
end;

function FindMatchingFile(var F: TSearchRec): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;

function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
  end else
    Result := GetLastError;
end;

function FindNext(var F: TSearchRec): Integer;
begin
  if FindNextFile(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F) else
    Result := GetLastError;
end;

function ListFileDir(Path: string; enumDirs:Boolean):String;
var
  SR: TSearchRec;
  sTemp:string;
begin
  Result := '';
  If (Path = '') Then Exit;
  If (Path[Length(Path)] <> '\') Then Path := Path + '\';
  if FindFirst(Path + '*.*', faAnyFile, SR) = 0 then
  begin
    repeat
      if enumDirs then begin
        if ((SR.Attr And faDirectory) = faDirectory) then
          If (SR.Name <> '..') and (SR.Name <> '.') then
            Result := Result + SR.Name + '#' + '-|';
      end else begin
        if ((SR.Attr And faDirectory) <> faDirectory) then begin
          sTemp := GetFileType(Path + SR.Name);
          Result := Result + SR.Name + '#' + sTemp + '#' + Inttostr(SR.Size) + '|';
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end else
    Result := 'Error';
end;

function GetDrives: string;
var
  r: LongWord;
  Drives: array[0..128] of char;
  pDrive: pchar;
begin
  Result := '';
  r := GetLogicalDriveStrings(sizeof(Drives), Drives);
  if r = 0 then exit;
  pDrive := Drives;

  while pDrive^ <> #0 do begin
    result := result + pdrive;
    case GetDriveType(pdrive) of
      DRIVE_REMOVABLE:Result := Result + '#2|';
      DRIVE_FIXED:Result := Result + '#1|';
      DRIVE_REMOTE:Result := Result + '#3|';
      DRIVE_CDROM:Result := Result + '#4|';
    else Result := Result + '#1|';
    end;
    inc(pDrive, 4);
  end;
end;
end.
