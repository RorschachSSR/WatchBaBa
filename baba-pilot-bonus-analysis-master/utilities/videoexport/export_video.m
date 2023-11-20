%% init
P = readtable('data/participants.csv');
P = sortrows(P, 'SubNo');
initUtility;

for id = 32:40
    fprintf('Clock: %s\n', datetime('now'));
    fprintf('-------Participant: %2d, %d, %s-------\n', id, P.Date(id), P.Name{id});
    mapHistory2video(P.Date(id), P.Name{id}, 'scaled');
end