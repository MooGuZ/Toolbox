function x = vec(x, dim, mode)
% VEC vectorize an array according to given options
%
% [OPTIONS]
%   DIM : positive integer, indicating the dimension that accounts for
%         vectorization unit. For example, DIM = 2 means VEC would collapse
%         first 2 dimension into 1.
%   MODE : 'front', 'back', or 'both'. 'front' means collapsing each unit;
%          while 'back' means combine all higher dimensions into one. And,
%          'both' means do 'front' and 'back' vecterization at same time,
%          and return a two dimension matrix.
if isempty(x)
    return
end

if exist('dim', 'var')
    if ~exist('mode', 'var')
        mode = 'front';
    end
    
    sz = size(x);
    
    switch lower(mode)
        case {'front'}
            if dim <= 0
                x = reshape(x, [1, sz]);
            elseif numel(sz) > dim
                x = reshape(x, [prod(sz(1 : dim)), sz(dim + 1 : end)]);
            else
                x = x(:);
            end
            
        case {'back'}
            if dim <= 0
                x = x(:)';
            elseif numel(sz) > dim
                x = reshape(x, [sz(1 : dim), prod(sz(dim + 1 : end))]);
            end
            
        case {'both'}
            if dim <= 0
                x = x(:)';
            elseif numel(sz) > dim
                x = reshape(x, ...
                    [prod(sz(1 : dim)), prod(sz(dim + 1 : end))]);
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