function logicalIndicator = sprite2Property(property, singlegrid, wordList, ruleAdjM)
%SPRITE2PROPERTY show if a grid contains sprite of a specified property
    TEXT = 10000;
    set_rules;
    whereProperty = wordList == property;
    whoHasProperty = wordList(logical(ruleAdjM(:, whereProperty)));
    whoHasProperty = whoHasProperty(isNoun(whoHasProperty)) - TEXT;
    if property == Rules('Push')
        whoHasProperty = [whoHasProperty; TEXT];
    end
    logicalIndicator = ~isempty(intersect(whoHasProperty, singlegrid));
    
end

