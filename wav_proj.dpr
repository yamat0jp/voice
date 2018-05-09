program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, System.Classes,
  wav in 'wav.pas';

function dump8BitWav(fpIn: TFileStream; sizeOfData: SmallInt): integer;
var
  i: integer;
  s: Single;
  c: array [0 .. 1] of ShortInt;
begin
  result := 0;
  i := 0;
  s := sizeOfData / SizeOf(c);
  while i < s do
  begin
    try
      fpIn.ReadBuffer(c, SizeOf(c));
    except
      result := -1;
      break;
    end;
    Writeln(c[0],',',c[1]);
    inc(i);
  end;
end;

function dump16BitWav(fpIn: TFileStream; sizeOfData: SmallInt): integer;
var
  i: integer;
  s: Single;
  c: array [0 .. 1] of SmallInt;
begin
  result := 0;
  i := 0;
  s := sizeOfData / SizeOf(c);
  while i < s do
  begin
    try
      fpIn.ReadBuffer(c, SizeOf(c));
    except
      result := -1;
      break;
    end;
    Writeln(c[0],',',c[1]);
    inc(i);
  end;
end;

function dumpDataSub(fpIn: TFileStream; posOfData, sizeOfData: integer;
  bytesPerSingleCh: SmallInt): SmallInt;
begin
  fpIn.Seek(posOfData, soFromCurrent);
  if bytesPerSingleCh = 1 then
    result := dump8BitWav(fpIn, sizeOfData)
  else
    result := dump16BitWav(fpIn, sizeOfData);
end;

function dumpData(inFile: PChar; sampBits, posOfData, sizeOfData: SmallInt)
  : SmallInt;
var
  bytesPerSingleCh: SmallInt;
  fpIn: TFileStream;
begin
  result := -1;
  bytesPerSingleCh := sampBits div 8;
  if FileExists(inFile) = false then
  begin
    Writeln('�I�[�v���ł��܂���.');
    Exit;
  end;
  fpIn := TFileStream.Create(inFile, fmOpenRead);
  try
    if dumpDataSub(fpIn, posOfData, sizeOfData, bytesPerSingleCh) <> 0 then
    begin
      Writeln('�G���[����.');
      Exit;
    end;
  finally
    fpIn.Free;
  end;
  result := 0;
end;

var
  sampRate, sampBits: SmallInt;
  posOfData, sizeOfData: Cardinal;

begin
  try
    { TODO -oUser -cConsole ���C�� : �����ɃR�[�h���L�q���Ă������� }
    if ParamCount <> 1 then
    begin
      Writeln('wav �t�@�C�����_���v���܂�.'#13#10, '������ <���̓t�@�C����> ���w�肵�Ă�������.'#13#10#13#10,
        '�� : dumpWav  in.wav');
      Exit;
    end;
    wavHdrRead(PChar(ParamStr(1)), sampRate, sampBits, posOfData, sizeOfData);
    dumpData(PChar(ParamStr(1)), sampBits, posOfData, sizeOfData);
    Writeln('����');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
