function str = mlstr(lines)
% MLSTR convers cell array of strings, LINES, into single string
% interpreted as multiple line paragraph in MATLAB.
if iscell(lines) && not(isempty(lines))
    LF  = char(10); % '\n' in MATLAB string
    str = cell(1, numel(lines) * 2);
    str(1 : 2 : end) = lines(:);
    str(2 : 2 : end) = {LF};
    str = cat(2, str{:});
else
    str = '';
end
