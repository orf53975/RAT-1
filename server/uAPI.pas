unit uAPI;
interface
uses uStructs;
const
  winsocket = 'wsock32.dll';
  kernel32  = 'kernel32.dll';
//shell32
function ShellExecute(hWnd: Cardinal; Operation, FileName, Parameters, Directory: PChar; ShowCmd: Integer): Cardinal; stdcall; external 'shell32.dll' name 'ShellExecuteA';
//shfolder
function SHGetFolderPathA(hwnd: Cardinal; csidl: Integer; hToken: Cardinal; dwFlags: Cardinal; pszPath: PChar): Cardinal; stdcall;external 'shfolder.dll' name 'SHGetFolderPathA';
implementation

end.
