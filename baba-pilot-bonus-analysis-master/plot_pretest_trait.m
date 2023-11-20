%% Plot Gaming Trait
% 2022 Jan-Feb
% Lu Yang-fan

% Run rawJSONtoTable and download survey data from Qualtrics.

%% Initialize

clear

importData;

% %% Delete subNo = 18
% % This participant spent more than 3000 seconds on chapter 2 level 1 -- Mirror room.
% % and leave before time out in chapter 3.
% P(P.SubNo == 18, :) = [];
% T(T.SubNo == 18, :) = [];
% S(S.SubNo == 18, :) = [];
% G(S.SubNo == 18, :) = [];

Q.Condition = P.Condition(Q.SubNo);
timingLabel = {'TutorialTime', 'PretestTime', 'TrainingTime', 'BonusTime', 'TotalTime'};

%% Principal analysis

X = Q{:, surveyLabel};

% [r, p] = corrcoef(X);
% r(p>0.05) = nan;
% heatmap(surveyLabel, surveyLabel, r);

[coeff,score,~, ~, explained, ~] = pca(zscore(X));

% save the first three components
Q.PC1 = score(:, 1);
Q.PC2 = score(:, 2);
Q.PC3 = score(:, 3);

figure
plot(explained);
xlabel('Component');
ylabel('%Variance Explained')

figure
biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',surveyLabel);
                            
figure
[rho, p] = corr(X);
rho(p>0.05) = nan;
heatmap(surveyLabel, surveyLabel, rho)

clear X coeff score explained rho p

%% Correlation between timing data and gameplay trait
close all

Gs = Q(:, :);
traitLabel = {'PC1', 'PC2', 'PC3'};

X = table2array(Gs(:, [timingLabel, traitLabel]));

[rho, p] = corr(X);
rho(p>0.05) = nan;

figure
heatmap([timingLabel, traitLabel], [timingLabel, traitLabel], rho);

figure
plotmatrix(X, '+');

clear Gs traitLabel rho p X

%% Correlation between timing data and raw gameplay survey items
close all

Gs = Q(:, [{'Condition'}, surveyLabel, timingLabel]);
X = table2array(Gs);

[rho, p] = corr(X);
rho(p>0.05) = nan;

figure
heatmap([{'Condition'}, surveyLabel, timingLabel], [{'Condition'}, surveyLabel, timingLabel], rho);

clear Gs rho p X

%% Sampling of gameplay trait in four conditions
close all


X = Q.PC1;
Y = Q.PC2;
c = Color4Condition(5 - Q.Condition, :);
scatter(X, Y, 36, c,'MarkerFaceColor', 'flat', 'MarkerFaceAlpha', 0.5, 'LineWidth', 1.5);
hold on

set_figure_prop;

legend off;

xlabel('PC1 - Gameplay Interval')
ylabel('PC2 - Game type preference')

clear X Y c i

[~,~,~] = anova1(Q.PC3, Q.Condition);
