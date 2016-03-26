function v = vds(v,fsz,nfrm,sCutoff,tCutoff)
% VDS downsample video by filtering the video with 1-D Gaussian filter
% three times on spacial and temporal axes.
%
%   V = VDS(V,FSZ,NFRM,SCUTOFF,TCUTOFF) downsample video V to a video with  
%   frame size FSZ and frame number NFRM. SCUTOFF and TCUTOFF are optional 
%   and presenting cutoff power percentage for spacial and temporal axes. 
%   They are set as 0.001% by default.
%
% see also movresize, sample, and downsample.
%
% MooGu Z. <hzhu@case.edu>
% Jun 5, 2014 - Version 0.1

filterSizeFactor = 3; % Rate between filter size and its standard deviation

% Size of Original Video
[orsz,ocsz,onfrm] = size(v);
% Frame Size of Downsample Video
if numel(fsz)==1, rsz = fsz; csz = fsz;
else rsz = fsz(1); csz = fsz(2); end

if ~exist('sCutoff','var'), sCutoff = 1e-5; end
if ~exist('tCutoff','var'), tCutoff = 1e-5; end
% Estimate Standard Deviation of Gaussian Filter
rsigma = norminv(1-sCutoff/2,0,1) / (rsz*pi);  % Row
csigma = norminv(1-sCutoff/2,0,1) / (csz*pi);  % Column
tsigma = norminv(1-tCutoff/2,0,1) / (nfrm*pi); % Time

% filtering on row axes
if mod(orsz,rsz) == 0
    filterSize = floor(filterSizeFactor * rsigma * orsz);
    f = filterFunc((-filterSize:filterSize)/orsz,rsigma);
    normFactor = reshape(conv(ones(orsz,1),f,'same'),orsz,1,1);
    for c = 1 : ocsz
        for t = 1 : onfrm
            v(:,c,t) = conv(v(:,c,t),f,'same') ./ normFactor;
        end
    end
    sampleIndex = 1 : orsz/rsz : orsz;
    v = v(sampleIndex,:,:);
else
    buffer = zeros(rsz,ocsz,onfrm);
    opos = linspace(0,1,orsz);  % Original Pixel Position
    dpos = linspace(0,1,rsz);   % Downsample Pixel Position
    for r = 1 : rsz
        f = reshape(filterFunc(opos-dpos(r),rsigma),orsz,1,1);
        for c = 1 : ocsz
            for t = 1 : onfrm
                buffer(r,c,t) = sum(v(:,c,t).*f);
            end
        end
    end
    v = buffer;
end

% filtering on colum axes
if mod(ocsz,csz) == 0
    filterSize = floor(filterSizeFactor * csigma * ocsz);
    f = filterFunc((-filterSize:filterSize)/ocsz,csigma);
    normFactor = reshape(conv(ones(ocsz,1),f,'same'),1,ocsz,1);
    for r = 1 : rsz
        for t = 1 : onfrm
            v(r,:,t) = conv(v(r,:,t),f,'same') ./ normFactor;
        end
    end
    sampleIndex = 1 : ocsz/csz : ocsz;
    v = v(:,sampleIndex,:);
else
    buffer = zeros(rsz,csz,onfrm);
    opos = linspace(0,1,ocsz);  % Original Pixel Position
    dpos = linspace(0,1,csz);   % Downsample Pixel Position
    for c = 1 : csz
        f = reshape(filterFunc(opos-dpos(c),csigma),1,ocsz,1);
        for r = 1 : rsz
            for t = 1 : onfrm
                buffer(r,c,t) = sum(v(r,:,t).*f);
            end
        end
    end
    v = buffer;
end

% filtering on time axes
if mod(onfrm,nfrm) == 0
    filterSize = floor(filterSizeFactor * tsigma * onfrm);
    f = filterFunc((-filterSize:filterSize)/onfrm,tsigma);
    normFactor = conv(ones(onfrm,1),f,'same');
    for r = 1 : rsz
        for c = 1 : csz
            v(r,c,:) = conv(reshape(v(r,c,:),onfrm,1),f,'same') ...
                ./ normFactor;
        end
    end
    sampleIndex = 1 : onfrm/nfrm : onfrm;
    v = v(:,:,sampleIndex);
else
    buffer = zeros(rsz,csz,nfrm);
    opos = linspace(0,1,onfrm);  % Original Pixel Position
    dpos = linspace(0,1,nfrm);   % Downsample Pixel Position
    for t = 1 : nfrm
        f = reshape(filterFunc(opos-dpos(t),tsigma),1,1,onfrm);
        for r = 1 : rsz
            for c = 1 : csz
                buffer(r,c,t) = sum(v(r,c,:).*f);
            end
        end
    end
    v = buffer;
end

end

function f = filterFunc(x,sigma)
% FILTERFUNCTION map numbers to filter function value

f = exp(-(x.^2)/(2*sigma^2));   % Gaussian Distribution PDF
f = f / sum(f(:));              % Normalization

end