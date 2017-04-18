function [M, R] = sltondim(M, dim, index)
% SLTONDIM select given sub-matrix indexed on specified dimension
%
%  [M, R] = SLTONDIM(M, DIM, INDEX) select slice with INDEX on dimension
%  DIM. M is a matrix containing all selected slices, and R is the residual
%  matrix.
%
% MooGu Z. <hxz244@case.edu>
% April 15, 2017
assert(dim > 0 && dim <= nndims(M), 'ILLEGAL DIMENSION');
[M, sz] = vec(M, dim, 'select');
if nargout > 1
    rindex = true(1, sz(dim));
    rindex(index) = false;
    R = reshape(M(:, rindex, :), [sz(1 : dim-1), sum(rindex), sz(dim+1 : end)]);
end
M = reshape(M(:, index, :), [sz(1 : dim-1), numel(index), sz(dim+1 : end)]);