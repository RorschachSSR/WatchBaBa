%% Replicate Level 4  Solution in Level 5

clear
initUtility
importData
levelConfigs = importConfig('data/map_config');
LvlNo = [4, 5, 1];
VerId = {[0, 0, 0, 0], [0 0 0 1 1], [0 1 1]};
behaviorSummary = table('Size', [64, 5], 'VariableTypes', {'double', 'double', 'double', 'double', 'double'},...
                                'VariableNames', {'SubNo', 'pushText', 'pushTextAsExtensionButFail', 'lvl4Type', 'lvl5Type'});

chp = 2;
lvl = 5;
subCount = 0;
for ver = 0:1 %0:VerId{chp}(lvl)
    filedir = sprintf('data/level_player_map_history/chp_%d_lvl_%d_ver_%d.mat', chp, lvl, ver);
    load(filedir)
    if chp < 3
        logicalArray = [levelConfigs(:).chapter] == chp ...
            & [levelConfigs(:).level] == lvl ...
            & [levelConfigs(:).version] == ver;
    else
        logicalArray = [levelConfigs(:).chapter] == chp;
    end
    height = levelConfigs(logicalArray).size.y;
    allSub = [levelHistory(:).SubNo];
    subList = unique(allSub);
    n_sub = length(subList);
    for i = 1:n_sub
        s = subList(i);
        actionLabels = [levelHistory(allSub == s).actionLabel];
        pushText = [actionLabels(:).directlyPushText];
        destroyed = [actionLabels(:).areYouDestroyed];
        lvl_4_type = P.level4_withHot(P.SubNo == s); % uncorrelated with lvl 4 or lvl 5 type
        subCount = subCount + 1;
        behaviorSummary(subCount, :) = {s, sum(pushText), sum(destroyed & pushText), lvl_4_type, ver};
    end
end

behaviorSummary = sortrows(behaviorSummary, 'SubNo');
behaviorSummary.lastLevelTime2Win = T.Time2Win(T.Chapter == 2 & T.Level == 4);
behaviorSummary.lastLevelSteps2Win = T.Steps2Win(T.Chapter == 2 & T.Level == 4);
behaviorSummary.preTestTime2Win = T.Time2Win(T.Chapter == 2 & T.Level == 1);
behaviorSummary.preTestSteps2Win = T.Steps2Win(T.Chapter == 2 & T.Level == 1);
behaviorSummary.thisLevelTime2Win = T.Time2Win(T.Chapter == 2 & T.Level == 5);
behaviorSummary.thisLevelSteps2Win = T.Steps2Win(T.Chapter == 2 & T.Level == 5);
behaviorSummary.baselineTime2Win = T.Time2Win(T.Chapter == 2 & T.Level == 3);
behaviorSummary.baselineSteps2Win = T.Steps2Win(T.Chapter == 2 & T.Level == 3);
writetable(behaviorSummary, 'data/processed_behavior/summary_ch2_lvl5.csv');