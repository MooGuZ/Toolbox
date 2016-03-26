function DS = dsample(M,sz,Cov,alpha)
% DSAMPLE would down sample the movie to specified resolution with a 
% Gaussian filter discribed by it's covariance matrix.
%
%   M = dsample(M,SZ,COV) down sample the movie M to specified size SZ
%   with a Gaussian filter discribed by its 3x3 covariance matrix COV.
%
%   M = dsample(M,SZ,COV,ALPHA) down sample the movie with calculation area
%   set as ALPHA multiply standard deviation on each direction.
%
% see also movresize, sample and vds.
%
% MooGu Z. <hzhu@case.edu>
% April 25, 2014 - Version 0.3
%
% [Change Log]
% 0.2 : Fix the bug caused by disparity of meshgrid and matrix coordinates
% 0.3 : Apply approximation method to avoid recalculate Gaussian parameters

if ~exist('alpha','var'), alpha = 3; end

DS = zeros(sz); % Initialize Down Sample Movie

% Check Diagnality of Covariance Matrix
isdiag = ~any(any(Cov-diag(diag(Cov))));
if ~isdiag
    [V,D] = eig(Cov);   % Diagnalize Covariance Matrix
    dinv  = 1./diag(D); % Eigen Value of Inverse Covariance Matrix
else
    dinv  = 1./diag(Cov);
end

% Calculation Radius Estimation
if isdiag
    rcal = alpha * sqrt(diag(Cov));
else
    rcal = alpha * max(V*sqrt(D),[],2);
end
% Not Allow any element of Rcal less than 0.5
rcal = max(rcal,0.5);

% Calculate Relative Coordinates of Downsampled Movie Pixels
[mrow,mcol,mtime] = size(M);
R = linspace(1,mrow,sz(1));  % row coordinates
C = linspace(1,mcol,sz(2));  % column coordinates
T = linspace(1,mtime,sz(3)); % time coordinates

% Gaussian Filter Function
if isdiag
    Gaussian = @(x) exp(-sum(bsxfun(@times,dinv,x.^2))/2);
else
    Gaussian = @(x) exp(-sum(bsxfun(@times,dinv,(V'*x).^2))/2);
end

% Relative Coordinates of each Pixel Calculation Area
[X,Y,Z] = meshgrid( ...
    -.5-floor(rcal(2)-.5):1:.5+floor(rcal(2)-.5), ...
    -.5-floor(rcal(1)-.5):1:.5+floor(rcal(1)-.5), ...
    -.5-floor(rcal(3)-.5):1:.5+floor(rcal(3)-.5));
[frow,fcol,ftime] = size(Y);
POS = [Y(:),X(:),Z(:)]';
% Gaussian Filter Paramter
Filter = Gaussian(POS);
Filter = reshape(Filter/sum(Filter),frow,fcol,ftime);

% Index Calculate Function
sind = @(x,r) floor(x) - floor(r-.5);      % Start Index
eind = @(x,r) floor(x) + floor(r-.5) + 1;  % End Index
% Down Sampling by Gaussian Filter
for i = 1 : numel(R)
    mrstart = sind(R(i),rcal(1));   % Start Row Index of Movie
    mrend   = eind(R(i),rcal(1));   % End Row Index of Movie
    % Start Row Index of Filter
    if mrstart < 1
        frstart = 2 - mrstart;
        mrstart = 1; 
    else
        frstart = 1; 
    end
    % End Row Index of Filter
    if mrend > mrow
        frend = frow - (mrend - mrow);
        mrend = mrow;
    else
        frend = frow;
    end
    for j = 1 : numel(C)
        mcstart = sind(C(j),rcal(2));   % Start Column Index of Movie
        mcend   = eind(C(j),rcal(2));   % End Column Index of Movie
        % Start Column Index of Filter
        if mcstart < 1
            fcstart = 2 - mcstart;
            mcstart = 1;
        else
            fcstart = 1;
        end
        % End Column Index of Filter
        if mcend > mcol
            fcend = fcol - (mcend - mcol);
            mcend = mcol;
        else
            fcend = fcol;
        end
        for k = 1 : numel(T)
            mtstart = sind(T(k),rcal(3));   % Start Time Index of Movie
            mtend   = eind(T(k),rcal(3));   % End Time Index of Movie
            % Start TIme Index of Filter
            if mtstart < 1
                ftstart = 2 - mtstart;
                mtstart = 1;
            else
                ftstart = 1;
            end
            % End Time Index of Filter
            if mtend > mtime
                ftend = ftime - (mtend - mtime);
                mtend = mtime;
            else
                ftend = ftime;
            end
            % Data and Filter
            data   = M(mrstart:mrend,mcstart:mcend,mtstart:mtend);
            % Normalization when Exceed the Boundary
            if frstart ~= 1 || fcstart ~=1 || ftstart ~= 1 ...
                    || frend ~= frow || fcend ~= fcol || ftend ~= ftime
                filter = Filter(frstart:frend,fcstart:fcend,ftstart:ftend);
                filter = filter(:) / sum(filter(:));
            else
                filter = Filter(:);
            end
            % Apply Gaussian Filter
            DS(i,j,k) = data(:)' * filter;
        end
    end
end

end
