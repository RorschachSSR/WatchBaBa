%% 
clear
importData; initUtility; 

P = sortrows(P, 'SubNo');
P_all = P;

X = S_noRep(:, {'SubNo', 'Level', 'Solution'});
U = unstack(X, 'Solution','Level', 'VariableNamingRule', 'modify');
U = [U; {29, '', '', ''}];
U = sortrows(U, 'SubNo');

noMelt = strcmp(U.x1, 'BagIsHotMelt');
noBagIsPush = strcmp(U.x1, 'BagIsPush');

noBag = ((strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'BagIsHotMelt'))...
        | (strcmp(U.x2, 'BagIsPush') & strcmp(U.x1, 'BagIsHotMelt')));
noPush = (strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'BreakHotMelt'))...
        |(strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'OtherIsYou'));


LvlNo = [4, 5, 3];

%% import level config
levelConfigs = importConfig('data/map_config');
ver = 1;

%% handle each level
clc
for chp = 3%1:3
    for lvl = 2:3%1:LvlNo(chp)
    
    fprintf('Chapter: %d, Level: %d \n', chp, lvl)
    
    if chp < 3
        logicalArray = [levelConfigs(:).chapter] == chp ...
                    & [levelConfigs(:).level] == lvl ...
                    & [levelConfigs(:).version] == ver;
    else
        logicalArray = [levelConfigs(:).chapter] == chp;
    end
    levelConfig = levelConfigs(logicalArray);
    entityList = unique([levelConfig.blocks(:).entityType]);

    % initialize data file
    levelHistory = struct('SubNo', {}, 'timestamp', {}, 'TimeFromLaunch', {}, ...
                            'Control', {}, 'Operation', {}, 'entities', {}, 'actionLabel', {}, 'revisit', {});
    emptyLabel = struct('ruleFormed', 0, 'ruleBroken', 0, ...
                         'areYouMoving', false, 'areYouDestroyed', false, ...
                         'directlyPushText', false, 'directlyPushSprite', false, ...
                         'numEntities', 0, 'numType', 0);

    % filter participants
    if chp == 2
        if lvl == 4
            P = P_all(P_all.c4 == ver, :);
        end
        if lvl == 5
            P = P_all(P_all.c5 == ver, :);
        end
    elseif chp == 3
        if lvl == 2
            if ver == 0
                P = P_all(noBagIsPush, :);
            elseif ver == 1
                P = P_all(noMelt, :);
            end
        end
        if lvl == 3
            if ver == 0
                P = P_all(noBag & ~ismember(P_all.SubNo, excludedPforBonus3), :);
            elseif ver == 1
                P = P_all(noPush & ~ismember(P_all.SubNo, excludedPforBonus3), :);
            end
        end
    else
        P = P_all;
    end
    h = height(P);
    fprintf('No. Participants: %d \n', h)
                        
    % summarize player history
    tic
    n_item = 0;
    for i = 1: h
        disp(['SubNo:', num2str(P.SubNo(i))])
        filename = [ 'data/player_map_analyzed/map_logic_', num2str(P.Date(i)), '_', P.Name{i}, '.mat' ];
        load(filename);
        
        logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                        & [mapHistory(:).Level] == lvl - 1;

        if ~any(logicalArray)
            continue;
        end
        mapHistory = mapHistory(logicalArray);

        t_max = length(mapHistory);
        [levelHistory(n_item + 1 : n_item + t_max).SubNo] = deal(P.SubNo(i));
        [levelHistory(n_item + 1 : n_item + t_max).timestamp] = deal(mapHistory(:).timestamp);
        [levelHistory(n_item + 1 : n_item + t_max).TimeFromLaunch] = deal(mapHistory(:).TimeFromLaunch);
        [levelHistory(n_item + 1 : n_item + t_max).Control] = deal(mapHistory(:).Control);
        [levelHistory(n_item + 1 : n_item + t_max).Operation] = deal(mapHistory(:).Operation);

        entityCluster = arrayfun(@(x) mapArray2entityCluster(x, entityList), mapHistory, 'UniformOutput', false);
        [levelHistory(n_item + 1 : n_item + t_max).entities] = deal(entityCluster{:});
        actionLabels = [{emptyLabel}, arrayfun(@(x, y) generateActionLabel(x, y), mapHistory(2:t_max), mapHistory(1:t_max-1), 'UniformOutput', false)];
        [levelHistory(n_item + 1 : n_item + t_max).actionLabel] = deal(actionLabels{:});

        wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), mapHistory);
        if any(wins)
            first_win = find(wins, 1, 'first');
        else
            first_win = numel(wins);
        end
        revisitLabels = num2cell((1:t_max) > first_win);
        [levelHistory(n_item + 1 : n_item + t_max).revisit] = revisitLabels{:};

        clear mapHistory
        n_item = n_item + t_max;
    end
    toc

    filename = [ 'data/level_player_map_history/chp_', num2str(chp), '_lvl_', num2str(lvl), '_ver_', num2str(ver), '.mat' ];
    save(filename, 'levelHistory');

    end
end