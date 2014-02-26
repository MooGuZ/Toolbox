function nbytes = writewav( filename, wav_struct, route )
%WRITEWAV Summary of this function goes here

% Check input arguments
assert( nargin >= 2, '[USAGE] nbytes = WRITEWAV( filename, wav_struct, [route] ) !!!' );
assert( isstruct(wav_struct) && strcmp( wav_struct.info.type, 'WAV' ), '[ERROR] Argument 2 should be a WAV structure !!! See WRITEWAV' );
assert( ischar(filename), '[ERROR] Argument 1 should be FILENAME string refering to a file !!!');

% Open file
% -Append sufix when necessary
if all( filename ~= '.' )
    filename = sprintf( '%s.wav', filname );
end
% -Open file according to FILENAME and ROUTE
if nargin == 3
    if any( route == 'c' )
        wav_file = fopen( filename, 'wb' );
    elseif any( route == 'd' )
        filename = sprintf( '%s/%s', voicebox( 'dir_data' ), filename );
        wav_file = fopen( filename, 'wb' );
    else
        filename = sprintf( '%s/%s', route, filename );
        wav_file = fopen( filename, 'wb' );
    end
% -Ask for the route if ROUTE not applied
else
    answer = input( 'Should this file store in default route ? (y/n) ', 's' );
    if answer == 'y'
        filename = sprintf( '%s/%s', voicebox( 'dir_data' ), filename );
        wav_file = fopen( filename, 'wb' );
    else
        wav_file = fopen( filename, 'wb' );
    end
end
assert( wav_file ~= -1, '[ERROR] Cannot create the WAV file !!!');

% Write file
% -Calculate paraments
tmp = size( wav_struct.data );
nchannel = tmp(1);
nsample  = tmp(2);
BlockAlign = wav_struct.info.nch * wav_struct.info.sbyte;
Bps = wav_struct.info.hz * uint32(BlockAlign);
% -RIFF WAVE Chunk
ID = 'RIFF';
    fwrite( wav_file, ID, 'char' );
nbytes = 44 + nchannel * nsample * uint32(wav_struct.info.sbyte); % NEED CONDITION %
    fwrite( wav_file, nbytes - 8, 'uint32' );
ID = 'WAVE';
    fwrite( wav_file, ID, 'char' );
% -Format Chunk
ID = 'fmt ';
    fwrite( wav_file, ID, 'char' );
len = 16; % NEED CONDITION %
    fwrite( wav_file, len, 'uint32' );
fwrite( wav_file, wav_struct.info.qmod, 'uint16' );
fwrite( wav_file, wav_struct.info.nch,  'uint16' );
fwrite( wav_file, wav_struct.info.hz,   'uint32' );
fwrite( wav_file, Bps,                  'uint32' );
fwrite( wav_file, BlockAlign,           'uint16' );
fwrite( wav_file, wav_struct.info.qbit, 'uint16' );
% -Data Chunk
ID = 'data';
    fwrite( wav_file, ID, 'char' );
len = nchannel * nsample * uint32(wav_struct.info.sbyte);
    fwrite( wav_file, len, 'uint32' );
% --Set write format
sbit = wav_struct.info.sbyte * 8;
wmod = sprintf( 'uint%d', sbit );
% --Write data
tmp = fwrite( wav_file, wav_struct.data, wmod );
assert( tmp == nchannel * nsample, '[ERROR] Something wrong in this fuction !!!' );

% Close file
assert( ~fclose( wav_file ), '[ERROR] Cannot close file (FID=%d) !!!', wav_file);

end

