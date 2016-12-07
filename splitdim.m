function M = splitdim(M, dim, sz)
% SPLITDIM reshape a matrix by split one specific dimension into multiple
% dimensions
%
%  M = SPLITDIM(M, DIM, SZ) reshape dimension DIM of matrix M into new size
%  SZ. If SZ is a scalar number, program split the dimension in to two, and
%  automatically calculate the length of 2nd dimension.

msize = size(M);
if isscalar(sz)
    sz = [sz, msize(dim) / sz];
end
M = reshape(M, [msize(1 : dim - 1), sz, msize(dim + 1 : end)]);