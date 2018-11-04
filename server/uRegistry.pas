unit uRegistry;

interface
uses windows, uFunctions, sysutils;

function ListKeys(Clave: String): String;
function ListValues(Clave: String): String;
function AddRegValue(RegKey, RegValue, RegType: String):Boolean;
function DeleteRegKey(sRegKey: String):boolean;
function RenameRegistryItem(Old, New: String): boolean;

implementation
function ToKey(Clave: String):HKEY;
begin
  if Clave='HKEY_CLASSES_ROOT' then
    Result:=HKEY_CLASSES_ROOT
  else if Clave='HKEY_CURRENT_CONFIG' then
    Result:=HKEY_CURRENT_CONFIG
  else if Clave='HKEY_CURRENT_USER' then
    Result:=HKEY_CURRENT_USER
  else if Clave='HKEY_LOCAL_MACHINE' then
    Result:=HKEY_LOCAL_MACHINE
  else if Clave='HKEY_USERS' then
    Result:=HKEY_USERS
  else
    Result:=0;
end;

function ListValues(Clave: String): String;
var
  phkResult: HKEY;
  dwIndex, lpcbValueName,lpcbData: Cardinal;
  lpData: PChar;
  lpType: DWORD;
  lpValueName: PChar;
  strTipo, strDatos, Nombre: String;
  j, Resultado: integer;
  DValue: PDWORD;
  Temp:string;
begin
  Result := '';
  if RegOpenKeyEx(ToKey(Copy(Clave, 1, Pos('\', Clave) - 1)),PChar(Copy(Clave, Pos('\', Clave) + 1, Length(Clave))),0, KEY_QUERY_VALUE, phkResult) <> ERROR_SUCCESS then exit;
  dwIndex := 0;
  GetMem(lpValueName,16383);
  Resultado := ERROR_SUCCESS;
  while (Resultado = ERROR_SUCCESS) do
  begin
    Resultado := RegEnumValue(phkResult, dwIndex, lpValueName, lpcbValueName, nil, @lpType, nil, @lpcbData);
    GetMem(lpData,lpcbData);
    lpcbValueName := 16383;
    Resultado := RegEnumValue(phkResult, dwIndex, lpValueName, lpcbValueName, nil, @lpType, PByte(lpData), @lpcbData);
    if Resultado = ERROR_SUCCESS then
    begin
      strDatos := '';
      if lpType = REG_DWORD  then
      begin
        DValue := PDWORD(lpData);
        strDatos := '0x'+ IntToHex(DValue^, 8) + ' (' + IntToStr(DValue^) + ')'; //0xHexValue (IntValue)
      end
      else
        if lpType = REG_BINARY then
        begin
          if lpcbData = 0 then
            strDatos := '(No Data)'
          else
            for j := 0 to lpcbData - 1 do
              strDatos:=strDatos + IntToHex(Ord(lpData[j]), 2) + ' ';
        end
        else
          if lpType = REG_MULTI_SZ then
          begin
            for j := 0 to lpcbData - 1 do
              if lpData[j] = #0 then
                lpData[j] := ' ';
            strDatos := lpData;
          end
          else
            strDatos := lpData;
      if lpValueName[0] = #0 then
        Nombre := '(End)'
      else
        Nombre := lpValueName;
      case lpType of
        REG_BINARY: strTipo := 'REG_BINARY';
        REG_DWORD: strTipo := 'REG_DWORD';
        REG_DWORD_BIG_ENDIAN: strTipo := 'REG_DWORD_BIG_ENDIAN';
        REG_EXPAND_SZ: strTipo := 'REG_EXPAND_SZ';
        REG_LINK: strTipo := 'REG_LINK';
        REG_MULTI_SZ: strTipo := 'REG_MULTI_SZ';
        REG_NONE: strTipo := 'REG_NONE';
        REG_SZ: strTipo := 'REG_SZ';
      end;
      if strDatos = '' then strdatos := ' ';
      Temp := Temp + '|' + Nombre + '#' + strTipo + '#' + strDatos;
      Inc(dwIndex);
    end;
    FreeMem(lpData);
  end;
  If Temp <> '' then
    Result := Temp;
  FreeMem(lpValueName);
  RegCloseKey(phkResult);
end;

function ListKeys(Clave: String): String;
var
  phkResult: HKEY;
  lpName: PChar;
  lpcbName, dwIndex: Cardinal;
  lpftLastWriteTime: FileTime;
  Temp:string;
begin
  Temp := '';
  RegOpenKeyEx(ToKey(Copy(Clave, 1, Pos('\', Clave) - 1)),PChar(Copy(Clave, Pos('\', Clave) + 1, Length(Clave))), 0,KEY_ENUMERATE_SUB_KEYS,phkResult);
  lpcbName := 255;
  GetMem(lpName, lpcbName);
  dwIndex := 0;
  while RegEnumKeyEx(phkResult, dwIndex, @lpName[0] , lpcbName, nil, nil, nil, @lpftLastWriteTime) = ERROR_SUCCESS do
  begin
    temp := temp + lpName + '|';
    Inc(dwIndex);
    lpcbName := 255;
  end;
  Result := temp;
  RegCloseKey(phkResult);
end;

function LastDelimiter(S: String; Delimiter: Char): Integer;
var
  i: Integer;
begin
  Result := -1;
  i := Length(S);
  if (S = '') or (i = 0) then
    Exit;
  while S[i] <> Delimiter do
  begin
    if i < 0 then
      break;
    dec(i);
  end;
  Result := i;
end;

function UpperString(S: String): String;
var
  i: Integer;
begin
  for i := 1 to Length(S) do
    S[i] := char(CharUpper(PChar(S[i])));
  Result := S;
end;

function HexToInt(s: string): longword;
var
  b: byte;
  c: char;
begin
  Result := 0;
  s      := UpperString(s);
  for b := 1 to Length(s) do
  begin
    Result := Result * 16;
    c      := s[b];
    case c of
      '0'..'9': Inc(Result, Ord(c) - Ord('0'));
      'A'..'F': Inc(Result, Ord(c) - Ord('A') + 10);
      else
        result := 0;
    end;
  end;
end;

function AddRegValue(RegKey, RegValue, RegType: String):Boolean;
var
  phkResult: hkey;
  strRegPath, strRoot: String;
  Cadena: String;
  bArrBinary: Array of Byte;
  i: integer;
begin
  result := false;

  strRoot := Copy(RegKey, 1, Pos('\', RegKey) - 1);
  Delete(RegKey, 1, Pos('\', RegKey));

  strRegPath := Copy(RegKey, LastDelimiter(RegKey, '\') + 1, Length(RegKey));
  Delete(RegKey, LastDelimiter(RegKey, '\'), Length(RegKey));

  if RegType = 'Key' then
  begin
    RegOpenKeyEx(ToKey(strRoot), PChar(RegKey), 0, KEY_CREATE_SUB_KEY, phkResult);
    Result := (RegCreateKey(phkResult, PChar(strRegPath), phkResult) = ERROR_SUCCESS);
    RegCloseKey(phkResult);
    Exit;
  end;
  if RegOpenKeyEx(ToKey(strRoot), PChar(RegKey), 0, KEY_SET_VALUE, phkResult) = ERROR_SUCCESS then
  begin
    if RegType = 'REG_SZ' then
      Result := (RegSetValueEx(phkResult, Pchar(strRegPath), 0, REG_SZ, Pchar(RegValue), Length(RegValue)) = ERROR_SUCCESS);
    if RegType = 'REG_BINARY' then
    begin
      if RegValue[Length(RegValue)] <> ' ' then
        RegValue := RegValue + ' ';
      Cadena := RegValue;
      i := 0;
      SetLength(bArrBinary, Length(Cadena) div 3);
      while Cadena <> '' do
      begin
        bArrBinary[i] := HexToInt(Copy(Cadena, 0, Pos(' ', Cadena) - 1));
        Delete(Cadena, 1, Pos(' ', Cadena) + 1);
        inc(i);
      end;
      Result := (RegSetValueEx(phkResult, Pchar(strRegPath), 0, REG_BINARY, @bArrBinary[0], Length(bArrBinary)) = ERROR_SUCCESS);
    end;
    if RegType = 'REG_DWORD' then begin
      i := StrToInt(RegValue);
      Result := (RegSetValueEx(phkResult, Pchar(strRegPath), 0, REG_DWORD, @i, sizeof(i)) = ERROR_SUCCESS);
    end;
    if RegType = 'REG_MULTI_SZ' then begin
      while Pos(#13#10, RegValue) > 0 do
        RegValue:=Copy(RegValue, 1, Pos(#13#10, RegValue) - 1) + #0+
                  Copy(RegValue, Pos(#13#10, RegValue) + 2, Length(RegValue));
      RegValue := RegValue + #0#0;
      Result := (RegSetValueEx(phkResult, Pchar(strRegPath), 0, REG_MULTI_SZ, PChar(RegValue), Length(RegValue)) = ERROR_SUCCESS);
    end;
    RegCloseKey(phkResult);
  end
  else
    Result := False;
end;

function DeleteRegKey(sRegKey: String):boolean;
var
  phkResult: hkey;
  strTempKey, strValue, strRoot, strSubKeys: String;
begin
  result := false;
  strTempKey := sRegKey;
  strRoot := Copy(strTempKey, 1, Pos('\', strTempKey) - 1);
  Delete(strTempKey, 1, Pos('\', strTempKey));
  if strTempKey[Length(strTempKey)]='\' then
  begin
    strTempKey:=Copy(strTempKey, 1, Length(strTempKey) - 1);
    strValue := Copy(strTempKey, LastDelimiter(strTempKey, '\') + 1, Length(strTempKey));
    Delete(strTempKey, LastDelimiter(strTempKey, '\'), Length(strTempKey));
    RegOpenKeyEx(ToKey(strRoot), PChar(strTempKey), 0, KEY_WRITE, phkResult);
    if ListKeys(sRegKey) = '' then
      Result := (RegDeleteKey(phkResult, PChar(strValue)) = ERROR_SUCCESS)
    else
    begin
      strSubKeys := ListKeys(sRegKey);
      while Pos('|', strSubKeys)>0 do
      begin
        Result := DeleteRegKey(sRegKey + Copy(strSubKeys, 1, Pos('|', strSubKeys) - 1) + '\');
        if Result = False then break;
        Delete(strSubKeys, 1, Pos('|', strSubKeys));
      end;
      Result := (RegDeleteKey(phkResult, PChar(strValue)) = ERROR_SUCCESS)
    end;
  end
  else
  begin
    strValue:=Copy(strTempKey, LastDelimiter(strTempKey, '\') + 1, Length(strTempKey));
    Delete(strTempKey, LastDelimiter(strTempKey, '\'), Length(strTempKey));
    RegOpenKeyEx(ToKey(strRoot), PChar(strTempKey), 0, KEY_SET_VALUE, phkResult);
    Result := (RegDeleteValue(phkResult, PChar(strValue)) = ERROR_SUCCESS);
  end;
  RegCloseKey(phkResult);
end;

function AllocMem(Size: Cardinal): Pointer;
begin
  GetMem(Result, Size);
  FillChar(Result^, Size, 0);
end;

function CopyRegistryKey(Source, Dest: HKEY): boolean;
const DefValueSize  = 512;
      DefBufferSize = 8192;
var Status      : Integer;
    Key         : Integer;
    ValueSize,
    BufferSize  : Cardinal;
    KeyType     : Integer;
    ValueName   : String;
    Buffer      : Pointer;
    NewTo,
    NewFrom     : HKEY;
begin
  result := false;
  SetLength(ValueName,DefValueSize);
  Buffer := AllocMem(DefBufferSize);
  try
    Key := 0;
    repeat
      ValueSize := DefValueSize;
      BufferSize := DefBufferSize;
      Status := RegEnumValue(Source,Key,PChar(ValueName),ValueSize,nil,@KeyType,Buffer,@BufferSize);
      if Status = ERROR_SUCCESS then
      begin
        Status := RegSetValueEx(Dest,PChar(ValueName),0,KeyType,Buffer,BufferSize);
        RegDeleteValue(Source,PChar(ValueName));
      end;
    until Status <> ERROR_SUCCESS;

    Key := 0;
    repeat
      ValueSize := DefValueSize;
      BufferSize := DefBufferSize;
      Status := RegEnumKeyEx(Source,Key,PChar(ValueName),ValueSize,nil,Buffer,@BufferSize,nil);
      if Status = ERROR_SUCCESS then
      begin
        Status := RegCreateKey(Dest,PChar(ValueName),NewTo);
        if Status = ERROR_SUCCESS then
        begin
          Status := RegCreateKey(Source,PChar(ValueName),NewFrom);
          if Status = ERROR_SUCCESS then
          begin
            CopyRegistryKey(NewFrom,NewTo);
            RegCloseKey(NewFrom);
            RegDeleteKey(Source,PChar(ValueName));
          end;
          RegCloseKey(NewTo);
        end;
      end;
    until Status <> ERROR_SUCCESS;
  finally
    FreeMem(Buffer);
  end;
end;

function RegKeyExists(const RootKey: HKEY; Key: String): Boolean;
var Handle : HKEY;
begin
  if RegOpenKeyEx(RootKey, PChar(Key), 0, KEY_ENUMERATE_SUB_KEYS, Handle) = ERROR_SUCCESS then
    begin
      Result := True;
      RegCloseKey(Handle);
    end else
    Result := False;
end;

procedure RenRegItem(AKey: HKEY; Old, New: String);
var
  OldKey,
  NewKey  : HKEY;
  Status  : Integer;
begin
  Status := RegOpenKey(AKey,PChar(Old),OldKey);
  if Status = ERROR_SUCCESS then
  begin
    Status := RegCreateKey(AKey,PChar(New),NewKey);
    if Status = ERROR_SUCCESS then CopyRegistryKey(OldKey,NewKey);
    RegCloseKey(OldKey);
    RegCloseKey(NewKey);
    RegDeleteKey(AKey,PChar(Old));
  end;
end;

function RenameRegistryItem(Old, New: String): boolean;
var
  AKey  : HKEY;
  ClaveBase: string;
begin
  ClaveBase := Copy(Old, 1, Pos('\', Old) - 1);
  AKey := ToKey(ClaveBase);
  delete(new, 1, pos('\', new));
  delete(Old, 1, pos('\', Old));
  if RegKeyExists(AKey, New) = true then
  begin
    result := false;
    exit;
  end;
  RenRegItem(AKey, old, new);
  if RegKeyExists(AKey, old) = true then
  begin
    result := false;
    exit;
  end;
  result := RegKeyExists(AKey, new);
end;

end.
