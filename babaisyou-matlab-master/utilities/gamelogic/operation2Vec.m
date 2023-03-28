function vec = operation2Vec(operationType)
    % vec: [y, x]
    if ~ismember(operationType, {'None', 'Left', 'Right', 'Up', 'Down'})
        error("Operation must be 'None', 'Left', 'Right', 'Up', 'Down'")
    end

    switch operationType
        case 'None'
            vec = [];
        case 'Left'
            vec = [0, -1];
        case 'Right'
            vec = [0, 1];
        case 'Up'
            vec = [1, 0];
        case 'Down'
            vec = [-1, 0];
    end

end