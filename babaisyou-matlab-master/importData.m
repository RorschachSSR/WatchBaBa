%% Import data
P = readtable('data/participants.csv');
T = readtable('data/leveltime_split.csv');
S = readtable('data/bonus_solution_category.csv');
Q = readtable('data/baseline_videogame.csv', 'EmptyValue', 0); % pre-experiment questionnaire

P = sortrows(P, 'SubNo');

%% Preprocess

% Recode Condition
P.c4 = double(P.Condition > 2);
P.c5 = double(~mod(P.Condition, 2));

% Add condition to other tables
condionVars = {'Condition', 'c4', 'c5'};
T = addvars(T, P{T.SubNo, condionVars{1}}, P{T.SubNo, condionVars{2}}, P{T.SubNo, condionVars{3}}, 'After', 'SubNo', 'NewVariableNames', condionVars);
S = addvars(S, P{S.SubNo, condionVars{1}}, P{S.SubNo, condionVars{2}}, P{S.SubNo, condionVars{3}}, 'After', 'SubNo', 'NewVariableNames', condionVars);

%% Change PassedFlag to 0 if the participant repeat the same solution

S_noRep = S;
excludedPforBonus3 = zeros(10, 1);
count = 1;
n = height(P);

for i = 1:n
    
    chapter = 3;
    for level = 2:3
        currentSolutionIndex = S_noRep.SubNo == i & S_noRep.Level == level;
        previousSolutionIndex = S_noRep.SubNo == i & S_noRep.Level == level - 1;
        currentTimerIndex = T.SubNo == i & T.Chapter == chapter & T.Level == level;
        if any(currentSolutionIndex)
            currentSolution = S_noRep.Solution(currentSolutionIndex);
            previousSolution = S_noRep.Solution(previousSolutionIndex);
            if strcmp(currentSolution, previousSolution)
                % display(T.SubNo(currentTimerIndex))
                % change passed flag to 0, if it is a repeated one
                T.PassedFlag(currentTimerIndex) = 0;
                % delete current solution, if it is a repeated one
                S_noRep(currentSolutionIndex, :) = [];
                % record the participant
                excludedPforBonus3(count) = i; count = count + 1;
            end
        else
            break
        end
    end
    
end

excludedPforBonus3 = excludedPforBonus3(excludedPforBonus3 ~= 0);

clear i n chapter level count;
clear currentSolutionIndex previousSolutionIndex currentTimerIndex;
clear currentSolution previousSolution;

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