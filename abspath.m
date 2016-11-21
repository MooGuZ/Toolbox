% PRB: haven't been tested on Window, here assuming PWD return path with
%      drive name in design.
function p = abspath(p)
part = pathdiv(p);
% deal with root path
switch part{1}
    case {'~'}
        if ispc
            p = [getenv('HOMEDRIVE'), pathdiv(getenv('HOMEPATH'))];
        else
            p = pathdiv(getenv('HOME'));
        end
        
    case {'.'}
        p = pathdiv(pwd());
        
    case {'..'}
        p = pathdiv(pwd());
        assert(numel(p) >= 1);
        p = p(1 : end - 1);
        
    otherwise
        if ispc
            if p(2) == ':'
                p = part(1);
            else
                p = [pathdiv(pwd()), part(1)];
            end
        else
            if p(1) == filesep
                p = part(1);
            else
                p = [pathdiv(pwd()), part(1)];
            end
        end
end
% deal with following parts
for i = 2 : numel(part)
    switch part{i}
        case {'.'} % skip
                        
        case {'..'} % backward
            assert(numel(p) >= 1);
            p = p(1 : end - 1);
            
        case {'~'}
            error('ILLEGAL');
            
        otherwise
            p = [p, part(i)];
    end        
end
% generate full path
if ispc
    p = fullfile(p{:});
else
    p = fullfile('/', p{:});
end
% % add filesep for folder input
% if isdir(p)
%     p = [p, filesep];
% end

