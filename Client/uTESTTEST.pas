unit uTESTTEST;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bsSkinData, BusinessSkinForm;

type
  TForm2 = class(TForm)
    bskndt1: TbsSkinData;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
