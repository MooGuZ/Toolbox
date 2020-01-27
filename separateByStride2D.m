function dataGroup = separateByStride2D(data, stride)
    % STEP 1: separate data in group by stride
    remrow = mod(size(data, 1), stride(1));
    remcol = mod(size(data, 2), stride(2));
    % add padding to data
    if remrow && remcol
        buffer = padarray(data, stride - [remrow, remcol], 0, 'post');
    elseif remrow
        buffer = padarray(data, [stride(1) - remrow, 0], 0, 'post');
    elseif remcol
        buffer = padarray(data, [0, stride(2) - remcol], 0, 'post');
    else
        buffer = data;
    end
    % reform to data group
    h = size(buffer, 1) / stride(1);
    w = size(buffer, 2) / stride(2);
    % reshape data into groups
    dataGroup = reshape(buffer, stride(1), h, stride(2), w);
    % reorder axis to put data in each grounp in first 2 dimensions
    dataGroup = permute(dataGroup, [2, 4, 1, 3]);
    % reshape data groups to make groups on 3rd axis
    dataGroup = reshape(dataGroup, h, w, []);
end
