%% Import data
initUtility

P = readtable('data/participants.csv'); P = sortrows(P, 'SubNo');
import_csv_operation; % import data from csv files (timerInfo: countdown timer in game, S: bonus solution type with duplicates)
Q = readtable('data/baseline_videogame.csv', 'EmptyValue', 0); % pre-experiment questionnaire
clear timerInfo

%% Preprocess

% Recode Condition
P.level4_withHot = double(P.Condition > 2);
P.level5_withHot = double(~mod(P.Condition, 2));

% Add condition to other tables
condionVars = {'Condition', 'level4_withHot', 'level5_withHot'};
T = addvars(T, P{T.SubNo, condionVars{1}}, P{T.SubNo, condionVars{2}}, P{T.SubNo, condionVars{3}}, 'After', 'SubNo', 'NewVariableNames', condionVars);
S = addvars(S, P{S.SubNo, condionVars{1}}, P{S.SubNo, condionVars{2}}, P{S.SubNo, condionVars{3}}, 'After', 'SubNo', 'NewVariableNames', condionVars);

%% Resolve duplicates in bonus solutions
% change PassedFlag to 0 if the participant repeats the same solution
% this happens because of an bug on map adaptation program in Unity (fixed on March 27, 2022)

bonus_solutions = S;
excludedPforBonus3 = zeros(height(P), 1, 'logical');
n = height(P);

for i = 1:n
    
    chapter = 3;
    for level = 2:3
        currentSolutionIndex = bonus_solutions.SubNo == i & bonus_solutions.Level == level;
        previousSolutionIndex = bonus_solutions.SubNo == i & bonus_solutions.Level == level - 1;
        currentTimerIndex = T.SubNo == i & T.Chapter == chapter & T.Level == level;
        if any(currentSolutionIndex)
            currentSolution = bonus_solutions.Solution(currentSolutionIndex);
            previousSolution = bonus_solutions.Solution(previousSolutionIndex);
            if strcmp(currentSolution, previousSolution)
                % display(T.SubNo(currentTimerIndex))
                % change passed flag to 0, if it is a repeated one
                T.PassedFlag(currentTimerIndex) = 0;
                % delete current solution, if it is a repeated one
                bonus_solutions(currentSolutionIndex, :) = [];
                % record the participant no.
                excludedPforBonus3(i) = true;
            end
        else
            break
        end
    end
    
end

clear i n chapter level;
clear currentSolutionIndex previousSolutionIndex currentTimerIndex;
clear currentSolution previousSolution;

%% bonus level map configuration (for bonus level 2 and 3)

X = bonus_solutions(:, {'SubNo', 'Level', 'Solution'});
U = unstack(X, 'Solution','Level', 'VariableNamingRule', 'modify');
U = [U; {29, '', '', ''}];
U = sortrows(U, 'SubNo');

bonus2_noMelt = strcmp(U.x1, 'BagIsHotMelt');
bonus2_noBagIsPush = strcmp(U.x1, 'BagIsPush');
bonus3_noBag = ((strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'BagIsHotMelt'))...
        | (strcmp(U.x2, 'BagIsPush') & strcmp(U.x1, 'BagIsHotMelt')));
bonus3_noPush = (strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'BreakHotMelt'))...
        | (strcmp(U.x2, 'BagIsPush') & strcmp(U.x1, 'BreakHotMelt'))...
        |(strcmp(U.x1, 'BagIsPush') & strcmp(U.x2, 'OtherIsYou'))...
        |(strcmp(U.x2, 'BagIsPush') & strcmp(U.x1, 'OtherIsYou'));

clear X


%% Maually Change HintFlag to 1 if they receive oral hint from the experimenter

T.HintFlag(T.SubNo == 5 & T.Chapter == 1 & T.Level == 2) = 1;
T.HintFlag(T.SubNo == 14 & T.Chapter == 1 & T.Level == 2) = 1;
T.HintFlag(T.SubNo == 7 & T.Chapter == 1 & T.Level == 2) = 1;

%% G: Game Experience Questionaire

surveyLabel = {'FirstGameplay', 'WholeFrequency', 'RecentFrequency', 'LastGameplay', 'LastTimeSpent',...
                'Puzzle', 'Simulation', 'Action', 'RTS', 'RPG', 'MOBA'};

% Reverse score of frequency items
%       higher score, higher frequency

Q.WholeFrequency = 5 - Q.WholeFrequency;
Q.RecentFrequency = 9 - Q.RecentFrequency;

% Transform time data onto logarithm scale

Q{:, 'FirstGameplay'} = log10(Q{:, 'FirstGameplay'} + 1);
Q{:, 'LastGameplay'} = log10(Q{:, 'LastGameplay'} + 1);
Q{:, 'LastTimeSpent'} = log10(Q{:, 'LastTimeSpent'} + 1);

% add behavorial data
n = height(Q);

Q = addvars(Q, zeros(n, 1), 'Before', 'Date', 'NewVariableNames', 'SubNo');

Q.TutorialTime = zeros(n, 1); % Time in chapter 1, level 1-4 (tutorial)
Q.PretestTime = zeros(n, 1); % Time in chapter 2, level 1 (pretest)
Q.TrainingTime = zeros(n, 1); % Time in chapter 2, Level 2-5
Q.BonusTime = zeros(n, 1); % Time in chapter 3 (bonus)

for i = 1:n
    subNo = P.SubNo(strcmp(Q.Name(i), P.Name) & Q.Date(i) == P.Date);
    Q.SubNo(i) = subNo;
    Q.TutorialTime(i) = sum(T.Time2Win(T.SubNo == subNo & T.Chapter == 1));
    Q.PretestTime(i) = sum(T.Time2Win(T.SubNo == subNo & T.Chapter == 2 & T.Level == 1));
    Q.TrainingTime(i) = sum(T.Time2Win(T.SubNo == subNo & T.Chapter == 2 & T.Level > 1));
    Q.BonusTime(i) = sum(T.Time2Win(T.SubNo == subNo & T.Chapter == 3));

end

Q.TotalTime = Q.TutorialTime + Q.PretestTime + Q.TrainingTime + Q.BonusTime;
Q = sortrows(Q, 'SubNo');

clear i n subNo