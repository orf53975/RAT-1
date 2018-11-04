unit cnRawinput;

interface

uses
  Windows, Messages;

const
  WM_INPUT = $00FF;

type
  HRAWINPUT = THANDLE;
  TWndMethod = procedure(var Message: TMessage) of object;
  
const
  RIM_INPUT       = 0;
  RIM_INPUTSINK   = 1;

type
  tagRAWINPUTHEADER = record
    dwType: DWORD;
    dwSize: DWORD;
    hDevice: THANDLE;
    wParam: WPARAM;
  end;
  {$EXTERNALSYM tagRAWINPUTHEADER}
  RAWINPUTHEADER = tagRAWINPUTHEADER;
  {$EXTERNALSYM RAWINPUTHEADER}
  PRAWINPUTHEADER = ^RAWINPUTHEADER;
  {$EXTERNALSYM PRAWINPUTHEADER}
  LPRAWINPUTHEADER = ^RAWINPUTHEADER;
  {$EXTERNALSYM LPRAWINPUTHEADER}
  TRawInputHeader = RAWINPUTHEADER;

const
  RIM_TYPEMOUSE      = 0;
  RIM_TYPEKEYBOARD   = 1;
  RIM_TYPEHID        = 2;

type
  tagRAWMOUSE = record
    usFlags: WORD;
    union: record
    case Integer of
      0: (
        ulButtons: ULONG);
      1: (
        usButtonFlags: WORD;
        usButtonData: WORD);
    end;
    ulRawButtons: ULONG;
    lLastX: LongInt;
    lLastY: LongInt;
    ulExtraInformation: ULONG;
  end;
  {$EXTERNALSYM tagRAWMOUSE}
  RAWMOUSE = tagRAWMOUSE;
  {$EXTERNALSYM RAWMOUSE}
  PRAWMOUSE = ^RAWMOUSE;
  {$EXTERNALSYM PRAWMOUSE}
  LPRAWMOUSE = ^RAWMOUSE;
  {$EXTERNALSYM LPRAWMOUSE}
  TRawMouse = RAWMOUSE;

const
  RI_MOUSE_LEFT_BUTTON_DOWN   = $0001; // Left Button changed to down.
  {$EXTERNALSYM RI_MOUSE_LEFT_BUTTON_DOWN}
  RI_MOUSE_LEFT_BUTTON_UP     = $0002; // Left Button changed to up.
  {$EXTERNALSYM RI_MOUSE_LEFT_BUTTON_UP}
  RI_MOUSE_RIGHT_BUTTON_DOWN  = $0004; // Right Button changed to down.
  {$EXTERNALSYM RI_MOUSE_RIGHT_BUTTON_DOWN}
  RI_MOUSE_RIGHT_BUTTON_UP    = $0008; // Right Button changed to up.
  {$EXTERNALSYM RI_MOUSE_RIGHT_BUTTON_UP}
  RI_MOUSE_MIDDLE_BUTTON_DOWN = $0010; // Middle Button changed to down.
  {$EXTERNALSYM RI_MOUSE_MIDDLE_BUTTON_DOWN}
  RI_MOUSE_MIDDLE_BUTTON_UP   = $0020; // Middle Button changed to up.
  {$EXTERNALSYM RI_MOUSE_MIDDLE_BUTTON_UP}

  RI_MOUSE_BUTTON_1_DOWN = RI_MOUSE_LEFT_BUTTON_DOWN;
  {$EXTERNALSYM RI_MOUSE_BUTTON_1_DOWN}
  RI_MOUSE_BUTTON_1_UP   = RI_MOUSE_LEFT_BUTTON_UP;
  {$EXTERNALSYM RI_MOUSE_BUTTON_1_UP}
  RI_MOUSE_BUTTON_2_DOWN = RI_MOUSE_RIGHT_BUTTON_DOWN;
  {$EXTERNALSYM RI_MOUSE_BUTTON_2_DOWN}
  RI_MOUSE_BUTTON_2_UP   = RI_MOUSE_RIGHT_BUTTON_UP;
  {$EXTERNALSYM RI_MOUSE_BUTTON_2_UP}
  RI_MOUSE_BUTTON_3_DOWN = RI_MOUSE_MIDDLE_BUTTON_DOWN;
  {$EXTERNALSYM RI_MOUSE_BUTTON_3_DOWN}
  RI_MOUSE_BUTTON_3_UP   = RI_MOUSE_MIDDLE_BUTTON_UP;
  {$EXTERNALSYM RI_MOUSE_BUTTON_3_UP}

  RI_MOUSE_BUTTON_4_DOWN = $0040;
  {$EXTERNALSYM RI_MOUSE_BUTTON_4_DOWN}
  RI_MOUSE_BUTTON_4_UP   = $0080;
  {$EXTERNALSYM RI_MOUSE_BUTTON_4_UP}
  RI_MOUSE_BUTTON_5_DOWN = $0100;
  {$EXTERNALSYM RI_MOUSE_BUTTON_5_DOWN}
  RI_MOUSE_BUTTON_5_UP   = $0200;
  {$EXTERNALSYM RI_MOUSE_BUTTON_5_UP}

  RI_MOUSE_WHEEL = $0400;
  {$EXTERNALSYM RI_MOUSE_WHEEL}

  MOUSE_MOVE_RELATIVE      = 0;
  {$EXTERNALSYM MOUSE_MOVE_RELATIVE}
  MOUSE_MOVE_ABSOLUTE      = 1;
  {$EXTERNALSYM MOUSE_MOVE_ABSOLUTE}
  MOUSE_VIRTUAL_DESKTOP    = $02; // the coordinates are mapped to the virtual desktop
  {$EXTERNALSYM MOUSE_VIRTUAL_DESKTOP}
  MOUSE_ATTRIBUTES_CHANGED = $04; // requery for mouse attributes
  {$EXTERNALSYM MOUSE_ATTRIBUTES_CHANGED}

type
  tagRAWKEYBOARD = record
    MakeCode: WORD;
    Flags: WORD;
    Reserved: WORD;
    VKey: WORD;
    Message: UINT;
    ExtraInformation: ULONG;
  end;
  {$EXTERNALSYM tagRAWKEYBOARD}
  RAWKEYBOARD = tagRAWKEYBOARD;
  {$EXTERNALSYM RAWKEYBOARD}
  PRAWKEYBOARD = ^RAWKEYBOARD;
  {$EXTERNALSYM PRAWKEYBOARD}
  LPRAWKEYBOARD = ^RAWKEYBOARD;
  {$EXTERNALSYM LPRAWKEYBOARD}
  TRawKeyBoard = RAWKEYBOARD;

const
  KEYBOARD_OVERRUN_MAKE_CODE = $FF;
  {$EXTERNALSYM KEYBOARD_OVERRUN_MAKE_CODE}

  RI_KEY_MAKE            = 0;
  {$EXTERNALSYM RI_KEY_MAKE}
  RI_KEY_BREAK           = 1;
  {$EXTERNALSYM RI_KEY_BREAK}
  RI_KEY_E0              = 2;
  {$EXTERNALSYM RI_KEY_E0}
  RI_KEY_E1              = 4;
  {$EXTERNALSYM RI_KEY_E1}
  RI_KEY_TERMSRV_SET_LED = 8;
  {$EXTERNALSYM RI_KEY_TERMSRV_SET_LED}
  RI_KEY_TERMSRV_SHADOW  = $10;
  {$EXTERNALSYM RI_KEY_TERMSRV_SHADOW}

type
  tagRAWHID = record
    dwSizeHid: DWORD;    // byte size of each report
    dwCount: DWORD;      // number of input packed
    bRawData: array [0..0] of BYTE;
  end;
  {$EXTERNALSYM tagRAWHID}
  RAWHID = tagRAWHID;
  {$EXTERNALSYM RAWHID}
  PRAWHID = ^RAWHID;
  {$EXTERNALSYM PRAWHID}
  LPRAWHID = ^RAWHID;
  {$EXTERNALSYM LPRAWHID}
  TRawHid = RAWHID;

  tagRAWINPUT = record
    header: RAWINPUTHEADER;
    case Integer of
      0: (mouse: RAWMOUSE);
      1: (keyboard: RAWKEYBOARD);
      2: (hid: RAWHID);
  end;
  {$EXTERNALSYM tagRAWINPUT}
  RAWINPUT = tagRAWINPUT;
  {$EXTERNALSYM RAWINPUT}
  PRAWINPUT = ^RAWINPUT;
  {$EXTERNALSYM PRAWINPUT}
  LPRAWINPUT = ^RAWINPUT;
  {$EXTERNALSYM LPRAWINPUT}
  TRawInput = RAWINPUT;

const
  RID_INPUT  = $10000003;
  {$EXTERNALSYM RID_INPUT}
  RID_HEADER = $10000005;
  {$EXTERNALSYM RID_HEADER}

  RIDI_PREPARSEDDATA = $20000005;
  {$EXTERNALSYM RIDI_PREPARSEDDATA}
  RIDI_DEVICENAME    = $20000007; // the return valus is the character length, not the byte size
  {$EXTERNALSYM RIDI_DEVICENAME}
  RIDI_DEVICEINFO    = $2000000b;
  {$EXTERNALSYM RIDI_DEVICEINFO}

type
  PRID_DEVICE_INFO_MOUSE = ^RID_DEVICE_INFO_MOUSE;
  {$EXTERNALSYM PRID_DEVICE_INFO_MOUSE}
  tagRID_DEVICE_INFO_MOUSE = record
    dwId: DWORD;
    dwNumberOfButtons: DWORD;
    dwSampleRate: DWORD;
  end;
  {$EXTERNALSYM tagRID_DEVICE_INFO_MOUSE}
  RID_DEVICE_INFO_MOUSE = tagRID_DEVICE_INFO_MOUSE;
  {$EXTERNALSYM RID_DEVICE_INFO_MOUSE}
  TRidDeviceInfoMouse = RID_DEVICE_INFO_MOUSE;
  PRidDeviceInfoMouse = PRID_DEVICE_INFO_MOUSE;

  PRID_DEVICE_INFO_KEYBOARD = ^RID_DEVICE_INFO_KEYBOARD;
  {$EXTERNALSYM PRID_DEVICE_INFO_KEYBOARD}
  tagRID_DEVICE_INFO_KEYBOARD = record
    dwType: DWORD;
    dwSubType: DWORD;
    dwKeyboardMode: DWORD;
    dwNumberOfFunctionKeys: DWORD;
    dwNumberOfIndicators: DWORD;
    dwNumberOfKeysTotal: DWORD;
  end;
  {$EXTERNALSYM tagRID_DEVICE_INFO_KEYBOARD}
  RID_DEVICE_INFO_KEYBOARD = tagRID_DEVICE_INFO_KEYBOARD;
  {$EXTERNALSYM RID_DEVICE_INFO_KEYBOARD}
  TRidDeviceInfoKeyboard = RID_DEVICE_INFO_KEYBOARD;
  PRidDeviceInfoKeyboard = PRID_DEVICE_INFO_KEYBOARD;

  PRID_DEVICE_INFO_HID = ^RID_DEVICE_INFO_HID;
  {$EXTERNALSYM PRID_DEVICE_INFO_HID}
  tagRID_DEVICE_INFO_HID = record
    dwVendorId: DWORD;
    dwProductId: DWORD;
    dwVersionNumber: DWORD;
    usUsagePage: WORD;
    usUsage: WORD;
  end;
  {$EXTERNALSYM tagRID_DEVICE_INFO_HID}
  RID_DEVICE_INFO_HID = tagRID_DEVICE_INFO_HID;
  {$EXTERNALSYM RID_DEVICE_INFO_HID}
  TRidDeviceInfoHid = RID_DEVICE_INFO_HID;
  PRidDeviceInfoHid = PRID_DEVICE_INFO_HID;

  tagRID_DEVICE_INFO = record
    cbSize: DWORD;
    dwType: DWORD;
    case Integer of
    0: (mouse: RID_DEVICE_INFO_MOUSE);
    1: (keyboard: RID_DEVICE_INFO_KEYBOARD);
    2: (hid: RID_DEVICE_INFO_HID);
  end;
  {$EXTERNALSYM tagRID_DEVICE_INFO}
  RID_DEVICE_INFO = tagRID_DEVICE_INFO;
  {$EXTERNALSYM RID_DEVICE_INFO}
  PRID_DEVICE_INFO = ^RID_DEVICE_INFO;
  {$EXTERNALSYM PRID_DEVICE_INFO}
  LPRID_DEVICE_INFO = ^RID_DEVICE_INFO;
  {$EXTERNALSYM LPRID_DEVICE_INFO}
  TRidDeviceInfo = RID_DEVICE_INFO;
  PRidDeviceInfo = PRID_DEVICE_INFO;

  TGetRawInputDeviceInfo = function (hDevice: THANDLE; uiCommand: UINT; pData: POINTER;
    var pcbSize: UINT): UINT; stdcall;

  TGetRawInputBuffer = function (pData: PRAWINPUT; var pcbSize: UINT;
    cbSizeHeader: UINT): UINT; stdcall;

  TGetRawInputData = function (hRawInput: HRAWINPUT; uiCommand: UINT; pData: POINTER;
    var pcbSize: UINT; cbSizeHeader: UINT): UINT; stdcall;

  LPRAWINPUTDEVICE = ^RAWINPUTDEVICE;
  {$EXTERNALSYM LPRAWINPUTDEVICE}
  PRAWINPUTDEVICE = ^RAWINPUTDEVICE;
  {$EXTERNALSYM PRAWINPUTDEVICE}
  tagRAWINPUTDEVICE = record
    usUsagePage: WORD; // Toplevel collection UsagePage
    usUsage: WORD;     // Toplevel collection Usage
    dwFlags: DWORD;
    hwndTarget: HWND;    // Target hwnd. NULL = follows keyboard focus
  end;
  {$EXTERNALSYM tagRAWINPUTDEVICE}
  RAWINPUTDEVICE = tagRAWINPUTDEVICE;
  {$EXTERNALSYM RAWINPUTDEVICE}
  TRawInputDevice = RAWINPUTDEVICE;

const
  RIDEV_REMOVE       = $00000001;
  {$EXTERNALSYM RIDEV_REMOVE}
  RIDEV_EXCLUDE      = $00000010;
  {$EXTERNALSYM RIDEV_EXCLUDE}
  RIDEV_PAGEONLY     = $00000020;
  {$EXTERNALSYM RIDEV_PAGEONLY}
  RIDEV_NOLEGACY     = $00000030;
  {$EXTERNALSYM RIDEV_NOLEGACY}
  RIDEV_INPUTSINK    = $00000100;
  {$EXTERNALSYM RIDEV_INPUTSINK}
  RIDEV_CAPTUREMOUSE = $00000200; // effective when mouse nolegacy is specified, otherwise it would be an error
  {$EXTERNALSYM RIDEV_CAPTUREMOUSE}
  RIDEV_NOHOTKEYS    = $00000200; // effective for keyboard.
  {$EXTERNALSYM RIDEV_NOHOTKEYS}
  RIDEV_APPKEYS      = $00000400;  // effective for keyboard.
  {$EXTERNALSYM RIDEV_APPKEYS}
  RIDEV_EXMODEMASK   = $000000F0;
  {$EXTERNALSYM RIDEV_EXMODEMASK}

type
  PRAWINPUTDEVICELIST = ^RAWINPUTDEVICELIST;
  {$EXTERNALSYM PRAWINPUTDEVICELIST}
  tagRAWINPUTDEVICELIST = record
    hDevice: THANDLE;
    dwType: DWORD;
  end;
  {$EXTERNALSYM tagRAWINPUTDEVICELIST}
  RAWINPUTDEVICELIST = tagRAWINPUTDEVICELIST;
  {$EXTERNALSYM RAWINPUTDEVICELIST}
  TRawInputDeviceList = RAWINPUTDEVICELIST;

  TGetRawInputDeviceList = function (pRawInputDeviceList: PRAWINPUTDEVICELIST;
    var puiNumDevices: UINT; cbSize: UINT): UINT; stdcall;

  TRegisterRawInputDevices = function (pRawInputDevices: PRAWINPUTDEVICE;
    uiNumDevices: UINT; cbSize: UINT): BOOL; stdcall;

  TGetRegisteredRawInputDevices = function (pRawInputDevices: PRAWINPUTDEVICE;
    var puiNumDevices: UINT; cbSize: UINT): UINT; stdcall;
type
  PObjectInstance = ^TObjectInstance;
  TObjectInstance = packed record
    Code: Byte;
    Offset: Integer;
    case Integer of
      0: (Next: PObjectInstance);
      1: (Method: TWndMethod);
  end;
  
type
  PInstanceBlock = ^TInstanceBlock;
  TInstanceBlock = packed record
    Next: PInstanceBlock;
    Code: array[1..2] of Byte;
    WndProcPtr: Pointer;
    Instances: array[0..313] of TObjectInstance;
  end;
  
type
  TOnRawKeyDown = procedure (Sender: TObject; Key: Word; FromKeyBoard: THandle) of object;
  TOnRawKeyUp = procedure (Sender: TObject; Key: Word; FromKeyBoard: THandle) of object;

  TCnRawKeyBoard = class
  private
    FHandle: THandle;
    FEnabled: Boolean;
    FDevices: array of RAWINPUTDEVICELIST;
    FRegistered: Boolean;
    FOnRawKeyDown: TOnRawKeyDown;
    FOnRawKeyUp: TOnRawKeyUp;
    FBackground: Boolean;
    FKeyBoardCount: Integer;

    procedure RegisterRawInput;
    function GetKeyBoardCount: Integer;
    procedure SetEnabled(const Value: Boolean);
    procedure SetBackground(const Value: Boolean);

  protected
    procedure WinProc(var Message: TMessage);
    procedure DoRawKeyDown(Key: Word; FromKeyBoard: THandle); virtual;
    procedure DoRawKeyUp(Key: Word; FromKeyBoard: THandle); virtual;
  public
    destructor Destroy; override;
    constructor Create;
    procedure UpdateKeyBoardsInfo;
    property KeyBoardCount: Integer read GetKeyBoardCount;
  published
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Background: Boolean read FBackground write SetBackground;
    property OnRawKeyDown: TOnRawKeyDown read FOnRawKeyDown write FOnRawKeyDown;
    property OnRawKeyUp: TOnRawKeyUp read FOnRawKeyUp write FOnRawKeyUp;
  end;

implementation

var
  User32DllHandle: THandle = 0;
  User32NeedFree: Boolean = False;
  InstFreeList: PObjectInstance;
  InstBlockList: PInstanceBlock;
  UtilWindowClass: TWndClass = (
    style: 0;
    lpfnWndProc: @DefWindowProc;
    cbClsExtra: 0;
    cbWndExtra: 0;
    hInstance: 0;
    hIcon: 0;
    hCursor: 0;
    hbrBackground: 0;
    lpszMenuName: nil;
    lpszClassName: 'TPUtilWindow');
  GetRawInputDeviceInfo        : TGetRawInputDeviceInfo        = nil;
  GetRawInputBuffer            : TGetRawInputBuffer            = nil;
  GetRawInputData              : TGetRawInputData              = nil;
  GetRawInputDeviceList        : TGetRawInputDeviceList        = nil;
  RegisterRawInputDevices      : TRegisterRawInputDevices      = nil;
  GetRegisteredRawInputDevices : TGetRegisteredRawInputDevices = nil;

function CalcJmpOffset(Src, Dest: Pointer): Longint;
begin
  Result := Longint(Dest) - (Longint(Src) + 5);
end;

function StdWndProc(Window: HWND; Message, WParam: Longint;
  LParam: Longint): Longint; stdcall; assembler;
asm
        XOR     EAX,EAX
        PUSH    EAX
        PUSH    LParam
        PUSH    WParam
        PUSH    Message
        MOV     EDX,ESP
        MOV     EAX,[ECX].Longint[4]
        CALL    [ECX].Pointer
        ADD     ESP,12
        POP     EAX
end;

function MakeObjectInstance(Method: TWndMethod): Pointer;
const
  BlockCode: array[1..2] of Byte = (
    $59,       { POP ECX }
    $E9);      { JMP StdWndProc }
  PageSize = 4096;
var
  Block: PInstanceBlock;
  Instance: PObjectInstance;
begin
  if InstFreeList = nil then
  begin
    Block := VirtualAlloc(nil, PageSize, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    Block^.Next := InstBlockList;
    Move(BlockCode, Block^.Code, SizeOf(BlockCode));
    Block^.WndProcPtr := Pointer(CalcJmpOffset(@Block^.Code[2], @StdWndProc));
    Instance := @Block^.Instances;
    repeat
      Instance^.Code := $E8;  { CALL NEAR PTR Offset }
      Instance^.Offset := CalcJmpOffset(Instance, @Block^.Code);
      Instance^.Next := InstFreeList;
      InstFreeList := Instance;
      Inc(Longint(Instance), SizeOf(TObjectInstance));
    until Longint(Instance) - Longint(Block) >= SizeOf(TInstanceBlock);
    InstBlockList := Block;
  end;
  Result := InstFreeList;
  Instance := InstFreeList;
  InstFreeList := Instance^.Next;
  Instance^.Method := Method;
end;

procedure FreeObjectInstance(ObjectInstance: Pointer);
begin
  if ObjectInstance <> nil then
  begin
    PObjectInstance(ObjectInstance)^.Next := InstFreeList;
    InstFreeList := ObjectInstance;
  end;
end;

procedure DeallocateHWnd(Wnd: HWND);
var
  Instance: Pointer;
begin
  Instance := Pointer(GetWindowLong(Wnd, GWL_WNDPROC));
  DestroyWindow(Wnd);
  if Instance <> @DefWindowProc then FreeObjectInstance(Instance);
end;

function AllocateHWnd(Method: TWndMethod): HWND;
var
  TempClass: TWndClass;
  ClassRegistered: Boolean;
begin
  UtilWindowClass.hInstance := HInstance;
{$IFDEF PIC}
  UtilWindowClass.lpfnWndProc := @DefWindowProc;
{$ENDIF}
  ClassRegistered := GetClassInfo(HInstance, UtilWindowClass.lpszClassName,
    TempClass);
  if not ClassRegistered or (TempClass.lpfnWndProc <> @DefWindowProc) then
  begin
    if ClassRegistered then
      Windows.UnregisterClass(UtilWindowClass.lpszClassName, HInstance);
    Windows.RegisterClass(UtilWindowClass);
  end;
  Result := CreateWindowEx(WS_EX_TOOLWINDOW, UtilWindowClass.lpszClassName,
    '', WS_POPUP {!0}, 0, 0, 0, 0, 0, 0, HInstance, nil);
  if Assigned(Method) then
    SetWindowLong(Result, GWL_WNDPROC, Longint(MakeObjectInstance(Method)));
end;

constructor TCnRawKeyBoard.Create();
begin
  inherited;
  FEnabled := False;
  FBackground := True;
  FHandle := AllocateHWnd(WinProc);
  UpdateKeyBoardsInfo;
end;

destructor TCnRawKeyBoard.Destroy;
begin
  DeallocateHWnd(FHandle);
  SetLength(FDevices, 0);
  inherited;
end;

procedure TCnRawKeyBoard.DoRawKeyDown(Key: Word; FromKeyBoard: THandle);
begin
  if Assigned(FOnRawKeyDown) then
    FOnRawKeyDown(Self, Key, FromKeyBoard);
end;

procedure TCnRawKeyBoard.DoRawKeyUp(Key: Word; FromKeyBoard: THandle);
begin
  if Assigned(FOnRawKeyUp) then
    FOnRawKeyUp(Self, Key, FromKeyBoard);
end;

function TCnRawKeyBoard.GetKeyBoardCount: Integer;
begin
  Result := FKeyBoardCount;
end;

procedure TCnRawKeyBoard.RegisterRawInput;
var
  Device: array[0..0] of RAWINPUTDEVICE;
begin
  Device[0].usUsagePage := RIM_TYPEKEYBOARD;
  Device[0].usUsage     := 6; //6 表示键盘子类
  Device[0].hwndTarget := FHandle;

  if FBackground then
    Device[0].dwFlags  := RIDEV_INPUTSINK
  else
    Device[0].dwFlags := RIDEV_CAPTUREMOUSE;

  // 注册一个 RawInputDevice
  RegisterRawInputDevices(@Device, 1, SizeOf(RAWINPUTDEVICE));
end;

procedure TCnRawKeyBoard.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if FEnabled and not FRegistered then
    begin
        RegisterRawInput;
        FRegistered := True;
    end;
  end;
end;

procedure TCnRawKeyBoard.SetBackground(const Value: Boolean);
begin
  if FBackground <> Value then
  begin
    FBackground := Value;
  end;
end;

procedure TCnRawKeyBoard.WinProc(var Message: TMessage);
var
  Ri: tagRAWINPUT;
  Size: Cardinal;
begin
  if FEnabled and (Message.Msg = WM_INPUT) then
  begin
    Ri.header.dwSize := SizeOf(RAWINPUTHEADER);
    Size := SizeOf(RAWINPUTHEADER);
    GetRawInputData(HRAWINPUT(Message.LParam), RID_INPUT, nil,
      Size, SizeOf(RAWINPUTHEADER));

    if GetRawInputData(HRAWINPUT(Message.LParam), RID_INPUT, @Ri,
      Size, SizeOf(RAWINPUTHEADER)) = Size then
    begin
      if (Ri.header.dwType = RIM_TYPEKEYBOARD) then
      begin
        if Ri.keyboard.Message = WM_KEYDOWN then
          DoRawKeyDown(Ri.keyboard.VKey, Ri.header.hDevice)
        else if Ri.keyboard.Message = WM_KEYUP then
          DoRawKeyUp(Ri.keyboard.VKey, Ri.header.hDevice);
      end;
    end;
  end;
end;

procedure GetRawInputAPIs;
begin
  User32DllHandle := GetModuleHandle('User32.DLL');
  if User32DllHandle = 0 then
  begin
    User32DllHandle := LoadLibrary('User32.DLL');
    User32NeedFree := User32DllHandle <> 0;
  end;

  if User32DllHandle <> 0 then
  begin
    @GetRawInputDeviceInfo        := GetProcAddress(User32DllHandle, 'GetRawInputDeviceInfoA');
    @GetRawInputBuffer            := GetProcAddress(User32DllHandle, 'GetRawInputBuffer');
    @GetRawInputData              := GetProcAddress(User32DllHandle, 'GetRawInputData');
    @GetRawInputDeviceList        := GetProcAddress(User32DllHandle, 'GetRawInputDeviceList');
    @RegisterRawInputDevices      := GetProcAddress(User32DllHandle, 'RegisterRawInputDevices');
    @GetRegisteredRawInputDevices := GetProcAddress(User32DllHandle, 'GetRegisteredRawInputDevices');
  end;
end;

procedure FreeRawInputAPIs;
begin
  if User32NeedFree and (User32DllHandle <> 0) then
  begin
    FreeLibrary(User32DllHandle);
    User32DllHandle := 0;
  end;
end;

procedure TCnRawKeyBoard.UpdateKeyBoardsInfo;
var
  C: Cardinal;
  KBName: array[0..1023] of AnsiChar;
  I: Integer;
//  DevInfo: RID_DEVICE_INFO;
begin
  FKeyBoardCount := 0;
  if GetRawInputDeviceList(nil, C, SizeOf(RAWINPUTDEVICELIST)) = 0 then
  begin
    if C > 0 then
    begin
      SetLength(FDevices, C);
      if GetRawInputDeviceList(@FDevices[0], C, SizeOf(RAWINPUTDEVICELIST)) <> $FFFFFFFF then
      begin
        for I := 0 to C - 1 do
        begin
          if FDevices[I].dwType = RIM_TYPEKEYBOARD then
          begin
//            DevInfo.cbSize := SizeOf(RID_DEVICE_INFO);
//            C := DevInfo.cbSize;
//            GetRawInputDeviceInfo(FDevices[I].hDevice, RIDI_DEVICEINFO, @DevInfo, C);

            Inc(FKeyBoardCount);
            GetRawInputDeviceInfo(FDevices[I].hDevice, RIDI_DEVICENAME, @KBName, C);
          end;
        end;
      end;
    end;
  end;
end;


initialization
  GetRawInputAPIs;

finalization
  FreeRawInputAPIs;

end.
