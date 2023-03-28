function [mapItem, moveCount] = handleDirectionYou(mapItem, moveDirection, startPos, endPos, ruleGraph)
    set_rules;
    TEXT = 10000;

    impactBlock = table('Size', [0 4], 'VariableNames', {'y','x', 'type', 'impact'},...
        'VariableTypes', {'double', 'double', 'double', 'logical'});

    % analyze rules
    wordList = ruleGraph.Nodes.Type;
    % [yous] is You
    you_Word = find(wordList == Rules('You'));
    yous_Index = predecessors(ruleGraph, you_Word);
    yous = wordList(yous_Index) - TEXT;
    % [pushables] is Push
    push_Word = find(wordList == Rules('Push'));
    texts = values(Rules);
    texts = [texts{:}]';
    if isempty(push_Word)
        pushables = texts;
    else
        pushables_Index = predecessors(ruleGraph, push_Word);
        pushables = wordList(pushables_Index) - TEXT;
        pushables = [pushables; texts];
    end
    % [stops] is Stop or Push
    stop_Word = find(wordList == Rules('Stop'));
    if isempty(stop_Word)
        stops = pushables;
    else
        stops_Index = predecessors(ruleGraph, stop_Word);
        stops = wordList(stops_Index) - TEXT;
        stops = union(stops, pushables);
    end 

    % handle you and push
    currentPos = startPos;
    while true
        entities = mapItem.gridmap{currentPos(1), currentPos(2)};

        % find all yous
        hasYou = false;
        for entity = entities'
            if ismember(entity, yous)
                [blocki, ~] = ismember(impactBlock, table(currentPos(1), currentPos(2), entity, true, 'VariableNames', {'y','x', 'type', 'impact'}), 'rows');
                if ~any(blocki)
                    impactBlock = [impactBlock; {currentPos(1), currentPos(2), entity, true}];
                end
                hasYou = true;
            end
        end

        % scans for push
        if hasYou && ~isequal(currentPos, endPos)
            position = currentPos + moveDirection;
            while true
                entities = mapItem.gridmap{position(1), position(2)};
                hasPush = false;
                for entity = entities'
                    if ismember(entity, pushables)
                        [blocki, ~] = ismember(impactBlock, table(position(1), position(2), entity, true, 'VariableNames', {'y','x', 'type', 'impact'}), 'rows');
                        if ~any(blocki)
                            impactBlock = [impactBlock; {position(1), position(2), entity, true}];
                        end
                        hasPush = true;
                    end
                end
                if ~hasPush
                    break
                end
                if isequal(position, endPos)
                    break
                end
                position = position + moveDirection;

            end
        end

        if isequal(currentPos, endPos)
            break;
        end
        currentPos = currentPos + moveDirection;
    end

    %% remove impact blocks that are stopped
    % handle map border
    position = endPos;
    entities = mapItem.gridmap{position(1), position(2)};
    for entity = entities'
        [blocki, ~] = ismember(removevars(impactBlock, 'impact'), table(position(1), position(2), entity, 'VariableNames', {'y','x', 'type'}), 'rows');
        if any(blocki)
            impactBlock{blocki, 'impact'} = false;
        end
    end
    % stopping from border (backwards)
    while true
        entities = mapItem.gridmap{position(1), position(2)};
        hasStop = false;
        for entity = entities'
            if ismember(entity, stops)
                [blocki, ~] = ismember(removevars(impactBlock, 'impact'), table(position(1), position(2), entity, 'VariableNames', {'y','x', 'type'}), 'rows');
                if any(blocki)
                    if any(~impactBlock{blocki, 'impact'})
                        hasStop = true;
                        break
                    end
                else
                    hasStop = true;
                    break
                end  
            end
        end
        if hasStop
            stopPos = position - moveDirection;
            entities = mapItem.gridmap{stopPos(1), stopPos(2)};
            for entity = entities'
                [blocki, ~] = ismember(removevars(impactBlock, 'impact'), table(stopPos(1), stopPos(2), entity, 'VariableNames', {'y','x', 'type'}), 'rows');
                if any(blocki)
                    impactBlock{blocki, 'impact'} = false;
                end
            end
        end
        if isequal(position, startPos + moveDirection)
            break
        end
        position = position - moveDirection;
    end

    % perform
    moveCount = 0;
    for i = 1:height(impactBlock)
        if impactBlock{i, 'impact'}
            moveCount = moveCount + 1;
            mapItem = destroy(mapItem, impactBlock{i, 'y'}, impactBlock{i, 'x'}, impactBlock{i, 'type'});
            mapItem = create(mapItem, impactBlock{i, 'y'} + moveDirection(1), impactBlock{i, 'x'} + moveDirection(2), impactBlock{i, 'type'});
        end
    end
end