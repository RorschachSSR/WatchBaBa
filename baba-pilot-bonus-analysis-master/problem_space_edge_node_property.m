%%PROBLEM SPACE EDGE NODE PROPERTIES
% 1. Run problem_space_human_search.m to generate the pooled problem space
% 2. Run problem_space_individual_search.m to generate the individual problem space
% 3. Run this script to generate the edge node properties

%% Load the pooled problem space
try
    clear all
catch
    disp('clear variable error')
end
clc
close all
initUtility;
importData;
participants = P;

chp = input('Chapter: ');
lvl = input('Level: ');

% manually select the starting state configuration, if there are multiple ones
condition_selector = '';
filter = ones(height(participants), 1, 'logical');

% training levels 4 & 5: influenced by condition(NN/NF/FN/FF) setting
%         if chp == 2 && lvl > 3
%             validInput = false;
%             while ~validInput
%                 condition_selector = input('Select one condition NN/NF/FN/FF: ', 's');
%                 validInput = true;
%                 switch condition_selector
%                     case 'NN'
%                         filter = participants.Condition == 1;
%                     case 'NF'
%                         filter = participants.Condition == 2;
%                     case 'FN'
%                         filter = participants.Condition == 3;
%                     case 'FF'
%                         filter = participants.Condition == 4;
%                     otherwise
%                         disp('Invalid condition')
%                         validInput = false;
%                 end
%             end
%         end

if chp == 2 
    if lvl == 4
        validInput = false;
        while ~validInput
            condition_selector = input('Select one map configuration defeat/hot: ', 's');
            validInput = true;
            switch condition_selector
                case 'defeat'
                    filter = ~participants.level4_withHot;
                case 'hot'
                    filter = participants.level4_withHot;
                otherwise
                    disp('Invalid condition')
                    validInput = false;
            end
        end
    elseif lvl == 5
        validInput = false;
        while ~validInput
            condition_selector = input('Select one map configuration defeat/hot: ', 's');
            validInput = true;
            switch condition_selector
                case 'defeat'
                    filter = ~participants.level5_withHot;
                case 'hot'
                    filter = participants.level5_withHot;
                otherwise
                    disp('Invalid condition')
                    validInput = false;
            end
        end
    end
end

% bonus level: map is adaptive to participant's responses
if chp == 3
    if lvl == 2
        validInput = false;
        while ~validInput
            condition_selector = input('Select one condition noBagIsPush/noMelt: ', 's');
            validInput = true;
            switch condition_selector
                case 'noBagIsPush'
                    filter = bonus2_noBagIsPush;
                case 'noMelt'
                    filter = bonus2_noMelt;
                otherwise
                    disp('Invalid condition')
                    validInput = false;
            end
        end
    elseif lvl == 3
        filter = ~excludedPforBonus3;
        validInput = false;
        while ~validInput
            condition_selector = input('Select one condition noBag/noPush: ', 's');
            validInput = true;
            switch condition_selector
                case 'noBag'
                    filter = filter & bonus3_noBag;
                case 'noPush'
                    filter = filter & bonus3_noPush;
                otherwise
                    disp('Invalid condition')
                    validInput = false;
            end
        end
    end
end

if isempty(condition_selector)
    savefile = ['problemspace/human_search_', num2str(chp), '_', num2str(lvl),'.mat'];
else
    savefile = ['problemspace/human_search_', num2str(chp), '_', num2str(lvl),'_', condition_selector, '.mat'];
end

load(savefile, 'G');

% add property to edge table
G.Edges.n_participant = zeros(height(G.Edges), 1);
G.Edges.visit_per_person = zeros(height(G.Edges), 1);
G.Edges.visit_var = zeros(height(G.Edges), 1);
G.Edges.visit_std = zeros(height(G.Edges), 1);
G.Edges.relative_visit = zeros(height(G.Edges), 1);
G.Edges.relative_frequency = zeros(height(G.Edges), 1);

% directory for individual problem space
if isempty(condition_selector)
    savedir = ['problemspace/individual_', num2str(chp), '_', num2str(lvl)];
else
    savedir = ['problemspace/individual_', num2str(chp), '_', num2str(lvl), '_', condition_selector];
end

%% loop individual problem space to compute properties

% global property
tic
participants(~filter, :) = [];
for i = 1:height(participants)
    individualfile = [savedir, '/individual_search_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat']; 
    load(individualfile, 'subG')
    
    edgeIdx = arrayfun(@(x, y) findedge(G, x, y), subG.Edges.EndNodes(:, 1), subG.Edges.EndNodes(:, 2));
    G.Edges.n_participant(edgeIdx) = G.Edges.n_participant(edgeIdx) + 1;

    delta = subG.Edges.Weight - G.Edges.visit_per_person(edgeIdx);
    G.Edges.visit_per_person(edgeIdx) = G.Edges.visit_per_person(edgeIdx) + delta ./ G.Edges.n_participant(edgeIdx);
    G.Edges.visit_var(edgeIdx) = G.Edges.visit_var(edgeIdx) + delta.*(subG.Edges.Weight - G.Edges.visit_per_person(edgeIdx));
end
toc

G.Edges.visit_std = sqrt(G.Edges.visit_var ./ G.Edges.n_participant);

tic
% local property
for i = 1:height(participants)
    individualfile = [savedir, '/individual_search_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat']; 
    load(individualfile, 'subG')
    
    edgeIdx = arrayfun(@(x, y) findedge(G, x, y), subG.Edges.EndNodes(:, 1), subG.Edges.EndNodes(:, 2));
    
    for e = edgeIdx' % loop through row vector
        s = G.Edges.EndNodes(e,1); % source node of the current edge
        oeid = outedges(G, s); % all possible outedges of the same source node

        s_oe_weight_sum = sum(G.Edges.Weight(oeid)); % sum of persons who have visited the outedges
        G.Edges.relative_visit(e) = G.Edges.Weight(e) / s_oe_weight_sum;

        s_oe_visit_sum = sum(G.Edges.visit_per_person(oeid)); % sum of persons who have visited the outedges
        G.Edges.relative_frequency(e) = G.Edges.visit_per_person(e) / s_oe_visit_sum;
    end
end
toc

%% assign properties to each participant

participants.rareness = zeros(height(participants), 1);
participants.uniqueness = zeros(height(participants), 1);
participants.preservation = zeros(height(participants), 1);
participants.variability = zeros(height(participants), 1);

for i = 1:height(participants)
    individualfile = [savedir, '/individual_search_', num2str(participants{i, 'Date'}), '_', participants{i, 'Name'}{:}, '.mat']; 
    load(individualfile, 'subG')
    
    edgeIdx = arrayfun(@(x, y) findedge(G, x, y), subG.Edges.EndNodes(:, 1), subG.Edges.EndNodes(:, 2));
    subWeight = subG.Edges.Weight;
    
    rareness = - log(G.Edges.n_participant(edgeIdx) ./ max(G.Edges.n_participant));
    uniqueness = - log(G.Edges.relative_frequency(edgeIdx));
    preservation = G.Edges.visit_per_person(edgeIdx);
    variability = G.Edges.visit_var(edgeIdx);

    participants.rareness(i) = dot(rareness, subWeight) / sum(subWeight);
    participants.uniqueness(i) = dot(uniqueness, subWeight) / sum(subWeight);
    participants.preservation(i) = dot(preservation, subWeight) / sum(subWeight);
    participants.variability(i) = dot(variability, subWeight) / sum(subWeight);
end

if isempty(condition_selector)
    outputpath = ['problemspace/property_computed/human_search_', num2str(chp), '_', num2str(lvl), '.mat'];
else
    outputpath = ['problemspace/property_computed/human_search_', num2str(chp), '_', num2str(lvl), '_', condition_selector, '.mat'];
end
save(outputpath, 'G', 'participants');

%% participant selection

ref = participants.preservation;
prc = prctile(ref, [5, 40, 60, 95]); 
%prc = prctile(ref, [5, 10, 90, 95])

tol = 0.0001;
low = find(ref - prc(1) < - tol );
mid = find(ref > prc(2) & ref < prc(3));
high = find(ref - prc(4) > tol);
% low = find(ref <=  prc(1));
% mid = find(ref > prc(2) & ref <= prc(3));
% high = find(ref >= prc(4));

% random selection of 1 participan t from each group
rng('Shuffle')
low = low(randi(length(low)));
mid = mid(randi(length(mid))); 
high = high(randi(length(high)));

% print selected participant to cmd line
fprintf('Chapter %d, Level %d, Selected participants:\n', chp, lvl);
fprintf('Low  preservation: No. %d, %d, %s\n', participants.SubNo(low), participants{low, 'Date'}, participants{low, 'Name'}{:});
fprintf('Mid  preservation: No. %d, %d, %s\n', participants.SubNo(mid), participants{mid, 'Date'}, participants{mid, 'Name'}{:});
fprintf('High preservation: No. %d, %d, %s\n', participants.SubNo(high), participants{high, 'Date'}, participants{high, 'Name'}{:});

%% visualize dimensions of edge property

f = figure('Position', [0 0 1500 1200]);

xnames = {'rareness', 'uniqueness', 'preservation', 'variability'};
numGroups = length(unique(participants.SubNo));
clr = hsv(numGroups);

% highlight participant selection
filter = zeros(numGroups, 1, 'logical');
filter(low) = true;
filter(mid) = true;
filter(high) = true;
clr(~filter, :) = repmat([0.5, 0.5, 0.5], sum(~filter), 1);

gplotmatrix([participants.rareness, participants.uniqueness, participants.preservation, participants.variability], [], participants.SubNo,...
            clr, [], [], 'off','hist',xnames)