function f = animview(data)
% ANIMVIEW create a GUI object to play given animation(s) with support of
% play/pause button and frame-corresponding slider.
%
%   F = ANIMVIEW(DATA) create a GUI object with figure handle F to play
%   animation in DATA. Assuming DATA is a 2D or 3D matrix of float values
%   in range of [0,1] that representing a gray-scale animation. The last
%   dimension of DATA is considered as axes of animation frames. If DATA is
%   a 2D matrix, ANIMVIEWER would try to recover frames in the vectors into
%   NxN matrix automatically. If this operation failed, an error would be
%   raised. You can also put multiple animation in one time.
%
% MooGu Z. <hzhu@case.edu>
% April 29, 2024
arguments (Repeating)
    data
end

% back-compatible
if iscell(data{1})
    data = data{1};
end

% Regularize Data into Cell of Matrix
for i = 1 : numel(data)
    if isstruct(data{i}) || isa(data{i}, 'DataPackage')
        data{i} = data{i}.data;
    end
    % gather from GPU if necessary
    if isa(data{i}, 'gpuArray')
        data{i} = gather(data{i});
    end
    % reshape frames of data
    if numel(size(data{i})) == 2
        n = size(data{i}, 1);
        try
            data{i} = reshape(data{i}, [sqrt(n), sqrt(n), size(data{i}, 2)]);
        catch
            error('RESOLUTION INFORMAITON NEEDED!');
        end
    end
end

% Create Figure and Play Animation in it
f = initialize(data);
f.UserData.tmr = timer( ...
    'TimerFcn',      {@playAnim, f}, ...
    'BusyMode',      'Drop', ...
    'ExecutionMode', 'FixedRate', ...
    'Period',        0.1);
start(f.UserData.tmr);
end

%% Layout Initialization
function f = initialize(data)
ws = struct( ...
    'iframe', 0, 'nframe', min(cellfun(@(c) size(c,3), data)), ...
    'ianim',  1, 'nanim',  min(cellfun(@(c) size(c,4), data)));
% Figure and Layout Manager
f = uifigure( ...
    'Name',            'Animation Viewer', ...
    'Visible',         'on', ...
    'CloseRequestFcn', @closeView);
flayout = uigridlayout(f);
flayout.ColumnWidth = {25, 25, '1x', 25, 25};
flayout.RowHeight   = {'1x', 25, 25, 25};
% Panel containing all animations
ws.panel = uipanel(flayout);
ws.panel.Layout.Column = [1,5];
ws.panel.Layout.Row    = 1;
% Animations
[nrow, ncol] = arrange(numel(data));
playout = uigridlayout(ws.panel);
playout.ColumnWidth = repmat({'1x'}, 1, ncol);
playout.RowHeight   = repmat({'1x'}, 1, nrow);
ws.animplayer = cell(1,numel(data));
for i = 1 : numel(data)
    D = data{i}(:,:,1:ws.nframe,1:ws.nanim);
    ws.animplayer{i} = uiimage(playout, ...
        'UserData',        animExpand(D), ...
        'ImageClickedFcn', @playpause);
    ws.animplayer{i}.Layout.Column = mod(i-1,ncol) + 1;
    ws.animplayer{i}.Layout.Row    = ceil(i/ncol);
end
% Resize Figure
f.Position(3:4) = [ncol, nrow] * 280 + [20 125];
movegui(f, 'center');
% Button:Previous
ws.btnPrev = uibutton(flayout, ...
    'Text',            'PREV', ...
    'ButtonPushedFcn', @prevAnim, ...
    'Visible',         ws.nanim > 1);
ws.btnPrev.Layout.Column = [1,2];
ws.btnPrev.Layout.Row    = 2;
% Label
ws.label = uilabel(flayout, ...
    'FontSize',            14, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment',   'center');
ws.label.Layout.Column = 3;
ws.label.Layout.Row    = 2;
if ws.nanim > 1
    ws.label.UserData = @(i,j) sprintf('ANIM %02d - FRAME %02d', i, j);
else
    ws.label.UserData = @(~,j) sprintf('FRAME %02d', j);
end
% Button:Next
ws.btnNext = uibutton(flayout, ...
    'Text',            'NEXT', ...
    'ButtonPushedFcn', @nextAnim, ...
    'Visible',         ws.nanim > 1);
ws.btnNext.Layout.Column = [4,5];
ws.btnNext.Layout.Row    = 2;
% Button:Play&Pause
ws.btnPlayPause = uibutton(flayout, ...
    'Text',            '', ...
    'Icon',            'pause.png', ...
    'IconAlignment',   'center', ...
    'ButtonPushedFcn', @playpause);
ws.btnPlayPause.Layout.Column = [1,2];
ws.btnPlayPause.Layout.Row    = [3,4];
% Slider
ws.slider = uislider(flayout, ...
    'Value',            1, ...
    'Limits',           [1, ws.nframe], ...
    'MajorTicks',       [], ...
    'MinorTicks',       [], ...
    'ValueChangingFcn', @jumpToFrame);
ws.slider.Layout.Column = 3;
ws.slider.Layout.Row    = 3;
% Speed Information
ws.idelay     = 3;
ws.delayText  = {'0.25x', '0.5x', '1.0x', '2.0x', '4.0x'};
ws.delayValue = [0.4, 0.2, 0.1, 0.05, 0.025];
% Button:SlowDown
ws.btnSlowDown = uibutton(flayout, ...
    'Text',            '', ...
    'Icon',            'slowdown.png', ...
    'IconAlignment',   'center', ...
    'ButtonPushedFcn', @slowdown);
ws.btnSlowDown.Layout.Column = 4;
ws.btnSlowDown.Layout.Row    = 3;
% Button:SpeedUp
ws.btnSpeedUp = uibutton(flayout, ...
    'Text',            '', ...
    'Icon',            'speedup.png', ...
    'IconAlignment',   'center', ...
    'ButtonPushedFcn', @speedup);
ws.btnSpeedUp.Layout.Column = 5;
ws.btnSpeedUp.Layout.Row    = 3;
% Button:Reset
ws.btnReset = uibutton(flayout, ...
    'Text',            ws.delayText{ws.idelay}, ...
    'ButtonPushedFcn', @reset);
ws.btnReset.Layout.Column = [4,5];
ws.btnReset.Layout.Row    = 4;
% Ranger
ws.ranger = uislider(flayout, 'range', ...
    'Value',           [1, ws.nframe], ...
    'Limits',          [1, ws.nframe], ...
    'MajorTicks',      [], ...
    'MinorTicks',      [], ...
    'ValueChangedFcn', @setupRange);
ws.ranger.Layout.Column = 3;
ws.ranger.Layout.Row    = 4;
ws.ihead  = 1;
ws.length = ws.nframe;
% Record Layout
ws.flayout = flayout;
ws.playout = playout;
% Setup Shared Information
f.UserData = ws;
end

%% Callback Functions
function closeView(hObject, ~)
ws = ancestor(hObject,"figure","toplevel").UserData;
if isfield(ws, 'tmr')
    stop(ws.tmr);
    delete(ws.tmr);
end
closereq
end

function prevAnim(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.ianim = mod(f.UserData.ianim - 2, f.UserData.nanim) + 1;
showFrame(hObject);
end

function nextAnim(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.ianim = mod(f.UserData.ianim, f.UserData.nanim) + 1;
showFrame(hObject);
end

function jumpToFrame(hObject, valueChangingData)
f = ancestor(hObject,"figure","toplevel");
f.UserData.iframe = round(valueChangingData.Value);
showFrame(hObject);
end

function setDelay(f)
% Setup Text
f.UserData.btnReset.Text = ...
    f.UserData.delayText{f.UserData.idelay};
% Setup Timer
d = f.UserData.delayValue(f.UserData.idelay);
switch f.UserData.tmr.Running
    case 'on'
        stop(f.UserData.tmr);
        f.UserData.tmr.Period = d;
        start(f.UserData.tmr);

    case 'off'
        f.UserData.tmr.Period = d;
end
end

function speedup(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.idelay = ...
    min(f.UserData.idelay + 1, numel(f.UserData.delayValue));
setDelay(f);
end

function slowdown(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.idelay = ...
    max(f.UserData.idelay - 1, 1);
setDelay(f);
end

function reset(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.idelay = 3;
setDelay(f);
end

function setupRange(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
f.UserData.ihead  = floor(hObject.Value(1));
f.UserData.length = ceil(hObject.Value(2)) - floor(hObject.Value(1));
end

function playpause(hObject, ~)
ws = ancestor(hObject,"figure","toplevel").UserData;
switch ws.tmr.Running
    case 'on'
        stop(ws.tmr);
        ws.btnPlayPause.Icon  = "play.png";

    case 'off'
        start(ws.tmr);
        ws.btnPlayPause.Icon  = "pause.png";
end
end

function showFrame(hObject, ~)
f = ancestor(hObject,"figure","toplevel");
ws = f.UserData;
for i = 1 : numel(ws.animplayer)
    ws.animplayer{i}.ImageSource = ...
        ws.animplayer{i}.UserData(:,:,:,ws.iframe,ws.ianim);
end
% Label Information
ws.label.Text = ws.label.UserData(ws.ianim, ws.iframe);
end

function playAnim(~, ~, f)
f.UserData.iframe = ...
    mod(f.UserData.iframe - f.UserData.ihead + 1, f.UserData.length) + f.UserData.ihead;
showFrame(f);
% Slider Value
f.UserData.slider.Value = f.UserData.iframe;
end

%% Local Functions
function data = animExpand(data)
szinfo = size(data);
data = reshape(data, [szinfo(1:2), 1, szinfo(3:end)]);
data = repmat(data, 1, 1, 3);
end
