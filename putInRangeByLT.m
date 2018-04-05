
function [data, scalar, offset] = putInRangeByLT(data, range)
    crange = [min(data(:)), max(data(:))];
    if any(isinf(crange))
        error('Input data contains INF, which is illegal');
    elseif crange(1) == crange(2)
        error('Input data is all equivalent, which is illegal');
    end
    % calculate scalar and offset
    scalar = diff(range) / diff(crange);
    offset = range(1) - crange(1) * scalar;
    % rescale data
    data = data * scalar + offset;
end