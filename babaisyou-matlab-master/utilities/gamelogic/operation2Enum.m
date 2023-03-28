function enum = operation2Enum(operationType)
    % enum: up, down, left, right -> 1, 2, 3, 4
    if ~ismember(operationType, {'None', 'Left', 'Right', 'Up', 'Down'})
        error("Operation must be 'None', 'Left', 'Right', 'Up', 'Down'")
    end

    switch operationType
        case 'None'
            enum = 0;
        case 'Left'
            enum = 3;
        case 'Right'
            enum = 4;
        case 'Up'
            enum = 1;
        case 'Down'
            enum = 2;
    end

end