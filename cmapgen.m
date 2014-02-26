function color_map = cmapgen(ncolor)
% CMAPGEN generate color map

noise = linspace(0,0.4,ncolor)';     % Amplitude
theta = 2*pi * ((1:ncolor)'/ncolor); % phase

color_map = [linspace(0,0.8,ncolor)',...
    0.5+noise.*sin(theta),0.5+noise.*cos(theta)];

color_map = ycbcr2rgb(color_map);

end