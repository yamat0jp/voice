unit effect;

interface

uses System.Classes, System.SysUtils, Vcl.Forms, Math, spWav;

function effect16BitWav(const sp: SpParam): integer;
function sinc(x: Single): Single;
function effectwav(const sp: SpParam): integer;

implementation

uses Unit2;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 2;
var
  i, k, a, pmin, pmax: integer;
  len, temp_size, offset0, offset1, p, q: integer;
  m, ma, pitch, rate: Single;
  pMem, pCpy, pRes: array of SmallInt;
  s: TMemoryStream;
  r: array of Single;
  procedure sub;
  var
    b, c: integer;
  begin
    ma := 0.0;
    p := pmin;
    for b := pmin to pmax - 1 do
    begin
      r[b] := 0.0;
      for c := 0 to temp_size - 1 do
        r[b] := r[b] + pRes[offset0 + c] * pRes[offset0 + c + b];
      if r[b] > ma then
      begin
        ma := r[b];
        p := b;
      end;
    end;
  end;

begin
  result := 0;
  try
    offset0 := 0;
    offset1 := 0;
    rate := 0.66;
    len := trunc(sp.sizeOfData - sp.posOfData / (rate * sp.channels));
    temp_size := trunc(len * 0.01);
    pmin := trunc(sp.samplePerSec * 0.005);
    pmax := trunc(sp.samplePerSec * 0.02);
    SetLength(r, pmax);
    SetLength(pCpy, len);
    SetLength(pRes, len);
    SetLength(pMem, len);
    s := TMemoryStream.Create;
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := sp.posOfData;
    s.Read(Pointer(pRes)^, s.Size);
    s.Free;
    if Form2.CheckBox1.Checked = false then
      sub;
    while offset1 + 2 * pmax < len do
    begin
      if Form2.CheckBox1.Checked = true then
        sub;
      for i := 0 to p do
      begin
        pCpy[offset1 + i] := pRes[offset0 + i];
        pCpy[offset1 + i + p] :=
          trunc((pRes[offset0 + p + i] * (p - i) + pRes[offset0 + i] * i) / p);
      end;
      q := trunc(rate * p / (1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset0 + i >= len then
          break;
        pCpy[offset1 + p + i] := pRes[offset0 + i];
      end;
      inc(offset0, q);
      inc(offset1, p + q);
      Application.ProcessMessages;
      Form2.ProgressBar1.Position := trunc(100 * (offset1 + 2 * pmax) / len);
    end;
    pitch := 1.5;
    k := trunc(len / pitch);
    for i := 0 to k - 1 do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - (j div 2) to q + (j div 2) do
        if (a >= 0) and (a < len) then
          pMem[i] := pCpy[a] + pRes[a] * trunc(sinc(pi * (m - a)))
        else
          pMem[i] := 0;
    end;
  except
    result := -1;
  end;
  s := TMemoryStream.Create;
  try
    s.Write(sp.pWav^, sp.posOfData);
    s.Write(Pointer(pMem)^, sp.sizeOfData - sp.posOfData);
    s.Position := 0;
    s.Read(sp.pWav^, s.Size);
  finally
    s.Free;
  end;
  Finalize(pRes);
  Finalize(pCpy);
  Finalize(pMem);
  Finalize(r);
  Form2.ProgressBar1.Position := 0;
end;

function sinc(x: Single): Single;
begin
  if x = 0 then
    result := 1.0
  else
    result := sin(x) / x;
end;

function effectwav(const sp: SpParam): integer;
begin
  if sp.channels = 1 then
  begin
    Form2.ListBox1.Items.Add('ステレオファイルにしてください');
    result := -1;
  end
  else
    result := effect16BitWav(sp);
end;

end.
