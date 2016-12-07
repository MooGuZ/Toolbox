function M = expanddim(M, dim)
% EXPANDDIM reshape matrix by combine two dimensions
%
%  M = EXPANDDIM(M, DIM) combine dimension DIM and DIM + 1 of matrix M

msize = size(M);
M = reshape(M, [msize(1 : dim - 1), ...
    msize(dim) * msize(dim + 1), msize(dim + 2 : end)]);