function C = pack2cell(data, dim)
% PACK2CELL divide numeric array DATA into samples and store them in an
% cell array. DIM, which is optional, indicates the dimension of a sample.
% By default, PACK2CELL take the last axis, whose length is not 1, as the
% sample axis.
if isempty(data)
    C = cell();
    return
end

if not(exist('dim', 'var'))
    dim = nndims(data) - 1;
end

if dim < nndims(data)
    if dim < 1
        C = arrayfun(@(x) x, data(:), 'UniformOutput', false);
    else
        smpsize = size(data);
        smpsize = smpsize(1 : dim);
        data = vec(data, dim, 'both');
        C = arrayfun(@(i) reshape(data(:, i), smpsize), 1 : size(data, 2), ...
            'UniformOutput', false);
    end
else
    C = {data};
end
    