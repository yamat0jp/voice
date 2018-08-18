# -*- coding: utf-8 -*-
"""
Created on Sat Aug 18 19:46:34 2018

@author: fuke masasi
"""

import pyaudio  #録音機能を使うためのライブラリ
import wave     #wavファイルを扱うためのライブラリ
 
RECORD_SECONDS = 10 #録音する時間の長さ（秒）
WAVE_OUTPUT_FILENAME = "sample.wav" #音声を保存するファイル名
iDeviceIndex = 0 #録音デバイスのインデックス番号
 
#基本情報の設定
FORMAT = pyaudio.paInt16 #音声のフォーマット
CHANNELS = 2             #ステレオ
RATE = 44100             #サンプルレート
CHUNK = 2**11            #データ点数
audio = pyaudio.PyAudio() #pyaudio.PyAudio()
 
stream = audio.open(format=FORMAT, channels=CHANNELS,
        rate=RATE, input=True,
        input_device_index = iDeviceIndex, #録音デバイスのインデックス番号
        frames_per_buffer=CHUNK)
 
#--------------録音開始---------------
 
print ("recording...")
frames = []
#for i in range(0, int(RATE / CHUNK * RECORD_SECONDS)):
while True:
    data = stream.read(CHUNK)
    frames.append(data)
 
 
print ("finished recording")
 
#--------------録音終了---------------
 
stream.stop_stream()
stream.close()
audio.terminate()
 
waveFile = wave.open(WAVE_OUTPUT_FILENAME, 'wb')
waveFile.setnchannels(CHANNELS)
waveFile.setsampwidth(audio.get_sample_size(FORMAT))
waveFile.setframerate(RATE)
waveFile.writeframes(b''.join(frames))
waveFile.close()