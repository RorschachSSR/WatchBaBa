%% plot sample topological dynamics
% run ParseMapHistory first
load('data/tradeoff_in_level_segmentation.mat')
importData; 

individualSeq = struct2table(Strct);
individualSeq.seqLen = cellfun(@length, individualSeq.seq);
individualSeq.Condition = P.Condition(individualSeq.SubNo);

if all(individualSeq.Level == T.Level)
    individualSeq.Success = ~T.HintFlag & T.PassedFlag;
end
%% Change point detection

chapter = 2; 
level   = 5;

subLevelSeq = individualSeq(individualSeq.Chapter == chapter & individualSeq.Level == level ...
                        & individualSeq.Success == 1 & individualSeq.SubNo == sub, :);

ts = subLevelSeq.timeStamp{:};
y = subLevelSeq.seq{:};
plot(ts(2:end), y, 'k', 'LineWidth', 1.2); hold on

startpoints = subLevelSeq.exploitStart{:};
endpoints   = subLevelSeq.exploitEnd{:};

for k = 1 : numel(startpoints)
    xx = startpoints(k):endpoints(k);
    yy = y(xx);
    plot(ts(xx+1), yy, 'Color', '#4DBEEE', 'LineWidth', 1.5); hold on
end

set_figure_prop
legend off

ylabel('Step Interval')
xlabel('Step No.')
title(['Example level segmentation: Sub ', num2str(sub), ', Chp ', num2str(chapter), ', Lvl ', num2str(level)])

ylim([-0.5, Inf])

yline(0.25, '--', 'KeyStickTime', 'LabelVerticalAlignment', 'bottom'); hold on 

clear xx yy

%% Map history

ts = subLevelSeq.timeStamp{:};
subLevelHistory = mapHistory(ts);

isoMorph = ones(numel(subLevelHistory), 1);

for i = 1 : numel(subLevelHistory)-1
    G0 = graph(subLevelHistory(i).topoAdjM);
    Gt = graph(subLevelHistory(i+1).topoAdjM);
    if isempty(isomorphism(G0, Gt))
        isoMorph(i+1) = 0;
        xline(subLevelHistory(i+1).count, ':', 'LineWidth', 1.5); hold on
    end
end

topological_change = 1 - isoMorph;

%%
for i = 1 : numel(subLevelHistory)
    display(i)
    figure(i)
    plotTopoGraph(subLevelHistory(i))
end