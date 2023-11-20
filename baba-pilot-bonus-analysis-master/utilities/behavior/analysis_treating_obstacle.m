%% Belief about "stop"

clear
initUtility
levelConfig = importConfig('data/map_config');

stop_property = zeros(4, 1);
for lvl = 1:4
    stop_property(lvl) = find(levelConfig(lvl).ruleGraph.Nodes.Type == Rules('Stop'));
end

cloud_cluster = levelConfig(2).spriteClusters(Sprites('Cloud'));
[y, x] = find(cloud_cluster);
bnd_upper = max(y);
bnd_lower = min(y);
bnd_left = min(x);
bnd_right = max(x);

mirror_cluster = levelConfig(5).spriteClusters(Sprites('Mirror'));

clear y x levelConfig

P = readtable('data/participants.csv');
h = height(P);
P = sortrows(P, 'SubNo');

varlabels = {'SubNo', 'Tutorial_1_nullify_stop',...
                      'Tutorial_2_nullify_stop',...
                      'Tutorial_3_nullify_stop',...
                      'Tutorial_4_nullify_stop',...
                      'Train_1_when_move_onto_mirror',...
                      'Train_1_is_pushing_text_first_onto_mirror', ...
                      'Train_1_when_push_text_from_mirror', ...
                      'Tutorial_1_move_outside_I_shape',...
                      'Tutorial_2_when_move_outside_I_shape'};

%% Nullify definition of you
      
T = table('Size', [h, numel(varlabels)], ...
            'VariableNames',varlabels,...
            'VariableTypes', {'double', 'logical', 'logical', 'logical', 'logical',...
                              'logical', 'double', ...
                              'double', 'logical', 'double'});
T.SubNo = (1:h)';

%%
        
tic
for i = 1:h
    disp(i)
    filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
    load(filename);

    first_in_tutorial_2 = find([mapHistory(:).Chapter] == 1 - 1 ...
                            & [mapHistory(:).Level] == 2- 1, 1, 'first');
    first_in_train = find([mapHistory(:).Chapter] == 2 - 1 ...
                            & [mapHistory(:).Level] == 1- 1, 1, 'first');
    
    % col: 2-5
    chp = 1; 
    for lvl = 1:4
        
        logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                            & [mapHistory(:).Level] == lvl - 1 ...
                            & 1:numel(mapHistory) < first_in_train;        
        levelHistory = mapHistory(logicalArray);

        nullify_stop = arrayfun(@(x) isempty(predecessors(x.ruleGraph, stop_property(lvl))), levelHistory);

        T{i, lvl + 1} = sum(nullify_stop);
    end

    % col: 6-8
    chp = 2; lvl = 1;
    logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                            & [mapHistory(:).Level] == lvl - 1;
    levelHistory = mapHistory(logicalArray);
    is_on_mirror = arrayfun(@(x) any(and(x.propertyClusters(Rules('You')), mirror_cluster), 'all'), levelHistory);
    first_on_mirror = find(is_on_mirror, 1, 'first');
    T{i, 6} = levelHistory(first_on_mirror).TimeFromLaunch - levelHistory(1).TimeFromLaunch;
    T{i, 7} = isPushing(levelHistory(first_on_mirror - 1), levelHistory(first_on_mirror).Operation, 'Sprite', 'Text');

    wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
    first_win = find(wins, 1, 'first');
    is_pushing_text = zeros(1, first_win-1, 'logical');
    
    for t = 2:first_win
        is_pushing_text(t) = isPushing(levelHistory(t - 1), levelHistory(t).Operation, 'Sprite', 'Text');
    end
    first_push_text_from_mirror = find(and(is_on_mirror(1:first_win-1), is_pushing_text), 1, 'first') + 1;
    T{i, 8} = levelHistory(first_push_text_from_mirror).TimeFromLaunch - levelHistory(1).TimeFromLaunch;

    % col: 9-10
    chp = 1; lvl = 1;
    logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                            & [mapHistory(:).Level] == lvl - 1 ...
                            & 1:numel(mapHistory) < first_in_tutorial_2;
    levelHistory = mapHistory(logicalArray);
    out = false;
    for t = 1:numel(levelHistory)
        [y, x] = find(levelHistory(t).propertyClusters(Rules('You')));
        if any(y > bnd_upper) || any(y < bnd_lower) || any(x < bnd_left) || any(x > bnd_right)
            out = true;
            break;
        end
    end
    T{i, 9} = out;

    chp = 1; lvl = 2;
    logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                            & [mapHistory(:).Level] == lvl - 1;
    levelHistory = mapHistory(logicalArray);

    wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), levelHistory);
    first_win = find(wins, 1, 'first');

    for t = 1:first_win
        [y, x] = find(levelHistory(t).propertyClusters(Rules('You')));
        if any(y > bnd_upper) || any(y < bnd_lower) || any(x < bnd_left) || any(x > bnd_right)
            break;
        end
    end
    T{i, 10} = levelHistory(t).TimeFromLaunch - levelHistory(1).TimeFromLaunch;
    
    disp(T(i, :))
end
toc

%%
writetable(T, 'data/processed_behavior/experience_treating_obstacle.csv')