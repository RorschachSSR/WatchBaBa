function [strct, exploitDur, exploitSteps, exploreDur, exploreSteps] = seqSegment(inputDiffSeq)
%SEQSEGMENT Segment the time stamp seqence into exploration and
%exploitation phases according to the difference between nearby timepoints

% Sample Input:    x = [10    20    70    30    20    40    90    40    10]
% Sample Segmentation:  10    20   (70    30    20)   40   (90    40    10)

% Sample Input:    x = [10    20    70    30    20    50    40    10    10]
% Sample Segmentation:  10    20   (70    30    20    50    40    10    10)

% Sample Input:    x = [70    30    20    40    50    70    10    50    60]
% Sample Segmentation: (70    30    20)   40    50   (70    10)   50    60

    arguments
        inputDiffSeq {isvector}
    end

    shape = size(inputDiffSeq);
    thre = 0.05;

    if shape(2) > 1 % row vector
        inputDiffSeq = inputDiffSeq'; % transpose into column vector
    end


    diff2 = diff([0; inputDiffSeq]);

    logicalVector = diff2 < thre;


    %% Exploitation
    oneVector = int8(logicalVector);
    oneVectorDiff = diff([oneVector; 0]);

    exploitStart = find( oneVectorDiff == 1);
    exploitEnd = find( oneVectorDiff == -1);

    if oneVector(1) == 1
        exploitStart = [1; exploitStart];
    end

    %% Exploration
    reverseVector = 1 - int8(logicalVector | [logicalVector(2:end); false]);
    reverseVectorDiff = diff([reverseVector; 0]);

    exploreStart = find( reverseVectorDiff == 1) + 1;
    exploreEnd = find( reverseVectorDiff == -1);

    if reverseVector(1) == 1
        exploreStart = [1; exploreStart];
    end

    %% Merge adjacent exploitation phases

    before = exploitEnd(1:end-1);
    after = exploitStart(2:end) - 1;

    I = find(before == after);
    waitList = [];

    for m = I'
        
        former0 = exploitStart(m);
        formert = exploitEnd(m);
        
        maxF = max(inputDiffSeq(former0:formert));
        
        latter0 = exploitStart(m + 1);
        lattert = exploitEnd(m + 1);
        
        maxL = max(inputDiffSeq(latter0:lattert));
        
        if maxL - maxF < thre
            waitList = [waitList; m];
        end
        
    end

    exploitEnd(waitList) = [];
    exploitStart(waitList + 1) = [];

    %% Median phase duration

    if numel(exploitStart) == numel(exploitEnd) && numel(exploreStart) == numel(exploreEnd)
        strct = struct('seq', inputDiffSeq, 'exploitStart', exploitStart, 'exploitEnd', exploitEnd, ...
                                        'exploreStart', exploreStart, 'exploreEnd', exploreEnd);
    else
        strct = struct([]);
    end

    exploitDur = zeros(numel(exploitStart), 1);
    exploitSteps = zeros(numel(exploitStart), 1);
    for i = 1:numel(exploitStart)
        intv0 = exploitStart(i); % interval start
        intvt = exploitEnd(i);   % interval end
        exploitDur(i) = sum(inputDiffSeq(intv0:intvt));
        exploitSteps(i) = sum( intvt - intv0 + 2);
    end

    exploreDur = zeros(numel(exploreStart), 1);
    exploreSteps = zeros(numel(exploreStart), 1);
    for i = 1:numel(exploreStart)
        intv0 = exploreStart(i); % interval start
        intvt = exploreEnd(i);   % interval end
        exploreDur(i) = sum(inputDiffSeq(intv0:intvt));
        exploreSteps(i) = sum( intvt - intv0 + 2);
    end

end

