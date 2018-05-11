program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  wav in 'wav.pas',
  WriteHeader in 'WriteHeader.pas';

function effect8BitWav(fpIn, fpOut: TFileStream; sizeOfData: LongInt): integer;
var
  i: integer;
  s: Single;
  c: array [0 .. 1] of Byte;
begin
  result := 0;
  i := 0;
  s := sizeOfData / SizeOf(c);
  while i < s do
  begin
    try
      fpIn.ReadBuffer(c, SizeOf(c));
      c[0] := 128;
      fpOut.WriteBuffer(c, SizeOf(c));
    except
      result := -1;
      break;
    end;
    Writeln(c[0], ' : ', c[1]);
    inc(i);
  end;
end;

function effect16BitWav(fpIn, fpOut: TFileStream; sizeOfData: LongInt)
  : integer;
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
      c[0] := 0;
      fpOut.WriteBuffer(c, SizeOf(c));
    except
      result := -1;
      break;
    end;
    Writeln(c[0], ' : ', c[1]);
    inc(i);
  end;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; sizeOfData: LongInt;
  bytesPerSingleCh: SmallInt): integer;
begin
  if bytesPerSingleCh = 1 then
    result := effect8BitWav(fpIn, fpOut, sizeOfData)
  else
    result := effect16BitWav(fpIn, fpOut, sizeOfData);
end;

function wavWrite(inFile, outFile: PChar; sampRate: LongWord; sampBits: Byte;
  sizeOfData: LongInt): integer;
var
  bytesPerSingleCh: Word;
  fpIn, fpOut: TFileStream;
begin
  try
    if FileExists(inFile) = true then
      fpIn := TFileStream.Create(inFile, fmOpenRead)
    else
    begin
      result := -1;
      Writeln(inFile, 'をオープンできません');
      Exit;
    end;
    fpOut := TFileStream.Create(outFile, fmCreate);
    bytesPerSingleCh := sampBits div 8;
    if waveHeaderWrite(fpOut, sizeOfData, bytesPerSingleCh, sampRate, sampBits)
      = -1 then
    begin
      result := -1;
      Writeln('ヘッダを書き込めません');
      Exit;
    end;
    if wavDataWrite(fpIn, fpOut, sizeOfData, bytesPerSingleCh) = -1
    then
    begin
      result := -1;
      Write('エラー発生');
      Exit;
    end;
  finally
    fpIn.Free;
    fpOut.Free;
  end;
  result:=0;
end;

var
  sampRate: LongWord;
  sampBits: Byte;
  sizeOfData: LongInt;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    wavHdrRead(PChar(ParamStr(1)), sampRate, sampBits, sizeOfData);
    wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), sampRate, sampBits,
      sizeOfData);
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
