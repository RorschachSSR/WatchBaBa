function output = heuristicManhattan(mapItem)
    set_rules;
    
    self = selfLocating(mapItem);
    goal = goalFinding(mapItem);
    
    bnd = mapItem.size.x + mapItem.size.y - 2;
    [selfy, selfx] = find(self);
    [goaly, goalx] = find(goal);
    
    output = minDis([selfy, selfx], [goaly, goalx], bnd);
    
end