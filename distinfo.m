function distinfo(data, dname, usegui)
% DISTINFO show distribution information of given data
%
% [OPTION]
%   USEGUI: use gui interface to show the distribution information. Decided
%           by whether or not GUI module is available in current
%           environment.
if not(exist('usegui', 'var'))
    usegui = usejava('desktop');
end

if not(exist('dname', 'var'))
    dname = 'DISTRIBUTION';
end

if usegui
    nbins = min(max(numel(data) / 100, 10), 1000);
    figure();
    hist(data(:), nbins);
    title(dname);
else
    fprintf('%s >> MEAN:%-8.2e\tVAR:%-8.2e\tMAX:%-8.2e\tMIN:%-8.2e\n', ...
        dname, mean(data(:)), var(data(:)), max(data(:)), min(data(:)));
end