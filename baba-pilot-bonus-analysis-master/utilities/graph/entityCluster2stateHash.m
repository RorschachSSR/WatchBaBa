function [stateHash, youPos] = entityCluster2stateHash(entityCluster, height, stringOutput)
% entityCluster2stateHash
% replace "you" sprites' real position by its reachable positions
% matrix representation of map: entityType isYou col1 col2 .... col_width 
    set_rules

    if nargin < 3
        stringOutput = false;
    end

    stateHash = [entityCluster(:, 1), zeros(size(entityCluster, 1), 1, 'uint32'), entityCluster(:, 2:end)];

    entityList = double(entityCluster(:, 1));
    width = size(entityCluster, 2) - 1;
    gridmap = entityCluster2mapArray(entityCluster, height);
    
    mapItem = struct();
    mapItem.gridmap = gridmap;
    
    [mapItem.ruleGraph, mapItem.spriteClusters, mapItem.propertyClusters] = gameLogicAnalyzer(mapItem);
    
    TEXT = 10000;
    wordList = mapItem.ruleGraph.Nodes.Type;
    whoWasYou_Index = predecessors(mapItem.ruleGraph, find(wordList == Rules('You')));
    whoWasYou = wordList(whoWasYou_Index) - TEXT;
    
    extendedObstacleGraph = analyzeExtendedObstacles(mapItem, false);
    
    youPos = zeros(sum(ismember(entityList, whoWasYou)), size(entityCluster, 2), 'uint32');
    twos = 2.^(0 : height-1);
    count = 0;
    for i = 1:length(entityList)
        entityType = entityList(i);
        if ismember(entityType, whoWasYou)
            entityCluster = mapItem.spriteClusters(entityType);
            bins = conncomp(extendedObstacleGraph);
            entityComp = bins(logical(entityCluster'));
            entityComp = unique(entityComp);
            reachablePos = zeros(height, width, 'logical');
            for ec = 1:length(entityComp)
                nComp = entityComp(ec);
                xList = extendedObstacleGraph.Nodes.xpos(bins == nComp);
                yList = extendedObstacleGraph.Nodes.ypos(bins == nComp);
                linearIndex = sub2ind([height, width], yList, xList);
                reachablePos(linearIndex) = true;
            end
            count = count + 1;
            youPos(count, :)    = [stateHash(i, 1), stateHash(i, 3:end)]; % save original "you" position
            stateHash(i, 2)     = 1;
            stateHash(i, 3:end) = twos * reachablePos;
        end
    end
    
    if stringOutput
        stateHash = mat2str(stateHash);
    end
end