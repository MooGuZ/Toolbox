function flist = listFileWithExt(path, varargin)
% LISTFIELWITHEXT would list all files with specified extention (start with
% '.'. This function would return all non-hidden files under specified path
% by default if no extention is specified.
%
% MooGu Z. <hzhu@case.edu>
%
% [CHANGE LOG]
% Nov 4, 2015 - initial commit
% May 24, 2016 - recursively search subfolders

if iscell(varargin{1})
    extSet = varargin{1};
else
    extSet = varargin;
end
% fetch all files information under the folder
finfolist = dir(path);
% initialize cell array
flist = cell(numel(finfolist), 1);
% search for files according to <animExtSet>
for i = 1 : numel(finfolist)
    % ignore hidden file and folders, including '.' and '..'
    if finfolist(i).name(1) == '.', continue; end
    % recursively search subfolder
    if finfolist(i).isdir
        subpath = fullfile(path, finfolist(i).name);
        flist{i} = listFileWithExt(subpath, extSet);
        flist{i} = cellfun(@(f) fullfile(finfolist(i).name, f), flist{i}, ...
            'UniformOutput', false);
        continue
    end
    % pick out animation files
    [~,~,ext] = fileparts(finfolist(i).name);
    if isempty(extSet) || any(strcmpi(ext,extSet))
        flist{i} = finfolist(i).name;
    end
end
% filter file name list
flist = flatcell(flist);

end