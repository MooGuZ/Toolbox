
function index = baseIndex(bases)
    bases = bsxfun(@minus, bases, mean(bases));
    index = sum(bases.^2);
end