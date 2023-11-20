%% read participants' name list

clear

P = readtable('data/participants.csv');
h = height(P);

%% initialize data table

% Level-wise

T = table('Size', [0, 8], ...
            'VariableNames',{'SubNo', 'Chapter', 'Level', 'PassedFlag', 'TimeExploit', 'TimeExplore', 'StepsExploit', 'StepsExplore'},...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'});
summaryT = table('Size', [0, 5], ...
            'VariableNames',{'SubNo', 'TimeExploit', 'TimeExplore', 'StepsExploit', 'StepsExplore'},...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double'});
        
Strct = struct('SubNo', {}, 'Chapter', {}, 'Level', {}, 'timeStamp', {}, 'seq', {}, 'exploitStart', {}, 'exploitEnd', {}, 'exploreStart', {}, 'exploreEnd', {});


%% import data

ChpNo = 3;
LvlNo = [4, 5, 3];

for i = 1:h
        filename = [ 'data/player_operation_history/data_', num2str(P.Date(i)), '_', P.Name{i}, '.csv' ];
        subdata = readtable(filename);
        
        temp = table;
        seq = [];
        timeStamp = [];
        IStart = [];
        ISuccess = [];
        passedFlag = 0;
        timeExploit = 0;
        timeExplore = 0;
        stepsExploit = 0;
        stepsExplore = 0;
        
        exploitDurSave = [];
        exploitStepsSave = [];
        exploreDurSave = [];
        exploreStepsSave = [];
        
        for chapter = 1 : ChpNo
            for level = 1 : LvlNo(chapter)
                temp = subdata(subdata.Chapter == chapter - 1 & subdata.Level == level - 1, :);
                oprt = temp(~strcmp('None', temp.Operation) | ...
                            strcmp('Undo', temp.Control) | strcmp('Redo', temp.Control), :);
                IStart = find(strcmp('Start', temp.Control));
                ISuccess = find(strcmp('Success', temp.Control));
                if ~isempty(ISuccess) % solved levels
                    passedFlag = 1;
                    logicalArray = oprt.TimeFromLaunch < temp.TimeFromLaunch(ISuccess(1));
                    seq = diff(oprt{logicalArray, 'TimeFromLaunch'});
                    timeStamp = oprt{logicalArray, 'Count'};
                elseif ~isempty(IStart) % fail to solve
                    seq = diff(oprt.TimeFromLaunch);
                    timeStamp = oprt.Count;
                end
                if ~isempty(seq)
                    [tempStruct, exploitDur, exploitSteps, exploreDur, exploreSteps] = seqSegment(seq);
                    timeExploit = mean(exploitDur);
                    timeExplore = mean(exploreDur);
                    stepsExploit = mean(exploitSteps);
                    stepsExplore = mean(exploreSteps);
                    if ~isempty(tempStruct)
                        display(['Subject ', num2str(i), '; Chapter ', num2str(chapter), '; Level ', num2str(level)])
                    end
                    T = [T; {i, chapter, level, passedFlag, timeExploit, ...
                            timeExplore, stepsExploit, stepsExplore}];
                    
                    tempStruct.SubNo   = i;
                    tempStruct.Chapter = chapter;
                    tempStruct.Level   = level;
                    tempStruct.timeStamp = timeStamp;
                    Strct(end+1) = tempStruct;
                
                    exploitDurSave = [exploitDurSave; exploitDur];
                    exploitStepsSave = [exploitStepsSave; exploitSteps];
                    exploreDurSave = [exploreDurSave; exploreDur];
                    exploreStepsSave = [exploreStepsSave; exploreSteps];
                end
                temp = table;
                seq = [];
                timeStamp = [];
                IStart = [];
                ISuccess = [];
                passedFlag = 0;
                timeExploit = 0;
                timeExplore = 0;
                stepsExploit = 0;
                stepsExplore = 0;
            end
        end
        
        summaryT = [summaryT;
                   {i, mean(exploitDurSave), mean(exploreDurSave),  ... 
                        mean(exploitStepsSave), mean(exploreStepsSave)}];  
        
end

%% Save table

writetable(T, 'data/tradeoff_in_level.csv');
writetable(summaryT, 'data/tradeoff_trait.csv');

%% Save struct table

save('data/tradeoff_in_level_segmentation.mat', 'Strct')