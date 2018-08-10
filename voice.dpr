program voice;

uses
  System.StartUpCopy,
  FMX.Forms,
  effect in 'effect.pas',
  selectFile in 'selectFile.pas',
  spWav in 'spWav.pas',
  Unit1 in 'Unit1.pas' {Form1},
  wav in 'wav.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
