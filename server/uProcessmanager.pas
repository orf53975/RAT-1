unit uProcessmanager;
interface
uses sysutils, tlhelp32, windows, psapi, ufunctions;

function ListProcess:String;

implementation
function ListProcess:String;
Var
  pHandle      :THandle;
  hSnapShot     :THandle;
  ProcessEntry  :TProcessEntry32;
  ppath         :string;
Begin
  Result := '';
  hSnapShot := CreateToolHelp32SnapShot(TH32CS_SNAPALL,0);
  ProcessEntry.dwSize := SizeOf(TProcessEntry32);
  try
    Process32First(hSnapShot, ProcessEntry);
    repeat
      phandle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, ProcessEntry.th32ProcessID);
      SetLength(ppath, MAX_PATH);
      if (GetModuleFileNameEx(phandle, 0, PChar(ppath), MAX_PATH)) > 0 then begin;
        SetLength(ppath, length(PChar(ppath)));
      end else begin
        ppath := 'System';
      end;
      Result := Result + ProcessEntry.szExeFile + '#' + pPath + '#' +  IntToStr(ProcessEntry.th32ProcessID) + '|';
    until not Process32Next(hSnapShot, ProcessEntry);
  finally
    CloseHandle(hSnapShot);
  end;
End;
end.
