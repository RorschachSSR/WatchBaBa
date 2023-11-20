clear
importData; 

X = Q{:, surveyLabel};
[coeff,score,~, ~, explained, ~] = pca(zscore(X));

% save the first 2 components
Q.GameFreq = score(:, 1);
Q.GamePref = score(:, 2);

%% Clearing

%T(T.PassedFlag == 0 | T.HintFlag == 1, :) = [];

%%
T.sum = T.Time2Initiate + T.Time2Win + T.Time4Revisit;
vars2Select = {'sum','Time2Initiate', 'Time2Win', 'Time4Revisit', 'Steps2Win', 'Steps4Revisit', 'StepInterval'};
varOfConcern = vars2Select{1};

%%
clear Ts U
Ts = T(:, {'SubNo', 'level4_withHot', 'level5_withHot', varOfConcern});

Ts.ID = strcat({'chp_'}, cellstr(num2str(T.Chapter)),{'lvl_'}, cellstr(num2str(T.Level)));
Ts.ID = categorical(Ts.ID);

U = unstack(Ts, varOfConcern,'ID');
U = addvars(U, Q.GameFreq(U.SubNo), Q.GamePref(U.SubNo), 'After', 'SubNo', 'NewVariableNames', {'GameFreq', 'GamePref'});
U = removevars(U, 'SubNo');

%%

[RHO, PVALUE] = corrcoef(U{:, :}, 'Rows', 'pairwise');
labels = U.Properties.VariableNames;

figure('Position', [0 0 1000 800])
clf
RHO(PVALUE > 0.05) = nan;
h = heatmap(RHO);
colormap jet
caxis([-1 1])
h.XDisplayLabels = labels;
h.YDisplayLabels = labels;

title(varOfConcern)

exportgraphics(gcf,['figures/corr_matrix_', varOfConcern, '.png'],'Resolution',300)

%% Scatter by level4_withHot

figure

histogram(U{U.level4_withHot==0, 'C1L2'}, 'Normalization','count', 'BinWidth', 100, ...
            'FaceColor', [0.8 0.8 0.8], 'EdgeColor', [0.6 0.6 0.6]); hold on
histogram(U{U.level4_withHot==1, 'C1L2'}, 'Normalization','count', 'BinWidth', 100, ...
            'FaceColor', [0.3010 0.7450 0.9330], 'EdgeColor', [0.1 0.1 0.1]);