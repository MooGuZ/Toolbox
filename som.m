function [map_label,proto] = som(data,map,param)

% Function Switchers
swSpInit = isfield(param,'init') && ~isempty(param.init);

[d,nsample] = size(data);
[nproto, ~] = size(map);

lrate = param.learning_rate; % Learning Rate

% Define Connective Tightness Function
G = @(sigma,xsquare)(exp(-1/(2*sigma^2)*xsquare));
s = param.sigma; % Sigma for Gaussion Distribution

% Initialize Prototypes in Space
if swSpInit
    proto = param.init;
else
    proto = bsxfun(@plus,mean(data,2),...
        bsxfun(@times,std(data,0,2),rand(d,nproto)));
end
% Cache Moving Rates for Prototypes
mrate = zeros(nproto);
for i = 1 : nproto
    % For each prototype as moving center
    mrate(i,:) = G(s,sum(bsxfun(@minus,map,map(i,:)).^2,2)');
end
% Adapting Prototypes to Data points
for i = 1 : param.niter
    for j = 1 : nsample
        % Find Nearest Prototype
        [~,pid] = min(sum(bsxfun(@minus,proto,data(:,j)).^2));
        % Move Prototypes to the Data Point
        proto = proto + lrate * bsxfun(@times,mrate(pid,:),...
            bsxfun(@minus,data(:,j),proto));
    end
end
% Classify Data Points to Prototypes
dist = zeros(nproto,nsample);
for i = 1 : nproto
    dist(i,:) = sum(bsxfun(@minus,data,proto(:,i)).^2);
end
[~,map_label] = min(dist);

end