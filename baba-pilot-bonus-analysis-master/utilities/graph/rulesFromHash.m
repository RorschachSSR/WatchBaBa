function rulesFromHash(hashcode, mapItem)
    hashcode = hashcode(9:end);
    n = numel(hashcode);

    % word list
    [height, width] = size(mapItem.gridmap);
    fullwordList = zeros(1, height*width);
    count = 0;
    for i = 1 : height
        for j = 1 : width
            temp = mapItem.gridmap{i, j};
            for k = 1:numel(temp)
                count = count + 1;
                fullwordList(count) = temp(k);
            end
        end
    end
    fullwordList(fullwordList == 0) = []; % remove pending zeros
    entityList = unique(fullwordList);
    nounList = entityList( isNoun(entityList) );
    propertyList = entityList( isProperty(entityList) );
    wordList = [nounList, propertyList];

    % sanity check
    n_noun = numel(nounList);
    n_property = numel(propertyList);
    if n < n_noun * n_property
        error('Not enough digits in hashcode');
    elseif n > n_noun * n_property
        error('Digits in hashcode exceeds the size of noun-property pairs');
    end

    % fill in ruleAdjM
    ruleAdjM = zeros(numel(wordList));
    for col = 1 : n_property
        for row = 1 : n_noun
            ruleAdjM(row, n_noun + col) = str2double(hashcode(row + n_noun * (col - 1)));
        end
    end

    mapItem.ruleGraph = digraph(ruleAdjM, table(wordList', 'VariableNames',{'Type'}));
    displayRules(mapItem);

end