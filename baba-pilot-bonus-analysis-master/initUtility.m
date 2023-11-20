%% INITUTILITY: initialize paths and variables for "global" use

%% add untilities folders to path
addpath('utilities/')
addpath('utilities/preprocessdata')
addpath('utilities/gamelogic')
addpath('utilities/graph')
addpath('utilities/heuristics')
addpath('utilities/sprites')
addpath('utilities/map')
addpath('utilities/behavior')
addpath('utilities/general')
addpath('utilities/visualization')

%% Variables for "global" use

%% Color palette
Color4Condition = [170 75 186;  % magneta
                  138  151  215; % purple
                 156  194  209; % teal
                 198  198  198]./255; % gray
            
Color4Solution = [0 68 136; %dark blue
                  102 153 204; %light blue
                  238 204 102; % light yellow
                  238 153 170]./255; %light red
                  
%% Categorical data type
solutionSet =  {'BagIsPush', 'BagIsHotMelt', 'BreakHotMelt', 'OtherIsYou'};
conditionSet = {'NN', 'NF', 'FN', 'FF'};