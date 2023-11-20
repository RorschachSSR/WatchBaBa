%% Effect of past experience 

clear
initUtility
P = readtable('data/participants.csv');
h = height(P);
P = sortrows(P, 'SubNo');

%% Handle new property: Defeat or Hot/Melt

levels = [2, 4;
          2, 5;
          3, 1];
varlabels = {'SubNo', 'Train_4_destroy_you_seq', 'Train_5_destroy_you_seq', 'Bonus_1_destroy_you_seq', ...
                        'Train_4_destroy_you_count', 'Train_5_destroy_you_count', 'Bonus_1_destroy_you_count'};
      
T = table('Size', [h, numel(varlabels)], ...
            'VariableNames', varlabels,...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double'});
T.SubNo = (1:h)';
                          
for i = 1:h
    tic
    disp(i)
    filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
    load(filename);
    
    for m = 1:size(levels, 1)
        % filter: chapter + level
        chp = levels(m, 1);
        lvl = levels(m, 2);
        logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                       & [mapHistory(:).Level] == lvl - 1;
        levelHistory = mapHistory(logicalArray);
        
        wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
        if any(wins)
            t_max = find(wins, 1, 'first');
        else
            % do not win in allowed time for chapter 3 (bonus)
            t_max = numel(wins);
        end
        levelHistory = levelHistory(1:t_max);

        destroy_you_sprite = arrayfun(@(x) checkResultForReplay(x, 'Defeat') && existYouDefinition(x), levelHistory);
        T{i, m+4} = sum(destroy_you_sprite);
        
        t_fisrt_destroy = find(destroy_you_sprite, 1, 'first');
        if isempty(t_fisrt_destroy)
            T{i, m+1} = nan; 
        else 
            switch m
                case 1
                    push_book = any(arrayfun(@(x, y) isPushing(y, x.Operation, 'Sprite', 'Book'), ...
                                                levelHistory(2:t_fisrt_destroy), levelHistory(1:t_fisrt_destroy-1)));
                    push_text = any(arrayfun(@(x, y) isPushing(y, x.Operation, 'Sprite', 'Text'), ...
                                                levelHistory(2:t_fisrt_destroy), levelHistory(1:t_fisrt_destroy-1)));
                    if push_book && push_text
                        T{i, m+1} = 2;
                        disp('after pushing text')
                    elseif push_book && ~push_text
                        T{i, m+1} = 1;
                        disp('after pushing book')
                    elseif ~push_book && ~push_text
                        T{i, m+1} = 0;
                        disp('before pushing book')
                    end
                case 2
                    push_text = any(arrayfun(@(x, y) isPushing(y, x.Operation, 'Sprite', 'Text'), ...
                                                levelHistory(2:t_fisrt_destroy), levelHistory(1:t_fisrt_destroy-1)));
                    if push_text
                        T{i, m+1} = 2;
                        disp('after pushing text')
                    else
                        T{i, m+1} = 1;
                        disp('before pushing text')
                    end
                case 3
                    push_dice = any(arrayfun(@(x, y) isPushing(y, x.Operation, 'Sprite', 'Dice'), ...
                                                levelHistory(2:t_fisrt_destroy), levelHistory(1:t_fisrt_destroy-1)));
                    push_text = any(arrayfun(@(x, y) isPushing(y, x.Operation, 'Sprite', 'Text'), ...
                                                levelHistory(2:t_fisrt_destroy), levelHistory(1:t_fisrt_destroy-1)));
                    if push_dice && push_text
                        T{i, m+1} = 2;
                        disp('after pushing text')
                    elseif push_dice && ~push_text
                        T{i, m+1} = 1;
                        disp('after pushing dice')
                    elseif ~push_dice && ~push_text
                        T{i, m+1} = 0; % there should be none of this category
                        disp('before pushing dice') 
                    end                        
            end
        end
    end
    toc
end

%% 
writetable(T, 'data/processed_behavior/experience_handle_new_property.csv')