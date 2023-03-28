function [mapItem, reward, termination] = step(mapItem, operationType, varargin) 
    if ~ismember(operationType, {'None', 'Left', 'Right', 'Up', 'Down'})
        error("Operation must be 'None', 'Left', 'Right', 'Up', 'Down'")
    end
    if ~isa(mapItem, "struct")
        error("mapItem should be a 1x1 struct")
    end
    if isfield(mapItem,'blocks')
        % remove blocks field to enforce sprite detection from the gridmap
        error("remove blocks field from mapItem") 
    end

    nin = nargin - 2;
    if nin == 0
        render = false;
    elseif nin == 1
        if islogical(varargin{1})
            render = varargin{1};
        elseif isnumeric(varargin{1})
            render = varargin{1} > 0;
        else
            error("render should be a logical or numerical value")
        end
    else
        error("Too many input arguments")
    end

    ruleGraph = gameLogicAnalyzer(mapItem);
    ruleGraph = rmedge(ruleGraph, find(ruleGraph.Edges.Weight == 0));

    mapItem = handleAttributeYou(mapItem, operationType, ruleGraph);

    ruleGraph = gameLogicAnalyzer(mapItem);
    ruleGraph = rmedge(ruleGraph, find(ruleGraph.Edges.Weight == 0));

    mapItem = handleAttributeDefeat(mapItem, ruleGraph);
    mapItem = handleAttributeHotMelt(mapItem, ruleGraph);

    [reward, termination] = checkGameResult(mapItem, ruleGraph);

    if render
        cla
        renderMap(mapItem, gca)
    end
end