function f = animview(data, varargin)
% ANIMVIEW create a GUI object to play given animation(s) with support of
% play/pause button and frame-corresponding slider.
%
%   F = ANIMVIEW(DATA) create a GUI object with figure handle F to play
%   animation in DATA. Assuming DATA is a 2D or 3D matrix of float values
%   in range of [0,1] that representing a gray-scale animation. The last
%   dimension of DATA is considered as axes of animation frames. If DATA is
%   a 2D matrix, ANIMVIEWER would try to recover frames in the vectors into
%   NxN matrix automatically. If this operation failed, an error would be
%   raised. DATA can also be a cell array of data with same quantity of frames
%   in each ones.
%
%   F = ANIMVIEW(DATA, PROPLIST...) provide interface to make deeper
%   modification. PROPLIST is composed by key and value pairs. Supported
%   keys are 'CMAP', 'DISPMODE', and 'RESOLUTION'.
%
% MooGu Z. <hzhu@case.edu>
% June 4, 2017
    conf = Config(varargin);
    % work space
    ws = struct();
    % put data into cell for uniform processing
    if not(iscell(data))
        data = {data};
    end
    % pre-processing of data
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
            if not(isfield(ws, 'resolution'))
                if conf.exist('resolution')
                    ws.resolution = conf.pop('resolution');
                else
                    n = size(data{i}, 1);
                    assert(round(sqrt(n))^2 == n, ...
                        'Need resolution information');
                    ws.resolution = sqrt([n, n]);
                end
            end
            data{i} = reshape(data{i}, [ws.resolution, size(data{i}, 2)]);
        end
        % check consistency
        if isfield(ws, 'nframe')
            assert(size(data{i}, 3) == ws.nframe, 'INCONSISTANT IN FRAME QUANTITY');
            assert(size(data{i}, 4) == ws.batchsize, 'INCONSISTANT IN BATCHSIZE');
        else
            ws.nframe    = size(data{i}, 3);
            ws.batchsize = size(data{i}, 4);
            assert(ws.nframe > 1, 'ANIMVIEWER REQUIRE AT LEAST 2 FRAMES');
        end
    end
    ws.data = data;
    % initialize parameters
    ws.inited  = false;
    ws.fcount  = 1;
    ws.bcount  = 1;
    ws.bgcolor = conf.pop('BackGroundColor', 0.94 * ones(1, 3));
    if (ws.nframe < 21)
        ws.sliderstep = (1 / (ws.nframe - 1)) * [1, 1];
    else
        ws.sliderstep = [1 / (ws.nframe - 1), 0.1];
    end
    % load icons
    icnpath = fullfile(fileparts(mfilename('fullpath')), 'material');
    ws.icon.play  = imresize( ...
        imread(fullfile(icnpath, 'play.png'), 'png', 'BackgroundColor', ws.bgcolor), ...
        [16, 16]);
    ws.icon.pause = imresize( ...
        imread(fullfile(icnpath, 'pause.png'), 'png', 'BackgroundColor', ws.bgcolor), ...
        [16, 16]);
    % initialize figure in invisible mode
    f = figure( ...
        'Name',            conf.pop('title', 'Animation Viewer'), ...
        'Visible',         'off', ...
        'Color',           ws.bgcolor, ...
        'CLoseRequestFcn', @closeView);
    % create GUI elements
    ws.animAxes = cell(1, numel(ws.data));
    ws.himage   = cell(1, numel(ws.data));
    for i = 1 : numel(ws.data)
        ws.animAxes{i} = axes( ...
            'Parent', f, ...
            'Units',  'Pixels', ...
            'xtick',  [], ...
            'ytick',  []);
        ws.himage{i} = imshow(ws.data{i}(:, :, 1, 1));
    end
    
    ws.slider = uicontrol( ...
        'Parent',     f, ...
        'Style',      'Slider', ...
        'Value',      1, ...
        'Max',        ws.nframe, ...
        'Min',        1, ...
        'SliderStep', ws.sliderstep, ...
        'Callback',   @jumpToFrame);
    
    ws.listener = addlistener(ws.slider, 'ContinuousValueChange', @jumpToFrame);
    
    ws.ppButton  = uicontrol( ...
        'Parent',   f, ...
        'Style',    'pushbutton', ...
        'String',   '', ...
        'CData',    ws.icon.pause, ...
        'Callback', @playpause);
    
    if ws.batchsize > 1
        ws.prevButton = uicontrol( ...
            'Parent',   f, ...
            'Style',    'pushbutton', ...
            'String',   'PREV', ...
            'Callback', @prevAnim);
        ws.nextButton = uicontrol( ...
            'Parent',   f, ...
            'Style',    'pushbutton', ...
            'String',   'NEXT', ...
            'Callback', @nextAnim);
        ws.label = uicontrol( ...
            'Parent', f, ...
            'Style',  'text', ...
            'String', sprintf('ANIM %02d - FRAME %02d', ws.bcount, ws.fcount));
    else
        ws.label = uicontrol( ...
            'Parent', f, ...
            'Style',  'text', ...
            'String', sprintf('FRAME %02d', ws.fcount));
    end
        
    ws.tmr = timer('TimerFcn', {@playAnim, f}, ...
                   'BusyMode', 'Queue', ...
                   'ExecutionMode', 'FixedRate', ...
                   'Period', 0.1);
            
    % guidata(f, ws);
    f.UserData = ws;
    
    % ------------- RUN -------------
    layout(f);

    if not(strcmpi(get(f, 'WindowStyle'), 'docked'))
        movegui(f, 'center');
    end
    
    set(f, 'ResizeFcn', @layout);
    set(f, 'Visible',   'on');
    
    start(ws.tmr);
end

function layout(canvas, ~)
    b = 20; % border width
    v = 10; % interval width between objects
    
    % information of objects' size
    szinfo = struct( ...
        'axis',       [256, 256], ...
        'textbutton', [48, 24], ...
        'ppbutton',   [16, 16], ...
        'slider',     [inf, 16], ...
        'label',      [128, 24]);
    
    fig = ancestor(canvas,"figure","toplevel");
    ws  = fig.UserData;
    
    % make arrangement for axes
    [nrow, ncol] = arrange(numel(ws.data));
    
    % calculate minimum canvas size
    minCanvas = b * 2 + [v * (ncol - 1) + szinfo.axis(1) * ncol, ...
            v * (nrow + 1) + szinfo.axis(2) * nrow + szinfo.textbutton(2) + szinfo.ppbutton(2)];
    
    % obtain figure position
    if ws.inited
        canvasSize = get(canvas, 'Position');
        canvasSize = canvasSize(3:4);
        szinfo.axis = (canvasSize - b * 2 - [v * (ncol - 1), ...
            v * (nrow + 1) + szinfo.textbutton(2) + szinfo.ppbutton(2)]) ...
            ./ [ncol, nrow];
    else
        canvasSize = minCanvas;
        if not(strcmpi(get(canvas, 'WindowStyle'), 'docked'))
            set(canvas, 'Position', [0, 0, canvasSize]);
        end
        fig.UserData.inited = true;
    end
    % calculate width of slider
    szinfo.slider(1) = canvasSize(1) - b * 2 - v - szinfo.ppbutton(1);
    
    % calculate each objects position
    pos.ppbutton = [b, b, szinfo.ppbutton];
    pos.slider   = [v + sum(pos.ppbutton([1, 3])), b, szinfo.slider];
    pos.label    = [ ...
        (canvasSize(1) - szinfo.label(1)) / 2, ...
        sum(pos.ppbutton([2, 4])) + v, ...
        szinfo.label];        
    if isfield(ws, 'prevButton')
        pos.prevbutton = [b, pos.label(2), szinfo.textbutton];
        pos.nextbutton = [canvasSize(1) - b - szinfo.textbutton(1), pos.prevbutton(2 : 4)];
    end
    pos.axis = [b, v + sum(pos.label([2, 4])), (szinfo.axis + v).* [ncol, nrow] - v];
    
    % rearrange objects
    threshold = [-inf, -inf, eps, eps];
    set(ws.ppButton, 'Position', max(pos.ppbutton, threshold));
    set(ws.slider, 'Position', max(pos.slider, threshold));
    set(ws.label, 'Position', max(pos.label, threshold));
    if isfield(ws, 'prevButton')
        set(ws.prevButton, 'Position', max(pos.prevbutton, threshold));
        set(ws.nextButton, 'Position', max(pos.nextbutton, threshold));
    end
    for i = 1 : numel(ws.data)
        irow = floor((i - 1) / ncol) + 1;
        icol = i - (irow - 1) * ncol;
        xcrd = pos.axis(1) + (szinfo.axis(1) + v) * (icol - 1);
        ycrd = pos.axis(2) + (szinfo.axis(2) + v) * (nrow - irow);
        set(ws.animAxes{i}, 'Position', max([xcrd, ycrd, szinfo.axis], threshold));
    end
end

function closeView(hObject, ~)
    ws = ancestor(hObject,"figure","toplevel").UserData;
    if isfield(ws, 'tmr')
        stop(ws.tmr);
        delete(ws.tmr);
    end
    closereq
end

function prevAnim(hObject, ~)
    fig = ancestor(hObject,"figure","toplevel");
    fig.UserData.bcount = mod(fig.UserData.bcount - 2, fig.UserData.batchsize) + 1;
    showFrame(hObject);
end

function nextAnim(hObject, ~)
    fig = ancestor(hObject,"figure","toplevel");
    fig.UserData.bcount = mod(fig.UserData.bcount, fig.UserData.batchsize) + 1;
    showFrame(hObject);
end

function jumpToFrame(hObject, ~)
    fig = ancestor(hObject,"figure","toplevel");
    fig.UserData.fcount = round(get(hObject, 'Value'));
    showFrame(hObject);
end

function playpause(hObject, ~)
    ws = ancestor(hObject,"figure","toplevel").UserData;
    switch ws.tmr.Running
      case 'on'
        stop(ws.tmr);
        set(ws.ppButton, 'CData', ws.icon.play);
        
      case 'off'
        start(ws.tmr);
        set(ws.ppButton, 'CData', ws.icon.pause);
    end
end

function showFrame(hObject, ~)
    fig = ancestor(hObject,"figure","toplevel");
    ws  = fig.UserData;
    for i = 1 : numel(ws.data)
        set(ws.himage{i}, 'CData', ws.data{i}(:, :, ws.fcount, ws.bcount));
    end
    set(ws.slider, 'Value', ws.fcount);
    if isfield(ws, 'prevButton')
        set(ws.label, 'String', sprintf('ANIM %02d - FRAME %02d', ws.bcount, ws.fcount));
    else
        set(ws.label, 'String', sprintf('FRAME %02d', ws.fcount));
    end
    if strcmpi(ws.tmr.Running, 'on')
        fig.UserData.fcount = mod(ws.fcount, ws.nframe) + 1;
    end
end

function playAnim(~, ~, f)
    showFrame(f);
end
