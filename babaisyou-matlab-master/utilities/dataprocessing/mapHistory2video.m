function outputfile = mapHistory2video(exp_date, name, rate, varargin)
% MAPHISTORY2VIDEO - Convert operation + map history mat file to video
%  MAPHISTORY2VIDEO(EXP_DATE, NAME, CONSTANT_OR_SCALED, CHAPTER, LEVEL) 
%   rate: 'constant'(equal interval between each step) or 'scaled'(4x speed)

    if ~isnumeric(exp_date) || ~ischar(name) || ~ismember(rate, {'constant', 'scaled'})
        error('Invalid input arguments');
    end 

    inputfile = sprintf('data/player_map_analyzed/map_logic_%d_%s.mat', exp_date, name);
    if strcmp(rate, 'constant')
        replaytype = 0;
        outputfile = sprintf('data/video/constant_rate_%d_%s', exp_date, name);
    else
        replaytype = 1;
        outputfile = sprintf('data/video/scaled_rate_%d_%s', exp_date, name);
    end
    

    load(inputfile, 'mapHistory');
    
    switch nargin
        case 3
            t0 = 1;
            tk = numel(mapHistory);
        case 5
            % filter: chapter + level
            chp = varargin{1};
            lvl = varargin{2};
            logicalArray = [mapHistory(:).Chapter] == chp-1 ...
                            & [mapHistory(:).Level] == lvl-1;
            if ~any(logicalArray)
                error('No History found for Chapter %d, Level %d', chp, lvl);
            end
            mapHistory = mapHistory(logicalArray);

            % analyze each map according to game logic
            [r, s, p] = arrayfun(@(x) gameLogicAnalyzer(x), mapHistory, 'UniformOutput', false);
            [mapHistory(:).ruleGraph] = deal(r{:});
            [mapHistory(:).spriteClusters]  = deal(s{:});
            [mapHistory(:).propertyClusters]  = deal(p{:});

            % filter: data before first win
            wins = arrayfun(@(x) checkResultForReplay(x, 'Win'), mapHistory);
            if any(wins)
                first_win = find(wins, 1, 'first');
            else
                % do not win in allowed time for chapter 3 (bonus)
                first_win = numel(wins);
            end
            t0 = 1;
            tk = first_win;
            [chp,lvl,idx] = get_video_name(exp_date,name,chp,lvl);
            outputfile = sprintf('data/video/chp%d_lvl%d_%s', chp, lvl,idx);
            clear wins chp lvl first_win logicalArray;
        otherwise
            error('Wrong number of input arguments');
    end

    if isunix && ~ismac
        error('MPEG-4 unsupported; Please use Windows or MacOS')
    else
        v = VideoWriter(outputfile, 'MPEG-4');
        v.Quality = 80;
    end
    
    switch replaytype
        case 0
            % constant rate: 0.125 between each operation, each operation takes one frame
            v.FrameRate = 4;
        case 1
            % scaled rate: 4x speed of real time
            % each frame takes 1/16 secs
            v.FrameRate = 16;
    end
    
    open(v);

    f = figure('Position', [100, 100, 1920/2, 1080/2], 'visible', 'off', 'color', 'k');
    axis ij
    set(gca,'xtick',[],'ytick',[],'xcolor','k','ycolor','k');
    set(gca,'nextplot','replacechildren'); 
    ax = gca;
    total_frame = 0;
    for i = t0:tk
        if mod(i, 100) == 0
            fprintf('Frame %d of %d\n', i, tk);
        end
        switch replaytype
            case 0
                renderMap(mapHistory(i), ax);
                frame = getframe(f);
                writeVideo(v, frame);
                cla(ax);
            case 1
                current_t = mapHistory(i).TimeFromLaunch;
                if i == tk
                    next_t = current_t + 1;
                else
                    next_t = mapHistory(i+1).TimeFromLaunch;
                end
                n_frames = max(1, round((next_t - current_t) / 0.25)); % real world 0.25 secs take 1 frame
                renderMap(mapHistory(i), ax);


                if i == t0
                    real_time = 0.25 * total_frame;
                    time_label = sprintf('%.1f s', real_time);
                    texthandle = annotation(f,'textbox',...
                                [0.15 0.1 0.15 0.1],...
                                'Color',[1 1 1],...
                                'String',time_label,...
                                'LineStyle','none',...
                                'FontSize',16,...
                                'FontName','Helvetica Neue',...
                                'FitBoxToText','off');
                end

                for j = 1:n_frames
                    real_time = 0.25 * total_frame;
                    texthandle.String = sprintf('%.1f s', real_time);
                    total_frame = total_frame + 1;
                    frame = getframe(f);
                    writeVideo(v, frame);
                end
                cla(ax);
        end
    end

    close(v);
    close(f);
end