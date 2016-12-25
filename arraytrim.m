function A = arraytrim(A, value)
% ARRAYTRIM trim specific trailing value of an array
%
% A = ARRAYTRIM(A, VALUE) trim A by remove trailing VALUE. Currently,
% returning array A at least have one element.
%
% MooGu Z. <hzhu@case.edu>
% Dec 20, 2016

index = find(A(:) ~= value, 1, 'last');
if isempty(index)
    A = value;
else
    A = A(1 : index);
end