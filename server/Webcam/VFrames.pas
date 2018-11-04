unit VFrames;

(******************************************************************************

  VFrames.pas
  Class TVideoImage

About
  The TVideoImage class provides a simplified access to the class TVideoSample
  from source unit VSample.pas.
  It is used to access WebCams and similar Video-capture devices via DirectShow.
  Its focus is on acquiring single images (frames) from the running video stream
  sent by the cameras. There exist methods to control properties (e.g. size,
  brightness etc.)
  Acquisition is fast enough to simulate running video.
  No audio support.

History
  Version 1.4
    Added support for YUY2 (YUYV, YUNV), MJPG,  I420 (YV12, IYUV)

  Version 1.3
  07.09.2008
    Added Video-Size and Video-property control
    Added check for extreme CPU load

  Version 1.2
  30.08.2008
    Added Pause and Resume
    
  Version 1.1
  26.07.2008

Contact:
  michael@grizzlymotion.com

Copyright
  For copyrights of the DirectX Header ports see the original source files.
  Other code (unless stated otherwise, see comments): Copyright (C) M. Braun

Licence:
  The lion share of this project lies within the ports of the DirectX header
  files (which are under the Mozilla Public License Version 1.1), and the
  original SDK sample files from Microsoft (END-USER LICENSE AGREEMENT FOR
  MICROSOFT SOFTWARE DirectX 9.0 Software Development Kit Update (Summer 2003))

  My own contribution compared to that work is very small (although it cost me
  lots of time), but still is "significant enough" to fulfill Microsofts licence
  agreement ;)
  So I think, the ZLib licence (http://www.zlib.net/zlib_license.html)
  should be sufficient for my code contributions.

Please note:
  There exist much more complete alternatives (incl. sound, AVI etc.):
  - DSPack (http://www.progdigy.com/)
  - TVideoCapture by Egor Averchenkov (can be found at http://www.torry.net)


******************************************************************************)

interface


USES Windows, Messages, SysUtils,fForms, Graphics, Classes,
//     DirectShow9, Controls,
     MMSystem, JPEG, VSample, SyncObjs;

CONST
  VID_DEF_BUFF_SIZE = 1;

TYPE
  TBufferImage = record
      Data: Pointer;
      Size, W, H: Integer;
      FourCC: Cardinal;
      Bitmap: TBitmap;
      Unpacked: Boolean;
      Mutex: TCriticalSection;
    end;
  TNewVideoFrameEvent = procedure(Sender: TObject; const Image: TBufferImage) of object;
  TVideoProperty = (VP_Brightness,
                    VP_Contrast,
                    VP_Hue,
                    VP_Saturation,
                    VP_Sharpness,
                    VP_Gamma,
                    VP_ColorEnable,
                    VP_WhiteBalance,
                    VP_BacklightCompensation,
                    VP_Gain);
  TVideoImage = class
                  private
                    VideoSample   : TVideoSample;
                    OnNewFrameBusy: boolean;
                    fVideoRunning : boolean;
                    fBusy         : boolean;
                    fForceRGB     : boolean;
                   // fSkipCnt      : integer;
                    fFrameCnt     : integer;
                   // f30FrameTick  : cardinal;
                    fFPS          : double;  // "Real" fps, even if not all frames will be displayed.
                    fWidth,
                    fHeight       : integer;
                    fFourCC       : cardinal;
                    fDisplayCanvas: TCanvas;
                    fImage        : ARRAY OF TBufferImage; // Local copy of image data
                    fImagePtrIndex: integer;
                    fBufferSize   : Cardinal;
                    fMessageHWND  : HWND;
                    fMsgNewFrame  : uint;
                    fOnNewFrame   : TNewVideoFrameEvent;
                    fDeviceName   : String;
                   // AppEvent      : TApplicationEvents;
                   // IdleEventTick : cardinal;
                    ValueY_298,
                    ValueU_100,
                    ValueU_516,
                    ValueV_409,
                    ValueV_208    : ARRAY[byte] OF integer;
                    ValueClip     : ARRAY[-1023..1023] OF byte;
                    fYUY2TablesPrepared : boolean;
                    JPG           : TJPEGImage;
                    MemStream     : TMemoryStream;
                    NewFrameEvent : TEvent;
                    procedure     PaintFrame;
                    procedure     UnpackFrame(var image: TBufferImage);
                    procedure     WndProc(var Msg: TMessage);
                    function      VideoSampleIsPaused: boolean;
                 //   procedure     AppEventsIdle(Sender: TObject; var Done: Boolean);
                    procedure     CallBack(NewData: PByteArray; var NewSize: Integer);
//                    function      TranslateProperty(const VP: TVideoProperty; VAR VPAP: TVideoProcAmpProperty): HResult;
                    PROCEDURE     PrepareTables;
                    procedure     YUY2_to_RGB(pData: pointer; Bitmap: TBitmap);
                    procedure     I420_to_RGB(pData: pointer; Bitmap: TBitmap);
                    procedure     ClearBuffer;
                  public
                    constructor   Create; overload;
                    constructor   Create(BufferSize: Cardinal); overload;
                    destructor    Destroy; override;
                    function      VideoStart(DeviceName: string; Resolution: Integer = -1): Boolean;
                    property      VideoRunning : boolean read fVideoRunning;
                    procedure     VideoPause;
                    property      IsPaused: boolean read VideoSampleIsPaused;
                    procedure     VideoResume;
                    procedure     VideoStop;
                    property      VideoWidth: integer read fWidth;
                    property      VideoHeight: integer read fHeight;
                    property      OnNewVideoFrame : TNewVideoFrameEvent read fOnNewFrame write fOnNewFrame;
                    function      HasNewFrame(TimeOut: Cardinal): Boolean;
                    function      GetBitmap(BMP: TBitmap): Boolean; overload;
                    function      GetBitmap(BMP: TBitmap; Index: Cardinal): Boolean; overload;
                    procedure     GetListOfDevices(DeviceList: TStringList);
                    PROCEDURE     GetListOfSupportedVideoSizes(VidSize: TStringList); overload;
                    function      GetListOfSupportedVideoSizes(DeviceName: String; VidSize: TStringList): Boolean; overload;
                    function      SetResolutionByIndex(Index: integer): Boolean;
                    property      FramesPerSecond: double read fFPS;
                  //  property      FramesSkipped: integer read fSkipCnt;
                    procedure     SetDisplayCanvas(Canvas: TCanvas);
                    property      ImageIndex: Integer read fImagePtrIndex;
                    property      BufferSize: Cardinal read fBufferSize;
                    procedure     ShowProperty;
                    procedure     ShowProperty_Stream;
                    {FUNCTION      ShowVfWCaptureDlg: HResult;
                    procedure     GetBrightnessSettings(VAR Actual: integer);
                    procedure     SetBrightnessSettings(const Actual: integer);
                    FUNCTION      GetVideoPropertySettings(    VP                : TVideoProperty;
                                                           VAR MinVal, MaxVal,
                                                               StepSize, Default,
                                                               Actual            : integer;
                                                           VAR AutoMode: boolean): HResult;
                    FUNCTION      SetVideoPropertySettings(VP: TVideoProperty; Actual: integer; AutoMode: boolean): HResult;}
                end;



//FUNCTION GetVideoPropertyName(VP: TVideoProperty): string;


// http://www.fourcc.org/yuv.php#UYVY

implementation



{FUNCTION GetVideoPropertyName(VP: TVideoProperty): string;
BEGIN
  CASE VP OF
    VP_Brightness           : Result := 'Brightness';
    VP_Contrast             : Result := 'Contrast';
    VP_Hue                  : Result := 'Hue';
    VP_Saturation           : Result := 'Saturation';
    VP_Sharpness            : Result := 'Sharpness';
    VP_Gamma                : Result := 'Gamma';
    VP_ColorEnable          : Result := 'ColorEnable';
    VP_WhiteBalance         : Result := 'WhiteBalance';
    VP_BacklightCompensation: Result := 'Backlight';
    VP_Gain                 : Result := 'Gain';
  END;
END;  }



(* Finally, callback seems to work. Previously it only ran for a few seconds.
   The reason for that seemed to be a deadlock (see http://msdn.microsoft.com/en-us/library/ms786692(VS.85).aspx)
   Now the image data is copied immediatly, and a message is sent to invoke the
   display of the data. *)
procedure TVideoImage.CallBack(NewData: PByteArray; var NewSize: Integer);
var
  i  : integer;
//  T1 : cardinal;
begin
  // Adjust pointer to image data if necessary
  i := Cardinal(fImagePtrIndex+1) mod fBufferSize;
  fImage[i].Mutex.Acquire;
  try
    Inc(fFrameCnt);

    // Calculate "Frames per second"...
{    T1 := TimeGetTime;
    if fFrameCnt mod 30 = 0 then
    begin
      if f30FrameTick > 0 then
        fFPS := 30000 / (T1-f30FrameTick);
      f30FrameTick := T1;
    end;}

    // Does the application run in unhealthy CPU usage?
    // Check, if no idle event has occured for at least 1 sec.
    // If so, skip current frame and give application time to "breathe".
{    if Abs(T1-IdleEventTick) > 1000 then
    begin
      Inc(fSkipCnt);
      exit;
    end;}

    with fImage[i] do
    begin
      if NewSize <> Size then
      begin
        Size := NewSize;
        ReallocMem(Data, Size);
      end;
      // Save image data to local memory
      W := fWidth;
      H := fHeight;
      if fForceRGB then FourCC := 0
      else FourCC := fFourCC;
      Unpacked := False;
      Move(NewData^, Data^, Size);
    end;
    fImagePtrIndex := i;

    NewFrameEvent.SetEvent;
  finally
    fImage[i].Mutex.Release;
  end;
  // This routine is called by the video software and therefore runs within their thread.
  // Posting a message to our own HWND will transport the information to the main thread.
  if Assigned(fDisplayCanvas) or Assigned(fOnNewFrame) then
    PostMessage(fMessageHWND, fMsgNewFrame, NewSize, Integer(fImage[i].Data));
  //sleep(0);
end;



// Own windows message handler only to get the "New Video Frame has arrived" message.
// Used to get the information out of the Camera-Thread into the application's thread.
// Otherwise we would run into a deadlock.
procedure TVideoImage.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = fMsgNewFrame then
      try
        IF not fBusy then
          begin
            fBusy := true;
            PaintFrame; // If a Display-Canvas has been set, paint video image on it.
            IF assigned(fOnNewFrame) then
              fOnNewFrame(self, fImage[fImagePtrIndex]);
            fBusy := false;
          end
        //  else Inc(fSkipCnt);
      except
        Application.HandleException(Self);
        fBusy := false;
      end
    else
      Result := DefWindowProc(fMessageHWND, Msg, wParam, lParam);
end;



procedure TVideoImage.ClearBuffer;
var I: Integer;
begin
  for I := 0 to fBufferSize - 1 do
  with fImage[I] do
  begin
    if (Size > 0) and Assigned(Data) then FreeMem(Data, Size);
    if Assigned(Bitmap) then Bitmap.Free;
    if Assigned(Mutex) then Mutex.Free;
    Mutex := TCriticalSection.Create;
    Data := nil;
    Size := 0;
    Bitmap := nil;
    W := 0;
    H := 0;
    Unpacked := False;
  end;
end;

constructor TVideoImage.Create(BufferSize: Cardinal);
begin
  inherited Create;
  fVideoRunning   := false;
  OnNewFrameBusy  := false;
  fDisplayCanvas  := nil;
  fWidth          := 0;
  fHeight         := 0;
  fFourCC         := 0;
  if BufferSize < 1 then BufferSize := 1;
  fBufferSize     := BufferSize;
  SetLength(fImage, BufferSize);
  ClearBuffer;
  fMsgNewFrame    := wm_user+662;
  fOnNewFrame     := nil;
  fBusy           := false;
  // Create a HWND that can capture some messages for us...
  fMessageHWND    := AllocateHWND(WndProc);
//  AppEvent        := TApplicationEvents.Create(Application.MainForm);
//  AppEvent.OnIdle := AppEventsIdle;
  JPG             := TJPEGImage.Create;
  MemStream       := TMemoryStream.Create;
  NewFrameEvent   := TEvent.Create(nil, False, False, 'NewFrame');
end;

constructor TVideoImage.Create;
begin
  Create(VID_DEF_BUFF_SIZE);
end;



// Check, when the last OnIdle message arrived. Save a time stamp.
// Used to check the CPU load. If necessary, we will skip video frames...
{procedure TVideoImage.AppEventsIdle(Sender: TObject; var Done: Boolean);
begin
  IdleEventTick := TimeGetTime;
  Done := true;
end;}


destructor  TVideoImage.Destroy;
begin
  if fVideoRunning then
    VideoStop;
  NewFrameEvent.Free;
  DeallocateHWnd(fMessageHWND);
//  AppEvent.Free;
  inherited Destroy;
end;


function TVideoImage.HasNewFrame(TimeOut: Cardinal): Boolean;
begin
  Result := NewFrameEvent.WaitFor(TimeOut) = wrSignaled;
end;


// For Properties see also http://msdn.microsoft.com/en-us/library/ms786938(VS.85).aspx
{function TVideoImage.TranslateProperty(const VP: TVideoProperty; VAR VPAP: TVideoProcAmpProperty): HResult;
begin
  Result := S_OK;
  CASE VP OF
    VP_Brightness             : VPAP := VideoProcAmp_Brightness;
    VP_Contrast               : VPAP := VideoProcAmp_Contrast;
    VP_Hue                    : VPAP := VideoProcAmp_Hue;
    VP_Saturation             : VPAP := VideoProcAmp_Saturation;
    VP_Sharpness              : VPAP := VideoProcAmp_Sharpness;
    VP_Gamma                  : VPAP := VideoProcAmp_Gamma;
    VP_ColorEnable            : VPAP := VideoProcAmp_ColorEnable;
    VP_WhiteBalance           : VPAP := VideoProcAmp_WhiteBalance;
    VP_BacklightCompensation  : VPAP := VideoProcAmp_BacklightCompensation;
    VP_Gain                   : VPAP := VideoProcAmp_Gain;
    else Result := S_False;
  END; 
end;   }



{FUNCTION TVideoImage.GetVideoPropertySettings(VP: TVideoProperty; VAR MinVal, MaxVal, StepSize, Default, Actual: integer; VAR AutoMode: boolean): HResult;
VAR
  VPAP       : TVideoProcAmpProperty;
  pCapsFlags : TVideoProcAmpFlags;
BEGIN
  Result   := S_FALSE;
  MinVal   := -1;
  MaxVal   := -1;
  StepSize := 0;
  Default  := 0;
  Actual   := 0;
  AutoMode := true;
  IF not(assigned(VideoSample)) or Failed(TranslateProperty(VP, VPAP)) then
    exit;
  Result := TranslateProperty(VP, VPAP);
  IF Failed(Result) then
    exit;

  Result := VideoSample.GetVideoPropAmpEx(VPAP, MinVal, MaxVal, StepSize, Default, pCapsFlags, Actual);
  IF Failed(Result) then
    begin
      MinVal   := -1;
      MaxVal   := -1;
      StepSize := 0;
      Default  := 0;
      Actual   := 0;
      AutoMode := true;
    end
    else begin
      AutoMode := pCapsFlags <> VideoProcAmp_Flags_Manual;
    end;
END;



FUNCTION TVideoImage.SetVideoPropertySettings(VP: TVideoProperty; Actual: integer; AutoMode: boolean): HResult;
VAR
  VPAP       : TVideoProcAmpProperty;
  pCapsFlags : TVideoProcAmpFlags;
BEGIN
  Result := TranslateProperty(VP, VPAP);
  IF not(assigned(VideoSample)) or Failed(Result) then
    exit;
  IF AutoMode
    then pCapsFlags := VideoProcAmp_Flags_Auto
    else pCapsFlags := VideoProcAmp_Flags_Manual;
  Result := VideoSample.SetVideoPropAmpEx(VPAP, pCapsFlags, Actual);
END;       }


procedure TVideoImage.GetListOfDevices(DeviceList: TStringList);
begin
  GetCaptureDeviceList(DeviceList);
end;


procedure TVideoImage.VideoPause;
begin
  if not assigned(VideoSample) then
    exit;
  VideoSample.PauseVideo;
end;



procedure TVideoImage.VideoResume;
begin
  if not assigned(VideoSample) then
    exit;
  VideoSample.ResumeVideo;
end;



procedure TVideoImage.VideoStop;
begin
  NewFrameEvent.ResetEvent;
  fFPS := 0;
  fDeviceName := '';
  if not assigned(VideoSample) then
    exit;
  try
    VideoSample.Free;
    VideoSample := nil;
  except end;
  ClearBuffer;

  fVideoRunning := false;
end;



function TVideoImage.VideoStart(DeviceName: string; Resolution: Integer = -1): Boolean;
VAR
  HR     : HResult;
  st     : string;
  W, H   : integer;
  FourCC : cardinal;
begin
//  fSkipCnt       := 0;
  fFrameCnt      := 0;
//  f30FrameTick   := 0;
  fFPS           := 0;
  fDeviceName    := '';
  if assigned(VideoSample) then VideoStop;
  if Resolution < -1 then Resolution := -1;
  fForceRGB := Resolution = -1;


  VideoSample := TVideoSample.Create(Application.Handle, fForceRGB, 0, HR);
  try
    Result := Succeeded(VideoSample.StartVideo(DeviceName, false, st));
  except
    Result := False;
  end;

  if Result then
  begin
    if Resolution <> -1 then
      Result := SetResolutionByIndex(Resolution)
    else if Succeeded(VideoSample.GetStreamInfo(W, H, FourCC)) then
    begin
      fWidth := W;
      fHeight := H;
      fFourCC := FourCC;
    end
    else
      Result := False;
  end;

  if Result then
  begin
    fVideoRunning := True;
    fDeviceName := DeviceName;
    VideoSample.SetCallBack(CallBack);  // Do not call GDI routines in Callback!
  end
  else
    VideoStop;
end;



function TVideoImage.VideoSampleIsPaused: boolean;
begin
  if assigned(VideoSample)
    then Result := VideoSample.PlayState = PS_PAUSED
    else Result := false;
end;


PROCEDURE TVideoImage.PrepareTables;
VAR
  i : integer;
BEGIN
  IF fYUY2TablesPrepared then
    exit;
  FOR i := 0 TO 255 DO
    BEGIN
      { http://msdn.microsoft.com/en-us/library/ms893078.aspx
      ValueY_298[i] := (i- 16) * 298  +  128;      //  -4640 .. 71350
      ValueU_100[i] := (i-128) * 100;              // -12800 .. 12700
      ValueU_516[i] := (i-128) * 516;              // -66048 .. 65532
      ValueV_409[i] := (i-128) * 409;              // -52352 .. 51943
      ValueV_208[i] := (i-128) * 208;              // -26624 .. 26416
      }
      // http://en.wikipedia.org/wiki/YCbCr  (ITU-R BT.601)
      ValueY_298[i] := round(i *  298.082);
      ValueU_100[i] := round(i * -100.291);
      ValueU_516[i] := round(i *  516.412  - 276.836*256);
      ValueV_409[i] := round(i *  408.583  - 222.921*256);
      ValueV_208[i] := round(i * -208.120  + 135.576*256);

    END;
  FillChar(ValueClip, SizeOf(ValueClip), #0);
  FOR i := 0 TO 255 DO
    ValueClip[i] := i;
  FOR i := 256 TO 1023 DO
    ValueClip[i] := 255;
  fYUY2TablesPrepared := true;
END;




procedure TVideoImage.I420_to_RGB(pData: pointer; Bitmap: TBitmap);
// http://en.wikipedia.org/wiki/YCbCr
VAR
  L, X, Y    : integer;
  ps         : pbyte;
  pY, pU, pV : pbyte;
begin
  pY := pData;
  PrepareTables;
  FOR Y := 0 TO Bitmap.Height-1 DO
    BEGIN
      ps := Bitmap.ScanLine[Y];

      pU := pData;
      Inc(pU, Bitmap.Width*(Bitmap.height+ Y div 4));
      pV := PU;
      Inc(pV, Bitmap.Width*Bitmap.height div 4);

      FOR X := 0 TO (Bitmap.Width div 2)-1 DO
        begin
          L := ValueY_298[pY^];
          ps^ := ValueClip[(L + ValueU_516[pU^]                  ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                   + ValueV_409[pV^]) div 256];
          Inc(ps);
          Inc(pY);

          L := ValueY_298[pY^];
          ps^ := ValueClip[(L + ValueU_516[pU^]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pU^] + ValueV_208[pV^]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                   + ValueV_409[pV^]) div 256];
          Inc(ps);
          Inc(pY);

          Inc(pU);
          Inc(pV);
        end;
    END;
end;



procedure TVideoImage.YUY2_to_RGB(pData: pointer; Bitmap: TBitmap);
// http://msdn.microsoft.com/en-us/library/ms893078.aspx
// http://en.wikipedia.org/wiki/YCbCr
type
  TFour  = ARRAY[0..3] OF byte;
VAR
  L, X, Y : integer;
  ps      : pbyte;
  pf      : ^TFour;
begin
  pf := pData;
  PrepareTables;
  FOR Y := 0 TO Bitmap.Height-1 DO
    BEGIN
      ps := Bitmap.ScanLine[Y];
      FOR X := 0 TO (Bitmap.Width div 2)-1 DO
        begin
          L := ValueY_298[pf^[0]];
          ps^ := ValueClip[(L + ValueU_516[pf^[1]]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                      + ValueV_409[pf^[3]]) div 256];
          Inc(ps);
          L := ValueY_298[pf^[2]];
          ps^ := ValueClip[(L + ValueU_516[pf^[1]]                     ) div 256];
          Inc(ps);
          ps^ := ValueClip[(L + ValueU_100[pf^[1]] + ValueV_208[pf^[3]]) div 256];
          Inc(ps);
          ps^ := ValueClip[(L                      + ValueV_409[pf^[3]]) div 256];
          Inc(ps);

          Inc(pf);
        end;
    END;
end;


procedure TVideoImage.PaintFrame;
BEGIN
  // Paint FBitmap to fDisplayCanvas, if available
  if assigned(fDisplayCanvas) then
    begin
      UnpackFrame(fImage[fImagePtrIndex]);
      IF fDisplayCanvas.LockCount < 1 then
        begin
          fDisplayCanvas.lock;
          try
            fDisplayCanvas.Draw(0, 0, fImage[fImagePtrIndex].Bitmap);
          finally
            fDisplayCanvas.unlock;
          end;
        end;
    end;
END;


procedure TVideoImage.UnpackFrame(var image: TBufferImage);
var
  Unknown : boolean;
  FourCCSt: string[4];
begin
  with Image do
  begin

  IF Unpacked or (Data = nil) then exit;

  if not Assigned(Bitmap) then
    Bitmap := TBitmap.Create;
  if (Bitmap.Width <> W) or (Bitmap.Height <> H) then
  begin
    Bitmap.PixelFormat := pf24bit;
    Bitmap.Width := W;
    Bitmap.Height := H;
  end;

  Unknown := false;
  try
    Case FourCC OF
      0           :  BEGIN
                       IF (Size = W*H*3)
                         then move(Data^, Bitmap.scanline[H-1]^, Size)
                         else Unknown := true;
                     END;
      FourCC_YUY2,
      FourCC_YUYV,
      FourCC_YUNV :  BEGIN
                       IF (Size = W*H*2)
                         then YUY2_to_RGB(Data, Bitmap)
                         else Unknown := true;
                     END;
      FourCC_MJPG :  BEGIN
                       try
                         MemStream.Clear;
                         MemStream.SetSize(Size);
                         MemStream.Position := 0;
                         MemStream.WriteBuffer(Data^, Size);
                         MemStream.Position := 0;
                         JPG.LoadFromStream(MemStream);
                         Bitmap.Assign(JPG);
                       except
                         Unknown := true;
                       end;
                     END;
      FourCC_I420,
      FourCC_YV12,
      FourCC_IYUV : BEGIN
                      IF (Size = (W*H*3) div 2)
                        then I420_to_RGB(Data, Bitmap)
                        else Unknown := true;
                    END;
      else          BEGIN
                      Unknown := true;
                    END;
    end; {case}

    IF Unknown then
      begin
        IF FourCC = 0
          then FourCCSt := 'RGB'
          else begin
            FourCCSt := '    ';
            move(FourCC, FourCCSt[1], 4);
          end;
        Bitmap.Canvas.TextOut(0,  0, 'Unknown compression');
        Bitmap.Canvas.TextOut(0, Bitmap.Canvas.TextHeight('X'), 'DataSize: '+INtToStr(Size)+'  FourCC: '+FourCCSt);
      end;

    Unpacked := true;
  except
  end;

  end;
end;


function TVideoImage.GetBitmap(BMP: TBitmap; Index: Cardinal): Boolean;
begin
  Result := False;
  with fImage[Index] do
  begin
    Mutex.Acquire;
    try
      if Assigned(Data) and (W > 0) and (H > 0) and (Size > 0) then
      begin
        UnpackFrame(fImage[Index]);
        if Unpacked then
        begin
          BMP.Assign(Bitmap);
          Result := True;
        end;
      end;
    finally
      Mutex.Release;
    end;
  end;
end;

function TVideoImage.GetBitmap(BMP: TBitmap): Boolean;
begin
  Result := GetBitmap(BMP, fImagePtrIndex);
end;




procedure TVideoImage.SetDisplayCanvas(Canvas: TCanvas);
begin
  fDisplayCanvas := Canvas;
end;



procedure TVideoImage.ShowProperty;
begin
  VideoSample.ShowPropertyDialog;
end;



procedure TVideoImage.ShowProperty_Stream;
var
  hr     : HResult;
  W, H   : integer;
  FourCC : cardinal;
begin
  VideoSample.ShowPropertyDialog_CaptureStream;
  hr := VideoSample.GetStreamInfo(W, H, FourCC);
  IF Failed(HR)
    then begin
      VideoStop;
    end
    else BEGIN
      fWidth := W;
      fHeight := H;
      fFourCC := FourCC;
      VideoSample.SetCallBack(CallBack);
    END;
end;



{FUNCTION  TVideoImage.ShowVfWCaptureDlg: HResult;
begin
  Result := VideoSample.ShowVfWCaptureDlg;
end;}



{procedure TVideoImage.GetBrightnessSettings(VAR Actual: integer);
begin
//  VideoSample.GetVideoPropAmp(VideoProcAmp_Brightness, Actual)
end;
procedure TVideoImage.SetBrightnessSettings(const Actual: integer);
begin
//  VideoSample.SetVideoPropAmp(VideoProcAmp_Brightness, Actual);
end;}


PROCEDURE TVideoImage.GetListOfSupportedVideoSizes(VidSize: TStringList);
BEGIN
  VideoSample.GetListOfVideoSizes(VidSize);
END;

function TVideoImage.GetListOfSupportedVideoSizes(DeviceName: String; VidSize: TStringList): Boolean;
VAR
  hr     : HResult;
  st     : string;
  VideoSample: TVideoSample;
begin
  Result := True;
  try
    VideoSample := TVideoSample.Create(Application.Handle, false, 0, HR);
    try
      //Sleep(100);
      try
        hr := VideoSample.StartVideo(DeviceName, false, st, False);
        if Failed(hr) then
          Result := False
        else
        begin
          VideoSample.GetListOfVideoSizes(VidSize);
          VideoSample.StopVideo;
        end;
      except
        Result := False;
      end;
    finally
      VideoSample.Free;
    end;
  except
    Result := False;
  end;
end;


function TVideoImage.SetResolutionByIndex(Index: integer): Boolean;
VAR
  hr     : HResult;
  W, H   : integer;
  FourCC : cardinal;
BEGIN
  if Index < -1 then Index := -1;
  if (Index = -1) or fForceRGB then
  begin
    VideoStop;
    Result := VideoStart(fDeviceName, Index);
    Exit;
  end;
  Result := False;
  VideoSample.SetVideoSizeByListIndex(Index);
  hr := VideoSample.GetStreamInfo(W, H, FourCC);
  IF Succeeded(HR) then
  begin
    fForceRGB := False;
    Result := True;
    fWidth := W;
    fHeight := H;
    fFourCC := FourCC;
  END;
END;


end.
