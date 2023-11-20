%% Linear mixed model of behavior statistics

clear
clc
importData; 

% Reduce the dimension in survey data

X = Q{:, surveyLabel};
optionsFactoran = statset('TolX',1e-4,'TolFun',1e-4);
[lambda,psi,rotation,stats, scores] = factoran(X,2, 'rotate', 'varimax' , 'optimopts', optionsFactoran);
% display(stats.p)
biplot(lambda, 'varlabels', surveyLabel)
clear lambda psi stats rotation
%% Add latent factors

close all

factorVars = {'GameFreq', 'GamePref'};
Q = addvars(Q, scores(:, 1), scores(:, 2), 'After', 'Name', 'NewVariableNames', factorVars);

clear scores X componentVars

%% Select the dependent variable

clear nonBonusFcn nonBonusLme bonusFcn bonusLme
varOfConcern = 'StepInterval';

%% Non-bonus levels

clear Ts statsFixed statsRandom
Ts = T(T.HintFlag == 0 & T.PassedFlag == 1, :);
Ts = addvars(Ts, Q{Ts.SubNo, factorVars(1)}, Q{Ts.SubNo, factorVars(2)}, 'After', 'Condition', 'NewVariableNames', factorVars);

Ts.SubNo = categorical(Ts.SubNo);

nonBonusFcn = [varOfConcern, ' ~ 1 + GameFreq + GamePref + level4_withHot + level5_withHot + Level + (1 | SubNo)'];
tutorialLme = fitlme(Ts(Ts.Chapter == 1, :), nonBonusFcn, 'CovariancePattern', 'Full', 'Optimizer', 'fminunc', ...
                                                        'DummyVarCoding', 'effects', 'CheckHessian', true);
trainingLme = fitlme(Ts(Ts.Chapter == 2, :), nonBonusFcn, 'CovariancePattern', 'Full', 'Optimizer', 'fminunc', ...
                                                        'DummyVarCoding', 'effects', 'CheckHessian', true);

display(tutorialLme)
display(trainingLme)

% statsFixed = anova(nonBonusLme);
% [~,~,statsRandom] = randomEffects(nonBonusLme);

% [~,~,stats] = covarianceParameters(nonBonusLme)

export(tutorialLme.Coefficients,'File','lmm_tutorial.csv','Delimiter',',')
export(trainingLme.Coefficients,'File','lmm_training.csv','Delimiter',',')

%% Test levels

clear Ts statsFixed statsRandom

Ts = T(T.HintFlag == 0 & T.PassedFlag == 1 & T.Chapter == 3, :);
Ts = addvars(Ts, Q{Ts.SubNo, factorVars(1)}, Q{Ts.SubNo, factorVars(2)}, 'After', 'Condition', 'NewVariableNames', factorVars);

Ts.Condition = categorical(Ts.Condition, [1 2 3 4], conditionSet);


if all(Ts.Level == bonus_solutions.Level)
    solutionVars = {'Pumpkin', 'Push', 'Melt'};
    Ts = addvars(Ts, bonus_solutions{:, solutionVars(1)}, bonus_solutions{:, solutionVars(2)}, bonus_solutions{:, solutionVars(3)}, 'After', 'HintFlag', 'NewVariableNames', solutionVars);
    
%     logicalArray = strcmp(Ts.SolutionType, 'OtherIsYou') | strcmp(Ts.SolutionType, 'BreakHotMelt');
%     Ts(logicalArray, {'SolutionType'}) = repmat({'PumpkinIsPush'}, sum(logicalArray), 1);
%     clear logicalArray
  
end

bonusFcn = [varOfConcern, ' ~ GameFreq + GamePref + Level + level4_withHot + level5_withHot + Pumpkin + Push + Melt', ... 
                          ' + level4_withHot:Pumpkin + level4_withHot:Push + level4_withHot:Melt + level5_withHot:Pumpkin + level5_withHot:Push + level5_withHot:Melt',...
                          ' + Level:Pumpkin + Level:Push + Level:Melt', ...
                           '+ (1 | SubNo) '];
bonusLme = fitlme(Ts, bonusFcn, 'CovariancePattern', 'Full', 'CheckHessian', true);

display(bonusLme)

% statsFixed = anova(bonusLme);
% [~,~,statsRandom] = randomEffects(bonusLme);

export(bonusLme.Coefficients,'File','lmm_bonus.csv','Delimiter',',')