unit wav;

interface

uses
  System.Classes, System.SysUtils, spWav;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
function wavHdrRead(wavefile: PChar; var sp: SpParam): integer;

implementation

uses Unit1;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
begin
  result := 0;
  try
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    Form1.ListBox1.Items.Add('データ形式：'+waveFmtPcm.formatTag.ToString);
    Form1.ListBox1.Items.Add('チャンネル数：'+ waveFmtPcm.channels.ToString);
    Form1.ListBox1.Items.Add('サンプリング周波数：'+ waveFmtPcm.sampleParSec.ToString);
    Form1.ListBox1.Items.Add('バイト数　/　秒：'+ waveFmtPcm.bytesPerSec.ToString);
    Form1.ListBox1.Items.Add('バイト数 Ｘ チャンネル数：'+ waveFmtPcm.blockAlign.ToString);
    Form1.ListBox1.Items.Add('ビット数　/　サンプル：'+ waveFmtPcm.bitsPerSample.ToString);
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        Form1.ListBox1.Items.Add('ステレオファイルを対象としています');
        Form1.ListBox1.Items.Add('チャンネル数は'+channels.ToString);
//        result := -1;
      end;
      if formatTag <> 1 then
      begin
        Form1.ListBox1.Items.Add('無圧縮のPCMのみ対象');
        Form1.ListBox1.Items.Add('フォーマット形式は'+ formatTag.ToString);
        result := -1;
      end;
      if (bitsPerSample <> 8) and (bitsPerSample <> 16) then
      begin
        Form1.ListBox1.Items.Add('8/16ビットのみ対象');
        Form1.ListBox1.Items.Add('bit/secは'+ bitsPerSample.ToString);
        result := -1;
      end;
    end;
  except
    on EReadError do
      result := -1;
  end;
end;

function wavHdrRead(wavefile: PChar; var sp: SpParam): integer;
var
  waveFileHeader: SWaveFileHeader;
  waveFmtPcm: tWaveFormatPcm;
  chank: tChank;
  fPos, len: integer;
  fp: TFileStream;
begin
  Form1.ListBox1.Items.Clear;
  try
    fp := TFileStream.Create(wavefile, fmOpenRead);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      Form1.ListBox1.Items.Add('読み込み失敗');
      fp.Free;
    end;
    else
      Form1.ListBox1.Items.Add('開けません');
    result := -1;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    Form1.ListBox1.Items.Add('RIFFフォーマットでない');
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    Form1.ListBox1.Items.Add('"WAVE"がない');
    result := -1;
    fp.Free;
    Exit;
  end;
  fPos := 0;
  len := waveFileHeader.sizeOfFile;
  while True do
  begin
    try
      fp.ReadBuffer(chank, SizeOf(tChank));
    except
      on EReadError do
      begin
        result := 0;
        fp.Free;
        break;
      end;
    end;
    if CompareStr(chank.hdrFmtData, STR_fmt) = 0 then
    begin
      len := chank.sizeOfFmtData;
      Form1.ListBox1.Items.Add(Format('fmt の長さ%d[bytes]',[len]));
      fPos := fp.Position;
      if readFmtChank(fp, waveFmtPcm) <> 0 then
      begin
        result := -1;
        fp.Free;
        Exit;
      end;
      sp.samplePerSec := waveFmtPcm.sampleParSec;
      sp.bitsPerSample := waveFmtPcm.bitsPerSample;
      sp.channels := waveFmtPcm.channels;
      sp.bytesPerSec := waveFmtPcm.bytesPerSec;
      fp.Seek(fPos + len, soFromBeginning);
    end
    else if CompareStr(chank.hdrFmtData, STR_data) = 0 then
    begin
      sp.sizeOfData := chank.sizeOfFmtData;
      Form1.ListBox1.Items.Add(Format('dataの長さ:%d[bytes]',[sp.sizeOfData]));
      sp.posOfData := fp.Position;
      fp.Seek(fPos + len, soFromBeginning);
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Form1.ListBox1.Items.Add(chank.hdrFmtData+'の長さ[bytes]'+len.ToString);
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
