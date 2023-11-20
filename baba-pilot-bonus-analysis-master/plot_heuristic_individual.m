%% Searching Behavior
clear
initUtility
load('data/player_map_analyzed/map_logic_20220118_rhj.mat')

%% Heuristic

chp = 3;
lvl = 1;
%% 
% 
logicalArray = [mapHistory(:).Chapter] == chp - 1 ...
                & [mapHistory(:).Level] == lvl - 1;
mapHistory = mapHistory(logicalArray);

figure
ts = [mapHistory(:).timestamp];
h = arrayfun(@heuristicManhattan, mapHistory);
plot(ts, h, 'k'); hold on

startpoints = strcmp('Start', {mapHistory(:).Control}) | strcmp('Restart', {mapHistory(:).Control});
y = h(startpoints);
x = ts(startpoints);
plot(x, y, 'g*');hold on

topoChange = zeros(size(ts), 'logical');
for i = 2:size(ts,2)
    if ~isisomorphic(mapHistory(i).obstacleGraph, mapHistory(i-1).obstacleGraph)
        topoChange(i) = true;
    end
end
y = h(topoChange);
x = ts(topoChange);
plot(x, y, 'bs'); hold on

ruleChange = zeros(size(ts), 'logical');
for i = 2:size(ts,2)
    if ~isequal(mapHistory(i).ruleGraph, mapHistory(i-1).ruleGraph)
        ruleChange(i) = true;
    end
end
y = h(ruleChange);
x = ts(ruleChange);
plot(x, y, 'md'); hold on

legend({'heuristic', 'start', 'topological change', 'rule change'}, 'Location', 'best')
