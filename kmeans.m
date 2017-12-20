function [kernel, label, record] = kmeans(data, k)
% K-means algorithm with label random initialization
%
% See also kmeansplot.
%
% MooGu Z. <hzhu@case.edu>
    
    niter = 1;
    % initialize records    
    record = struct('kernel', {}, 'label', {});
    % find region of data
    maxval = max(data, [], 2);
    minval = min(data, [], 2);
    % initialize kernel
    kernel = rand(size(data, 1), k);
    kernel = bsxfun(@plus, bsxfun(@times, kernel, maxval - minval), minval);
    % EM-Algorithm to solve K-means clustering
    while true
        dist = cell2mat(arrayfun( ...
            @(i) sum(bsxfun(@minus, data, kernel(:, i)).^2), 1:k, ...
            'UniformOutput', false)');
        % update label
        [~, label] = min(dist);
        % udpate records
        record(niter) = struct('kernel', kernel, 'label', label);        
        % check stop criteria
        if niter > 1 && not(any(label - record(niter-1).label))
            break
        end
        % update iteration counter
        niter = niter + 1;
        % update kernel
        kernel = updateKernel(kernel, data, label);    
    end

end

function kernel = updateKernel(kernel, data, label)
% Routine to update kernel, this implementation would avoid NaN in the case
% that no data point belongs to a kernel.

    lset   = unique(label);
    buffer = cell2mat(arrayfun( ...
        @(i) mean(data(:, label == i), 2), lset, 'UniformOutput', false));
    kernel(:, lset) = buffer;

end

