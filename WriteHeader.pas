unit WriteHeader;

interface

uses System.Classes, System.SysUtils, spWav;

function waveHeaderWrite(fp: TFileStream; const sp: SpParam): integer;
function wavWrite(inFile, outFile: PChar; const wHdr: WrSWaveFileHeader;
  var sp: SpParam): integer;

implementation

uses effect, Unit2;

function waveHeaderWrite(fp: TFileStream; const sp: SpParam): integer;
var
  bytes: Byte;
  wrWavHdr: WrSWaveFileHeader;
  s: tWaveFormatPCM;
begin
  wrWavHdr.hdrRiff := STR_RIFF;
  wrWavHdr.sizeOfFile := sp.sizeOfData + SizeOf(WrSWaveFileHeader) - 8;
  wrWavHdr.hdrWave := STR_WAVE;
  wrWavHdr.hdrFmt := STR_fmt;
  wrWavHdr.sizeOfFmt := SizeOf(tWaveFormatPCM);
  s.formatTag := 1;
  s.channels := sp.channels;
  s.sampleParSec := sp.samplePerSec;
  bytes := sp.bitsPerSample div 8;
  s.bytesPerSec := bytes * sp.channels * sp.samplePerSec;
  s.blockAlign := bytes * sp.channels;
  s.bitsPerSample := sp.bitsPerSample;
  wrWavHdr.stWaveFormat := s;
  wrWavHdr.hdrData := STR_data;
  wrWavHdr.sizeOfData := sp.sizeOfData;
  fp.WriteBuffer(wrWavHdr, SizeOf(WrSWaveFileHeader));
  result := fp.Position;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; const sp: SpParam): integer;
var
  pInMem, pOutMem: TMemoryStream;
begin

end;

end.
