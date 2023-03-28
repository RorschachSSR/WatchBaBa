function [reward, termination] = checkGameResult(mapItem, ruleGraph)
    termination = 0;
    reward = 0;

    set_rules;
    TEXT = 10000;
    % handle rules
    wordList = ruleGraph.Nodes.Type;
    % [yous] is You
    you_Word = find(wordList == Rules('You'));
    yous_Index = predecessors(ruleGraph, you_Word);
    yous = wordList(yous_Index) - TEXT;
    % [wins] is Win
    win_Word = find(wordList == Rules('Win'));
    wins_Index = predecessors(ruleGraph, win_Word);
    wins = wordList(wins_Index) - TEXT;


    noYou = true;
    [height, width] = size(mapItem.gridmap);
    for y = 1:height
        for x = 1:width
            entities = mapItem.gridmap{y, x};
            if any(ismember(entities, yous))
                noYou = false;
                if any(ismember(entities, wins))
                    termination = 1;
                    reward = 1;
                    return;
                end
            end
        end
    end

    if noYou
        termination = 1;
        reward = -1;
    end

end