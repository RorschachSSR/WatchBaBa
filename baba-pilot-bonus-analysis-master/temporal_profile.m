%% Plot step interval for each level

LvlNo = [4, 5, 3];
VerId = {[0, 0, 0, 0], [0 0 0 1 1], [0 1 1]};
clear levelHistory

for chp = 1:3
    for lvl = 1 : LvlNo(chp)
        for ver = 0:VerId{chp}(lvl)
            tic
            filedir = sprintf('data/level_player_map_history/chp_%d_lvl_%d_ver_%d.mat', chp, lvl, ver);
            load(filedir)
            
            levelHistory = rmfield(levelHistory, {'actionLabel' 'entities'});
            revisit = [levelHistory(:).revisit];
            levelHistory = levelHistory(~revisit);
            startIndex = strcmp('Start', {levelHistory.Control}) | strcmp('Restart', {levelHistory.Control});
            t = [levelHistory(:).TimeFromLaunch];
            delta_t = t(2:end) - t(1:end-1);
            delta_t = [0, delta_t];
            delta_t(startIndex) = 0;
            subs = [levelHistory(:).SubNo];
            
            figure('Position', [0 0 1500 1000], 'visible', 'off')
            for sub = unique(subs)
                dt = delta_t(subs == sub);
                dt(dt == 0) = [];
                subplot(8, 8, sub)
                histogram(dt, 'BinWidth', 0.25, 'FaceColor', [0 0.5 0.5])
                title(sprintf('Participant ID: %d', sub))
            end
            figuredir = sprintf('figures/RT_chp_%d_lvl_%d_ver_%d_individual.png', chp, lvl, ver);
            saveas(gcf, figuredir)
            close(gcf)
            
            figure('Position', [0 0 600 400], 'visible', 'off')
            delta_t(delta_t == 0) = [];
            histogram(delta_t, 'BinWidth', 0.25, 'FaceColor', [0 0.5 0.5])
            figuredir = sprintf('figures/RT_chp_%d_lvl_%d_ver_%d_all.png', chp, lvl, ver);
            saveas(gcf, figuredir)
            close(gcf)
            
            toc
        end
    end
end