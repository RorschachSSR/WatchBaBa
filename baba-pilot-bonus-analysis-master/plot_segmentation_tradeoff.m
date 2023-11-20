clear
importData;

E = readtable('data/tradeoff_in_level.csv');
E.HintFlag = T.HintFlag;
E.PassedFlag = T.PassedFlag;

%% Level-wise
ChpNo = 3;
LvlNo = [4, 5, 3];

rp = zeros(sum(LvlNo), 4);

count = 0;

for chapter = 1:ChpNo
    for level = 1:LvlNo(chapter)
        count = count + 1;
        Es = E(E.Chapter == chapter & E.Level == level & E.PassedFlag == 1 & E.HintFlag == 0, :);
        Es(isnan(Es.TimeExplore), :) = [];
        figure
        scatter(Es.TimeExploit, Es.TimeExplore, 25, Color4Condition(5-P.Condition(Es.SubNo), :),...
                            'MarkerFaceColor', 'flat', ...
                            'MarkerFaceAlpha', 0.5, 'LineWidth', 1.5);
        [r, p] = corr(log(Es.TimeExploit), log(Es.TimeExplore), 'Rows','complete'); %'Type', 'Spearman'
        set(gca, 'XScale', 'log')
        set(gca, 'YScale', 'log')
        pbaspect([1 1 1])

        set_figure_prop
        legend off
        xlim([1 16])
        ylim([0.1 2])
        xlabel('mean exploit duration')
        ylabel('mean explore duration')
        
        title(['r=', num2str(r, '%.3f'), ';', 'p=', num2str(p, '%.3f')])
        exportgraphics(gcf, ['Fig\tradeoff_', num2str(chapter), '_', num2str(level), '.png'], 'Resolution', 300)
        
        if p < 0.05
            display([num2str(chapter), ':', num2str(level), ':', num2str(r)] )
        end
        
        rp(count, :) = [chapter, level, r, p];
    end
end

close all
%% Solution-wise for bonus chapter

%% 

PE = readtable('data/tradeoff_trait.csv');

x = PE.TimeExploit;
y = PE.TimeExplore;

[r, p] = corr(x, y, 'Rows','complete');
scatter(x, y, 25, Color4Condition(5-P.Condition, :), 'MarkerFaceColor', 'flat', 'MarkerFaceAlpha', 0.5, 'LineWidth', 1.5);
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
pbaspect([1 1 1])

set_figure_prop
legend off
xlabel('mean exploit duration')
ylabel('mean explore duration')

% labels = cellstr(num2str(PE.SubNo));
% dx = 0.005; dy = 0.005; % displacement so the text does not overlay the data points
% text(x+dx, y+dy, labels, 'Fontsize', 6);