function checkVisited(messg)
    global came_from
    global frontier
    global map_height

    persistent count_state count_win count_defeat count_revisit logTime saveTime
    currTime = datetime('now');

    if isempty(count_state)
        count_state = 0;
    end
    if isempty(count_win)
        count_win = 0;
    end
    if isempty(count_defeat)
        count_defeat = 0;
    end
    if isempty(count_revisit)
        count_revisit = 0;
    end
    if isempty(logTime)
        logTime = currTime;
    end
    if isempty(saveTime)
        saveTime = currTime;
    end

    if nargin < 1
        return;
    end

    entity_cluster  = messg.next;
    prev_entity_cluster = messg.camefrom;
    r          = messg.reward;
    [key     ,  ~]       = entityCluster2stateHash(entity_cluster, map_height, true);
    [key_from, you_from] = entityCluster2stateHash(prev_entity_cluster, map_height, false);
    
    if r == 0 && isKey(came_from, key)
        count_revisit = count_revisit + 1;
        if mod(count_revisit, 1000) == 1
            fprintf('* [%d] revisit a state\n', count_revisit)
        end
        return;
    end
    
    render = false;
    switch r
        case 0
            if isKey(came_from, key)
                count_revisit = count_revisit + 1;
                if mod(count_revisit, 1000) == 1
                    fprintf('* [%d] revisit a state\n', count_revisit)
                end
                return;
            end
            count_state = count_state + 1;
            send(frontier, entity_cluster);
            came_from(key) = struct('state', key_from, 'you', you_from, 'action', messg.moves, 'reward', r);
        case 1
            if isKey(came_from, key)
                value = came_from(key);
                if isequal(value.state, key_from)
                    if value.reward == 0 % if the state is not treated as a terminal state
                        value.reward = r;
                        value.action = [value.action, messg.moves]; % append the trajectory
                        came_from(key) = value;
                        count_win = count_win + 1;
                        fprintf('+ [%d] winning state\n', count_win);
                    end
                end
            else
                came_from(key) = struct('state', key_from, 'you', you_from, 'action', messg.moves, 'reward', r);
                count_state = count_state + 1;
                count_win = count_win + 1;
                fprintf('+ [%d] winning state\n', count_win);
            end
        case -1
            if ~isKey(came_from, key)
                came_from(key) = struct('state', key_from, 'you', you_from, 'action', messg.moves, 'reward', r);
                count_defeat = count_defeat + 1;
                fprintf('+ [%d] defeat state\n', count_defeat);
            end
    end

    if count_state < 1000
        if mod(count_state, 100) == 1
            fprintf('+ [%d] non-terminal state\n', count_state);
            render = true;
        end
    elseif mod(count_state, 1000) == 1
        fprintf('+ [%d] non-terminal state\n', count_state);
        render = true;
    end

    % log and save
    dt = currTime - logTime;
    if dt > minutes(15)
        logTime = currTime;
        logfile = sprintf('log_%s.txt', datetime('now', 'Format', 'yyyy-MM-dd'));
        fid = fopen(logfile, 'a');
        fprintf(fid, '%s: %d states, %d wins, %d defeats, %d revisits, %d in queue\n', datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'), count_state, count_win, count_defeat, count_revisit, frontier.QueueLength);
    end
    dt = currTime - saveTime;
    if dt > minutes(60)
        saveTime = currTime;
        save('problemspace/came_from.mat', 'came_from');
    end

    % render map
    if render
        mapItem.gridmap = entityCluster2mapArray(entity_cluster, map_height);
        f = figure('visible', 'off');
        ax = axes(f);
        renderMap(mapItem, ax);

        switch r
            case 0 
                type = 'non-terminal';
            case 1
                type = 'win';
            case -1
                type = 'defeat';
        end

        snapshot(f, sprintf('problemspace/rendering/map_%s_%d_%s', datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'), count_state, type));

        close(f)
    end
end