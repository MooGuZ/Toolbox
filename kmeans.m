function [kernel,label,state] = kmeans(data,k,labinit)

swShow = true; % Switcher of Show
if swShow
    niter = 0;
end

[d,nsample] = size(data);

% Initialize Groups
if exist('labinit','var')
    label = labinit;
else
    n = floor(nsample/k);
    index = randperm(nsample);
    label = ones(1,nsample);
    for i = 1 : k
        label(index((i-1)*n+1:i*n)) = i;
    end
end
state.label.init = label;

kernel = zeros(d,k);
dist = zeros(k,nsample);
label_record = zeros(1,nsample);
while any(label - label_record)
    label_record = label;
    for i = 1 : k
        % Calculate Kernels according to Groups
        kernel(:,i) = mean(data(:,label==i),2);
        % Recalculate Distance of Data Points to Each Kernel
        dist(i,:) = sum(bsxfun(@minus,data,kernel(:,i)).^2);
    end
    % Group according to Distances to each Kernel
    [error,label] = min(dist,[],1);
    % Classification Evaluation
    Q = mean(error);
    % Show Results
    if swShow
        niter = niter + 1;
        fprintf('Q[%2d] >> %.2f\n',niter,Q);
    end
end
state.label.final = label;

end

