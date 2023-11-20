%% Visualize Solution

% 2022 Jan-Feb
% Lu Yang-fan

% This code processes the solution data. Run json2table to convert 
% raw RT data to a table in 'data/bonus_solution_category.csv'.

%% Initialize

clear

importData;

% %% Delete subNo = 18
% % This participant spent more than 3000 seconds on chapter 2 level 1 -- Mirror room.
% 
% P(P.SubNo == 18, :) = [];
% T(T.SubNo == 18, :) = [];
% S(S.SubNo == 18, :) = [];
% Q(S.SubNo == 18, :) = [];

%% Conditions

C = categorical(P.Condition, [1 2 3 4], {'NN', 'NF', 'FN', 'FF'});
h = histogram(C,'BarWidth',0.5);
xlabel('Condition')
ylabel('Count')

set(gca, 'FontSize', 14)

groupCounts = h.Values;

clear h C

%% Solution at each attempt

% SubNo = 5 is the only participant who find the "BagIsHot&Melt" Solution
% at first try

figure('Position', [100 100 600 400])
tryNo = 1;

% duplicate solutions are omitted in this analysis

Ss = bonus_solutions(bonus_solutions.Level == tryNo, :);
Ss.SolutionType = categorical(Ss.Solution, solutionSet);
Ss.ConditionType = categorical(Ss.Condition, [1 2 3 4], conditionSet);

summaryTable = groupsummary(Ss, {'ConditionType', 'SolutionType'}, 'IncludeEmptyGroups',true);
summaryCounts = permute(reshape(summaryTable.GroupCount, [4 4]),[2,1]);

b = bar(summaryCounts,'stacked');

for k = 1:numel(conditionSet)
    b(k).FaceColor = Color4Solution(k, :);
end

set_figure_prop;
legend(solutionSet);
ylabel('Count');
xlabel('Condition');
xticklabels(conditionSet);
xlim([0.5, 4.5]);
ylim([0,18]);

clear Ss summaryTable summaryCounts
clear tryNo b k

%%
bonus_solutions(bonus_solutions.Level ~= 2, :) = [];

h = height(P);
x = strcmp(bonus_solutions.Solution, 'BreakHotMelt');

c = bonus_solutions.Condition;

[tbl,chi2,p,labels] = crosstab(c, x);