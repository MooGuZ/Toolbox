function anim2gif(anim,varargin)
% ANIM2GIF would convert animation stored in column frames into gif file
%
% MooGu Z. <hzhu@case.edu>
% April 22, 2014 - Version 0.2

% Input Parsing
% -------------
% create input parser object
p = inputParser;
% set up parameters
p.addRequired('anim', ...
    @(x) isa(x,'DataPackage') || (isnumeric(x) && isreal(x)));
p.addOptional('FileName',[string(datetime()),'.gif'], @(x) ischar(x) || isa(x, 'string'));
p.addParamValue('FrameSize', nan, ...
    @(x) isnumeric(x) && isreal(x) && isvector(x));
p.addParamValue('Normalization',false, ...
    @(x) islogical(x) && isscalar(x));
p.addParamValue('FrameRate',25, ...
    @(x) isnumeric(x) && isreal(x) && isscalar(x));
% input parsing
p.parse(anim,varargin{:});
% set up parameters according to input arguments
fname  = p.Results.FileName;
sz     = p.Results.FrameSize;
swNorm = p.Results.Normalization;
delay  = 1 / p.Results.FrameRate;
% inference frame size if necessary
if isnan(p.Results.FrameSize)
    if isa(anim, 'DataPackage')
        sz = anim.smpsize;
    else
        sz = floor(sqrt(size(anim,1)))*[1,1];
    end
end
% unpack DataPackage if necessary
if isa(anim, 'DataPackage')
    anim = vec(anim.data, 2);
end
% check availability of animation
switch numel(size(anim))
    case 2
        [npixel,nframe] = size(anim);
        swColor = false;
    case 3
        [npixel,nframe,ncolor] = size(anim);
        assert(ncolor==3, ...
            'the 3rd dimension of color animation should be size of 3.')
        swColor = true;
    otherwise
        error('animation should by 2D or 3D matrix');
end
% check insistence of size
assert(prod(sz) == npixel,...
    'ANIM2GIF requires square images or specified frame size');
% clear parser
clear('p');
%--------------------------------------------------------------------------

% Normalization
if swNorm
    Min = min(anim(:));
    Max = max(anim(:));
    anim = (anim - Min) / (Max - Min);
end

% convert whole animation into index and colormap format
if swColor
    [I,cmap] = rgb2ind(anim,256);  
else
    [I,cmap] = gray2ind(anim,256);
end
% write GIF file
imwrite(reshape(I,[sz,1,nframe]),cmap,fname,'gif','DelayTime',delay,'Loopcount', inf);

end