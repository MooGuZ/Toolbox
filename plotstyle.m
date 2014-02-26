function style = plotstyle(seed, att, bin)

% STEP 0: Propocess
% -----------------
% 0. Default Setting
if ~exist('bin', 'var')
    bin = 1;
end
if ~exist('att', 'var')
    att = 'normal';
end
% 1. Check Input
validateattributes(seed,  {'numeric'}, {'scalar', 'integer'}, ...
    'PLOTSTYLE', 'SEED',  1);
validateattributes(bin,   {'numeric'}, {'scalar', 'integer', 'positive'}, ...
    'PLOTSTYLE', 'BIN',   2);
validateattributes(att, {'char'}, {'vector', 'nonempty'}, ...
    'PLOTSTYLE', 'ATTRIBUTES', 3);
% 2. Styles List
color = 'bkrmcgy';
point = ' .osx+*dv^<>ph';
line  = {'-', ':', '-.', '--'};
% 3. Style List Length
clen  = length(color);
plen  = length(point);
llen  = length(line);


% STEP 1: Calculate Styles' Index
% -------------------------------
cind = mod(ceil(seed / bin) - 1, clen) + 1;
pind = mod(ceil(seed / (bin*clen)) - 1, plen) + 1;
lind = mod(ceil(seed / (bin*clen*plen)) - 1, llen) + 1;


% STEP 2: Compose Style String
% ----------------------------
% 1. Compose Style in NORMAL Mode
if strcmp(att,'normal')
    style = [color(cind), point(pind), line{lind}];
elseif strcmp(att,'solidline')
    style = [color(cind), point(pind), '-'];
elseif strcmp(att,'noline')
    style = [color(cind), point(pind)];
else
    error('plotstyle:unvaliableAttribute', 'Attribute %s is unavaliable', upper(att));
end

end
