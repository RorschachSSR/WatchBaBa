clear
initUtility;
dirData = dir('data/player_map_analyzed/*.mat');

LvlNo = [4, 5, 3];
hfunc = @heuristicManhattan;
  
for chp = 1 %1:3
    for lvl = 1:LvlNo(chp)

        % sampled time points
        xq = 0:1e-4:1;

        % incremental means and errors
        n_defeat = 0;
        u_defeat = zeros(size(xq));
        S_defeat = zeros(size(xq));
        sigma_defeat = zeros(size(xq));
        n_win = 0;
        u_win = zeros(size(xq));
        S_win = zeros(size(xq));
        sigma_win = zeros(size(xq));
        
        tic
        for i = 1:numel(dirData)
            s = dirData(i);
            load(['data/player_map_analyzed/', s.name]);

            % select a level
            logicalArray = [mapHistory(:).Chapter] == chp-1 ...
                            & [mapHistory(:).Level] == lvl-1;
            if ~any(logicalArray)
                continue;
            end
            mapHistory = mapHistory(logicalArray);

            % label wins and defeats
            wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), mapHistory);
            starts = strcmp('Start', {mapHistory(:).Control}) | strcmp('Restart', {mapHistory(:).Control});
            defeats = arrayfun(@(x) checkResultForReplay(x, 'Defeat'), mapHistory);
            
            % cumulate means and variance for first defeats
            if any(defeats)
                first_defeat = find(defeats, 1, 'first');
                starts_before_defeat = starts;
                starts_before_defeat(first_defeat:end) = false;
                latest_start = find(starts_before_defeat, 1, 'last');

                % normalize time series
                firstDefeatHistory = mapHistory(:, latest_start:first_defeat);
                x = normalize([firstDefeatHistory(:).TimeFromLaunch], 'range');
                h = arrayfun(hfunc, firstDefeatHistory);
                vq = interp1(x, h, xq);

                % incremental mean and error
                n_defeat = n_defeat + 1;
                disp(n_defeat);
                old_u = u_defeat;
                u_defeat = u_defeat + (vq - u_defeat) / n_defeat;
                S_defeat = S_defeat + (vq - u_defeat) .* (vq - old_u);
                sigma_defeat = sqrt(S_defeat / (n_defeat - 1));
            end
            
            % cumulate means and variance for first wins
            if ~any(wins)
                continue;
            end

            first_win = find(wins, 1, 'first');
            starts_before_win = starts;
            starts_before_win(first_win:end) = false;
            last_start = find(starts_before_win, 1, 'last');

            % normalize time series
            firstWinHistory = mapHistory(:, last_start:first_win);
            x = normalize([firstWinHistory(:).TimeFromLaunch], 'range');
            h = arrayfun(hfunc, firstWinHistory);
            vq = interp1(x,h,xq);
            % incremental mean and error
            n_win = n_win + 1;
            disp(n_win);
            old_u = u_win;
            u_win = u_win + (vq - u_win) / n_win;
            S_win = S_win + (vq - u_win) .* (vq - old_u);
            sigma_win = sqrt(S_win / (n_win - 1));
        end
        toc

        figure;
        shadedErrorBar(xq,u_defeat,sigma_defeat,'lineProps',{'-', 'Color', [164 141 127]./255, 'LineWidth', 1.5}); hold on
        shadedErrorBar(xq,u_win,sigma_win,'lineProps',{'-', 'Color', [99 140 199]./255, 'LineWidth', 1.5}); hold on
        xlabel('Normalized time', 'Fontsize', 14)
        ylabel('Heuristic', 'Fontsize', 14)
        legend({'Defeat', 'Win'})
        savefig(['Fig/heuristicManhattan_', num2str(chp), '_', num2str(lvl), '.fig']);
        close gcf
        
    end
end

