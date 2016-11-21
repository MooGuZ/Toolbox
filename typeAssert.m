function var = typeAssert(var, type, convertFunc)
% TYPEASSERT convert given variable to given type TYPE, if it is not in
% that type at this time. This function always returns a variable in TYPE.
if not(isa(var, type))
    if exist('convertFunc', 'var')
        var = convertFunc(var);
    else
        eval(sprintf('var = %s(var);', type));
    end
end
