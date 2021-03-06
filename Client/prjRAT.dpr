program prjRAT;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  uFunctions in 'uFunctions.pas',
  uCommands in 'uCommands.pas',
  uFlags in 'uFlags.pas',
  uVNC in 'uVNC.pas' {Form4},
  uServ in 'uServ.pas',
  uClients in 'uClients.pas',
  ZLibEx in 'ZLibEx.pas',
  uRegAdd in 'uRegAdd.pas' {Form8},
  uWebcam in 'uWebcam.pas' {Form9},
  uControl in 'uControl.pas' {Form10};


{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Micton RAT';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm8, Form8);
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TForm10, Form10);
  Application.Run;
end.
