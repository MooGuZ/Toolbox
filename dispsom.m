function dispsom(map,mlabel,dlabel,clabel,ftitle)

% Function Switchers
swPrint = true;
swClsfr = exist('clabel','var') && ~isempty(clabel);

% Estimate Minimum Distance between Map Points
d = min(sum(minus(map(1:end-1,:),map(2:end,:)).^2,2));

% Convert Grid Size to Marker Size
n2sz = @(x)(260/x);

% Create Figure
figure(); 
hold on
grid on
% Adjust Axis
axis equal
axis([min(map(:,1))-d,max(map(:,1))+d,...
    min(map(:,2))-d,max(map(:,2))+d]);
% Draw Prototypes as Circles
plot(map(:,1),map(:,2),'ok',...
    'MarkerSize',n2sz(sqrt(size(map,1))),'LineWidth',1);
if exist('ftitle','var'), title(ftitle); end
% Generate Color Map
Lset = sort(unique(dlabel));
cmap = cmapgen(numel(Lset));
% Remapping Data Labels
tmp = zeros(size(dlabel));
for i = 1 : numel(Lset)
    tmp(dlabel == Lset(i)) = i;
end
dlabel = tmp;
% Identify Classifier with Marker Type
if swClsfr
    % Generate Marker Map
    Cset = sort(unique(clabel));
    mmap = repmat('.sdo*+xph',1,ceil(numel(Cset)/9));
    mmap = mmap(1:numel(Cset));
    % Remapping Classifier Label
    tmp = zeros(size(clabel));
    for i = 1 : numel(Cset)
        tmp(clabel == Cset(i)) = i;
    end
    clabel = tmp;
end
% Draw Data Points with Random Position Close
% - to its Prototype
for i = 1 : numel(mlabel)
    if swClsfr
        markertype = mmap(clabel(i));
    else
        markertype = '.';
    end
    amp = d/2.5 * rand(1);
    pha = 2*pi * rand(1);
    plot(map(mlabel(i),1)+amp*cos(pha),...
        map(mlabel(i),2)+amp*sin(pha),...
        markertype,'Color',cmap(dlabel(i),:),...
        'MarkerSize',13);
end
hold off
drawnow

% Print SOM
if swPrint
    print(gcf,'-depsc2','-r300',['./fig/som-',datestr(now),'.eps']);
end

end
