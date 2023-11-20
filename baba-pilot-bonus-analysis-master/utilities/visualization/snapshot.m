function snapshot(varargin)
%EXPORTCURRENTFIG Export current figure to a file
    if nargin > 0
        figure_handle = varargin{1};
        if nargin > 1
            filename = [varargin{2}, '.png'];
        else
            filename = sprintf('figures/snapshots/snapshot_%s.png', datestr(now, 'yyyy-mm-dd_HH-MM-SS' ));
        end
    else
        figure_handle = gcf;
    end
    saveas(figure_handle, filename);
end