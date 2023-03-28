function mapItem = create(mapItem, y, x, type)
    entities = mapItem.gridmap{y, x};
    entities = vertcat(entities, type);
    mapItem.gridmap{y, x} = entities;
end