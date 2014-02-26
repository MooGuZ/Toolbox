function wav_struct = readwav( filename )
%READWAV Read .wav format sound file into memory WAV_STRUCT=(FILENAME) 
%
%   Input arguments:
%
%       FILENAME {string} containing the name of the .WAV file to get,
%                   a absolute route or just filename both accepted, 
%                   .WAV sufix also can be omited. when just filename 
%                   not route, this function will check the current  
%                   route and then the route returned by VOICEBOX(
%                   'DIR_DATA' ). ( get detail by HELP VOICEBOX )
%                    
%   Output arguments:
%
%       WAV_STRUCT {voice_structure} containing the infomation and data 
%                       from .WAV file, the members as follows:
%
%       info {structure} containing information about .WAV file
%           type  {char}    Voice type in currenct structure, 'WAV' here
%           nch   {uint16}  Number of channels
%           hz    {uint32}  Sample per second
%           qbit  {uint16}  Quantification precision in bits
%           qmod  {uint16}  Quntification Mode: 1=PCM, 2=ADPCM, 6=A-law,
%                               7=Mu-law
%           sbyte {uint16}  Bytes for one sample data stored
%
%       data {matlab_array} containing sample value in .WAV file
%
%   See also writewav, encodewav, decodewav, voicebox

% Check input arguments
assert( nargin == 1 && nargout == 1,...
    '[USAGE] wav_struct = READWAV( filename )' );
assert( ischar(filename),...
    '[ERROR] Argument 1 should be a string refering to a file !!!' );

% Initial wav structure
wav_struct.info.type = 'WAV';

% OPEN FILE 
% -Append .wav sufix is not in filename
if all( filename ~= '.' )
    filename = sprintf( '%s.wav', filename );
end
% -Search file in current route then the route returned by VOICEBOX
wav_file = fopen( filename, 'rb' );
if wav_file == -1
    filename = sprintf( '%s/%s', voicebox( 'dir_data' ), filename );
    wav_file = fopen( filename, 'rb' );
end
assert( wav_file ~= -1, '[ERROR] Cannot access input file !!!' );

% READ FILE 
% -RIFF WAVE Chunk
ID  = fread( wav_file, 4, 'char=>char' );
    assert( strcmp( ID', 'RIFF' ), '[ERROR] File damaged !!!' );
[~] = fread( wav_file, 1, 'uint32=>uint32' );
ID  = fread( wav_file, 4, 'char=>char' );
    assert( strcmp( ID', 'WAVE' ), '[ERROR] File damaged !!!' );
% -Format Chunk
ID  = fread( wav_file, 4, 'char=>char' );
    assert( strcmp( ID', 'fmt ' ), '[ERROR] File damaged !!!' );
len = fread( wav_file, 1, 'uint32=>uint32' );
wav_struct.info.qmod = fread( wav_file, 1, 'uint16=>uint16' );
wav_struct.info.nch  = fread( wav_file, 1, 'uint16=>uint16' );
wav_struct.info.hz   = fread( wav_file, 1, 'uint32=>uint32' );
                       fread( wav_file, 1, 'uint32=>uint32' );
          BlockAlign = fread( wav_file, 1, 'uint16=>uint16' );
wav_struct.info.sbyte= BlockAlign / wav_struct.info.nch;
wav_struct.info.qbit = fread( wav_file, 1, 'uint16=>uint16' );
if len == 18
wav_struct.info.extra= fread( wav_file, 1, 'uint16=>uint16' );
end
% -Fact Chunk if exist
ID  = fread( wav_file, 4, 'char=>char' );
if strcmp( ID', 'fact' ) || strcmp( ID', 'LIST' )
    len = fread( wav_file, 1, 'uint32=>uint32' );
    fseek( wav_file, len, 0 );
    ID  = fread( wav_file, 4, 'char=>char' );
end
% -Data Chunk
assert( strcmp( ID', 'data' ), '[ERROR] File damaged !!!' );
len   = fread( wav_file, 1, 'uint32=>uint32' );
% --Set read format
sbit  = wav_struct.info.sbyte * 8;
fmode = sprintf( 'uint%d=>uint%d', sbit, sbit );
% --Set store format
mdim  = double( wav_struct.info.nch );
ndim  = double( len / double( BlockAlign ) );
% --Read data
wav_struct.data = fread( wav_file, [mdim,ndim], fmode );

% Close file
assert( ~fclose( wav_file ), '[ERROR] Cannot close file (FID=%d) !!!',...
    wav_file);

end

