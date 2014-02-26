function info = wavinfo( filename )
%WAVINFO Summary of this function goes here
%   Detailed explanation goes here
if ~ischar( filename )
    error( '[error] need filename for input argument' );
end

if all( filename ~= '/' )
    filename = sprintf( '%s/%s', voicebox( 'dir_data' ), filename );
end

fid = fopen( filename, 'rb' );

fseek(fid,8,-1);						% read riff chunk
header=fread(fid,4,'uchar');
if header' ~= 'WAVE'
    fclose(fid); 
    error(sprintf('File does not begin with a WAVE chunck'));
end

fmt=0;
data=0;
while ~data						% loop until FMT and DATA chuncks both found
    header=fread(fid,4,'char');
    len=fread(fid,1,'ulong');
    if header' == 'fmt '			% ******* found FMT chunk *********
        fmt=1;
        info.mode=fread(fid,1,'ushort');		% format: 1=PCM, 6=A-law, 7-Mu-law
        info.nchannel=fread(fid,1,'ushort');	% number of channels
        info.hz=fread(fid,1,'ulong');           % sample rate in Hz
        fread(fid,1,'ulong');                   % average bytes per second
        fread(fid,1,'ushort');                  % block alignment in bytes
        info.bits=fread(fid,1,'ushort');		% bits per sample
        fseek(fid,len-16,0);				    % skip to end of chunk
    elseif header' == 'data'        % ******* found DATA chunk *********
        if ~fmt 
            fclose(fid); 
            error(sprintf('File %s does not contain a FMT chunck',filename));
        end
        info.nsample = fix(len/(info.bits*info.nchannel/8));
        data=1;
    else							% ******* found unwanted chunk *********
        fseek(fid,len,0);
    end
end

info.headlen = ftell( fid );

fclose(fid);

end

