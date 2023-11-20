function entityCluster = mapArray2entityCluster(mapItem, entityList)
    %%MAPARRAY2ENTITYCLUSTER Convert an cell array map to an matrix recording all entity clusters
    % Input: 
    %    mapItem: struct containg a cell array item that represent the map as grid
    %    entityList: a list of unique entities from the level map
    % Output: a matrix recording all entity clusters

    if nargin < 2
        entityList = unique(vertcat(mapItem.gridmap{:}));
    end

    [height, width] = size(mapItem.gridmap);
    % if height > 16
    %     type = 'uint32';
    % else
    %     type = 'uint16';
    % end
    type = 'uint32';

    n_entity = length(entityList);
    entityCluster = zeros(n_entity, 1 + width, type);
    twos = 2.^(0 : height-1);
    entityCluster(:, 1) = entityList;

    for i = 1:n_entity
        entityMap = cellfun(@(x) any(x == entityList(i)), mapItem.gridmap);
        entityCluster(i, 2:end) = twos * entityMap;
    end

end