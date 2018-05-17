program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  spWav in 'spWav.pas',
  effect in 'effect.pas',
  WriteHeader in 'WriteHeader.pas',
  wav in 'wav.pas';

var
  sp: SpParam;
  hdrHeader: WrSWaveFileHeader;

begin
  try
    { TODO -oUser -cConsole ���C�� : �����ɃR�[�h���L�q���Ă������� }
    if ParamCount <> 1 then
    begin
      usage;
      Exit;
    end;
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), hdrHeader, sp) = -1 then
      Exit;
    Writeln('����');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
