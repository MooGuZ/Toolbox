function canvas = imstackdraw(imstack, varargin)
% IMSTACKDRAW draw image stack into an image
% NOTE: only deal with gray image currently
conf = Config(varargin);
% get fundamental information
if nndims(imstack) >= 4
    % Color Images
    iscolor = true;
    assert(size(imstack, 3) == 3, 'ILLEGAL COLOR IMAGE');
    [height, width, ~, n] = size(imstack);
else
    iscolor = false;
    [height, width, n] = size(imstack);
end
if conf.exist('arrange')
    arrangement = conf.pop('arrange');
    nrow = arrangement(1);
    ncol = arrangement(2);
else
    [nrow, ncol] = arrange(n);
end
border = conf.pop('border', 3);
background = conf.pop('background', 0.5);
% create canvas
if iscolor
    canvas = background * ones( ...
        [border + ([height, width] + border) .* [nrow, ncol], 3]);
else
    canvas = background * ones( ...
        border + ([height, width] + border) .* [nrow, ncol]);
end
% copy each image to canvas
ycord = border;
for r = 1 : nrow
    xcord = border;
    for c = 1 : ncol
        index = (r - 1)* ncol + c;
        if index > n, return; end
        if iscolor
            canvas(ycord + (1 : height), xcord + (1 : width), :) ...
                = imstack(:, :, :, index);
        else
            canvas(ycord + (1 : height), xcord + (1 : width)) ...
                = imstack(:, :, index);
        end
        xcord = xcord + width + border;
    end
    ycord = ycord + height + border;
end