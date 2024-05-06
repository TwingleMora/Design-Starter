clc,
close all
clearvars
Signal_names=["Short_BBCArabic2.wav", "Short_FM9090.wav", "Short_QuranPalestine.wav", "Short_RussianVoice.wav", "Short_SkyNewsArabia.wav"];
for i= 1:5
[audioIN, fs]= audioread(Signal_names(i));
 duration=size(audioIN,1)/fs;          %determine the duration of each signal and 
 audio_length=length(audioIN);         %determine the max length of all signals and it won't change even inverting to mono
 
 %fprintf('Audio signal %d :sampling Frequency= %d Hz and a Duration = %.2f sec and a length= %d \n ' ,i,fs,duration,audio_length);  
 
 mono_audio=sum(audioIN.');            % Convert from stereo to mono sound
 mono_audio=mono_audio.';              % Transpose back to maintain column vector format 
 max_length=740544;
 mono_audio(end+(max_length-audio_length))=0;  %appending zeroes for the short signals so they all have the same length 
 
 %**********Plotting***********
 figure(1)
 subplot(1,5,i)
 plot(mono_audio,'m');
 xlabel('Time(sec)'),ylabel('Amplitude(v))'), title("Monophonic signal"+i);
 grid on
 %**********fft plotting and bandwidth calculating************
 figure(2)
 mono_freqResponse= fft (mono_audio,audio_length);
 f_axis= -fs/2:(fs/audio_length):fs/2-(fs/audio_length); %audio_length won't change  even using fft
 subplot(2,5,i)
 plot (f_axis,fftshift(abs( mono_freqResponse)),'y');
 xlabel('Frequency (HZ)'),ylabel('Amplitude(v))'), title("Monophonic signal "+i+" Frequency spectrum");
 grid on
 mono_audio=interp (mono_audio, 15);             %length of new mono signal is 15 times the old one
 
 %*********** Carrier signal ************
 n=i-1;
 deltaFreq=50000;
 F1=100000;
 Fc_n=(F1+deltaFreq*n);      %if Fc_n >fs/2 ========> leakage
 carrier_fs=15*fs;
 carrierSignal=cos(2*pi*Fc_n*n*(1/carrier_fs));
 
end









