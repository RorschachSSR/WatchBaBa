%% analyze action labels
clear
initUtility

varNames = {'chapter', 'level', 'version', 'n_sub', 'n_steps', 'ruleFormed','ruleBroken', 'areYouMoving', 'areYouDestroyed',...
        'attemptedPush', 'successfulPush', 'directlyPushText', 'directlyPushSprite', 'numEntities', 'numType'};
actionTable = table('Size', [16, length(varNames)], ...
                    'VariableTypes', {'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'}, ...
                    'VariableNames', varNames);
actionTable.chapter = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3]';
actionTable.level   = [1, 2, 3, 4, 1, 2, 3, 4, 4, 5, 5, 1, 2, 2, 3, 3]';
actionTable.version = [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1]';
fileNames = arrayfun(@(x,y,z) sprintf('data/level_player_map_history/chp_%d_lvl_%d_ver_%d.mat', x, y, z), actionTable.chapter, actionTable.level, actionTable.version, 'UniformOutput', false);

%%
for k = 1:height(actionTable)
    load(fileNames{k});
    revisit = [levelHistory(:).revisit];
    levelHistory = levelHistory(~revisit);
    operations = {levelHistory(:).Operation};
    levelHistory = levelHistory(~strcmp(operations, 'None'));
    actionLabels = [levelHistory(:).actionLabel];
    
    actionTable{k, 'n_sub'} = length(unique([levelHistory(:).SubNo]));
    n_steps = length(levelHistory);
    actionTable{k, 'n_steps'} = n_steps / actionTable{k, 'n_sub'};

    actionTable{k, 'areYouMoving'} = sum([actionLabels(:).areYouMoving]) / n_steps;
    actionTable{k, 'areYouDestroyed'} = sum([actionLabels(:).areYouDestroyed]) / n_steps;
%     actionTable{k, 'areYouMoving'} = sum([actionLabels(:).areYouMoving]) / actionTable{k, 'n_sub'};
%     actionTable{k, 'areYouDestroyed'} = sum([actionLabels(:).areYouDestroyed]) / actionTable{k, 'n_sub'};

    % attempted pushes
    isPushing = [actionLabels(:).directlyPushText] | [actionLabels(:).directlyPushSprite];
    n_attempted_push  = sum(isPushing);
    actionTable{k, 'attemptedPush'} = n_attempted_push / actionTable{k, 'n_sub'};
    actionTable{k, 'directlyPushText'} = sum([actionLabels(isPushing).directlyPushText]) / n_attempted_push;
    actionTable{k, 'directlyPushSprite'} = sum([actionLabels(isPushing).directlyPushSprite]) / n_attempted_push;
    actionTable{k, 'numEntities'} = sum([actionLabels(isPushing).numEntities])/ n_attempted_push;
    actionTable{k, 'numType'} = sum([actionLabels(isPushing).numType])/ n_attempted_push;
%     actionTable{k, 'directlyPushText'} = sum([actionLabels(:).directlyPushText]) / actionTable{k, 'n_sub'};
%     actionTable{k, 'directlyPushSprite'} = sum([actionLabels(:).directlyPushSprite]) / actionTable{k, 'n_sub'};
%     actionTable{k, 'numEntities'} = sum([actionLabels(:).numEntities])/ n_attempted_push;
%     actionTable{k, 'numType'} = sum([actionLabels(:).numType])/ n_attempted_push;

    isPushing = isPushing & [actionLabels(:).areYouMoving];
    n_successful_push = sum(isPushing);
    actionTable{k, 'successfulPush'} = n_successful_push / actionTable{k, 'n_sub'};
    isPushingText = [actionLabels(:).directlyPushText] & [actionLabels(:).areYouMoving];
    actionTable{k, 'ruleFormed'} = sum([actionLabels(isPushingText).ruleFormed]) / sum(isPushingText);
    actionTable{k, 'ruleBroken'} = sum([actionLabels(isPushingText).ruleBroken]) / sum(isPushingText);
%      actionTable{k, 'ruleFormed'} = sum([actionLabels(:).ruleFormed] > 0) / actionTable{k, 'n_sub'};
%      actionTable{k, 'ruleBroken'} = sum([actionLabels(:).ruleBroken] > 0) / actionTable{k, 'n_sub'};
end

writetable(actionTable, 'data/processed_behavior/summary_action_labels.csv');
%actionTable = readtable('data/processed_behavior/summary_action_labels.csv');

%% plot
selectedvars = {'n_sub', 'n_steps', ...
                    'ruleFormed','ruleBroken', 'areYouMoving','areYouDestroyed', ...
                    'attemptedPush', 'successfulPush', ...
                    'directlyPushText', 'directlyPushSprite', ...
                    'numEntities', 'numType'};
cdata = actionTable{:, selectedvars};
ylabels = {'Chp 1 Lvl 1', 'Chp 1 Lvl 2', 'Chp 1 Lvl 3', 'Chp 1 Lvl 4', 'Chp 2 Lvl 1', 'Chp 2 Lvl 2', 'Chp 2 Lvl 3', ...
           'Chp 2 Lvl 4 (defeat)', 'Chp 2 Lvl 4 (hot melt)', 'Chp 2 Lvl 5 (defeat)', 'Chp 2 Lvl 5 (hot melt)', ...
           'Chp 3 Lvl 1', 'Chp 3 Lvl 2 (populate bags)', 'Chp 3 Lvl 2 (block melt)', 'Chp 3 Lvl 3 (block bag)', 'Chp 3 Lvl 3 (block push)'};
xlabels = {'n_{subject}', 'n_{steps}^{subject}', ...
            'p(form rule|succesful push text)', 'p(break rule|succesful push text)', 'p(move|act)', 'p(destroyed|act)', ...
            'n_{attempt push}^{subject}', 'n_{succesful push}^{subject}', ...
            'p(text|attempt push)', 'p(sprite|attempt push)', ...
            'n_{pushed entities}^{attempted push}', 'n_{pushed entity type}^{attempted push}'};
h = heatmap(cdata);

h.XDisplayLabels = xlabels;
h.YDisplayLabels = ylabels;
h.ColorScaling = 'scaledcolumns';

%% corr
figure
[RHO,PVALUE] = corr(cdata, 'Type', 'pearson');
RHO = tril(RHO, -1);
RHO(RHO == 0) = nan;
PVALUE = tril(PVALUE, -1);
RHO(PVALUE > 0.05) = nan;
cdata(14, :) = [];
h = heatmap(RHO);
colormap(h, parula);
caxis([-1 1]);

h.XDisplayLabels = xlabels;
h.YDisplayLabels = xlabels;
%% unique states
entitiesMap = {levelHistory(:).entities};
[Au,idx,idx2] = uniquecell(entitesMap);
