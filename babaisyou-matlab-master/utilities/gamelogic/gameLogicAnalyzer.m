function [ruleGraph, varargout] = gameLogicAnalyzer(mapItem)
%% GAMELOGICANALYZER 
%       INPUT: a struct that contains the map information as a field "gridmap"
%       We hypothesize that the grid map is thereon processed through two pathways:
%           - symbolic
%           - visual

if ~isfield(mapItem, 'gridmap')
    error('`mapItem` does not contain a `gridmap` field. Convert block list to grid map by first.')
end
nout = max(nargout,1) - 1;

%% Initial Layer
    % symbolic
    textGrid = cellfun(@(x) x(isText(x)), mapItem.gridmap, 'UniformOutput', false);
    % visual
    spriteGrid = cellfun(@(x) x(isSprite(x)), mapItem.gridmap, 'UniformOutput', false);
    TEXT       = 10000; % treat test as graphic sprites identically
    clusterGrid = cellfun(@(x, y) [x; (y > 0) * TEXT], spriteGrid, textGrid, 'UniformOutput', false);
    [spriteList, nounList, propertyList, operatorIsPositions] = findText(mapItem);
    wordList = [nounList; propertyList];
    
    % map configuration
    if isfield(mapItem, 'size')
        width = mapItem.size.x;
        height = mapItem.size.y;
    else
        [height, width] = size(mapItem.gridmap);
    end

 %% Symbolic
    set_rules;
    
    % initialize adjacency matrix
    ruleAdjM = zeros(numel(wordList));
    
    % Loop through all "is" keywords
    for i = 1 : size(operatorIsPositions, 1)
        x = operatorIsPositions(i, 1);
        y = operatorIsPositions(i, 2);
        %horizontal
        if x > 1 && x < width
            left  = textGrid{y, x-1};
            right = textGrid{y, x+1};
            for l = length(left)
                for r = length(right)
                    if l > 0 && r > 0
                        ruleAdjM(wordList == left(l), wordList == right(r)) = 1;
                    end
                end
            end
        end
        %vertical
        if y > 1 && y < height
            up  = textGrid{y+1, x};
            down = textGrid{y-1, x};
            for u = 1 : length(up)
                for d = 1 : length(down)
                    if u > 0 && d > 0
                        ruleAdjM(wordList == up(u), wordList == down(d)) = 1;
                    end
                end
            end
        end
    end
    
    ruleGraph = digraph(ruleAdjM, table(wordList, 'VariableNames',{'Type'}));
    invalidEdges = arrayfun(@(x,y) ~isNoun(wordList(x)) || ~isProperty(wordList(y)), ruleGraph.Edges.EndNodes(:,1), ruleGraph.Edges.EndNodes(:,2));
    ruleGraph.Edges.Weight(invalidEdges) = 0;

    if nout == 0
        return
    end

    %% Visual
    spriteList  = [spriteList; TEXT];
    spriteClusters = containers.Map('KeyType', 'double', 'ValueType','any');
    
    % disconnect each pair of grids from each other 
    % if they are occupied by distinct looking sprites
    
    for i = 1 : numel(spriteList)
        spriteClusters(spriteList(i)) = cellfun(@(x) any(x == spriteList(i)), clusterGrid);
    end

    varargout{1} = spriteClusters;
    if nout == 1
        return
    end
    
    %% Composite
    if ~any(propertyList == Rules('Push'))
        propertyList = sort([propertyList; Rules('Push')]);
    end
    propertyClusters = containers.Map('KeyType', 'double', 'ValueType','any');
    
    for i = 1 : numel(propertyList)
        propertyClusters(propertyList(i)) = cellfun(@(x) sprite2Property(propertyList(i), x, wordList, ruleAdjM), clusterGrid);
    end
    varargout{2} = propertyClusters;
end