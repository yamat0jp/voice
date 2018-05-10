unit wav;

interface

uses
  System.Classes, System.SysUtils;

{$INCLUDE spWave}
function readFmtChank(fp: TFileStream; waveFmtPcm: tWaveFormatPcm): integer;
function wavHdrRead(wavefile: PChar; var sampRate, sampBits: SmallInt;
  var posOfData, sizeOfData: Cardinal): integer;

implementation

function readFmtChank(fp: TFileStream; waveFmtPcm: tWaveFormatPcm): integer;
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
  except
    on EReadError do
      result := -1;
  end;
end;

function wavHdrRead(wavefile: PChar; var sampRate, sampBits: SmallInt;
  var posOfData, sizeOfData: Cardinal): integer;
var
  waveFileHeader: SWaveFileHeader;
  waveFmtPcm: tWaveFormatPcm;
  chank: tChank;
  len: integer;
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
      if readFmtChank(fp, waveFmtPcm) <> 0 then
      begin
        result := -1;
        fp.Free;
        Exit;
      end;
      sampRate := waveFmtPcm.sampleParSec;
      sampBits := waveFmtPcm.bitsPerSample;
    end
    else if CompareStr(chank.hdrFmtData, STR_data) = 0 then
    begin
      sizeOfData := chank.sizeOfFmtData;
      Writeln('data�̒���:', sizeOfData, '[bytes]');
      posOfData := fp.Position;
      fp.Seek(sizeOfData - 4, soFromCurrent);
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Writeln(chank.hdrFmtData, '�̒���[bytes]', len);
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
