function operationType  = enum2Operation(enum)
    % 1, 2, 3, 4 -> up, down, left, right
    if ~ismember(enum, [0, 1, 2, 3, 4])
        error("Enum must be 0, 1, 2, 3, or 4");
    end

    switch enum
        case 0
            operationType = 'None';
        case 3
            operationType = 'Left';
        case 4
            operationType = 'Right';
        case 1
            operationType = 'Up';
        case 2
            operationType = 'Down';
    end

end