function outputArg = containsIs(inputArg)
    set_rules;
    outputArg = false;
    if isempty(inputArg)
        return
    end
    outputArg = any(inputArg == Rules('Is'));
end