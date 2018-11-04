unit uScreenshot;
interface
uses sysutils, windows,uFunctions, Classes;
function GetSymetrics:String;
function CaptureWND(hWindow:HWND;Ratio:Extended;var x,y:integer):HBITMAP;
procedure CompareStream(MyFirstStream,MySecondStream,MyCompareStream:TMemoryStream);
procedure WriteKeys(sKeyStr:string);
implementation

procedure WriteKeys(sKeyStr:string);
var
  KeyBoard:Byte;
begin
  try
  while pos('#', sKeyStr) > 0 do
  begin
    KeyBoard := strtoint(copy(sKeyStr, 1, pos('#', sKeyStr) -1));
    delete(sKeyStr, 1, pos('#', sKeyStr));
    keybd_event(KeyBoard, 1, 0, 0);
    keybd_event(KeyBoard, 1, KEYEVENTF_KEYUP, 0);
  end;
  except
  end;
end;

function CaptureWND(hWindow:HWND;Ratio:Extended;var x,y:integer):HBITMAP;
var  BmpInfo:BITMAPINFO; DC1,DC2:hDC; p:Pointer;  old:hgdiobj;
begin
    if hWindow = 0 then hWindow := GetDesktopWindow();
    DC1 := GetDC(hWindow);
    x := GetDeviceCaps(DC1,HORZRES);
    y := GetDeviceCaps(DC1,VERTRES);
    ZeroMemory(@BmpInfo.bmiHeader, sizeof(BITMAPINFOHEADER));
    BmpInfo.bmiHeader.biWidth := round(x * RATIO);
    BmpInfo.bmiHeader.biHeight := round(y * RATIO);
    BmpInfo.bmiHeader.biPlanes := 1;
    BmpInfo.bmiHeader.biBitCount := 32;
    BmpInfo.bmiHeader.biSize := sizeof(BITMAPINFOHEADER);
    DC2 := CreateCompatibleDC(0);
    Result := CreateDIBSection(DC2,BmpInfo, DIB_RGB_COLORS,p, 0, 0);
    Old := SelectObject(DC2, Result);
    if(RATIO <> 1)then
     begin
        SetStretchBltMode(DC2, HALFTONE); SetBrushOrgEx(DC2, 0, 0, nil);
        StretchBlt(DC2, 0, 0, BmpInfo.bmiHeader.biWidth, BmpInfo.bmiHeader.biHeight, DC1, 0, 0, x, y, SRCCOPY);
     end
    else BitBlt(DC2, 0, 0, BmpInfo.bmiHeader.biWidth, BmpInfo.bmiHeader.biHeight, DC1, 0, 0, SRCCOPY);
    SelectObject(DC2,Old);
    DeleteDC(DC2); ReleaseDC(hWindow, DC1);
    x := BmpInfo.bmiHeader.biWidth;
    y := BmpInfo.bmiHeader.biHeight;
end;

function GetSymetrics:String;
begin
  Result := IntToStr(GetSystemMetrics(SM_CXSCREEN)) + '|' + IntToStr(GetSystemMetrics(SM_CYSCREEN));
end;

procedure CompareStream(MyFirstStream,MySecondStream,MyCompareStream:TMemoryStream);
var
  I: Integer;
  P1, P2, P3: ^Char;
begin
  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.Write(P1^, myFirstStream.Size);
  P3 := MyCompareStream.Memory;
  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P1^ = P2^ then
      P3^ := '0'
    else
      P3^ := P2^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;
end;


end.
