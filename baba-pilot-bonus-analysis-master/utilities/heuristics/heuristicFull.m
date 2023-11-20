function [d, path] = heuristicFull(mapItem)
    % heuristicFull: the shortest path considering all possible obstacles
                    % stop + push + defeat + melt
        G = analyzeExtendedObstacles(mapItem);
        d = mapItem.size.x * mapItem.size.y; % d = Inf

        You = selfLocating(mapItem);
        Win = goalFinding(mapItem);

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