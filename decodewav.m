function voice_struct = decodewav( wav_struct )
%DECODEWAV transform voice structure type 'WAV' to generate

% Check input and output argument
assert( nargin == 1 && nargout == 1,...
    '[USAGE] voice_struct = DECODEWAV( wav_struct )' );
assert( strcmp( wav_struct.info.type, 'WAV' ),...
    '[ERROR] Argument 1 should be a voice structure typed "WAV" !!!' );

% Format transform
voice_struct = wav_struct;
voice_struct.info.type = 'nCODEC';

end

