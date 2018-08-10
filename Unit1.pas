unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Media, effect, selectFile, spWav,
  wav,
  FMX.Layouts, FMX.ListBox;

type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    Button5: TButton;
    Button6: TButton;
    ListBox1: TListBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private êÈåæ }
  public
    { public êÈåæ }
    Media: TMediaCodecManager;
    mic: TAudioCaptureDevice;
    sp: SpParam;
    pMem: TMemoryStream;
    fileName: string;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog1.Execute = true then
  begin
    Edit1.Text := OpenDialog1.fileName;
    MediaPlayer1.fileName := Edit1.Text;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  MediaPlayer1.Play;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  MediaPlayer1.Stop;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if FileExists(Edit1.Text) = true then
    fileName := Edit1.Text
  else
    if FileExists('temp.wav') = true then
    begin
      Edit1.Text := 'temp.wav';;
      fileName := Edit1.Text;
    end
    else
    begin
      Edit1.Text:='';
      Exit;
    end;
  if wavHdrRead(PChar(fileName), sp) < 0 then
    Exit;
  if readWav(fileName, pMem) = false then
    Exit;
  sp.pWav := pMem.Memory;
  if effectWav(sp) = 0 then
  begin
    pMem.SaveToFile('effect.wav');
    MediaPlayer1.fileName := 'effect.wav';
    MediaPlayer1.Play;
  end;
  pMem.Free;
  Finalize(sp.pWav^);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  mic := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
  if mic = nil then
    Exit;
  mic.fileName := 'temp.wav';
  mic.StartCapture;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  if MediaPlayer1.State = TMediaState.Playing then
    MediaPlayer1.Stop
  else
  begin
    mic.StopCapture;
    MediaPlayer1.fileName := 'temp.wav';
    MediaPlayer1.Play;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Media := TMediaCodecManager.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  Media.Free;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (MediaPlayer1.State = TMediaState.Playing)and(MediaPlayer1.Duration = MediaPlayer1.CurrentTime) then
  begin
    MediaPlayer1.Stop;
    MediaPlayer1.CurrentTime:=0;
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  MediaPlayer1.Volume := TrackBar1.Value;
end;

end.
