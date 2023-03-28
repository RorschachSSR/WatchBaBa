function mapItem = destroy(mapItem, y, x, type)
    entities = mapItem.gridmap{y, x};
    entities(find(entities == type, 1, 'first')) = [];
    if isempty(entities)
        mapItem.gridmap{y, x} = [];
    else
        mapItem.gridmap{y, x} = entities;
    end
end