unit uServ;

interface
uses Windows,Classes,sysUtils,Winsock,ComCtrls, uClients, uFunctions;

const
  ERROR_LISTEN          = 04;
  ERROR_ACCEPT          = 05;
  ERROR_BIND            = 08;
  SUCCESS_ACCEPT        = 11;

type
  TMyThread = class(TThread)
  private
    ListenPort  :Integer;
    myLstItem:TListitem;
    procedure OnSocketClose;
  protected
    procedure Execute; override;
  public
    Sock        :TSocket;
    constructor Create(CreateSuspended: Boolean);
    procedure SetPortTo(sValue: Integer;fListitem:TListitem);
    Function Listen: Integer;
    Function AcceptNew(iSock: TSocket): Integer;
  end;

implementation

constructor TMyThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  ListenPort := 0;
  FreeOnTerminate := True;
end;

procedure TMyThread.OnSocketClose;
begin
  try
    myLstItem.Delete;
  except

  end;
end;

procedure TMyThread.Execute;
begin
  Listen;
  //Socket should be closed now
  OnSocketClose;
end;

procedure TMyThread.SetPortTo(sValue: Integer;fListitem:TListitem);
begin
  ListenPort := sValue;
  myLstItem := fListitem;
  myLstItem.ImageIndex := 1;
end;

Function TMyThread.AcceptNew(iSock: TSocket): Integer;
var
  ClientThread:TClientThread;
Begin
  ClientThread := TClientThread.Create(True);
  ClientThread.tMyThread := ClientThread;
  ClientThread.SetSocket(iSock);
  ClientThread.Resume;
  Result := SUCCESS_ACCEPT;
End;

Function TMyThread.Listen: Integer;
var
  WSA         :TWSAData;
  Addr        :TSockAddrIn;
  Remote      :TSockAddr;
  ReturnError :Integer;
  Len         :Integer;
  TempSock    :TSocket;
Begin
  WSAStartUp($0101, WSA);
  Sock := Socket(AF_INET, SOCK_STREAM, 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := hTons(ListenPort);
  Addr.sin_addr.S_addr := INADDR_ANY;
  If (Bind(Sock, Addr, SizeOf(Addr)) <> 0) Then
  Begin
    Result := ERROR_BIND;
    ReturnError := Result;
    myLstItem.Delete;
    Exit;
  End;
  If (Winsock.listen(Sock, SOMAXCONN) <> 0) Then
  Begin
    Result := ERROR_LISTEN;
    ReturnError := Result;
    WSACleanUp();
    myLstItem.Delete;
    Exit;
  End;
  Len := SizeOf(Remote);
  Repeat
    TempSock := Accept(Sock, @Remote, @Len);
    If (TempSock = INVALID_SOCKET) Then
    Begin
      Result := ERROR_ACCEPT;
      ReturnError := Result;
      myLstItem.Delete;
      WSACleanUp();
      Exit;
    End;
    AcceptNew(TempSock);
    TempSock := INVALID_SOCKET;
  Until False;
  WSACleanUp();
End;
end.
