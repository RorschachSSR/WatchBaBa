clear
initUtility
P = readtable('data/participants.csv');
h = height(P);
P = sortrows(P, 'SubNo');

levelConfig = importConfig('data/map_config');
defeat_property= find(levelConfig(8).ruleGraph.Nodes.Type == Rules('Defeat'));
hot_property = find(levelConfig(11).ruleGraph.Nodes.Type == Rules('Hot'));

clear levelConfig
%% Using pushable entities as extension of "you" sprite

varlabels = {'SubNo', 'Train_4_push_text_as_extension', 'Train_5_push_text_as_extension'};
      
T = table('Size', [h, numel(varlabels)], ...
            'VariableNames', varlabels,...
            'VariableTypes', {'double', 'logical', 'logical'});
T.SubNo = (1:h)';
                          
tic
for i = 1:h
    disp(i)
    filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
    load(filename);
    
    % chapter 2 level 4
    chp = 2; lvl = 4;
    logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                    & [mapHistory(:).Level] == lvl - 1;
    levelHistory = mapHistory(logicalArray);
    wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
    first_win = find(wins, 1, 'first');

    for t = 2:first_win
        if P.Condition(i) < 3 % naive
            if isempty(predecessors(levelHistory(t).ruleGraph, defeat_property))
                if isPushing(levelHistory(t-1), levelHistory(t).Operation, 'Sprite', 'Text')    
                    T{i, 2} = true;
                end
                break
            end
        else % familiar
            if isempty(predecessors(levelHistory(t).ruleGraph, hot_property)) 
                if isPushing(levelHistory(t-1), levelHistory(t).Operation, 'Sprite', 'Text')    
                    T{i, 2} = true;
                end
                break
            end
        end
    end

    % chapter 2 level 5
    chp = 2; lvl = 5;
    logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                    & [mapHistory(:).Level] == lvl - 1;
    levelHistory = mapHistory(logicalArray);
    wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
    first_win = find(wins, 1, 'first');

    for t = 2:first_win
        if checkResultForReplay(levelHistory(t), 'Defeat') ...
            && existYouDefinition(levelHistory(t)) ...
            && isPushing(levelHistory(t-1), levelHistory(t).Operation, 'Sprite', 'Text')
                T{i, 3} = true;
                break
        end
    end

    disp(T(i, :))

end
toc

%%
writetable(T, 'data/processed_behavior/experience_pushable_extension.csv')