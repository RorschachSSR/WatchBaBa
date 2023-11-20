function hash = hashfunc(mapItem)
    set_rules;

    extendedObstacleGraph = analyzeExtendedObstacles(mapItem);
    bins = conncomp(extendedObstacleGraph);
    
    % you component center
    xCenter = 0; yCenter = 0; %youCompCenter = 0;
    if isKey(mapItem.propertyClusters, Rules('You'))
        You = mapItem.propertyClusters(Rules('You'));
        if any(You, 'all')
            YouBins = bins(logical(You'));
            nComp = YouBins(1);
            xCenter = round(median(extendedObstacleGraph.Nodes.xpos(bins == nComp)));
            yCenter = round(median(extendedObstacleGraph.Nodes.ypos(bins == nComp)));
            %youCompCenter = xCenter + (yCenter - 1) * mapItem.size.x;
        end
    end
    hashYou = sprintf('%02d%02d', xCenter, yCenter);
    % sprintf('%03d', youCompCenter);
    
    % win component center
    xCenter = 0; yCenter = 0; %winCompCenter = 0;
    if isKey(mapItem.propertyClusters, Rules('Win'))
        Win = mapItem.propertyClusters(Rules('Win'));
        if any(Win, 'all') 
            WinBins = bins(logical(Win'));
            nComp = WinBins(1);
            xCenter = round(median(extendedObstacleGraph.Nodes.xpos(bins == nComp)));
            yCenter = round(median(extendedObstacleGraph.Nodes.ypos(bins == nComp)));
            %winCompCenter = xCenter + (yCenter - 1) * mapItem.size.x;
        end
    end
    hashWin = sprintf('%02d%02d', xCenter, yCenter);
    %sprintf('%03d', winCompCenter);

    % rules
    ruleAdj = full(adjacency(mapItem.ruleGraph));
    wordList = mapItem.ruleGraph.Nodes.Type;
    rulesFormed = ruleAdj(isNoun(wordList), isProperty(wordList));
    hashRule = sprintf(repmat('%d',1,numel(rulesFormed)), rulesFormed(:));

    hash = [hashYou, hashWin, hashRule];
end