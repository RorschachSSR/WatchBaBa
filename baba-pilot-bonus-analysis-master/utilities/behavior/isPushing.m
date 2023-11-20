function logicalIndicator = isPushing(mapItem, operationType, options)

    arguments
        mapItem {isa(mapItem, "struct")}
        operationType {mustBeMember(operationType, {'None', 'Left', 'Right', 'Up', 'Down'})}
        options.Sprite {ischar}
    end

    set_rules;
    set_sprites;
    TEXT = 10000;

    % handle inputs
    if strcmp(operationType, 'None')
        logicalIndicator = false;
        return
    end
    if isfield(options, 'Sprite')
        sprite = options.Sprite;
        spriteCode = Sprites(sprite);
        if ~isKey(mapItem.spriteClusters, spriteCode)
            logicalIndicator = false;
            return
        end
    end
    
    
    % map configuration
    if isfield(mapItem, 'size')
        width = mapItem.size.x;
        height = mapItem.size.y;
    else
        [height, width] = size(mapItem.gridmap);
    end

    % locate you
    if isKey(mapItem.propertyClusters, Rules('You'))
        youCluster = mapItem.propertyClusters(Rules('You'));
    else
        logicalIndicator = false;
        return
    end

    influenceRange = zeros(height, width, 'logical');
    switch operationType
        case 'Left'
            influenceRange(:, 1:width-1) = youCluster(:, 2:width);
        case 'Right'
            influenceRange(:, 2:width) = youCluster(:, 1:width-1);
        case 'Up'
            influenceRange(2:height, :) = youCluster(1:height-1, :);
        case 'Down'
            influenceRange(1:height-1, :) = youCluster(2:height, :);
    end

    pushCluster = mapItem.propertyClusters(Rules('Push'));

    if isfield(options, 'Sprite')
        spriteCluster = mapItem.spriteClusters(spriteCode);
        if spriteCode == Sprites('Text')
            pushCluster = spriteCluster;
        else
            wordList = mapItem.ruleGraph.Nodes.Type;
            spriteIndex = find(wordList == spriteCode + TEXT);
            pushIndex = find(wordList == Rules('Push'));
            if isempty(spriteIndex) || isempty(pushIndex)
                logicalIndicator = false;
                return
            end
            whoPushable = predecessors(mapItem.ruleGraph, pushIndex);
            if ~isempty(intersect(spriteIndex, whoPushable)) 
                pushCluster = spriteCluster;
            else
                logicalIndicator = false;
                return
            end
        end
    end

    logicalIndicator = any(influenceRange & pushCluster, 'all');

end