function selfMap = selfLocating(mapItem)
    selfMap = [];
    set_rules;
    if isKey(mapItem.propertyClusters, Rules('You'))
        selfMap = mapItem.propertyClusters(Rules('You'));
    end
end 