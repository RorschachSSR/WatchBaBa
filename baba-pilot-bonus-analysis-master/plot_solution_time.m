%% compare RT distribution

%% import data

clear 
importData;

%% Select the variable to process

varOfConcern = 'Time2Win';

%% draw pdf of each level

figure

pos = {[1,2,3,4], [6,7,8,9,10], [11,12,13]};

ChpNo = 3;
LvlNo = [4, 5, 3];
X = [];

for chapter = 1:ChpNo
    for level = 1:LvlNo(chapter)
        
        X = T{T.Chapter == chapter & T.Level == level & T.HintFlag == 0 & T.PassedFlag == 1, varOfConcern};
        
        subplot(3,5,pos{chapter}(level))
        
        histogram(X, 8, 'BinWidth', 50, 'Normalization','pdf', 'FaceColor', [0.3010 0.7450 0.9330], 'EdgeColor', 'w'); hold on
        [f,xi] = ksdensity(X, 'BoundaryCorrection', 'reflection');
        xlim([0 1000])
        plot(xi,f,'Color', [0 0.4470 0.7410], 'LineWidth',2)
        title(sprintf('Chapter %d Level %d', chapter, level))
        % xp = prctile(X, [5, 95]);
        % xline(xp(1), "k-"); xline(xp(2), "k-");
    end
end

clear chapter level ChpNo LvlNo X pos f xi

%% draw pdf of each solution

Ts = T(T.Chapter == 3 & T.PassedFlag == 1, :);
Ss = bonus_solutions;

if all(Ts.Level == Ss.Level)
    Ss = addvars(Ss, Ts{:, varOfConcern}, 'NewVariableNames', varOfConcern);
    Ss.SolutionType = categorical(bonus_solutions.Solution, solutionSet);
end

bw = max(Ss{:, varOfConcern}) / 16;

if bw < 1
    bw = ceil(bw * 10) / 10;
else
    bw = ceil(bw);
end

for i = 1:4
    
    subplot(1, 4, i)
    
    X = Ss{Ss.SolutionType == solutionSet{i}, varOfConcern};
    
    histogram(X, 'BinWidth', bw, 'Normalization','pdf', 'FaceColor', Color4Solution(i, :), 'FaceAlpha', 0.5, 'EdgeColor', 'w'); hold on
    [f,xi] = ksdensity(X);
    plot(xi,f,'Color', Color4Solution(i, :), 'LineWidth',2)
    
    xlim([-Inf, bw * 8]);
    ylim([0 2])
    
    title(solutionSet{i});
    
end

clear i bw X f xi Ts Ss