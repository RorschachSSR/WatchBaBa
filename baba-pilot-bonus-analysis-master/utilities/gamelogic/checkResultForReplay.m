function output = checkResultForReplay(mapItem, flag)
%DETECTWINFAIL detects if the player has won or failed
%   output = 1 if the player has won/failed according to the flag
    if ~ismember(flag,{'Win','Defeat'})
        error('Invalid flag, should be "Win" or "Defeat"');
    end

    set_rules;

    flagWin = 0;
    flagFail = 0;
    if ~isKey(mapItem.propertyClusters, Rules('You'))
        flagFail = 1;
    else
        if ~any(mapItem.propertyClusters(Rules('You')), 'all')
            flagFail = 1;
        end
        if isKey(mapItem.propertyClusters, Rules('Win'))
            if any(mapItem.propertyClusters(Rules('Win')) & mapItem.propertyClusters(Rules('You')), 'all')
                flagWin = 1;
            end
        end
    end

    if strcmp(flag, 'Win')
        output = flagWin;
    else
        output = flagFail;
    end
end