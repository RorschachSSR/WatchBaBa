function [posPerformingPush, youCluster, extendedObstacleGraph]  = getNeighbors(mapItem)
    [mapItem.ruleGraph, ~, mapItem.propertyClusters] = gameLogicAnalyzer(mapItem);
    posPerformingPush = struct('x', {}, 'y', {}, 'moveDir', {});

    set_rules;
    [height, width] = size(mapItem.gridmap);
    potentialPos = zeros(height, width);
    
    %% Possible interactions
    % Push
    pushableCluster = mapItem.propertyClusters(Rules('Push'));
    affectableCluster = pushableCluster;
    % Defeat
    if isKey(mapItem.propertyClusters, Rules('Defeat'))
        defeatCluster = mapItem.propertyClusters(Rules('Defeat'));
        affectableCluster = or(affectableCluster, defeatCluster);
    end
    % Win
    if isKey(mapItem.propertyClusters, Rules('Win'))
        winCluster = mapItem.propertyClusters(Rules('Win'));
        affectableCluster = or(affectableCluster, winCluster);
    end
    % Hot and Melt
    if isKey(mapItem.propertyClusters, Rules('Hot')) && isKey(mapItem.propertyClusters, Rules('Melt'))
        wordList = mapItem.ruleGraph.Nodes.Type;
        wordMeltIndex = find(wordList == Rules('Melt'));
        whoYous = predecessors(mapItem.ruleGraph, find(wordList == Rules('You')));
        if findedge(mapItem.ruleGraph, whoYous, wordMeltIndex) > 0
            affectableCluster = or(affectableCluster, mapItem.propertyClusters(Rules('Hot')));
        end
    end
    
    % Postitions to exert effects
    potentialPos(:, 1:width-1) = or(potentialPos(:, 1:width-1), affectableCluster(:, 2:width));
    potentialPos(:, 2:width) = or(potentialPos(:, 2:width), affectableCluster(:, 1:width-1));
    potentialPos(2:height, :) = or(potentialPos(2:height, :), affectableCluster(1:height-1, :));
    potentialPos(1:height-1, :) = or(potentialPos(1:height-1, :), affectableCluster(2:height, :));
    potentialPos = and(potentialPos, ~affectableCluster);
    % stop position can not be occupied
    if isKey(mapItem.propertyClusters, Rules('Stop'))
        stoppingCluster = mapItem.propertyClusters(Rules('Stop'));
        potentialPos = and(potentialPos, ~stoppingCluster);
    end
    % positions should be reachable for the “you" sprite
    youCluster = mapItem.propertyClusters(Rules('You'));
    extendedObstacleGraph = analyzeExtendedObstacles(mapItem);
    bins = conncomp(extendedObstacleGraph);
    youcomp = bins(logical(youCluster'));
    youcomp = unique(youcomp);
    reachablePos = zeros(height, width, 'logical');
    for i = 1:length(youcomp)
        nComp = youcomp(i);
        xList = extendedObstacleGraph.Nodes.xpos(bins == nComp);
        yList = extendedObstacleGraph.Nodes.ypos(bins == nComp);
        linearIndex = sub2ind([height, width], yList, xList);
        reachablePos(linearIndex) = true;
    end
    potentialPos = and(potentialPos, reachablePos);

    [y, x] = find(potentialPos);
    for i = 1:length(x)
        if x(i) > 1 && pushableCluster(y(i), x(i)-1)
            posPerformingPush(end+1).x = x(i);
            posPerformingPush(end).y = y(i);
            posPerformingPush(end).moveDir = 'Left';
        elseif x(i) < width && pushableCluster(y(i), x(i)+1)
            posPerformingPush(end+1).x = x(i);
            posPerformingPush(end).y = y(i);
            posPerformingPush(end).moveDir = 'Right';
        elseif y(i) > 1 && pushableCluster(y(i)-1, x(i))
            posPerformingPush(end+1).x = x(i);
            posPerformingPush(end).y = y(i);
            posPerformingPush(end).moveDir = 'Down';
        elseif y(i) < height && pushableCluster(y(i)+1, x(i))
            posPerformingPush(end+1).x = x(i);
            posPerformingPush(end).y = y(i);
            posPerformingPush(end).moveDir = 'Up';
        end
    end
    
end