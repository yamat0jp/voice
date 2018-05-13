unit effect;

interface

uses System.Classes, System.SysUtils, spWav;

function effect8BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
function effect16BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
procedure usage;

implementation

function effect8BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
var
  i, j: integer;
  pInMem, pOutMem: TBytes;
begin
  j := sp.sizeOfData - 2;
  pInMem := InInMem.Memory;
  pOutMem := InOutMem.Memory;
  for i := 0 to sp.sizeOfData div 2 do
  begin
    pOutMem[2 * i] := pInMem[j];
    pOutMem[2 * i + 1] := pInMem[j + 1];
    dec(j, 2);
  end;
end;

function effect16BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
var
  i, j, k: integer;
  pInMem, pOutMem: TBytes;
begin
  pInMem := InInMem.Memory;
  pOutMem := InOutMem.Memory;
  i := 0;
  k := sp.sizeOfData div 2;
  while i < k do
  begin
    pOutMem[i] := pInMem[j];
    pOutMem[i + 1] := pInMem[j + 1];
    inc(i, 2);
    dec(j, 2);
  end;
end;

procedure usage;
begin
  Writeln('のこぎり波');
  Writeln('例：effect.wav 100 2000');
end;

end.
