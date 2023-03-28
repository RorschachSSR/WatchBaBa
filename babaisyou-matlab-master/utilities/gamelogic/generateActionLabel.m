function labels = generateActionLabel(mapItem, mapItem_previous)
    set_rules;
    set_sprites;
    labels = struct('ruleFormed', 0, 'ruleBroken', 0, ...
    'areYouMoving', false, 'areYouDestroyed', false, 'directlyPushText', false, 'directlyPushSprite', false, 'numEntities', 0, 'numType', 0);

    if ~strcmp(mapItem.Control, 'None') && ~strcmp(mapItem.Control, 'Defeat')
        % do not label redos and undos
        return;
    end

    %% rules
    wordList = mapItem_previous.ruleGraph.Nodes.Type;
    ruleAdj = full(adjacency(mapItem.ruleGraph));
    ruleAdj_previous = full(adjacency(mapItem_previous.ruleGraph));
    delta_rule = ruleAdj - ruleAdj_previous;

    labels.ruleFormed = sum(delta_rule(:) == 1);
    labels.ruleBroken = sum(delta_rule(:) == -1);

    %% pushing
    % locate you
    if isKey(mapItem_previous.propertyClusters, Rules('You'))
        youCluster = mapItem_previous.propertyClusters(Rules('You'));
    else
        return
    end
    % map configuration
    if isfield(mapItem, 'size')
        width = mapItem.size.x;
        height = mapItem.size.y;
    else
        [height, width] = size(mapItem.gridmap);
    end
    % get operation
    if strcmp(mapItem.Operation, 'None')
        return
    else
        operationType = mapItem.Operation;
    end
    %% moving
    youIndex = find(wordList == Rules('You'));
    whoWasYou_Index = predecessors(mapItem_previous.ruleGraph, youIndex);
    whoWasYou = wordList(whoWasYou_Index) - 10000;
    movedyouCluster = cellfun(@(x) any(ismember(x, whoWasYou)), mapItem.gridmap);
    if ~isequal(youCluster, movedyouCluster)
        labels.areYouMoving = true;
        if sum(movedyouCluster(:)) < sum(youCluster(:))
            labels.areYouDestroyed = true;
        end
    end
    %% directly pushing
    pushableCluster = mapItem_previous.propertyClusters(Rules('Push'));

    count = 0;
    movingCluster = youCluster;
    isDirectlyPushing = false;

    pushIndex = find(wordList == Rules('Push'));
    if isempty(pushIndex)
        whoPushable = [];
    else
        whoPushable_Index = predecessors(mapItem_previous.ruleGraph, pushIndex);
        whoPushable = wordList(whoPushable_Index);
        whoPushable(~isNoun(whoPushable)) = [];
        whoPushable = whoPushable - 10000;
    end

    while true
        influenceRange = zeros(height, width, 'logical');
        switch operationType
            case 'Left'
                influenceRange(:, 1:width-1) = movingCluster(:, 2:width);
            case 'Right'
                influenceRange(:, 2:width) = movingCluster(:, 1:width-1);
            case 'Up'
                influenceRange(2:height, :) = movingCluster(1:height-1, :);
            case 'Down'
                influenceRange(1:height-1, :) = movingCluster(2:height, :);
        end
        if any(influenceRange & pushableCluster, 'all')
            count = count + 1;
            movingCluster = influenceRange & pushableCluster;
            if count == 1
                isDirectlyPushing = true;
                pushedEntityList = vertcat(mapItem_previous.gridmap{influenceRange});
                pushedEntityList = pushedEntityList(ismember(pushedEntityList, whoPushable) | isText(pushedEntityList));
                if any(pushedEntityList > Sprites('Text'))
                    labels.directlyPushText = true;
                elseif any(ismember(pushedEntityList, whoPushable))
                    labels.directlyPushSprite = true;
                end
            else 
                temp = vertcat(mapItem_previous.gridmap{influenceRange});
                temp = temp(ismember(temp, whoPushable) | isText(temp));
                pushedEntityList = [pushedEntityList; temp];
            end
        else
            break;
        end
    end

    if ~isDirectlyPushing
        return
    else
        labels.numEntities = length(pushedEntityList);
        % all text count as the same type
        labels.numType = length(unique(pushedEntityList(isSprite(pushedEntityList)))) + any(isText(pushedEntityList));
    end
    
end