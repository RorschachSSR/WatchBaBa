function obstacleGraph = analyzeObstacles(mapItem, pushFlag)
%ANALYZEOBSTACLES Analyze the obstacles in the map
% input:    INPUT: map preprocessed by game logic analyzer
% output:   obstacleGraph: graph that represents the connectivity between map positions, 
%                          taking the obstacles into account.

    set_rules;
    if nargin < 2
        pushFlag = true;
    end

    % map configuration
    if isfield(mapItem, 'size')
        width = mapItem.size.x;
        height = mapItem.size.y;
    else
        [height, width] = size(mapItem.gridmap);
    end

    %% Obstacle Graph
    obstacleAdjM = zeros(width * height);
        
    pushCluster = mapItem.propertyClusters(Rules('Push'));
    stopCluster = zeros(height, width, 'logical');
    if isKey(mapItem.propertyClusters, Rules('Stop'))
        stopCluster = mapItem.propertyClusters(Rules('Stop'));
    end

    % init: connect each grid to nearby grids (left, right, up, down)
    for y = 1:height
        for x = 1:width
            mask = 1;
            %right (east)
            if x < width
                node1 = width * (y - 1) + x;
                node2 = width * (y - 1) + x + 1;
                obstacleAdjM(node1, node2) = 1 * mask;
            end
            %down
            if y-1 > 0
                node1 = width * (y - 1) + x;
                node2 = width * (y - 2) + x;
                obstacleAdjM(node2, node1) = 1 * mask;
            end
        end
    end

    if pushFlag
        obstacleCluster = pushCluster | stopCluster;
    else
        obstacleCluster = stopCluster;
    end

    % disconnect the stop/push nodes from other nodes
    for y = 1:height
        for x = 1:width
            if obstacleCluster(y, x)
                mask = 0;
                %left
                if x-1 > 0
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 1) + x - 1;
                    obstacleAdjM(node2, node1) = 1 * mask;
                end
                %right
                if x < width
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 1) + x + 1;
                    obstacleAdjM(node1, node2) = 1 * mask;
                end
                %up
                if y < height
                    node1 = width * (y - 1) + x;
                    node2 = width *  y      + x;
                    obstacleAdjM(node1, node2) = 1 * mask;
                end
                %down
                if y-1 > 0
                    node1 = width * (y - 1) + x;
                    node2 = width * (y - 2) + x;
                    obstacleAdjM(node2, node1) = 1 * mask;
                end
            end
        end
    end

    x = repmat(1:width, 1, height);
    y = sort(repmat(1:height, 1, width));
    obstacleGraph = graph(obstacleAdjM, table(x', y', 'VariableNames', {'xpos', 'ypos'}), 'upper');

end