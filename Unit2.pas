unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls, Vcl.MPlayer,
  effect, selectFile, spWav, wav, WriteHeader, PythonEngine;

type
  TForm2 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    ListBox1: TListBox;
    PythonEngine1: TPythonEngine;
    Memo1: TMemo;
    Button2: TButton;
    PythonInputOutput1: TPythonInputOutput;
    PythonModule1: TPythonModule;
    PythonDelphiVar1: TPythonDelphiVar;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure MediaPlayer1MouseEnter(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PythonInputOutput1SendData(Sender: TObject;
      const Data: AnsiString);
    procedure PythonModule1Initialization(Sender: TObject);
    procedure PythonDelphiVar1GetData(Sender: TObject; var Data: Variant);
    procedure FormCreate(Sender: TObject);
  private
    { Private �錾 }
  public
    { Public �錾 }
    sp: SpParam;
    pMem: TMemoryStream;
    fileName: string;
    tmep: string;
    Terminate: Boolean;
  end;

function voice_proc(self, args: PPyObject): PPyObject; cdecl;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function voice_proc(self, args: PPyObject): PPyObject; cdecl;
begin
  Application.ProcessMessages;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if FileExists(Edit1.Text) = true then
    fileName := Edit1.Text
  else if FileExists('temp.wav') = true then
  begin
    Edit1.Text := 'temp.wav';
    fileName := Edit1.Text;
  end
  else
  begin
    Edit1.Text := '';
    Exit;
  end;
  MediaPlayer1.Close;
  if wavHdrRead(PChar(fileName), sp) < 0 then
    Exit;
  if readWav(fileName, pMem) = false then
    Exit;
  sp.pWav := pMem.Memory;
  if effectWav(sp) = 0 then
  begin
    pMem.SaveToFile('effect.wav');
    if SaveDialog1.Execute = true then
    begin
      Edit1.Text := SaveDialog1.fileName;
      pMem.SaveToFile(Edit1.Text);
      MediaPlayer1.fileName := Edit1.Text;
      MediaPlayer1.Open;
      MediaPlayer1.Play;
    end
    else
    begin
      MediaPlayer1.fileName := Edit1.Text;
      MediaPlayer1.Open;
    end;
  end;
  pMem.Free;
  Finalize(sp.pWav^);
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if Terminate = true then
  begin
    Terminate := false;
    ListBox1.Items.Clear;
    PythonEngine1.ExecStrings(Memo1.Lines);
  end
  else
    Terminate:=true;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Terminate := true;
end;

procedure TForm2.MediaPlayer1MouseEnter(Sender: TObject);
begin
  if MediaPlayer1.fileName <> 'temp.wav' then
  begin
    if FileExists(Edit1.Text) = false then
    begin
      Edit1.Text := '';
      MediaPlayer1.fileName := '';
      MediaPlayer1.Open;
    end
    else
    begin
      if ExpandFileName(Edit1.Text) <> ExpandFileName(MediaPlayer1.fileName)
      then
        MediaPlayer1.fileName := Edit1.Text;
      MediaPlayer1.Open;
    end;
  end;
end;

procedure TForm2.PythonDelphiVar1GetData(Sender: TObject; var Data: Variant);
begin
  Data := Terminate;
end;

procedure TForm2.PythonInputOutput1SendData(Sender: TObject;
  const Data: AnsiString);
begin
  ListBox1.Items.Add(Data);
end;

procedure TForm2.PythonModule1Initialization(Sender: TObject);
begin
  PythonModule1.AddMethod('proc', voice_proc, 'proc');
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin
  if OpenDialog1.Execute = true then
  begin
    Edit1.Text := OpenDialog1.fileName;
    wavHdrRead(PChar(Edit1.Text), sp);
    MediaPlayer1MouseEnter(Sender);
  end;
end;

end.
