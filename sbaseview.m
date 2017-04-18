function f = sbaseview(base, varargin)
% SBASEVIEW show static bases in a GUI.

    conf = Config(varargin);

    pos = layout();

    % data structure in GUI
    ws = struct();
    
    % special case
    if ndims(base) ~= 3
        hw = sqrt(size(base, 1));
        assert(MathLib.isinteger(hw), 'Shape is wrong');
        base = reshape(base, hw, hw, size(base, 2));
    end
    
    ws.base = base + 0.5;
    ws.ibase = 1;
    ws.dmode = 'single';
    ws.bgcolor = [0.94, 0.94, 0.94];
    ws.summary = generateSummary(ws.base);

    % create figure
    f = figure( ...
        'Name',            conf.pop('title', 'Static Base Inspector'), ...
        'Position',        pos.figure,  ...
        'Visible',         'off', ...
        'Color',           ws.bgcolor, ...
        'CloseRequestFcn', @close);

    ws.animAxes = axes( ...
        'Units', 'Pixels', ...
        'xtick', [], ...
        'ytick', [], ...
        'Position', pos.animAxes);

    switch lower(ws.dmode)
        case {'single'}
            ws.hanim = imshow(ws.base(:, :, ws.ibase), [0, 1]);
            
        case {'summary'}
            ws.hanim = imshow(ws.summary);
            
        otherwise
            error('Something wrong in the program');
    end
    
    ws.prevButton = uicontrol( ...
        'Parent', f, ...
        'Style', 'pushbutton', ...
        'String', 'PREV', ...
        'Position', pos.prevButton, ...
        'Callback', @prevBase);
    
    ws.nextButton = uicontrol( ...
        'Parent', f, ...
        'Style', 'pushbutton', ...
        'String', 'NEXT', ...
        'Position', pos.nextButton, ...
        'Callback', @nextBase);
    
    ws.bindexText = uicontrol( ...
        'Parent', f, ...
        'Style',  'text', ...
        'String', ['Base - ', num2str(ws.ibase)], ...
        'FontSize', round(0.8 * pos.bindexText(4)), ...
        'Position', pos.bindexText, ...
        'Enable', 'inactive', ...
        'ButtonDownFcn', @editBaseIndex, ...
        'Visible', 'on');
        
    ws.bindexEdit = uicontrol( ...
        'Parent', f, ...
        'Style',  'edit', ...
        'String', '', ...
        'Position', pos.bindexEdit, ...
        'Callback', @gotoBase, ...
        'Visible', 'off');
    
    ws.cmapSelector = uibuttongroup( ...
        'Parent', f, ...
        'Units', 'Pixels', ...
        'Title', 'Color Map', ...
        'Position', pos.cmapSelector, ...
        'SelectionChangedFcn', @selectCMap);
    
    ws.cmapGray = uicontrol( ...
        'Parent', ws.cmapSelector, ...
        'Units', 'Normalized', ...
        'Style', 'radiobutton', ...
        'String', 'Gray', ...
        'Position', [0.1, 0.1, 0.35, 0.8], ...
        'HandleVisibility', 'off');
    
    ws.cmapColorful = uicontrol( ...
        'Parent', ws.cmapSelector, ...
        'Units', 'Normalized', ...
        'Style', 'radiobutton', ...
        'String', 'Colorful', ...
        'Position', [0.55, 0.1, 0.35, 0.8], ...
        'HandleVisibility', 'off');
    
    set(ws.cmapSelector, 'SelectedObject', ws.cmapGray);
    
    ws.dmodeSelector = uibuttongroup( ...
        'Parent', f, ...
        'Units', 'Pixels', ...
        'Title', 'Display Mode', ...
        'Position', pos.dmodeSelector, ...
        'SelectionChangedFcn', @selectDMode);
    
    ws.dmodeSingle = uicontrol( ...
        'Parent', ws.dmodeSelector, ...
        'Units', 'Normalized', ...
        'Style', 'radiobutton', ...
        'String', 'Single', ...
        'Position', [0.1, 0.1, 0.35, 0.8], ...
        'HandleVisibility', 'off');
    
    ws.dmodeSummary = uicontrol( ...
        'Parent', ws.dmodeSelector, ...
        'Units', 'Normalized', ...
        'Style', 'radiobutton', ...
        'String', 'Summary', ...
        'Position', [0.55, 0.1, 0.35, 0.8], ...
        'HandleVisibility', 'off');
    
    set(ws.dmodeSelector, 'SelectedObject', ws.dmodeSingle);

    guidata(f, ws);
    movegui(f, 'center');
    set(f, 'ResizeFcn', @layout);
    set(f, 'Visible',   'on');
end

function pos = layout(hObject, ~)
    a = 512; % anim-axes size
    o = 16;  % object size
    b = 20;  % border width
    v = 10;  % interval width between objects
    
    pos = struct();
    
    % size of fixed-size objects
    objsz = struct();
    objsz.prevButton = [50, 1.5*o];
    objsz.nextButton = objsz.prevButton;
    objsz.bindexText = [100, o];
    objsz.bindexEdit = objsz.bindexText;
    objsz.cmapSelector = [250, 3*o];
    objsz.dmodeSelector = [250, 3*o];
    
    % position of figure and size of animation axes
    fixedSpace = [2*b, 2*b + 3*v + ...
        objsz.prevButton(2) + objsz.cmapSelector(2)];
    if exist('hObject', 'var')
        pos.figure = get(hObject, 'Position');
        objsz.animAxes = pos.figure(3 : 4) - fixedSpace;
    else
        objsz.animAxes = [a, a];
        pos.figure = [0, 0, objsz.animAxes + fixedSpace];
    end
    
    % calculate objects' position
    pos.cmapSelector = [b, b, objsz.cmapSelector];
    pos.dmodeSelector = [pos.figure(3) - b - objsz.dmodeSelector(1), b, objsz.dmodeSelector];
    pos.prevButton = [b, sum(pos.cmapSelector([2, 4])) + v, objsz.prevButton];
    pos.nextButton = [pos.figure(3) - b - objsz.nextButton(1), pos.prevButton(2), objsz.nextButton];
    pos.bindexText = [round((pos.figure(3) - objsz.bindexText(1))/2), pos.prevButton(2), objsz.bindexText];
    pos.bindexEdit = pos.bindexText;
    pos.animAxes   = [b, sum(pos.prevButton([2, 4])) + v, objsz.animAxes];
    
    % arrange objects if capable
    if exist('hObject', 'var')
        ws = guidata(hObject); 
        % assistant vector to prevent negative width/height
        threshold = [-Inf, -Inf, eps, eps];   
        set(ws.animAxes,   'Position', max(pos.animAxes, threshold));
        set(ws.prevButton, 'Position', max(pos.prevButton, threshold));
        set(ws.nextButton, 'Position', max(pos.nextButton, threshold));
        set(ws.bindexText, 'Position', max(pos.bindexText, threshold));
        set(ws.bindexEdit, 'Position', max(pos.bindexEdit, threshold));
        set(ws.cmapSelector, 'Position', max(pos.cmapSelector, threshold));
        set(ws.dmodeSelector, 'Position', max(pos.dmodeSelector, threshold));
    end
end

function close(~, ~)
%     ws = guidata(hObject);
%     if isfield(ws, 'tmr')
%         stop(ws.tmr);
%         delete(ws.tmr);
%     end
    closereq
end

% function animateBase(~, ~, f)
%     ws = guidata(f);
%     setAnimProgress(f, ws.anim.progress + 1 / ws.anim.nframe);
% end

function setBaseIndex(hObject, index)
    ws = guidata(hObject);
    ws.ibase = MathLib.bound(round(index), [1, size(ws.base, 3)]);
    guidata(hObject, ws);
    showBase(hObject);
end

function showBase(hObject, ~)
    ws = guidata(hObject);
    switch lower(ws.dmode)
        case {'single'}
            I = ws.base(:, :, ws.ibase);
            set(ws.bindexText, 'String', ['Base - ', num2str(ws.ibase)]);
            
        case {'summary'}
            I = ws.summary;
            set(ws.bindexText, 'String', 'Summary');
            
        otherwise
            error('Something wrong in the program');
    end
    set(ws.hanim, 'CData', I);
    guidata(hObject, ws);
end

% function setAnimProgress(hObject, progress)
%     ws = guidata(hObject);
%     ws.anim.progress = wrapTo360(progress * 360) / 360;
%     switch lower(ws.dmode)
%         case {'real'}
%             I = real(ws.base(:, :, ws.ibase) * exp(-2j * pi * ws.anim.progress)) + 0.5;
%             
%         case {'complex'}
%             I = mat2img(ws.base(:, :, ws.ibase) * exp(-2j * pi * ws.anim.progress));
%             
%         otherwise
%             error('Something wrong in the program');
%     end
%     set(ws.hanim, 'CData', I);
%     set(ws.animSlider, 'Value', ws.anim.progress);
%     guidata(hObject, ws);
% end

function prevBase(hObject, ~)
    ws = guidata(hObject);
    setBaseIndex(hObject, ws.ibase - 1);
end

function nextBase(hObject, ~)
    ws = guidata(hObject);
    setBaseIndex(hObject, ws.ibase + 1);
end

function gotoBase(hObject, ~)
    ws = guidata(hObject);
    indexString = get(ws.bindexEdit, 'String');
    if not(isempty(indexString))
        index = round(str2double(indexString));
        if isnan(index)
            warning('Input is not a valid index');
        else
            setBaseIndex(hObject, index);
        end
    end
    set(ws.bindexEdit, 'Visible', 'off');
    set(ws.bindexText, 'Visible', 'on');
    uicontrol(ws.bindexText);
end

function editBaseIndex(hObject, ~)
    ws = guidata(hObject);
    set(ws.bindexEdit, 'String', '');
    set(ws.bindexText, 'Visible', 'off');
    set(ws.bindexEdit, 'Visible', 'on');
    uicontrol(ws.bindexEdit);
end

function selectCMap(hObject, eventData)
    ws = guidata(hObject);
    switch eventData.NewValue.String
        case {'Gray'}
            colormap(ws.hanim, 'gray');
            
        case {'Colorful'}
            colormap(ws.hanim, 'default');
            
        otherwise
            error('This cannot happend');
    end
    guidata(hObject, ws);
end

function selectDMode(hObject, eventData)
    ws = guidata(hObject);
    ws.dmode = eventData.NewValue.String;
    guidata(hObject, ws);
    showBase(hObject);
end

function img = generateSummary(bases)
    boarder = 3;
    % get shape information of bases
    [h, w, n] = size(bases);
    % make arrangement of bases
    [row, col] = arrange(n);
    % generate cell of bases
    imgcell = cell(row, col);
    % fillup cells
    background = zeros([h, w] + 2 * boarder);
    for i = 1 : n
        imgcell{i} = background;
        imgcell{i}(boarder + (1 : h), boarder + (1 : w)) = bases(:, :, i);
    end
    % fill up following cells
    for j = 1 : numel(imgcell) - n
        imgcell{n + j} = background;
    end
    % create summary image
    img = cell2mat(imgcell);
end
