%%BUILD_SPACE_INDIVIDUAL_SEARCH
% The game sovling behavior is descriptively modelled as searching behavior
% in a problem state space (defined by state hashing function). This script
% build a directed graph from the searching process of each participants.

% Input: map history with game logic analysis
% Output: hash table of states, and a directed graph built from state nodes

%% Parameters 

clear
close all
initUtility;
importData;

%% Generate graph

% NOTE: linked list takes up memory; clear the variable space between chapters

for chp = 2
    for lvl = 5
        participants = P;
        
        %% manually select the starting state configuration, if there are multiple ones
         condition_selector = '';
         filter = ones(height(participants), 1, 'logical');

        %% training levels 4 & 5: influenced by condition(NN/NF/FN/FF) setting
%         if chp == 2 && lvl > 3
%             validInput = false;
%             while ~validInput
%                 condition_selector = input('Select one condition NN/NF/FN/FF: ', 's');
%                 validInput = true;
%                 switch condition_selector
%                     case 'NN'
%                         filter = participants.Condition == 1;
%                     case 'NF'
%                         filter = participants.Condition == 2;
%                     case 'FN'
%                         filter = participants.Condition == 3;
%                     case 'FF'
%                         filter = participants.Condition == 4;
%                     otherwise
%                         disp('Invalid condition')
%                         validInput = false;
%                 end
%             end
%         end

        if chp == 2 
            if lvl == 4
                validInput = false;
                while ~validInput
                    condition_selector = input('Select one map configuration defeat/hot: ', 's');
                    validInput = true;
                    switch condition_selector
                        case 'defeat'
                            filter = ~participants.level4_withHot;
                        case 'hot'
                            filter = participants.level4_withHot;
                        otherwise
                            disp('Invalid condition')
                            validInput = false;
                    end
                end
            elseif lvl == 5
                validInput = false;
                while ~validInput
                    condition_selector = input('Select one map configuration defeat/hot: ', 's');
                    validInput = true;
                    switch condition_selector
                        case 'defeat'
                            filter = ~participants.level5_withHot;
                        case 'hot'
                            filter = participants.level5_withHot;
                        otherwise
                            disp('Invalid condition')
                            validInput = false;
                    end
                end
            end
        end

        %% bonus level: map is adaptive to participant's responses
        if chp == 3
            if lvl == 2
                validInput = false;
                while ~validInput
                    condition_selector = input('Select one condition noBagIsPush/noMelt: ', 's');
                    validInput = true;
                    switch condition_selector
                        case 'noBagIsPush'
                            filter = bonus2_noBagIsPush;
                        case 'noMelt'
                            filter = bonus2_noMelt;
                        otherwise
                            disp('Invalid condition')
                            validInput = false;
                    end
                end
            elseif lvl == 3
                filter = ~excludedPforBonus3;
                validInput = false;
                while ~validInput
                    condition_selector = input('Select one condition noBag/noPush: ', 's');
                    validInput = true;
                    switch condition_selector
                        case 'noBag'
                            filter = filter & bonus3_noBag;
                        case 'noPush'
                            filter = filter & bonus3_noPush;
                        otherwise
                            disp('Invalid condition')
                            validInput = false;
                    end
                end
            end
        end

        %% build graph for each participant
        tic

        if isempty(condition_selector)
            savedir = ['problemspace/individual_', num2str(chp), '_', num2str(lvl)];
        else
            savedir = ['problemspace/individual_', num2str(chp), '_', num2str(lvl), '_', condition_selector];
        end

        if ~exist(savedir, 'dir')
            mkdir(savedir);
        end
        
        participants(~filter, :) = [];
        for i = 1:height(participants)
            disp(['---------------[Participant ', num2str(i), ']---------------']);
            filename = ['data/player_map_analyzed/map_logic_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat'];
            load(filename);

            % prepare individual graph
            subhash = containers.Map();
            nodeT = table('Size', [0 10], ...
                        'VariableTypes', {'cellstr', 'logical', 'logical', 'logical', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                        'VariableNames', {'Name', 'win', 'start', 'defeat', 'n_visit', 'n_undo', 'n_participant', 'n_stay', 'm_stay', 'ss_stay'});
            subG = digraph([], nodeT);

            % filter: chapter + level
            logicalArray = [mapHistory(:).Chapter] == chp-1 ...
                            & [mapHistory(:).Level] == lvl-1;
            if ~any(logicalArray)
                continue;
            end
            mapHistory = mapHistory(logicalArray);
            
            % init history
            prev_hash = [];
            prev_t = [];

            % filter: data before first win
            wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), mapHistory);
            if any(wins)
                first_win = find(wins, 1, 'first');
            else
                % do not win in allowed time for chapter 3 (bonus)
                first_win = numel(wins);
            end

            % loop through all operations before the first win
            for k = 1 : first_win

                x = mapHistory(k);
                t = x.TimeFromLaunch;
                isInEffective = x.NumOfCommands == 0;
                
                hash = hashfunc(x);

                % skip "undo" operations
                if strcmp(x.Control, 'Undo')
                    if isequal(prev_hash, hash)  % count the undos within the same state
                        nodeIndex = findnode(subG, prev_hash); % undo must go back to a known state
                        subG.Nodes.n_undo(nodeIndex) = subG.Nodes.n_undo(nodeIndex) + 1;
                    end
                    prev_hash = hash;
                    continue;
                end

                win = wins(k);
                start = strcmp('Start', x.Control) | strcmp('Restart', x.Control);
                defeat = checkResultForReplay(x, 'Defeat');
                % if it is the first try of the level or the operation is restart
                % clear history
                if start
                    prev_hash = [];
                    prev_t = [];
                end
                isTransition = ~isInEffective && (win || defeat || ~isequal(prev_hash, hash));

                % update subhash and nodetable
                if isTransition && ~isKey(subhash, hash)
                    disp('new hash');
                    newNode = dlnode(struct('gridmap', {x.gridmap}));
                    subhash(hash) = newNode;
                    nodeProp = table({hash}, win, start, defeat, 1, 0, 0, 0, 0, 0, ...
                                    'VariableNames', {'Name', 'win', 'start', 'defeat', 'n_visit', 'n_undo', 'n_participant', 'n_stay', 'm_stay', 'ss_stay'});
                    subG = addnode(subG, nodeProp);
                else
                    nodeIndex = findnode(subG, hash);
                    subG.Nodes.n_visit(nodeIndex) = subG.Nodes.n_visit(nodeIndex) + 1;
                    % handle redundancy
                    pointer = subhash(hash);
                    while true
                        if isequal(pointer.Data.gridmap, x.gridmap)
                            break;
                        end
                        if isempty(pointer.Next)
                            newNode = dlnode(struct('gridmap', {x.gridmap}));
                            newNode.insertAfter(pointer);
                            break;
                        else
                            pointer = pointer.Next;
                        end
                    end
                    % update existent node properties
                    if win || start || defeat
                        if win
                            subG.Nodes.win(nodeIndex) = true;
                        end
                        if start
                            subG.Nodes.start(nodeIndex) = true;
                        end
                        if defeat
                            subG.Nodes.defeat(nodeIndex) = true;
                        end
                    end
                end
                % update edge
                if isTransition && ~isempty(prev_hash)
                    edgeIndex = findedge(subG, prev_hash, hash);
                    if  edgeIndex == 0
                        disp('new edge')
                        subG = addedge(subG, prev_hash, hash, 1);
                    else
                        % weight: visit counts
                        subG.Edges.Weight(edgeIndex) = subG.Edges.Weight(edgeIndex) + 1;
                    end
                    % update previous node properties
                    % the player stay at the previous state from prev_t to t
                    delta_t = t - prev_t;
                    nodeIndex = findnode(subG, prev_hash);
                    % incremental mean and summed squares of delta_t
                    subG.Nodes.n_stay(nodeIndex) = subG.Nodes.n_stay(nodeIndex) + 1;
                    old_m = subG.Nodes.m_stay(nodeIndex);
                    subG.Nodes.m_stay(nodeIndex) = old_m + (delta_t - old_m) / subG.Nodes.n_stay(nodeIndex);
                    subG.Nodes.ss_stay(nodeIndex) = subG.Nodes.ss_stay(nodeIndex) + (delta_t - old_m) * (delta_t - subG.Nodes.m_stay(nodeIndex));
                end
                % timing
                if isTransition; prev_t = t; end
                prev_hash = hash;
            end

            individualfile = [savedir, '/individual_search_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat']; 
            save(individualfile, 'subG', 'subhash')
        end
        toc  
        
    end
end