unit uVNC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, ImgList, ToolWin, Menus, uCommands, GR32_Image,GR32_Layers,
  bsSkinData, BusinessSkinForm; 

type
  TForm4 = class(TForm)
    il1: TImageList;
    stat1: TStatusBar;
    pb1: TProgressBar;
    tlb1: TToolBar;
    btn1: TToolButton;
    btn2: TToolButton;
    img1: TImage32;
    tmr1: TTimer;
    bskndt1: TbsSkinData;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    procedure btn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RequestImage;
    procedure RequestNextImage;
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure img1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmr1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure img1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);  
  private
    { Private declarations }
  public
    sSocket:Integer;
    sVNCSocket:Integer;
    isInList:Boolean;
    sUserFolder:String;
    hHeight, hWidth, hRatio:Integer;
    mParent:Pointer;
    strKeys:String;
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

uses uMain,
  uFunctions, uControl;

{$R *.dfm}
procedure TForm4.RequestNextImage;
var
  sTempStr:String;
begin
  if btn1.Down then begin
    pb1.Position := 0;
    sTempStr := IntToStr(hRatio);
    If SendPacket(sVNCSocket,PACK_VNCDATA,sTempStr) then
      Stat1.Panels.Items[0].Text := 'VNC Activated!'
    else begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
      sVNCSocket := 0;
      btn1.Down := False;
      FormShow(nil);
    end;
  end;
end;



procedure TForm4.tmr1Timer(Sender: TObject);
var
  Data:String;
  sTempStr:String;
begin
  if strkeys <> '' then
  begin
    sTempStr := strKeys;
    strKeys := '';
    SendPacket(sSocket,PACK_VNCKEY,sTempStr)
  end;
end;

procedure TForm4.RequestImage;
var
  sTempStr:String;
begin
  if btn1.Down then begin
    pb1.Position := 0;
    Self.BorderStyle := bsSIngle;
    sTempStr := IntToStr(hRatio);
    If SendPacket(sVNCSocket,PACK_STARTVNC,sTempStr) then
      Stat1.Panels.Items[0].Text := 'VNC Activated!'
    else begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
      sVNCSocket := 0;
      btn1.Down := False;
      FormShow(nil);
    end;
  end else
    Self.BorderStyle := bsSizeable;
end;

procedure TForm4.btn1Click(Sender: TObject);
begin
  RequestImage;
end;

procedure TForm4.btn2Click(Sender: TObject);
var
  strString:String;
begin
  strString := DateToStr(Date) + '_' + TimeToStr(Time);
  strString := StringReplace(strString,'.','_',[rfReplaceAll, rfIgnoreCase]);
  strString := StringReplace(strString,':','_',[rfReplaceAll, rfIgnoreCase]);
  strString := StringReplace(strString,'/','_',[rfReplaceAll, rfIgnoreCase]);
  img1.Bitmap.SaveToFile(sUserFolder + strString + '.bmp');
end;

procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if btn1.Down then
    btn1.Down := False;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  isInList := False;
end;

procedure TForm4.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  img1.SetFocus;
end;

procedure TForm4.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  img1.SetFocus;
end;

procedure TForm4.FormResize(Sender: TObject);
var
  eRatio:extended;
begin
  if ((hWidth <> 0) and (hHeight <> 0)) then begin
    eRatio := hWidth / hHeight;
    Width := Trunc(Img1.Height * eRatio);
    eRatio :=  ((img1.height) /hheight );
    hRatio := Trunc(eRatio * 100);
  end;
end;

procedure TForm4.FormShow(Sender: TObject);
var
  sTempStr:String;
begin
  // ---------Button----------------
  btn1.Enabled := False;
  if sVNCSocket <> 0 then begin
    btn1.Enabled := True;
    exit;
  end;
  sTempStr := '|' + Inttostr(sSocket);
  If SendPacket(sSocket,PACK_REQUESTVNC,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Requesting VNC-Socket...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm4.img1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if btn1.Down then
    strKeys := strKeys + inttostr(ord(key)) + '#';
end;

procedure TForm4.img1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  m1:integer;
  m2:integer;
  sTempStr:String;
begin
  img1.SetFocus;
  if btn1.Down then
  begin
    m1 := (x * hWidth) div img1.Width ;
    m2 := (y * hHeight) div img1.Height;
    if button = mbLeft then begin
      sTempStr := '|' + IntToStr(m1) +  '|' +IntToStr(m2) +'|';
      SendPacket(sSocket,PACK_VNCLEFT,sTempStr);
    end else begin
      sTempStr := '|' + IntToStr(m1) +  '|' +IntToStr(m2) +'|';
      SendPacket(sSocket,PACK_VNCRIGHT,sTempStr);
    end;
  end;
end;

end.
