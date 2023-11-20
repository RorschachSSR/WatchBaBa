%% Effect of Past Experience 

clear
initUtility
P = readtable('data/participants.csv');
h = height(P);
P = sortrows(P, 'SubNo');

%% Nullify definition of you

levels = [1, 2;
          1, 3;
          1, 4;
          2, 1;
          2, 2;
          2, 5;
          3, 1;
          3, 2;
          3, 3];

varlabels = {'SubNo', 'Tutorial_2_nullify_you', 'Tutorial_3_nullify_you', 'Tutorial_4_nullify_you', ...
            'Train_1_nullify_you', 'Train_2_nullify_you', 'Train_5_nullify_you', ...
            'Bonus_1_nullify_you', 'Bonus_2_nullify_you', 'Bonus_3_nullify_you'};
      
T = table('Size', [h, numel(varlabels)], ...
            'VariableNames', varlabels, ...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', ...
                              'double', 'double', 'double', 'double', 'double'});
T.SubNo = (1:h)';
                          
tic
for i = 1:h
    disp(i)
    filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
    load(filename);
    
    for m = 1:size(levels, 1)
        % filter: chapter + level
        logicalArray = [mapHistory(:).Chapter] == levels(m, 1) - 1 ...
                       & [mapHistory(:).Level] == levels(m, 2) - 1;
        if ~any(logicalArray)
            continue;
        end
        levelHistory = mapHistory(logicalArray);
        wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
        
        if any(wins)
                first_win = find(wins, 1, 'first');
        else
            % do not win in allowed time for chapter 3 (bonus)
            first_win = numel(wins);
        end
        
        levelHistory = levelHistory(1:first_win);
        
        definedYou = arrayfun(@(x) existYouDefinition(x), levelHistory);
        T{i, m + 1} = sum(~definedYou, 'all');
        
    end
end
toc

%%
writetable(T, 'data/processed_behavior/experience_nullify_you.csv')