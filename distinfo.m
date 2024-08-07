function distinfo(data, dname, usegui)
% DISTINFO show distribution information of given data
%
% [OPTION]
%   USEGUI: use GUI interface to show the distribution information. Decided
%           by whether or not GUI module is available in current
%           environment.
if not(exist('usegui', 'var'))
    usegui = usejava('desktop');
end

if not(exist('dname', 'var'))
    dname = 'DISTRIBUTION';
end

if usegui
    nbins = round(min(max(numel(data) / 100, 10), 1000));
    histogram(data(:), nbins);
    title(dname);
else
    fprintf('%s >> MEAN:%-8.2e STD:%-8.2e  MAX:%-8.2e MIN:%-8.2e\n', ...
        dname, mean(data(:),"omitmissing"), std(data(:), "omitmissing"), max(data(:)), min(data(:)));
end