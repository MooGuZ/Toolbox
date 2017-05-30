function canvas = imstackdraw(imstack, varargin)
% IMSTACKDRAW draw image stack into an image
% NOTE: only deal with gray image currently
conf = Config(varargin);
% get fundamental information
[height, width, n] = size(imstack);
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
canvas = ones(border + ([height, width] + border) .* [nrow, ncol]) * background;
% copy each image to canvas
ycord = size(canvas, 1) - border + 1;
for r = 1 : nrow
    xcord = border;
    for c = 1 : ncol
        index = (r - 1)* ncol + c;
        if index > n, return; end
        canvas(ycord - (height : -1 : 1), xcord + (1 : width)) = imstack(:, :, index);
        xcord = xcord + width + border;
    end
    ycord = ycord - height - border;
end