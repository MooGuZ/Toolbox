function piece = randcrop(data, psize, ncrop)
% RANDCROP crop one piece of data with specified dimension randomly.
%
% PIECE = RANDCROP(DATA, PIECESIZE)
%
% MooGu Z. <hzhu@case.edu>
% Jun 3, 2015 - Version 0.00 : initial commit

if iscell(data)
    if exist('ncrop', 'var')
        assert(numel(data) == numel(ncrop));
        piece = cell(1, sum(ncrop));
        for i = 1 : numel(ncrop)
            for j = 1 : ncrop(i)
                piece{sum(ncrop(1 : i-1)) + j} = randcrop(data{i}, psize);
            end
        end
    else
    end
else
    if not(exist('ncrop', 'var'))
        dsize  = MathLib.modarr(size(data), psize, false, @le);
        sindex = arrayfun(@randi, size(data) - dsize + 1);
        eindex = sindex + dsize - 1;
        index  = arrayfun(@colon, sindex, eindex, 'UniformOutput', false);
        piece  = data(index{:});
    else
        piece = randcrop({data}, psize, ncrop);
    end
end
