unit uThread;

interface
uses SysUtils, scktcomp, Windows, Classes;
type
  TServer = class(TThread)
  private
  public
    sHost, sSendString:String;
    iPort, iSocketType:Integer;
    bByte:Byte;
    constructor Create;
  protected
    procedure Execute; override;
  end;
implementation

constructor TServer.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

end.
