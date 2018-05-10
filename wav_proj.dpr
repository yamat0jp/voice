program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils, System.Classes,
  wav in 'wav.pas';

function dump8BitWav(fpIn: TFileStream; sizeOfData: Word): integer;
var
  i: integer;
  s: Single;
  c: array [0 .. 1] of Word;
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
    Writeln(c[0], ',', c[1]);
    inc(i);
  end;
end;

function dump16BitWav(fpIn: TFileStream; sizeOfData: Word): integer;
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
    Writeln(c[0], ',', c[1]);
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

function dumpData(inFile: PChar; sampBits, posOfData, sizeOfData: Word)
  : SmallInt;
var
  bytesPerSingleCh: Word;
  fpIn: TFileStream;
begin
  result := -1;
  bytesPerSingleCh := sampBits div 8;
  if FileExists(inFile) = false then
  begin
    Writeln('オープンできません.');
    Exit;
  end;
  fpIn := TFileStream.Create(inFile, fmOpenRead);
  try
    if dumpDataSub(fpIn, posOfData, sizeOfData, bytesPerSingleCh) <> 0 then
      Writeln('エラー発生.')
    else
      result := 0;
  finally
    fpIn.Free;
  end;
end;

var
  sampRate, sampBits: SmallInt;
  posOfData, sizeOfData: Cardinal;
  i: integer;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    if ParamCount < 1 then
    begin
      Writeln('wav ファイルをダンプします.'#13#10, '引数に <入力ファイル名> を指定してください.'#13#10#13#10,
        '例 : dumpWav  in.wav');
      Exit;
    end;
    if ParamStr(1) = '-h' then
      i:=2
    else
      i:=1;
    wavHdrRead(PChar(ParamStr(i)), sampRate, sampBits, posOfData, sizeOfData);
    if i = 1 then
      dumpData(PChar(ParamStr(1)), sampBits, posOfData, sizeOfData);
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
