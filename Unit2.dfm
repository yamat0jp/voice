object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 439
    Top = 46
    Width = 42
    Height = 23
    OnClick = SpeedButton1Click
  end
  object button3: TLabel
    Left = 34
    Top = 245
    Width = 139
    Height = 26
    Caption = 'pyaudio'#12391'10'#31186#38291#37682#38899#12375#12414#12377' '#27425#12395'GO'#12508#12479#12531#12434#12463#12522#12483#12463
    WordWrap = True
  end
  object Label1: TLabel
    Left = 34
    Top = 159
    Width = 79
    Height = 13
    Caption = 'python27.dll'#12497#12473
  end
  object MediaPlayer1: TMediaPlayer
    Left = 136
    Top = 120
    Width = 85
    Height = 30
    VisibleButtons = [btPlay, btPause, btStop]
    AutoOpen = True
    DeviceType = dtWaveAudio
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnMouseEnter = MediaPlayer1MouseEnter
  end
  object Edit1: TEdit
    Left = 64
    Top = 48
    Width = 369
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 320
    Top = 125
    Width = 75
    Height = 25
    Caption = 'GO'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 439
    Top = 120
    Width = 170
    Height = 161
    ItemHeight = 13
    TabOrder = 3
  end
  object Memo1: TMemo
    Left = 240
    Top = 178
    Width = 185
    Height = 89
    Lines.Strings = (
      'import pyaudio  #'#37682#38899#27231#33021#12434#20351#12358#12383#12417#12398#12521#12452#12502#12521#12522
      'import wave     #wav'#12501#12449#12452#12523#12434#25201#12358#12383#12417#12398#12521#12452#12502#12521#12522
      ''
      'RECORD_SECONDS = 10 #'#37682#38899#12377#12427#26178#38291#12398#38263#12373#65288#31186#65289
      'WAVE_OUTPUT_FILENAME = "temp.wav" #'#38899#22768#12434#20445#23384#12377#12427#12501#12449#12452#12523#21517
      'iDeviceIndex = 0 #'#37682#38899#12487#12496#12452#12473#12398#12452#12531#12487#12483#12463#12473#30058#21495
      ''
      '#'#22522#26412#24773#22577#12398#35373#23450
      'FORMAT = pyaudio.paInt16 #'#38899#22768#12398#12501#12457#12540#12510#12483#12488
      'CHANNELS = 2             #'#12473#12486#12524#12458
      'RATE = 44100             #'#12469#12531#12503#12523#12524#12540#12488
      'CHUNK = 2**11            #'#12487#12540#12479#28857#25968
      'audio = pyaudio.PyAudio() #pyaudio.PyAudio()'
      ''
      'stream = audio.open(format=FORMAT, channels=CHANNELS,'
      '        rate=RATE, input=True,'
      '        input_device_index = iDeviceIndex, #'#37682#38899#12487#12496#12452#12473#12398#12452#12531#12487#12483#12463#12473#30058#21495
      '        frames_per_buffer=CHUNK)'
      ''
      '#--------------'#37682#38899#38283#22987'---------------'
      ''
      'print ("recording...")'
      'frames = []'
      'for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):'
      '#while True:'
      '    data = stream.read(CHUNK)'
      '    frames.append(data)'
      ''
      ''
      'print ("finished recording")'
      ''
      '#--------------'#37682#38899#32066#20102'---------------'
      ''
      'stream.stop_stream()'
      'stream.close()'
      'audio.terminate()'
      ''
      'waveFile = wave.open(WAVE_OUTPUT_FILENAME, '#39'wb'#39')'
      'waveFile.setnchannels(CHANNELS)'
      'waveFile.setsampwidth(audio.get_sample_size(FORMAT))'
      'waveFile.setframerate(RATE)'
      'waveFile.writeframes(b'#39#39'.join(frames))'
      'waveFile.close()')
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object Button2: TButton
    Left = 64
    Top = 214
    Width = 75
    Height = 25
    Caption = 'record'
    TabOrder = 5
    OnClick = Button2Click
  end
  object Edit2: TEdit
    Left = 34
    Top = 178
    Width = 187
    Height = 21
    TabOrder = 6
    Text = 'C:\Users\yamat\Anaconda2'
  end
  object OpenDialog1: TOpenDialog
    Filter = 'wav file|*.wav'
    Left = 528
    Top = 88
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'wav'
    Filter = 'wav file|*.wav'
    Left = 528
    Top = 168
  end
  object PythonEngine1: TPythonEngine
    DllPath = 'C:\Users\yamat\Anaconda2'
    IO = PythonInputOutput1
    Left = 432
    Top = 168
  end
  object PythonInputOutput1: TPythonInputOutput
    OnSendData = PythonInputOutput1SendData
    UnicodeIO = False
    RawOutput = False
    Left = 432
    Top = 216
  end
end
