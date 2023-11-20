%% Exploration and Exploitation in each level

clear
load('data/tradeoff_in_level_segmentation.mat')
importData; 

individualSeq = struct2table(Strct);
individualSeq.seqLen = cellfun(@length, individualSeq.seq);
individualSeq.Condition = P.Condition(individualSeq.SubNo);

if all(individualSeq.Level == T.Level)
    individualSeq.Success = ~T.HintFlag & T.PassedFlag;
end

%% Plot
ChpNo = 3;
LvlNo = [4, 5, 3];
tileNo = [1, 6, 11];

figure('Position', [0 0 1440 900])
t = tiledlayout(3,5, 'TileSpacing', 'compact');

for chapter = 1:ChpNo
    
    for level = 1:LvlNo(chapter)
        nexttile(tileNo(chapter) + level - 1);
        
        levelSeq = individualSeq(individualSeq.Chapter == chapter & individualSeq.Level == level & individualSeq.Success == 1, :);
        levelSeq = sortrows(levelSeq, {'Condition', 'seqLen'}, {'ascend', 'descend'});
        
        h = height(levelSeq);
        for i = 1:h
            cond = levelSeq.Condition(i);
            sub  = levelSeq.SubNo(i);
            y = levelSeq.seq{i} + i;
            % (-numel(y) + 1):1:0, 
            plot( y, 'Color', Color4Condition(5-cond, :)); hold on
        end
        ylim([0 ceil(h/10) * 10 + 10 ])
        xlim([0 100])
        yticklabels({[]})
        xlabel('Step No.')
        ylabel('Step Interval')
        title(['Chp ', num2str(chapter), ' Lvl ', num2str(level)])
        box off
        
    end
end

xlabel(t, 'Level')
ylabel(t, 'Chapter')

% exportgraphics(t, 'inlevelDynamics.png', 'Resolution',300)

%% Change point detection

chapter = 3; 
level   = 1;

sub     = 5;

subLevelSeq = individualSeq(individualSeq.Chapter == chapter & individualSeq.Level == level ...
                        & individualSeq.Success == 1 & individualSeq.SubNo == sub, :);

y = subLevelSeq.seq{:};
plot(1:numel(y), y, 'k', 'LineWidth', 1.2); hold on

startpoints = subLevelSeq.exploitStart{:};
endpoints   = subLevelSeq.exploitEnd{:};

for k = 1 : numel(startpoints)
    xx = startpoints(k):endpoints(k);
    yy = y(xx);
    plot(xx, yy, 'Color', '#4DBEEE', 'LineWidth', 1.5); hold on
end

set_figure_prop
legend off

ylabel('Step Interval')
xlabel('Step No.')
title(['Example level segmentation: Sub ', num2str(sub), ', Chp ', num2str(chapter), ', Lvl ', num2str(level)])

ylim([-2, Inf])

yline(0.25, '--', 'KeyStickTime', 'LabelVerticalAlignment', 'bottom')

clear y xx yy