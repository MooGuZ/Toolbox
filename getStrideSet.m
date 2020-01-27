function [S, padsize] = getStrideSet(X, stride, referPoint, direction)
% GETSTRIDESET generate cell array containing 2D matrix in each unit which corresponding to a stride slice 
% of original matrix 
% 
%  S = GETSTRIDESET(X, STRIDE, [REFERPOINT, DIRECTION, PADDINGTYPE]) return stride set of X in stride size 
%  of STRIDE. REFERPOINT is a coordinate contained in the top left slice in returning stride set. It's set 
%  as [1,1] by default. DIRECTION can be 'normal' or 'reverse' corresponds to the direction of each slice 
%  arranged in original matrix. 
%
% Version 0.01 - Hao Zhu <hxz244@case.edu>
% Jul 30, 2018
    
    xsize = size(X);
    M = xsize(1);
    N = xsize(2);
    L = prod(xsize) / (M * N);
    m = stride(1);
    n = stride(2);
    
    % STEP 0 : setup default values
    if not(exist('referPoint', 'var')),  referPoint = [1,1];   end
    if not(exist('direction', 'var')),   direction = 'normal'; end
    
    % STEP 1 : padding matrix with zeros
    if all(referPoint == [1,1]) % post padding
        padsize = mod(-[M, N], [m, n]);
        P = padarray(X, padsize, 0, 'post');
    else % both-side padding
        switch direction
          case {'normal'}
            gridStart = referPoint;
            gridEnd   = referPoint + [m, n] - 1;
            
          case {'reverse'}
            gridEnd   = referPoint;
            gridStart = referPoint - [m, n] + 1;
        end
        % calculate padding size on each side
        nrowGrid = max(ceil((gridStart(1)-1) / m), ceil((M-gridEnd(1)) / m));
        ncolGrid = max(ceil((gridStart(2)-1) / n), ceil((N-gridEnd(2)) / n));
        padsizePre  = [nrowGrid * m, ncolGrid * n] - gridStart + 1;
        padsizePost = [nrowGrid * m, ncolGrid * n] - ([M, N] - gridEnd);
        % padding array
        P = padarray(padarray(X, padsizePre, 0, 'pre'), padsizePost, 0, 'post');
        % compose padding size
        padsize = [padsizePre, padsizePost];
    end
    
    % STEP 2 : compose stride slice from each grid
    nrow = size(P, 1) / m;
    ncol = size(P, 2) / n;
    % reshape to separate grids
    P = reshape(P, [m, nrow, n, ncol, L]);
    % permute to make slice in first two dimensions
    P = permute(P, [2, 4, 1, 3, 5]);
    % compose cell array
    S = cell(m, n, L);
    % fill-in each slice
    switch direction
      case {'normal'}        
        for i = 1 : m
            for j = 1 : n
                for k = 1 : L
                    S{i, j, k} = P(:, :, i, j, k);
                end
            end
        end
        
      case {'reverse'}
        for i = 1 : m
            for j = 1 : n
                for k = 1 : L
                    S{i, j, k} = P(:, :, m - i + 1, n - j + 1, k);
                end
            end
        end
    end
    % reshape cell array
    S = reshape(S, [m, n, xsize(3:end)]);
end
