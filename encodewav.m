function wav_struct = encodewav( voice_struct )
%ENCODEWAV transform general voice structure to 'WAV' type

% Check input and output argument
assert( nargin == 1 && nargout == 1, '[USAGE] wav_struct = ENCODEWAV( voice_struct )' );
assert( strcmp( voice_struct.info.type, 'nCODEC' ), '[ERROR] Argument 1 should be a general voice structure !!!' );

% Format transform
wav_struct = voice_struct;
wav_struct.info.type = 'WAV';

end

