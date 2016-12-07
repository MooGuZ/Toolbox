function [M, R] = sltondim(M, dim, index)
% SLTONDIM select given sub-matrix indexed on specified dimension

msize = size(M);
M = reshape(M, [prod(msize(1 : dim - 1)), ...
    msize(dim), prod(msize(dim + 1 : end))]);

% create logic array for slice selecting
tf = false(1, msize(dim));
tf(index) = true;

if nargout > 1
    R = M(:, ~tf, :);
    rsize = [msize(1 : dim - 1), sum(~tf), msize(dim + 1 : end)];
    R = reshape(R, rsize);
end
M = M(:, tf, :);
msize = [msize(1 : dim - 1), sum(tf), msize(dim + 1 : end)];
M = reshape(M, msize);