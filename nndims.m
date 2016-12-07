function n = nndims(X)
% NNDIMS similar to build-in function NDIM, except that it return N as the
% effective dimension of X. More specifically, empty return NaN, scalar
% returns 0, and column vector returns 1.
if isempty(X)
    n = NaN;
elseif isscalar(X)
    n = 0;
elseif iscolumn(X)
    n = 1;
else
    n = numel(size(X));
end