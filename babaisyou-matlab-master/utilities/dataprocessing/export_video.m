%% init
clear
P = readtable('data/participants.csv');
P = sortrows(P, 'SubNo');
initUtility;

for id = 1:5%height(P)
    inputfile = sprintf('data/player_map_analyzed/map_logic_%d_%s.mat', P.Date(id), P.Name{id});
    load(inputfile, 'mapHistory');
    minchp=mapHistory(1).Chapter;
    maxchp=mapHistory(end).Chapter;
    for chp = minchp : maxchp
        switch chp
            case 0 
                lvlrange=[0,1,2,3];
            case 1
                lvlrange=[0,1,2,3,4];
            case 2
                lvlrange=[0,1,2];
        end
        for lvl = min(lvlrange):max(lvlrange)
            logicalArray = [mapHistory(:).Chapter] == chp ...
                            & [mapHistory(:).Level] == lvl;
            if ~any(logicalArray)
                continue;
            else
            fprintf('Clock: %s\n', datetime('now'));
            fprintf('-------Participant: %2d, %d, %s-------\n', id, P.Date(id), P.Name{id});
            mapHistory2video(P.Date(id), P.Name{id}, 'constant',chp+1,lvl+1);
            end
        end
    end
end