%% Effect of Past Experience 

clear
initUtility
P = readtable('data/participants.csv');
h = height(P);
P = sortrows(P, 'SubNo');

varlabels = {'SubNo', 'Tutorial_1_push_dice_to_win', 'Tutorial_3_push_dice_to_win', 'Tutorial_4_push_sun_to_win', 'Tutorial_1_push_dice_counts', 'Tutorial_3_push_dice_counts', 'Tutorial_4_push_sun_counts'};

levels = [1, 1;
          1, 3;
          1, 4];

%% Nullify definition of you
      
T = table('Size', [h, 7], ...
            'VariableNames',varlabels,...
            'VariableTypes', {'double', 'logical', 'logical', 'logical', 'double', 'double', 'double'});
T.SubNo = (1:h)';

%%
tic
for i = 1:h
    disp(i)
    filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
    load(filename);
    
    for m = 1:size(levels, 1)
        logicalArray = [mapHistory(:).Chapter] == levels(m, 1) - 1 ...
                        & [mapHistory(:).Level] == levels(m, 2) - 1;
        levelHistory = mapHistory(logicalArray);
        wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
        first_win = find(wins, 1, 'first');
        
        if levels(m, 2) < 4
            T{i, m+1} = isPushing(levelHistory(first_win - 1), levelHistory(first_win).Operation, 'Sprite', 'Dice');
        else
            T{i, m+1} = isPushing(levelHistory(first_win - 1), levelHistory(first_win).Operation, 'Sprite', 'Sun');
        end

        s = 0;
        if levels(m, 2) < 4
            for t = 2:first_win
                if isPushing(levelHistory(t - 1), levelHistory(t).Operation, 'Sprite', 'Dice')
                    s = s + 1;
                end
            end
        else
            for t = 2:first_win
                if isPushing(levelHistory(t - 1), levelHistory(t).Operation, 'Sprite', 'Sun')
                    s = s + 1;
                end
            end
        end
        T{i, m+4} = s;

    end

end
toc

writetable(T, 'data/processed_behavior/experience_superstitious_pushing.csv')

%% correlation

T = readtable('data/processed_behavior/experience_superstitious_pushing.csv');
[RHO,PVALUE] = corr(T{:, 2:8}, 'Type', 'Kendall');
RHO(PVALUE > 0.05) = nan;
h = heatmap(RHO);

h.XDisplayLabels = labels;
h.YDisplayLabels = labels;