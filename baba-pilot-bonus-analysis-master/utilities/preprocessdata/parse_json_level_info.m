%% Parse json info files

% March 21, 2023 
% Lu Yang-fan

%% read participants' name list
% Columns: subNo | date | name | condition
% Condition: 
%      level 4 | level 5
%   1: Naive Naive
%   2: Naive Familiar
%   3: Familiar Naive
%   4: Familiar Familiar
%   Naive: defeat property word
%   Familiar: hot property word

participants = readtable('data/participants.csv');
h = height(participants);

%% Read Timer Info
% gets `Timespent` total residence time in each level

timerInfo = table('Size', [0, 5], ...
            'VariableNames',{'SubNo', 'Chapter', 'Level', 'PassedFlag', 'TimeSpent'},...
            'VariableTypes', {'double', 'double', 'double', 'double', 'double'});

for i = 1:h
    
   filename = [ 'data/player_level_timer/LevelManagerInfo_', num2str(participants.Date(i)), '_', participants.Name{i}, '.json' ];
   text = fileread(filename);
   value = jsondecode(text);
   
   % add data

    chapterNum = numel(value.chapterTimerInfoDict.m_keys);

    tempPass = 0;
    tempTimer = 0;

    for chapter = 1:chapterNum
        % number of levels have timer info recorded
        levelNum_timer = numel(value.chapterTimerInfoDict.m_values(chapter).levelTimerInfoDict.m_keys);
        if numel(value.chapterInfoDict.m_keys) < chapter 
            % do not pass the first bonus level
            value.chapterInfoDict.m_keys = [value.chapterInfoDict.m_keys; chapter - 1];
            value.chapterInfoDict.m_values(chapter).levelInfoDict.m_keys = 0;
            value.chapterInfoDict.m_values(chapter).levelInfoDict.m_values = 0;
        else
            % number of levels have passage info recorded
            levelNum_pass = numel(value.chapterInfoDict.m_values(chapter).levelInfoDict.m_keys);
            if levelNum_timer - levelNum_pass == 1
                value.chapterInfoDict.m_values(chapter).levelInfoDict.m_keys = value.chapterTimerInfoDict.m_values(chapter).levelTimerInfoDict.m_keys;
                value.chapterInfoDict.m_values(chapter).levelInfoDict.m_values = [value.chapterInfoDict.m_values(chapter).levelInfoDict.m_values; 0];
            end
        end

        for level = 1:levelNum_timer
            tempPass = value.chapterInfoDict.m_values(chapter).levelInfoDict.m_values(level);
            tempTimer = value.chapterTimerInfoDict.m_values(chapter).levelTimerInfoDict.m_values(level);
            newCell = {i, chapter, level, tempPass, tempTimer};
            timerInfo = [timerInfo; newCell];
        end
    end

end

clear i filename text value newCell tempPass tempTimer chapterNum levelNum_timer levelNum_pass chapter level 

%% Read Bonus Solution Info

S = table('Size', [0, 7], ...
            'VariableNames',{'SubNo', 'Chapter', 'Level', 'Solution', 'Pumpkin', 'Push', 'Melt'},...
            'VariableTypes', {'double', 'double', 'double', 'string', 'logical', 'logical', 'logical'});
% noun
bag = 8;
pumpkin = 4;
cloud = 1;
dice = 3;
% property
you = 0;
push = 4;
melt = 8;
hot = 9;
        
for i = 1:h

    filename = [ 'data/player_bonus_solution/SolutionInfo_', num2str(participants.Date(i)), '_', participants.Name{i}, '.json' ];
    text = fileread(filename);
    value = jsondecode(text);
    
    % solution level
    chapter = 3;
    
    L = numel(value.sList);
    
    for j = 1:L
        if value.sList(j).chapterIndex == chapter - 1
            sol = '';
            bagORpumpkin = false;
            usepush = false;
            usemelt = false;
            
            level = value.sList(j).levelIndex + 1;
            solutionInfo = value.sList(j).ruleInfoDict;
            cloudRow = solutionInfo.m_keys == cloud;
            bagRow = solutionInfo.m_keys == bag;
            diceRow = solutionInfo.m_keys == dice;
            pumpkinRow = solutionInfo.m_keys == pumpkin;
            
            isBagMelt = any(bagRow) && any(solutionInfo.m_values(bagRow).attributeList == melt);
            isBagHot  = any(bagRow) && any(solutionInfo.m_values(bagRow).attributeList == hot);
            isCloudMelt = any(cloudRow) && any(solutionInfo.m_values(cloudRow).attributeList == melt);
            isCloudYou = any(cloudRow) && any(solutionInfo.m_values(cloudRow).attributeList == you);
            isDicePush = any(diceRow) && any(solutionInfo.m_values(diceRow).attributeList == push);
            
            useBagIsPush = any(bagRow) && any(solutionInfo.m_values(bagRow).attributeList == push);
            useBagIsHotMelt = isBagHot && isBagMelt;
            useBreakHotMelt = ~isBagHot || ~isCloudMelt;
            useOtherIsYou = ~isCloudYou;
            usePumpkinIsPush = useBreakHotMelt || useOtherIsYou;
            
            if ~useBagIsPush && ~useBagIsHotMelt && ~usePumpkinIsPush && ~isDicePush
                useBagIsHotMelt = true;
            end
            
            if useBagIsPush
                sol = 'BagIsPush';
                usepush = true;
            elseif useBagIsHotMelt
                sol = 'BagIsHotMelt';
                usemelt = true;
            elseif useBreakHotMelt
                sol = 'BreakHotMelt';
                bagORpumpkin = true;
                usemelt = true;
                usepush = true;
            elseif useOtherIsYou
                sol = 'OtherIsYou';
                bagORpumpkin = true;
                usepush = true;
            end
            
            newCell = {i, chapter, level, sol, bagORpumpkin, usepush, usemelt};
            S = [S; newCell];
        end
    end
    
end

% S: category of bonus level solution
clear bag pumpkin cloud dice you push melt hot
clear chapter level solutionInfo cloudRow bagRow diceRow pumpkinRow
clear isBagMelt isBagHot isCloudMelt isCloudYou isDicePush
clear useBagIsPush useBagIsHotMelt useBreakHotMelt useOtherIsYou usePumpkinIsPush
clear i j L filename text value newCell sol bagORpumpkin usepush usemelt
clear participants h

%% Buggy categorization in game script before March 8

% clear filename text value newCell
% 
% T = table('Size', [0, 4], ...
%             'VariableNames',{'SubNo', 'Chapter', 'Level', 'Solution'},...
%             'VariableTypes', {'double', 'double', 'double', 'string'});
% % noun
% bag = 8;
% pumpkin = 4;
% cloud = 1;
% % property
% you = 0;
% push = 4;
% melt = 8;
% hot = 9;
%         
% for i = 1:h
% 
%     filename = [ 'data/player_bonus_solution/SolutionInfo_', num2str(P.Date(i)), '_', P.Name{i}, '.json' ];
%     text = fileread(filename);
%     value = jsondecode(text);
%     
%     % solution level
%     chapter = 3;
%     
%     L = numel(value.sList);
%     
%     for j = 1:L
%         if value.sList(j).chapterIndex == chapter - 1
%             sol = '';
%             
%             level = value.sList(j).levelIndex + 1;
%             solutionInfo = value.sList(j).ruleInfoDict;
%             cloudRow = solutionInfo.m_keys == cloud;
%             bagRow = solutionInfo.m_keys == bag;
%             pumpkinRow = solutionInfo.m_keys == pumpkin;
%             
%             if any(solutionInfo.m_values(pumpkinRow).attributeList == push)
%                  sol = 'PumpkinIsPush';
%             elseif any(solutionInfo.m_values(bagRow).attributeList == melt)
%                 sol = 'BagIsMelt';
%             elseif any(solutionInfo.m_values(bagRow).attributeList == push)
%                 sol = 'BagIsPush';
%             end
%             
%             newCell = {i, chapter, level, sol};
%             T = [T; newCell];
%         end
%     end
%     
% end