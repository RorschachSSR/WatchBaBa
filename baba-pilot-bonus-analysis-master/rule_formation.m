clear
initUtility

colors = [         0         0         0
    0.8333    0.5208    0.3317
    1.0000    0.7812    0.4975];
       
colors_gradient = [linspace(0.3030 , 1)', linspace(0.1894, 0.7812)',  linspace(0.1206, 0.4975)'];

levelConfigs = importConfig('data/map_config');
%% Level initial configuration



LvlNo = [4, 5, 1];
VerId = {[0, 0, 0, 0], [0 0 0 1 1], [0]};

for chp = 1:3
    for lvl = 1:LvlNo(chp)
        for ver = 0:VerId{chp}(lvl)
            if chp < 3
                logicalArray = [levelConfigs(:).chapter] == chp ...
                    & [levelConfigs(:).level] == lvl ...
                    & [levelConfigs(:).version] == ver;
            else
                logicalArray = [levelConfigs(:).chapter] == chp;
            end
            levelConfig = levelConfigs(logicalArray);
            wordEnum = levelConfig.ruleGraph.Nodes.Type;
            wordLabels = arrayfun(@(x) RulesReverse(x), wordEnum, 'UniformOutput', false);

            theoretical_matrix = -ones(numel(wordEnum));
            theoretical_matrix(wordEnum < 20000, wordEnum > 30000) = 0;
            
            config_matrix = theoretical_matrix;
            config_matrix(logical(full(adjacency(levelConfig.ruleGraph)))) = 1;
            
            figure
            figure('Position', [100 100 600 600])
            h = heatmap(config_matrix);
            colorbar
            caxis([-1 1])
            %colorbar([-1 0 1], 'TickLabels', {'Invalid' 'Valid' 'Formed'})
            colormap(colors)
            
            %box off
            set(gca, 'XDisplayLabels', wordLabels, ...
                'YDisplayLabels', wordLabels, ... 
                'FontSize', 10);
            split = find(wordEnum < 20000, 1, 'last');
            set(gca, 'YLabel', 'Subject (preceding "is")', ...
                     'XLabel', 'Predicative word (succeeding "is")')
            h.CellLabelFormat = '%d';
            
            title(sprintf('Chapter %1d Level %1d Ver %1d', chp, lvl, ver))
            figfilename = sprintf('figures/rules/chp_%d_lvl_%d_ver_%d_initial.png', chp, lvl, ver);
            saveas(gcf, figfilename);
        end
    end
end
%% Level-wise heat map

LvlNo = [4, 5, 3];
VerId = {[0, 0, 0, 0], [0 0 0 1 1], [0 1 1]};
clear levelHistory

for chp = 1:2 %:3
    for lvl = 1 : LvlNo(chp)
        for ver = 0:VerId{chp}(lvl)
            tic
            filedir = sprintf('data/level_player_map_history/withRuleGraph/withRule_chp_%d_lvl_%d_ver_%d.mat', chp, lvl, ver);
            load(filedir)
            
            % calculate dwelling time for each state
            levelHistory = rmfield(levelHistory, {'actionLabel' 'entities' 'gridmap'});
            revisit = [levelHistory(:).revisit];
            levelHistory = levelHistory(~revisit);
            startIndex = strcmp('Start', {levelHistory.Control}) | strcmp('Restart', {levelHistory.Control});
            t = [levelHistory(:).TimeFromLaunch];
            delta_t = t(2:end) - t(1:end-1);
            delta_t = [0, delta_t];
            delta_t(startIndex) = 0;
            delta_t = [delta_t(2:end), 0];
            dt = num2cell(delta_t);
            [levelHistory(:).dt] = deal(dt{:});
            
            % load config
            if chp < 3
                logicalArray = [levelConfigs(:).chapter] == chp ...
                    & [levelConfigs(:).level] == lvl ...
                    & [levelConfigs(:).version] == ver;
            else
                logicalArray = [levelConfigs(:).chapter] == chp;
            end
            levelConfig = levelConfigs(logicalArray);
            wordEnum = levelConfig.ruleGraph.Nodes.Type;
            wordLabels = arrayfun(@(x) RulesReverse(x), wordEnum, 'UniformOutput', false);

            exp_matrix = zeros(numel(wordEnum));
            % time spent on each "rule"
            for i = 1 : numel(levelHistory)
                if mod(i, 1000) == 0
                    disp(i)
                end
                A  = full(adjacency(levelHistory(i).ruleGraph));
                exp_matrix = exp_matrix + A .* levelHistory(i).dt;
            end
            
            exp_matrix(exp_matrix == 0) = nan;
            
            % heatmap
            figure('Position', [100 100 600 600])
            h = heatmap(exp_matrix);
            colormap(colors_gradient)
            colorbar
            
            %box off
            set(gca, 'XDisplayLabels', wordLabels, ...
                'YDisplayLabels', wordLabels, ... 
                'FontSize', 10);
            split = find(wordEnum < 20000, 1, 'last');
            set(gca, 'YLabel', 'Subject (preceding "is")', ...
                     'XLabel', 'Predicative word (succeeding "is")')
            h.CellLabelFormat = '%.1f';
            
            title(sprintf('Chapter %1d Level %1d Ver %1d', chp, lvl, ver))
            figfilename = sprintf('figures/rules/chp_%d_lvl_%d_ver_%d_exp.png', chp, lvl, ver);
            saveas(gcf, figfilename);
            toc
        end
    end
end