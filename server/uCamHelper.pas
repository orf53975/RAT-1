unit uCamHelper;

interface

uses
  Windows, SysUtils, Classes, Graphics,
  VFrames;

type
  TCamHelper = class
    constructor Create;
    destructor Destroy; override;
  private
    Vid : TVideoImage;
    FCamNumber, FCamCount: Integer;
    FStarted: Boolean;
  public
    function StartCam(CamNumber: Integer; Resolution: Integer = 0): Boolean;
    function SetResolution(Resolution: Integer): Boolean;
    procedure StopCam;
    function GetImage(BMP: TBitmap; Timeout: Cardinal = INFINITE): Boolean;
    function GetCams: String;
    function GetResolutions(CamNumber: Integer): String;
    function GetFullList: String;
    property Started: Boolean read FStarted;
    property CamNumber: Integer read FCamCount;
    property CamCount: Integer read FCamCount;
  end;

var
  CamHelper: TCamHelper;

implementation

procedure CreateSceenshot(var Bitmap: TBitmap; Rect: TRect); overload;
var DC: THandle;
begin
  if Assigned(Bitmap) then
  begin
    DC := GetDC(0);
    try
      with Bitmap do
      begin
        Width := Rect.Right - Rect.Left;
        Height:= Rect.Bottom - Rect.Top;
        BitBlt(Canvas.Handle,
                Rect.Left, // X
                Rect.Top, // Y
                Width, // Width
                Height, // Height
                DC, 0, 0, SrcCopy);
      end;
    finally
      ReleaseDC(0, DC);
    end;
  end;
end;

procedure CreateSceenshot(var Bitmap: TBitmap); overload;
var Rect: TRect;
begin
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := GetSystemMetrics(SM_CXSCREEN);
  Rect.Bottom := GetSystemMetrics(SM_CYSCREEN);
  CreateSceenshot(Bitmap, Rect);
end;

constructor TCamHelper.Create;
begin
  FCamNumber := 0;

  Vid := TVideoImage.Create;
end;

function TCamHelper.StartCam(CamNumber: Integer; Resolution: Integer = 0): Boolean;
begin
  Result := False;
  if Started and (FCamNumber = CamNumber) then Exit;
  StopCam;
  if CamNumber = 0 then
  begin
    FStarted := True;
  end
  else
  begin
    FStarted := Vid.VideoStart('#'+IntToStr(CamNumber), Resolution - 1);
  end;
  if Started then
  begin
    FCamNumber := CamNumber;
  end;
  Result := Started;
end;

function TCamHelper.GetImage(BMP: TBitmap; Timeout: Cardinal = INFINITE): Boolean;
begin
  Result := False;
  if not Started then Exit;
  if FCamNumber = 0 then
  begin
    CreateSceenshot(BMP);
    Result := True;
  end
  else if Vid.HasNewFrame(1000) and FStarted then
    Result := Vid.GetBitmap(BMP);
end;

function TCamHelper.SetResolution(Resolution: Integer): Boolean;
begin
  if Started and (FCamNumber > 0) then
    Result := Vid.SetResolutionByIndex(Resolution - 1)
  else Result := False;
end;

procedure TCamHelper.StopCam;
begin
  if Vid.VideoRunning then Vid.VideoStop;
  FStarted := False;
end;

function TCamHelper.GetCams: String;
var SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    Vid.GetListOfDevices(SL);
    FCamCount := SL.Count;
    SL.Delimiter := '|';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

function TCamHelper.GetResolutions(CamNumber: Integer): String;
var SL: TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    if CamNumber = 0 then
      SL.Add(Format('%dx%d (RGB)', [GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN)]))
    else
      Vid.GetListOfSupportedVideoSizes('#'+IntToStr(CamNumber), SL);
    SL.Delimiter := '#';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

function TCamHelper.GetFullList: String;
var
  SL: TStringList;
  I: Integer;
begin
  Result := '';
  SL := TStringList.Create;
  try
    SL.Add(GetCams);
    for I := 0 to FCamCount - 1 do
      SL.Add(GetResolutions(I));
    SL.Delimiter := '#';
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

destructor TCamHelper.Destroy;
begin
  Vid.Free;
end;

end.
