%% Visualize RT

% 2022 Jan-Feb
% Lu Yang-fan

% This code processes the level time data. Run rawCSVtoBehavior and rawJSONtoTable to
% get 'leveltime.csv' and 'leveltimesplit.csv'.

%% Initialize

clear
importData;

Q.Condition = P.Condition(Q.SubNo);

rng('Shuffle')

%% Select the variable to process

varOfConcern = 'StepInterval';

%% By Level and Condition

clear Ts

chapter = 3;

Ts = T(T.Chapter == chapter, :);
levelNum = max(Ts.Level);

if chapter == 3
    Ts(Ts.PassedFlag == 0, :) = [];
else
    % treat level as unpassed if it was completed after Hint is toggled on
    Ts(Ts.HintFlag == 1, :) = [];
end

% Mean
figure('Position', [400,200,750,500]);
summaryTable = groupsummary(Ts, {'Condition', 'Level'},  {'mean', 'std'}, varOfConcern, 'IncludeEmptyGroups',true);

m = reshape(summaryTable{:, ['mean_', varOfConcern]}, levelNum, 4);
sem = reshape(summaryTable{:, ['std_', varOfConcern]}./sqrt(summaryTable.GroupCount), levelNum, 4);

for condition = 1:4
    
    errorbar((1:levelNum) + 0.2 * (rand(1)-0.5) , m(:, condition), sem(:, condition), '.-', 'MarkerSize',18,... 
                'LineWidth', 2, 'Color', Color4Condition(5 - condition, :)); hold on 
end

set_figure_prop
legend(conditionSet)

xlim([0.5 levelNum + 0.5])
xticks(1:levelNum)
xlabel('Level')

ylim([0 Inf])
ylabel(varOfConcern)
title(['Chapter ', num2str(chapter)])

logicalArray = Ts.Level == 1;

%% By Solution

clear m sem chapter levelNum condition logicalArray
clear summaryTable Ts

Ts = T(T.Chapter == 3 & T.PassedFlag == 1, :);
Ss = bonus_solutions;

if all(Ts.Level == Ss.Level)
    Ss = addvars(Ss, Ts{:, varOfConcern}, 'NewVariableNames', varOfConcern);
    Ss.SolutionType = categorical(bonus_solutions.Solution, solutionSet);
end

summaryTable = groupsummary(Ss, {'SolutionType'},  {'mean', 'std'}, varOfConcern, 'IncludeEmptyGroups',true);
m = summaryTable{:, ['mean_', varOfConcern]};
se = summaryTable{:, ['std_', varOfConcern]} ./ sqrt(summaryTable.GroupCount);

h = bar(m);

h.FaceColor = 'flat';
h.CData = Color4Solution;

set_figure_prop
xticklabels(solutionSet)
ylabel(varOfConcern)
hold on

f = @(a)bsxfun(@plus,cat(1,a{:,1}),cat(1,a{:,2})).';
errorbar(f(get(h,{'xoffset','xdata'})),m,se,'.','Color','k','linewidth',1)

legend off

%% By Condition and Solution

clear Ts Ss h i f summaryTable m se

Ts = T(T.Chapter == 3 & T.PassedFlag == 1, :);
Ss = bonus_solutions;

if all(Ts.Level == Ss.Level)
    Ss = addvars(Ss, Ts{:, varOfConcern}, 'NewVariableNames', varOfConcern);
    Ss.SolutionType = categorical(Ss.Solution, solutionSet);
    Ss.ConditionType = categorical(Ss.Condition, [1 2 3 4], conditionSet);
end

summaryTable = groupsummary(Ss, {'ConditionType', 'Soluti onType'},  {'mean', 'std'}, varOfConcern, 'IncludeEmptyGroups',true);
m = reshape(summaryTable{:, ['mean_', varOfConcern]}, 4, 4);
sem = reshape(summaryTable{:, ['std_', varOfConcern]} ./ sqrt(summaryTable.GroupCount), 4, 4);

figure('Position', [400,200,750,500]);

for condition = 1:4
    errorbar((1:4) + 0.2 * (rand(1)-0.5) , m(:, condition), sem(:, condition), '.-', 'MarkerSize',18,... 
                'LineWidth', 2, 'Color', Color4Condition(5 - condition, :)); hold on 
end

set_figure_prop

xlim([0.5, 4.5])
xticks(1:4)
xticklabels(solutionSet)

ylim([0 Inf])
ylabel(varOfConcern)

legend(conditionSet)

%% 
clear Ts Ss summaryTable m sem k condition
clear ans