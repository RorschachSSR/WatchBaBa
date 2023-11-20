function renderMap(mapItem, varargin)
%%RENDERMAP - Draws the input game map
% renderMap(mapItem) - mapItem is a structure that contains a field called gridmap, which is a 2D cell array of integer vectors
% renderMap(mapItem, ax) - draws on the given axes

    set_textures;

    carray = mapItem.gridmap(end:-1:1, :);
    [h, w] = size(mapItem.gridmap);
    switch nargin
        case 1
            figure;
            axis ij
            ax = gca;
        case 2
            ax = varargin{1};
        otherwise
            error('Too many input arguments');
    end
    
    for y = 1:h
        for x = 1:w
            block  = carray{y, x};
            count = numel(block);
            texture = zeros(100, 100, 3, 'uint8');
            switch count
                case 0
                    % black background
                    image(ax, [x-1 x], [y-1 y], texture); hold on
                case 1
                    % single sprite
                    image(ax, [x-1 x], [y-1 y], imread(['textures/', Textures(block)])); hold on
                otherwise
                    % stacks of sprites
                    texture = imread(['textures/', Textures(block(1))]);
                    for i = 2:count
                        new = imread(['textures/', Textures(block(i))]);
                        mask = repmat(sum(new,3) > 0, [1 1 3]);
                        texture(mask) = new(mask);
                    end
                    image(ax, [x-1 x], [y-1 y], texture); hold on
            end
        end
    end

    xlim([0 w])
    ylim([0 h])
    pbaspect([w h 1])
    
    xt = 0:w-1;
    yt = 0:h-1;
    xticks(xt + 0.5);
    yticks(yt + 0.5);
    xticklabels(xt + 1)
    yticklabels(h - yt);

    set(ax,'TickDir','out');
    box off

end