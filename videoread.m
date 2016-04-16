function video = videoread(filePath, params)
% VIDEOREAD read video according to it's extension name.
%
% LIMITE : 
% - only gray scale video supported

% MooGu Z. <hzhu@case.edu>
% Apr 08, 2016

[~, ~, fext] = fileparts(filePath);

switch lower(fext)
  case {'.gif'}
    video = gifread(filePath);
    
  case {''}
    fid = fopen(filePath, 'r', 'b');
    video = reshape(fread(fid, prod(params.videoSize), params.readFormat{:}), params.videoSize);
    video = crop(video, params.activeArea) + params.offset;
    
  otherwise
    error('RuntimeError:Videoread', ...
          'Unrecognized video type with extension : %s', fext);
end
    
