function mapItem = handleAttributeDefeat(mapItem, ruleGraph)
    set_rules;
    TEXT = 10000;
    % handle rules
    wordList = ruleGraph.Nodes.Type;
    % [yous] is You
    you_Word = find(wordList == Rules('You'));
    yous_Index = predecessors(ruleGraph, you_Word);
    yous = wordList(yous_Index) - TEXT;
    % [defeats] is Defeat
    defeat_Word = find(wordList == Rules('Defeat'));
    if isempty(defeat_Word)
        return;
    else
        defeats_Index = predecessors(ruleGraph, defeat_Word);
        defeats = wordList(defeats_Index) - TEXT;
        if isempty(defeats)
            return;
        end
    end

    [height, width] = size(mapItem.gridmap);
    for y = 1:height
        for x = 1:width
            entities = mapItem.gridmap{y, x};
            if any(ismember(entities, defeats))
                for entity = entities'
                    if ismember(entity, yous)
                        mapItem = destroy(mapItem, y, x, entity);
                    end
                end
            end
        end
    end
end