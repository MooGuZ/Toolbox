function cmap = colorspace(k, background)
% COLORSPACE generate a color map with specified number of colors, which
% as distinguishable as possible.
%
% This algorithm is modified from the implementation of Timothy E. Holy
% in 2010-2011.
%
% Morgan Zhu <hzhu@case.edu>

    if not(exist('background', 'var'))
        background = [1, 1, 1]; % default to white
    end    
    bglab = rgb2lab(background);
    % sampling RGB space
    n = ceil(k^(2/3));
    s = linspace(0, 1, n);
    [r, g, b] = ndgrid(s, s, s);
    sample = [r(:), g(:), b(:)];
    % convert to Lab space
    smplab = rgb2lab(sample);
    % initialize color index
    index = zeros(k, 1);
    % choose distinguishable color iteratively
    i = 1;
    minD = sum(bsxfun(@minus, smplab, bglab).^2, 2);    
    while true
        [~, index(i)] = max(minD);
        if i >= k, break; end
        D = sum(bsxfun(@minus, smplab, smplab(index(i), :)).^2, 2);
        minD = min(minD, D);
        i = i + 1;
    end
    % choose color by index
    cmap = sample(index, :);
    
end
