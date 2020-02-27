function n = nndims(X)
% NNDIMS similar to build-in function NDIM, except that it return N as the
% effective dimension of X. More specifically, empty return NaN, scalar
% returns 0, and column vector returns 1.
xsize = size(X);
nelem = prod(xsize);
if nelem == 0
    n = nan;
elseif nelem == 1
    n = 0;
else
    n = find(xsize > 1, 1, 'last');
end
