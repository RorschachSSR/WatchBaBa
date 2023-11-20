function goalMap = goalFinding(mapItem)
    goalMap = [];
    set_rules;
    if isKey(mapItem.propertyClusters, Rules('Win'))
        goalMap = mapItem.propertyClusters(Rules('Win'));
    end
end 