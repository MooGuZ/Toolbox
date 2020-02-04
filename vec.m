function [x, sz] = vec(x, dim, mode)
% VEC vectorize an array according to given options
%
% [OPTIONS]
%   DIM : positive integer, indicating the dimension that accounts for
%         vectorization unit. For example, DIM = 2 means VEC would collapse
%         first 2 dimension into 1.
%   MODE : 'front', 'back', or 'both'. 'front' means collapsing each unit;
%          while 'back' means combine all higher dimensions into one. And,
%          'both' means do 'front' and 'back' vecterization at same time,
%          and return a two dimension matrix. Besides, there is a new mode
%          supported : 'select', which collapses all lower dimension and
%          combines all higher dimension, would convert input into a cubic
%          shape, where the specified dimension laies on the 2nd.

sz = size(x);

if isempty(x)
    return
end

if exist('dim', 'var')
    if ~exist('mode', 'var')
        mode = 'front';
    end
    
    switch lower(mode)
        case {'front'}
            if dim <= 0
                x = reshape(x, [1, sz]);
            elseif dim < nndims(x)
                x = reshape(x, [prod(sz(1 : dim)), sz(dim + 1 : end)]);
            else
                x = x(:);
            end
            
        case {'back'}
            if dim <= 0
                x = x(:)';
            elseif dim < nndims(x)
                x = reshape(x, [sz(1 : dim), prod(sz(dim + 1 : end))]);
            end
            
        case {'both', 'square'}
            if dim <= 0
                x = x(:)';
            elseif dim < nndims(x)
                x = reshape(x, [prod(sz(1 : dim)), prod(sz(dim + 1 : end))]);
            else
                x = x(:);
            end
            
        case {'select', 'cubic'}
            if dim <= 0
                x = reshape(x, [1, 1, numel(x)]);
            elseif dim == 1
                x = reshape(x, [1, sz(1), prod(sz(2:end))]);
            elseif dim <= nndims(x)
                x = reshape(x, [prod(sz(1 : dim-1)), sz(dim), prod(sz(dim + 1 : end))]);
            else
                x = x(:);
            end                
            
        otherwise
            error('ArguemntError:MathLib', ...
                'Unrecognized vectorization mode : %s', upper(mode));
    end
else
    x = x(:);
end