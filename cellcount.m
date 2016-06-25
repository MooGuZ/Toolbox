function n = cellcount(c, skipEmpty)
% CELLCOUNT count non-cell elements in cell hierarchy

if not(exist('skipEmpty', 'var'))
    skipEmpty = false;
end

n = 0;
for i = 1 : numel(c)
    if iscell(c{i})
        n = n + cellcount(c{i}, skipEmpty);
    elseif not(isempty(c{i}))
        n = n + 1;
    else
        if not(skipEmpty)
            n = n + 1;
        end
    end
end

