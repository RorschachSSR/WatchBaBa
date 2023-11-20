function gridmap = entityCluster2mapArray(entityCluster, height)
% entityCluster2mapArray - convert entity cluster to map array
    entityList = double(entityCluster(:, 1));
    n_entity = size(entityList, 1);
    entityCluster(:, 1) = [];

    width = size(entityCluster, 2);
    layered_map = zeros(height, width, n_entity);

    for n = 1:n_entity
        for x = 1:width
            col = dec2bin(entityCluster(n,x), height);
            layered_map(:, x, n) = entityList(n) * str2num(col(end:-1:1)');
        end
    end

    gridmap = num2cell(layered_map, 3);
    gridmap = cellfun(@(x) x(:), gridmap, 'UniformOutput', false);
    gridmap = cellfun(@(x) x(x > 0), gridmap, 'UniformOutput', false);
end