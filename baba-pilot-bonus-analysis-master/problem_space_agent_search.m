%% Create a pool of 8 workers
clear
clc
if isunix && ~ismac
    n_workers = 8;
else
    n_workers = 4;
end
if isempty(gcp('nocreate'))
    parpool(n_workers);
end

%% Set initial state
initUtility
levelConfigs = importConfig('default');
% Select a problem (map config)
configID = 6;
mapItem.gridmap = levelConfigs(configID).gridmap;
[height, width] = size(mapItem.gridmap);
entityList = unique([levelConfigs(configID).blocks(:).entityType]);
entity_cluster_initial = mapArray2entityCluster(mapItem, entityList);
chp = levelConfigs(configID).chapter;
lvl = levelConfigs(configID).level;
clear levelConfigs

%% Create log file
logfile = sprintf('log_%s.txt', datetime('now', 'Format', 'yyyy-MM-dd'));
fid = fopen(logfile, 'w');
fprintf(fid, 'Chapter %d, Level %d, Platform %s\n', chp, lvl, computer);
fclose(fid);

global map_height
map_height = height;

%% Initialize searching frontier and explored set
global frontier came_from
frontier = parallel.pool.PollableDataQueue;
came_from = containers.Map('ValueType','any','KeyType','char');
send(frontier, entity_cluster_initial);
[key     ,  ~]       = entityCluster2stateHash(entity_cluster_initial, map_height, true);
came_from(key) = struct('state',[], 'you', [], 'action',[], 'reward', 0);
clear entity_cluster_initial

%% Create a hub to check visited states
hub = parallel.pool.DataQueue;
afterEach(hub, @checkVisited);

while frontier.QueueLength > 0
    if frontier.QueueLength >= n_workers
        n_process = n_workers;
    else
        n_process = frontier.QueueLength;
    end

    waitList = cell(1, n_process);
    for i = 1:n_process
        waitList{i} = poll(frontier);
    end
    
    parfor worker = 1:n_process
        current_entity_cluster = waitList{worker};
        mapItem = struct();
        mapItem.gridmap = entityCluster2mapArray(current_entity_cluster, height);

        % neighbor generation from current state
        [posPerformingPush, youCluster, extendedObstacleGraph]  = getNeighbors(mapItem);
        youCluster = youCluster';
        sources = find(youCluster(:));
        targets = arrayfun(@(x,y) width * (y - 1) + x, [posPerformingPush(:).x], [posPerformingPush(:).y]);
        finalmoves = {posPerformingPush(:).moveDir};

        % loop through neighbors (target postion + final move)
        n_pos = size(posPerformingPush,2);
        for i = 1:n_pos
            target = targets(i);
            [TR, D] = shortestpathtree(extendedObstacleGraph, sources, target, 'Method', 'positive', 'OutputForm', 'cell');
            [M, k] = min(D);
            path = TR{k};
            % up, down, left, right -> 1, 2, 3, 4
            deltaPos = diff(path);
            moves = zeros(1, M);
            moves(deltaPos == -1) = 3;
            moves(deltaPos == 1) = 4;
            moves(deltaPos == -width) = 2;
            moves(deltaPos == width) = 1;
            finalmove = finalmoves{i};
            moves = [moves, operation2Enum(finalmove)];
            % update state
            new_mapItem = mapItem;
            n_moves = length(moves);
            reward = 0; % terminal state
            for a = 1: n_moves
                if a < n_moves
                    new_mapItem = step(new_mapItem, enum2Operation(moves(a)));
                else
                    [new_mapItem, reward, ~] = step(new_mapItem, enum2Operation(moves(a)));
                end
            end
            next_entity_cluster = mapArray2entityCluster(new_mapItem, entityList);
            if isequal(next_entity_cluster, current_entity_cluster)
                continue;
            end
            mssg = struct('next', next_entity_cluster, 'camefrom', current_entity_cluster, 'moves', moves, 'reward', reward);
            send(hub, mssg);
        end
    end
end

%%
fid = fopen(logfile, 'w');
fprintf(fid, 'COMPLETE: %s\n', datetime('now'));
fclose(fid);
delete(gcp('nocreate'));% Delete any existing pool
