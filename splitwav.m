function [ file_count ] = splitwav( wav_file, tlimit, smode )
%SPLITWAV make huge file into small pieces which not longer then TLIMIT
%   Detailed explanation goes here

% Check input and output arguments
assert( nargin >= 2 && ischar( wav_file ), '[USAGE] [file_count] = SPLITWAV(wav_file,tlimit[,smode])' );
if nargin < 3
    smode = ' ';
end

% Open file
wav = readwav( wav_file );

% Count time
dims = size( wav.data );
len  = dims(2);
time = len / double(wav.info.hz);
if time > tlimit
    file_count = floor( double(time) / tlimit );
    slen = fix( wav.info.hz * tlimit );
    % Split Loop
    for i = 1 : file_count
        ssc = slen * ( i -1 ) + 1;
        sec = slen * i;
        Tmp(i).info = wav.info;
        Tmp(i).data = wav.data(:,ssc:sec);
        if strcmp( wav_file((length(wav_file)-3):length(wav_file)), '.wav' )
            filename = sprintf( '%s.%d.wav', wav_file(1:length(wav_file)-4), i );
        else
            filename = speintf( '%s.%d.wav', wav_file, i );
        end
        writewav( filename, Tmp(i), smode );
    end
end

end

