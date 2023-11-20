%% Extract RT from raw operation data

% 2022 March
% Lu Yang-fan

% The time counter in the game cumulates the total time the player spend in
% each level, which allows revisits. Here we extract the time spent before
% the first win and the revisiting time after the first win to furthur investigate 
% the players' behavior.

% The output data extract temporal information of each level which
%   (1) distinguishes the time spent before the first win and the revisiting time after first win
%   (2) distinguishes time and steps (game operation: up, down, left, right, undo, redo)

%% read participants' name list
participants = readtable('data/participants.csv');
h = height(participants);

%% initialize data table

% Level-wise

% time2win: time spent before the first win
% time4revisit:  time spent revisiting passed levels

T = table('Size', [0, 11], ...
            'VariableNames',{'SubNo', 'Chapter', 'Level', 'PassedFlag', 'HintFlag', 'Time2Initiate', 'Time2Win', 'Time4Revisit', 'Steps2Win', 'Steps4Revisit', 'StepInterval'},...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'});


% reshape to participant-wise data

% chp = {'tutorial', 'train', 'test'};
% lvl = {{'start', 'rule', 'you', 'shuffle'}; 
%         {'mirror', 'go', 'winner', 'reach', 'limits'}; 
%         {'1st', '2nd', '3rd'}};
    
% TNames = [strcat(chp{1}, '_', lvl{1}), strcat(chp{2}, '_', lvl{2}), strcat(chp{3}, '_', lvl{3})];
% 
% TNames_time2win = strcat(TNames, '_', 'time2win');
% TNames_time4revisit  = strcat(TNames, '_', 'time4revisit');

%% import data

ChpNo = 3;
LvlNo = [4, 5, 3];

for i = 1:h
        filename = [ 'data/player_operation_history/data_', num2str(participants.Date(i)), '_', participants.Name{i}, '.csv' ];
        subdata = readtable(filename);
        
        temp = table;
        IStart = [];
        ISuccess = []; 
        IStop = [];
        IHint = [];
        time2initiate = 0;
        time2win = 0;
        time4revisit = 0;
        steps2win = 0;
        steps4revisit = 0;
        stepInterval = 0;
        passedFlag = 0;
        hintFlag = 0;
        
        for chapter = 1 : ChpNo
            for level = 1 : LvlNo(chapter)
                temp = subdata(subdata.Chapter == chapter - 1 & subdata.Level == level - 1, :);
                oprt = temp(~strcmp('None', temp.Operation) | strcmp('Undo', temp.Control) | strcmp('Redo', temp.Control), :);
                IStart = find(strcmp('Start', temp.Control));
                ISuccess = find(strcmp('Success', temp.Control));
                IStop = find(strcmp('Stop', temp.Control));
                IHint = find(strcmp('ToggleHint', temp.Control), 1);
                
                if ~isempty(IStart)
                    time2initiate = oprt.TimeFromLaunch(1) - temp.TimeFromLaunch(IStart(1));
                    if ~isempty(ISuccess) % solved levels
                        passedFlag = 1;
                        time2win = sum(temp.TimeFromLaunch([ISuccess(1); IStop(IStop < ISuccess(1))])) - sum(temp.TimeFromLaunch(IStart(IStart < ISuccess(1))));
                        time4revisit = sum(temp.TimeFromLaunch([ISuccess; IStop])) - sum(temp.TimeFromLaunch(IStart)) - time2win;
                        steps2win = sum(oprt.TimeFromLaunch < temp.TimeFromLaunch(ISuccess(1)));
                        steps4revisit = height(oprt) - steps2win;
                        stepInterval = mean(diff(oprt{oprt.TimeFromLaunch < temp.TimeFromLaunch(ISuccess(1)), 'TimeFromLaunch'}));
                        if ~isempty(IHint)
                            hintFlag = 1;
                        end
                    else  % fail to solve
                        checkN = numel(IStart) - numel(ISuccess) - numel(IStop);
                        if checkN == 0
                            time2win = sum(temp.TimeFromLaunch(IStop)) - sum(temp.TimeFromLaunch(IStart));
                        else
                            time2win = temp.TimeFromLaunch(end) + sum(temp.TimeFromLaunch(IStop)) - sum(temp.TimeFromLaunch(IStart));
                        end
                        steps2win = height(oprt);
                        stepInterval = mean(diff(oprt.TimeFromLaunch));
                    end
                    T = [T; {i, chapter, level, passedFlag, hintFlag, time2initiate, time2win, time4revisit, steps2win, steps4revisit, stepInterval}];
                end
                time2initiate = 0;
                time2win = 0;
                time4revisit = 0;
                steps2win = 0;
                steps4revisit = 0;
                stepInterval = 0;
                passedFlag = 0;
                hintFlag = 0;
            end
        end
        
end

clear i h temp IStart ISuccess IStop IHint chapter level ChpNo LvlNo filename subdata oprt checkN
clear time2initiate time2win time4revisit steps2win steps4revisit stepInterval passedFlag hintFlag
clear participants

%% Handle timeout in chapter 3

parse_json_level_info;
delta = timerInfo.TimeSpent - T.Time2Win - T.Time4Revisit;

ind = delta > 1 & T.Chapter == 3;
T.Time2Win(ind) = timerInfo.TimeSpent(ind);

clear delta ind