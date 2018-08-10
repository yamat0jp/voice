unit effect;

interface

uses System.Classes, System.SysUtils, Math, spWav;

function effect8BitWav(const sp: SpParam): integer;
function effect16BitWav(const sp: SpParam): integer;
function sinc(x: Single): Single;
procedure usage;
function effectwav(const sp: SpParam): integer;

implementation

uses Unit2;

function effect8BitWav(const sp: SpParam): integer;
begin
end;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, k, a, b, pmin, pmax: integer;
  len, temp_size, offset0, offset1, p, q: integer;
  m, ma, pitch, rate: Single;
  pMem, pCpy, pRes: array of SmallInt;
  s: TMemoryStream;
  r: array of Single;
begin
  result := 0;
  try
    temp_size := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := sp.posOfData;
    offset1 := sp.posOfData;
    rate := 0.66;
    len := trunc(sp.sizeOfData / (rate * sp.channels));
    SetLength(pCpy, len);
    SetLength(pRes, len);
    s := TMemoryStream.Create;
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := 0;
    s.Read(Pointer(pRes)^, s.Size);
    s.Free;
    Pointer(pMem) := sp.pWav;
    k := (sp.sizeOfData - sp.posOfData) div sp.channels;
    ma := 0.0;
    p := pmin;
    for b := 0 to pmax - pmin - 1 do
    begin
      r[b] := 0.0;
      for a := sp.posOfData to sp.posOfData + temp_size do
        r[b] := r[b] + pMem[a] * pMem[a + b];
      if r[b] > ma then
      begin
        ma := r[b];
        p := b;
      end;
    end;
    while offset1 + 2 * pmax < len do
    begin
      for i := 0 to p do
      begin
        pCpy[offset1 + i] := pRes[offset0 + i];
        pCpy[offset1 + i + p] :=
          trunc((pRes[offset0 + p + i] * (p - i) + pRes[offset0 + i] * i) / p);
      end;
      q := trunc(rate * p / (1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset1 + i + p >= len then
          break;
        pCpy[offset1 + p + i] := pMem[offset0 + i];
      end;
      inc(offset0, q);
      inc(offset1, p + q);
    end;
    pitch := 1.5;
    for i := sp.posOfData to k - 1 do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - j div 2 to q + j div 2 do
        if (a >= sp.posOfData) and (a < len) then
          pMem[i] := pCpy[a] + pRes[a] * trunc(sinc(pi * (m - a)))
        else
          pMem[i] := 0;
    end;
  except
    result := -1;
  end;
  Finalize(pRes);
  Finalize(pCpy);
  Finalize(r);
end;

function sinc(x: Single): Single;
begin
  if x = 0 then
    result := 1.0
  else
    result := sin(x) / x;
end;

procedure usage;
begin

end;

function effectwav(const sp: SpParam): integer;
begin
  if sp.channels = 1 then
  begin
    Form2.ListBox1.Items.Add('�X�e���I�t�@�C���ɂ��Ă�������');
    // result := -1;
  end;
  if sp.bitsPerSample = 8 then
    result := effect8BitWav(sp)
  else
    result := effect16BitWav(sp);
end;

end.
