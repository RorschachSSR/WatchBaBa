function [spriteList, nounList, propertyList, operatorIsPositions] = findText(mapItem)
    set_rules;
    if isfield(mapItem, 'blocks')
        % text word list
        entityList = unique([mapItem.blocks(:).entityType]);
        entityList = transpose(entityList);
        spriteList = entityList( isSprite(entityList) );
        nounList = entityList( isNoun(entityList) );
        propertyList = entityList( isProperty(entityList) );
        % "is" keyword positions
        logicalArray = arrayfun(@(var) var.entityType == Rules('Is'), mapItem.blocks);
        operatorIsPositions = cell2mat(arrayfun(@(var) [var.position.x + 1, var.position.y + 1], mapItem.blocks(logicalArray), 'UniformOutput', false));
    else
        % text word list
        fullwordList = vertcat(mapItem.gridmap{:});
        entityList = unique(fullwordList);
        spriteList = entityList( isSprite(entityList) );
        nounList = entityList( isNoun(entityList) );
        propertyList = entityList( isProperty(entityList) );
        % "is" keyword positions
        [coord_y, coord_x] = find(cellfun(@(var) containsIs(var), mapItem.gridmap));
        operatorIsPositions = [coord_x, coord_y];
    end
end