function A = cell2array(C)
% CELL2ARRAY aims at converting same objects in a cell into a corresponding
% array. Error would arouse when failed.
A = reshape([C{:}], size(C));
