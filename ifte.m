function value = ifte(condition, a, b)
% IFTE provide a convenient way to use if-then-else structure in value
% assigning process. This equivalent to operator '()?():()' in C/C++.

if condition
    value = a;
else
    value = b;
end