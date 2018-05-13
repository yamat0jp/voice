unit wav;

interface

uses
  System.Classes, System.SysUtils;

{$INCLUDE spWav}
function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
function wavHdrRead(wavefile: PChar; var sp: SpParam): integer;

implementation

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
begin
  result := 0;
  try
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    Writeln('�f�[�^�`���F', waveFmtPcm.formatTag);
    Writeln('�`�����l�����F', waveFmtPcm.channels);
    Writeln('�T���v�����O���g���F', waveFmtPcm.sampleParSec);
    Writeln('�o�C�g���@/�@�b�F', waveFmtPcm.bytesPerSec);
    Writeln('�o�C�g�� �w�`�����l�����F', waveFmtPcm.blockAlign);
    Writeln('�r�b�g���@/�@�T���v���F', waveFmtPcm.bitsPerSample);
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        Writeln('�X�e���I�t�@�C����ΏۂƂ��Ă��܂�');
        Writeln('�`�����l������', channels);
        result := -1;
      end;
      if formatTag <> 1 then
      begin
        Writeln('�����k��PCM�̂ݑΏ�');
        Writeln('�t�H�[�}�b�g�`����', formatTag);
        result := -1;
      end;
      if (bitsPerSample <> 8) and (bitsPerSample <> 16) then
      begin
        Writeln('8/16�r�b�g�̂ݑΏ�');
        Writeln('bit/sec��', bitsPerSample);
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
  try
    fp := TFileStream.Create(wavefile, fmOpenRead);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      Writeln('�ǂݍ��ݎ��s');
      fp.Free;
    end;
    else
      Writeln('�J���܂���');
    result := -1;
    Exit;
  end;
  Writeln(wavefile);
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    Writeln('RIFF�t�H�[�}�b�g�łȂ�');
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    Writeln('"WAVE"���Ȃ�');
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
      Writeln('fmt �̒���', len, '[bytes]');
      fPos := fp.Position;
      if readFmtChank(fp, waveFmtPcm) <> 0 then
      begin
        result := -1;
        fp.Free;
        Exit;
      end;
      sp.samplePerSec := waveFmtPcm.sampleParSec;
      sp.bytesPerSec := waveFmtPcm.bytesPerSec;
      fp.Seek(fPos + len, soFromBeginning);
    end
    else if CompareStr(chank.hdrFmtData, STR_data) = 0 then
    begin
      sp.sizeOfData := chank.sizeOfFmtData;
      Writeln('data�̒���:', sp.sizeOfData, '[bytes]');
      sp.posOfData := fp.Position;
      fp.Seek(fPos + len, soFromBeginning);
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Writeln(chank.hdrFmtData, '�̒���[bytes]', len);
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
