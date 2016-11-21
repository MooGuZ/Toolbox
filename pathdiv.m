function part = pathdiv(p)
index = find(p == filesep);
if isempty(index)
    part = {p};
else
    n = numel(index);
    if index(1) == 1
        n = n - 1;
    else
        index = [0, index];
    end
    if index(end) ~= numel(p)
        index = [index, numel(p) + 1];
        n = n + 1;
    end
    part = cell(1, n);
    for i = 1 : numel(part)
        part{i} = p(index(i) + 1 : index(i+1) - 1);
    end
end