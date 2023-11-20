function logicalIndicator = isVecParallel(vecA, vecB)
    if ~isrow(vecA) || ~isrow(vecB) || size(vecA, 2) ~= 2 || size(vecB, 2) ~= 2
        error("Input arguments must be 2-element row vectors")
    end

    logicalIndicator = false;
    vecA = sign(vecA);
    vecB = sign(vecB);
    if isequal(vecA, vecB)
        logicalIndicator = true;
        return
    elseif isequal(vecA + vecB, [0, 0])
        logicalIndicator = true;
        return
    end
end