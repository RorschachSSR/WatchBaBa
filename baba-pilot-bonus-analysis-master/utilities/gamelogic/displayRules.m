function displayRules(mapItem)
    %%PRINTRULEGRAPHASTEXT use this function if `mapItem` already contains a `ruleGraph` field.
    if ~isfield(mapItem, 'ruleGraph')
        error('`mapItem` does not contain a `ruleGraph` field. Run analyzer first.')
    end
    set_rules_reverse;
    edgeTable = mapItem.ruleGraph.Edges;
    nodeTable = mapItem.ruleGraph.Nodes;
    for i = 1:size(edgeTable,1)
        nounCode = nodeTable.Type(edgeTable{i,1}(1));
        propertyCode = nodeTable.Type(edgeTable{i,1}(2));
        fprintf('%s is %s \n', RulesReverse(nounCode), RulesReverse(propertyCode));
    end
end