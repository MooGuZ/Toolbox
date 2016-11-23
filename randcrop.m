function piece = randcrop(data, psize)
% RANDCROP crop one piece of data with specified dimension randomly.
%
% PIECE = RANDCROP(DATA, PIECESIZE)
%
% MooGu Z. <hzhu@case.edu>
% Jun 3, 2015 - Version 0.00 : initial commit

dsize  = MathLib.modarr(size(data), psize, false, @le);
sindex = arrayfun(@randi, size(data) - dsize + 1);
eindex = sindex + dsize - 1;
index  = arrayfun(@colon, sindex, eindex, 'UniformOutput', false);
piece  = data(index{:});
