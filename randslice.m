function S = randslice(M, dim, n)
% RANDSLICE slice a matrix on specific dimension.
%
%  S = RANDSLICE(M, DIM, N) slice N consecutive slices on dimension DIM
%  of matrix M, and return a matrix S.
%
% MooGu Z. <hzhu@case.edu>
% April 15, 2017

assert(n >= 1 && size(M, dim) >= n, 'ILLEGAL ARGUMENTS');

if dim > nndims(M)
    S = M;
else
    [M, sz] = vec(M, dim, 'select');
    S = reshape(M(:, randi(size(M, 2) - n + 1) + (0 : n-1), :), ...
        [sz(1 : dim-1), n, sz(dim+1 : end)]);
end