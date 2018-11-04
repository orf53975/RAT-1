unit uRegAdd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, uCommands, bsSkinData, BusinessSkinForm;

type
  TForm8 = class(TForm)
    grp1: TGroupBox;
    edtRegName: TEdit;
    lbl1: TLabel;
    lblRegValue: TLabel;
    mmoRegValue: TMemo;
    cbbRegType: TComboBox;
    lblRegType: TLabel;
    btnRegAdd: TBitBtn;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bskndt1: TbsSkinData;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    procedure edtRegNameChange(Sender: TObject);
    procedure cbbRegTypeSelect(Sender: TObject);
    procedure mmoRegValueKeyPress(Sender: TObject; var Key: Char);
    procedure btnRegAddClick(Sender: TObject);
  private
    { Private declarations }
  public
    sSocket:Integer;
    sPath:String;
    sType:String;
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation
uses uMain;
{$R *.dfm}

procedure TForm8.btnRegAddClick(Sender: TObject);
begin
  SendPacket(sSocket,PACK_REGADD,'|' + sPath + edtRegName.Text + '|' + cbbRegType.Text + '|' + mmoRegValue.Text);
  Self.Close;
end;

procedure TForm8.cbbRegTypeSelect(Sender: TObject);
begin
  mmoRegValue.Enabled := True;
  lblRegValue.Enabled := True;
  btnRegAdd.Enabled := True;
  mmoRegValue.Enabled := True;
  lblRegValue.Enabled := True;
  btnRegAdd.Enabled := True;
  mmoRegValue.Clear;
  sType := cbbRegType.Text;
end;

procedure TForm8.edtRegNameChange(Sender: TObject);
var
  bBool:Boolean;
begin
 if edtRegName.Text <> '' then
    bBool := True
  else
    bBool := False;
  lblRegType.Enabled := bBool;
  cbbRegType.Enabled := bBool;
end;

procedure TForm8.mmoRegValueKeyPress(Sender: TObject; var Key: Char);
begin
  if (sType = 'REG_SZ') or (sType = 'REG_EXPAND_SZ') then begin
    if (Key = #10) or (Key = #13) then begin
      Key := #0;
    end;
  end else if sType = 'REG_BINARY' then begin
    if (Key in ['0'..'9', 'A'..'F', 'a'..'f', ' ', #8]) = False then begin
      Key := #0;
    end;
  end else if sType = 'REG_DWORD' then begin
    if (Key in ['0'..'9', #8]) = False then begin
      Key := #0;
    end;
  end;
end;

end.
