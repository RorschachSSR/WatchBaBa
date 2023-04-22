
figure 
axis ij
xlim([0 2])
ylim([0 2])

initUtility
levelConfigs = importConfig('default');

%% select level config
mapItem.gridmap = levelConfigs(10).gridmap;

%% run
renderMap(mapItem, gca)
while true
    k = waitforbuttonpress;
    % 28 leftarrow
    % 29 rightarrow
    % 30 uparrow
    % 31 downarrow
    value = double(get(gcf,'CurrentCharacter'));
    
    if ~isscalar(value)
        continue
    end
    
    switch value
    case 28
        fprintf('leftarrow\n')
        [mapItem, reward, termination] = step(mapItem, 'Left', true);
    case 29
        fprintf('rightarrow\n')
        [mapItem, reward, termination] = step(mapItem, 'Right', true);
    case 30
        fprintf('uparrow\n')
        [mapItem, reward, termination] = step(mapItem, 'Up', true);
    case 31
        fprintf('downarrow\n')
        [mapItem, reward, termination] = step(mapItem, 'Down', true);
    otherwise
        fprintf('END OF PROGRAM\n')
        break
    end
    
    if termination == 1
        if reward > 0
            fprintf('WIN\n')
        else
            fprintf('LOSE\n')
        end
        break
    end

    %pause(0.08)
end

% close(gcf)