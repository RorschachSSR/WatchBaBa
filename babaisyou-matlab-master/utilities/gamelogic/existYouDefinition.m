function logicalIndicator = existYouDefinition(mapItem)
    %% EXISTYOUDEFINITION: check if the current state has a "you" definition
    if ~isfield(mapItem, 'ruleGraph')
        error('`mapItem` does not contain a `ruleGraph` field. Run analyzer first.')
    end

    set_rules;
    logicalIndicator = true;

    wordList = mapItem.ruleGraph.Nodes.Type;
    whoYous = predecessors(mapItem.ruleGraph, find(wordList == Rules('You')));

    if isempty(whoYous)
        logicalIndicator = false;
    end
end