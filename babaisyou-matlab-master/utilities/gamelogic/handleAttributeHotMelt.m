function mapItem = handleAttributeHotMelt(mapItem, ruleGraph)
    set_rules;
    TEXT = 10000;
    % handle rules
    wordList = ruleGraph.Nodes.Type;
    % [melts] is Melt
    melt_Word = find(wordList == Rules('Melt'));
    if isempty(melt_Word)
        return
    else
        melts_Index = predecessors(ruleGraph, melt_Word);
        melts = wordList(melts_Index) - TEXT;
        if isempty(melts)
            return
        end
    end
    % [hots] is Hot
    hot_Word = find(wordList == Rules('Hot'));
    if isempty(hot_Word)
        return;
    else
        hots_Index = predecessors(ruleGraph, hot_Word);
        hots = wordList(hots_Index) - TEXT;
        if isempty(hots)
            return
        end
    end

    [height, width] = size(mapItem.gridmap);
    for y = 1:height
        for x = 1:width
            entities = mapItem.gridmap{y, x};
            if any(ismember(entities, hots))
                for entity = entities'
                    if ismember(entity, melts)
                        mapItem = destroy(mapItem, y, x, entity);
                    end
                end
            end
        end
    end
end