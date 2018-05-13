program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  wav in 'wav.pas',
  WriteHeader in 'WriteHeader.pas',
  spWav in 'spWav.pas';

function checkRange(var sp: SpParam): integer;
begin
  result := 0;
  if sp.startpos * sp.bytesPerSec > sp.sizeOfData then
  begin
    Writeln('�J�n�ʒu���t�@�C���T�C�Y�𒴂��Ă��܂�');
    result := -1;
  end
  else if (sp.endpos + 1) * sp.bytesPerSec > sp.sizeOfData then
  begin
    Writeln('�I���ʒu���t�@�C���T�C�Y�𒴂��Ă��܂�');
    Writeln('�I�����t�@�C���̍Ō�ɒ������܂���');
    sp.endpos := (sp.sizeOfData div sp.bytesPerSec) - 1;
  end;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; const sp: SpParam): integer;
var
  Buffer: array of ShortInt;
begin
  result := 0;
  fpIn.Position := sp.posOfData;
  try
    GetMem(Pointer(Buffer), sp.sizeOfData);
  except
    Writeln('���������m�ۂł��܂���');
    result := -1;
  end;
  if fpIn.Read(Pointer(Buffer)^, sp.sizeOfData) = -1 then
  begin
    Writeln('�ǂݍ��݂Ɏ��s');
    result := -1;
  end;
  if fpOut.Write(Pointer(Buffer)^, sp.sizeOfData) = -1 then
  begin
    Writeln('�������݂Ɏ��s');
    result := -1;
  end;
  FreeMem(Pointer(Buffer));
end;

function wavWrite(inFile, outFile: PChar; var sp: SpParam): integer;
var
  fpIn, fpOut: TFileStream;
begin
  try
    fpIn := TFileStream.Create(inFile, fmOpenRead);
    fpOut := TFileStream.Create(outFile, fmCreate);
    sp.sizeOfData := (sp.endpos - sp.startpos + 1) * sp.bytesPerSec;
    if waveHeaderWrite(fpOut, sp) > 44 then
      raise EWriteError.Create('�w�b�_���������߂܂���');
    if wavDataWrite(fpIn, fpOut, sp) = -1 then
      raise EWriteError.Create('�G���[����');
  except
    on EFOpenError do
      Writeln(inFile, '���I�[�v���ł��܂���');
    on EFOpenError do
      fpIn.Free;
    else

    begin
      fpIn.Free;
      fpOut.Free;
    end;
    result := -1;
    Exit;
  end;
  result := 0;
end;

procedure usage;
begin
  Writeln('����<���̓t�@�C����><�o�̓t�@�C����><���x�{��>');
end;

var
  sp: SpParam;

begin
  try
    { TODO -oUser -cConsole ���C�� : �����ɃR�[�h���L�q���Ă������� }
    if ParamCount <> 3 then
    begin
      usage;
      Exit;
    end;
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    sp.samplePerSec := StrToInt(ParamStr(3)) * sp.samplePerSec;
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), sp) = -1 then
      Exit;
    Writeln('����');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
