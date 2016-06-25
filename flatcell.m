function fc = flatcell(c)
% FLATCELL expend sub-cells in cell to return a cell with flat structure.
% This function also remove empty element.
%
% NOTE : current implementation need memory in scale of WIDTH(C) *
% HIGHT(C), in which, WIDTH(C) is the number of elements in flat cell, and
% HEIGHT(C) represent maximum level of sub-cell structure.

fc = cell(1, cellcount(c, true));

j = 0;
for i = 1 : numel(c)
    if iscell(c{i})
        n = cellcount(c{i}, true);
        fc(j + (1 : n)) = flatcell(c{i});
        j = j + n;
    elseif not(isempty(c{i}))
        j = j + 1;
        fc{j} = c{i};
    end
end

end