{
  Delphi Winsock 1.1 Library by Aphex
  http://iamaphex.cjb.net
  unremote@knology.net
}

unit SocketUnit;

interface

uses
  Windows,
  winsock;

type
  TClientSocket = class(TObject)
  private
    FAddress: pchar;
    FTag: integer;
    FConnected: boolean;
  protected
    FSocket: TSocket;
  public
    procedure Connect(Address: string; Port: integer);
    property Connected: boolean read FConnected;
    destructor Destroy; override;
    procedure Disconnect;
    function ReceiveBuffer(var Buffer; BufferSize: integer): integer;
    function SendBuffer(var Buffer; BufferSize: integer): integer;
    property Socket: TSocket read FSocket;
    property Tag: integer read FTag write FTag;
  end;

var
  WSAData: TWSAData;

implementation

procedure TClientSocket.Connect(Address: string; Port: integer);
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  resp : integer;
begin
  Disconnect;
  try
    FAddress := pchar(Address);
    FSocket := Winsock.socket(AF_INET, SOCK_STREAM, 0);
    SockAddrIn.sin_family := AF_INET;
    SockAddrIn.sin_port := htons(Port);
    SockAddrIn.sin_addr.s_addr := inet_addr(FAddress);
    except
    exit;
  end;
  if SockAddrIn.sin_addr.s_addr = INADDR_NONE then
  begin
    HostEnt := gethostbyname(FAddress);
    if HostEnt = nil then
    begin
      Exit;
    end;
    SockAddrIn.sin_addr.s_addr := Longint(PLongint(HostEnt^.h_addr_list^)^);
  end;
  try
    resp := Winsock.Connect(FSocket, SockAddrIn, SizeOf(SockAddrIn));
    except
    exit;
  end;
  if resp < 0 then FConnected := False
  else FConnected := True;
end;

procedure TClientSocket.Disconnect;
begin
  FConnected := False;
  try
	  shutdown(FSocket, SD_BOTH);
    except
  end;
  try
    closesocket(FSocket);
    except
  end;
end;

function TClientSocket.ReceiveBuffer(var Buffer; BufferSize: integer): integer;
begin
   Result := recv(FSocket, Buffer, BufferSize, 0);
   if Result <= 0 then
   begin
     Disconnect;
   end;
end;

function TClientSocket.SendBuffer(var Buffer; BufferSize: integer): integer;
begin
  Result :=send(FSocket, Buffer, BufferSize, 0);
  if Result = SOCKET_ERROR then
    Disconnect;
end;

destructor TClientSocket.Destroy;
begin
  inherited Destroy;
  Disconnect;
end;

initialization
  WSAStartUp($101, WSAData);

finalization
  WSACleanup;

end.