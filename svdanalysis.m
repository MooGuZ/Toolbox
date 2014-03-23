function [svalue,svectors,data] = svdanalysis(data,swClean)
%SVDANALYSIS process DATA with normal SVD analysis. Which contains data
% clean, singular decomposition, and resort singular vector according to
% singular value in decreasing order.
%
% [SVALUE,SVECTORS] = SVDANALYSIS(DATA) return singular values SVALUE and
% corresponding singular vectors SVECTORS of DATA. The singular value and
% corresponding singular vectors are sorted in decreasing order of singular
% values.
%
% See also, svdcompress, svddisp.
%
% MooGu Z. <hzhu@case.edu>
% Jan 30, 2014 - Version 0.1
% Mar 14, 2014 - Version 0.1.1
%   - Add input argument to select whether or not clean the data

if ~exist('swClean','var')
    swClean = false;
end

if swClean
    % Clear Data to Remove NaNs
    data = data(:,~any(isnan(data)));
    % Centralize the Data
    data = bsxfun(@minus,data,mean(data,2));
end

% Singular Value Decomposition
[U,S,~] = svd(data,'econ');

% Sort Singular Values and Vectors in Decreasing Order
[svalue,ind] = sort(diag(S),'descend');
svectors = U(:,ind);

end

