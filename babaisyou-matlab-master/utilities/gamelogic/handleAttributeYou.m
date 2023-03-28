function mapItem = handleAttributeYou(mapItem, operationType, ruleGraph)
    if strcmp(operationType, 'None')
        return
    end

    [height, width] = size(mapItem.gridmap);
    moveDirection = operation2Vec(operationType);

    % vec: [y, x]
    scanDirection = [1, 0]; % vertical
    if isVecParallel(moveDirection, scanDirection)
        if isequal(moveDirection, scanDirection)
            % scan up
            for x = 1:width
                mapItem = handleDirectionYou(mapItem, moveDirection, [1, x], [height, x], ruleGraph);
            end
        else
            % scan down
            for x = 1:width
                mapItem = handleDirectionYou(mapItem, moveDirection, [height, x], [1, x], ruleGraph);
            end
        end
    end

    scanDirection = [0, 1]; % horizontal
    if isVecParallel(moveDirection, scanDirection)
        if isequal(moveDirection, scanDirection)
            % scan right
            for y = 1:height
                mapItem = handleDirectionYou(mapItem, moveDirection, [y, 1], [y, width], ruleGraph);
            end
        else
            % scan left
            for y = 1:height
                mapItem = handleDirectionYou(mapItem, moveDirection, [y, width], [y, 1], ruleGraph);
            end
        end
    end

end