function OutputCellArray = blockList2mapArray(mapItem, ifunique)
    % INPUT: a struct array item from the imported map history from
    %       `readMapLog`, with a field `blocks` containing all entities' positions
    % OUTPUT: a cell array item that represent the map as grid
    if ~islogical(ifunique)
        error("ifunique must be logical")
    end
    OutputCellArray = cell(mapItem.size.y, mapItem.size.x);
    
    blocks = mapItem.blocks;
    for i = 1 : numel(blocks)
        x = blocks(i).position.x + 1;
        y = blocks(i).position.y + 1;
        OutputCellArray{y, x} = [OutputCellArray{y, x}; blocks(i).entityType];
    end

    if ifunique
        OutputCellArray = cellfun(@(x) unique(x, 'stable'), OutputCellArray, 'UniformOutput',false);
    end
end