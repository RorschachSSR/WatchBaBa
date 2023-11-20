function [d, path] = heuristicObstacle(mapItem)
% heuristicObstacle: the shortest path considering all push and stop objects to be obstacles
    G = analyzeObstacles(mapItem);
    d = mapItem.size.x * mapItem.size.y; % d = Inf

    You = selfLocating(mapItem);
    Win = goalFinding(mapItem);

    set_rules;
    if ~isempty(self) && ~isempty(goal)
        if any(You, 'all') && any(Win, 'all')
            YouIndices = find(You');
            WinIndices = find(Win');
            for s = YouIndices'
                for t = WinIndices'
                    [path, new_d] = shortestpath(G, s, t);
                    if new_d < d
                        d = new_d;
                    end
                end
            end
        end
    end
    
end