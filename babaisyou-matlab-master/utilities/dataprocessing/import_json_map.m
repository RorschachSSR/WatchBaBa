%% Read operation histion and map history
clear
P = readtable('data/participants.csv');
initUtility; 

%% MERGESTRUCTS
mergestructs = @(x,y) cell2struct([struct2cell(x); struct2cell(y)],[fieldnames(x);fieldnames(y)]);

%% Merge operation history and map history
% Preprocess: convert a list of sprites into a 2D array

termination = height(P);

sub_i = 0;
order_violation = zeros(termination, 1, 'logical');

while sub_i < termination
    tic
    sub_i = sub_i + 1;
    date = P.Date(sub_i);
    name = P.Name{sub_i}; 
    
    filename = ['data/player_operation_history/data_', num2str(date), '_', name, '.csv'];
    subData = readtable(filename);
    oprt = subData(~strcmp('None', subData.Operation) | ...
                   strcmp('Undo', subData.Control) | strcmp('Redo', subData.Control) | ...
                   strcmp('Start', subData.Control) | strcmp('Restart', subData.Control), :);
    stepsNo = height(oprt);

    % Check whether the replay data is complete
    filename = ['data/player_map_history_json/map_', num2str(date), '_', name, '.json'];
    [mapHistory, row] = readMapLog(filename);
    
    replayts = [mapHistory(:).timestamp]';

    if row ~= stepsNo || ~all(oprt.Count == replayts)
        % stepwise data should be consistent with replayed map data
        disp(['Data incomplete: Line ', num2str(sub_i), ', ', num2str(date), ', ', name])
    else
        oprt = removevars(oprt, 'Count');
        mapHistory = mergestructs(mapHistory, table2struct(oprt)');
        disp(['Data complete: Line ', num2str(sub_i), ', ', num2str(date), ', ', name])
    end
    
    % Check whether level visiting history is in the right order
    hist = [oprt.Chapter, oprt.Level];
    [~, ia, ~] = unique(hist, 'rows');
    if all(diff(ia) > 0)
        disp('Right level order')
    else
        disp('Wrong level orger')
        order_violation(sub_i) = true;
    end
    clear ia

    gridMap = arrayfun(@(x) blockList2mapArray(x, true), mapHistory, 'UniformOutput', false);
    [mapHistory(:).gridmap] = deal(gridMap{:});
    
    mapHistory = rmfield(mapHistory, {'size', 'blocks'});
    
    k = [num2str(date), '_', name];
    filename = ['data/player_map_analyzed/map_logic_', k, '.mat'];
    save(filename, 'mapHistory');
    
    clear r s p o gridMap
    
    toc
end


clear row replayts stepts filename subno date name