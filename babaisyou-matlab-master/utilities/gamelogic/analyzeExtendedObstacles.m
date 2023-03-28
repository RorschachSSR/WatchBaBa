function extendedObstacleGraph = analyzeExtendedObstacles(mapItem, pushFlag)
%EXTEND OBSTACLES:  Analyze the interactive obstacles in the map
% input:    INPUT: map preprocessed by game logic analyzer and obstacle analyzer
% output:   extendedObstacleGraph: graph that represents the connectivity between map positions, 
%              taking the interactive obstacles (e.g., defeat & hot/melt) into account.

    set_rules;
    if nargin < 2
        pushFlag = true;
    end
    extendedObstacleGraph = analyzeObstacles(mapItem, pushFlag);

    % map configuration
    if isfield(mapItem, 'size')
        height = mapItem.size.y;
        width =  mapItem.size.x;
    else
        [height, width] = size(mapItem.gridmap);
    end

    extendObstacleCluster = zeros(height, width);
    
    % add defeats
    if isKey(mapItem.propertyClusters, Rules('Defeat'))
        extendObstacleCluster = or(extendObstacleCluster, mapItem.propertyClusters(Rules('Defeat')));
    end

    % add hots
    if isKey(mapItem.propertyClusters, Rules('Hot')) && isKey(mapItem.propertyClusters, Rules('Melt')) && isKey(mapItem.propertyClusters, Rules('You'))
        wordList = mapItem.ruleGraph.Nodes.Type;
        wordMeltIndex = find(wordList == Rules('Melt'));
        whoYous = predecessors(mapItem.ruleGraph, find(wordList == Rules('You')));
        if findedge(mapItem.ruleGraph, whoYous, wordMeltIndex) > 0
            extendObstacleCluster = or(extendObstacleCluster, mapItem.propertyClusters(Rules('Hot')));
        end
    end

    for y = 1:height
        for x = 1:width
            if extendObstacleCluster(y, x)
                %left
                if x-1 > 0
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 1) + x - 1;
                    extendedObstacleGraph = rmedge(extendedObstacleGraph, node1, node2);
                end
                %right
                if x < width
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 1) + x + 1;
                    extendedObstacleGraph = rmedge(extendedObstacleGraph, node1, node2);
                end
                %up
                if y < height
                    node1 = width * (y - 1) + x;
                    node2 = width *  y      + x;
                    extendedObstacleGraph = rmedge(extendedObstacleGraph, node1, node2);
                end
                %down
                if y-1 > 0
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 2) + x;
                    extendedObstacleGraph = rmedge(extendedObstacleGraph, node1, node2);
                end
            end
        end
    end
end