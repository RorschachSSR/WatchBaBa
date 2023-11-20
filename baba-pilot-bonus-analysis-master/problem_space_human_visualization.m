%%PLOT_HUMAN_SEARCHING_SPACE
% Output: visualization of the transitions between problem states
% Input: hash table of states, and a directed graph built from state nodes

%% Parameters
clc
clear all
close all
initUtility;

%% select level

dirData = dir('problemspace/property_computed/*.mat');

arrayfun(@(x) fprintf('%s \n', x.name), dirData);

whichfile = strtrim(input('Select from the above files: ', 's'));
clear dirData

%% Visualize the problem space

load(['problemspace/property_computed/', whichfile]);
load(['problemspace/', whichfile], 'hashtable');
%% open figure
f = figure('Position', [0 0 1500 1000]);
cmap = [0.2440    0.4358    0.9988;
        0.1938    0.7758    0.6251;
        0.9892    0.8136    0.1885]; %custom color map

% plot graph

p = plot(G, 'NodeLabel', {}, 'ArrowSize', 6);
% layout(p, 'layered', 'Source', 1, 'AssignLayers', 'alap');
layout(p, 'force', 'UseGravity',true);

% edge appearance: line width proportional to number of visit
G.Edges.LWidths = 1+ 10 * G.Edges.n_participant / max(G.Edges.n_participant);
p.LineWidth = G.Edges.LWidths;
p.EdgeAlpha = 0.4;
% node appearance: marker size proportional to number of person visit
G.Nodes.MarkerSizes = 4 + 10 * G.Nodes.n_participant / max(G.Nodes.n_participant);
p.MarkerSize = G.Nodes.MarkerSizes;
p.NodeCData = G.Nodes.win * 1 + G.Nodes.defeat * (-1);
caxis([-1 1])
colormap(f, cmap);
colorbar('Ticks', [-1 0 1], 'TickLabels', {'Defeat' 'Non-terminal' 'Win'});
% node labels
startIndex = find(G.Nodes.start);
winIndex = find(G.Nodes.win);
defeatIndex = find(G.Nodes.defeat);
p.NodeFontSize = 9;
labelnode(p, startIndex, {'Start '});
p.NodeLabel(winIndex) = strcat(p.NodeLabel(winIndex), 'Win ');
p.NodeLabel(defeatIndex) = strcat(p.NodeLabel(defeatIndex), 'Defeat ');
% data tips in figure UI
p.DataTipTemplate.DataTipRows(1).Label = "Hash";
row = dataTipTextRow('Node Index', 1:height(G.Nodes));
p.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('No. Participant', G.Nodes.n_participant);
p.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('No. Visits', G.Nodes.n_visit);
p.DataTipTemplate.DataTipRows(end+1) = row;
row = dataTipTextRow('Average Staying Time', G.Nodes.m_stay);
p.DataTipTemplate.DataTipRows(end+1) = row;

%% save and export fig
exportgraphics(gcf, ['problemspace/graphplot/', whichfile(1:end-4),'.png'], 'Resolution', 300); 

%% highlight participant
subno = input('Participant No. : ');
i = find(participants.SubNo == subno);

savedir = ['problemspace/individual', whichfile(13:end-4)];
individualfile = [savedir, '/individual_search_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat']; 

disp(individualfile)
load(individualfile, 'subG')
edgeIdx = arrayfun(@(x, y) findedge(G, x, y), subG.Edges.EndNodes(:, 1), subG.Edges.EndNodes(:, 2));
p.EdgeColor = [0 0.45 0.74];
p.LineWidth = ones(height(G.Edges), 1);
p.LineWidth(edgeIdx) = subG.Edges.Weight;

highlight(p, 'Edges', edgeIdx, 'EdgeColor','r')
%% calculate centrality
G = simplify(G); % remove self loops
uincc = centrality(G, 'incloseness','Cost', 1./G.Edges.Weight);
uoutcc = centrality(G, 'outcloseness', 'Cost', 1./G.Edges.Weight); 
ubc   = centrality(G, 'betweenness' ); %'Cost', 1./G.Edges.Weight
upc  = centrality(G, 'pagerank');
uhub = centrality(G, 'hubs');
uauth = centrality(G, 'authorities');

%% node color with centrality
p.MarkerSize = 6;
p.EdgeColor = [0.5 0.5 0.5];
p.NodeCData = ubc;

caxis('auto')
colorbar('delete')
colormap(gcf, flip(autumn(256),1))
colorbar

%% select a specific state node
nodeIndex = 2;
disp(nodeIndex)
hashcode = G.Nodes{nodeIndex, 'Name'}{:};
pointer = hashtable(hashcode);
%num_instance = renderState(G, hashtable, nodeIndex);
mapItem = pointer.Data;
rulesFromHash(hashcode, mapItem);

%% analyze one instance of the state

[mapItem.ruleGraph, mapItem.spriteClusters, mapItem.propertyClusters] = gameLogicAnalyzer(mapItem);
mapItem.obstacleGraph = analyzeObstacles(mapItem);

%% visualize one node instance
f = figure('Position', [0 0 1200 800]);
renderMap(mapItem, gca);
obg = plotObstacleGrid(mapItem.obstacleGraph);
%% Condensation

% C is a directed acyclic graph (DAG), and is topologically sorted. The node numbers in C correspond to the bin numbers returned by conncomp.condensation determines the nodes and edges in C by the components and connectivity in G:
% C contains a node for each strongly connected component in G.
% C contains an edge between node I and node J if there is an edge from any node in component I to any node in component J of G.
bins = conncomp(G);
p.MarkerSize = 7;
p.NodeCData = bins;
colormap(hsv(37))

C = condensation(G);
p2 = plot(C);
p2.MarkerSize = 7;
p2.NodeCData = 1:37;
colormap(hsv(37))