clear
initUtility
importData

T_handle_new_property = readtable('data/processed_behavior/experience_handle_new_property.csv');
T_nullify_you = readtable('data/processed_behavior/experience_nullify_you.csv');
T_pushable_extension = readtable('data/processed_behavior/experience_pushable_extension.csv');
T_superstitious_pushing = readtable('data/processed_behavior/experience_superstitious_pushing.csv');
T_treating_obstacle = readtable('data/processed_behavior/experience_treating_obstacle.csv');

T_handle_new_property(:, 1) = [];
T_nullify_you(:, 1) = [];
T_pushable_extension(:, 1) = [];
T_superstitious_pushing(:, 1) = [];
T_treating_obstacle(:, 1) = [];

full_experience = [T_treating_obstacle, T_superstitious_pushing, T_pushable_extension, T_handle_new_property, T_nullify_you];

clear T_handle_new_property T_nullify_you T_pushable_extension T_superstitious_pushing T_treating_obstacle

% removes behaviors that less than 4 participant perform
count = sum(full_experience{:, :}, 'omitnan');
logicalVector = count < 4;
full_experience(:, logicalVector) = [];

%% add bonus solution

X = bonus_solutions(:, {'SubNo', 'Level', 'Solution'});
U = unstack(X, 'Solution','Level');
U = [U; {29, '', '', ''}];
U = sortrows(U, 'SubNo');

dummysol = dummyvar(categorical(U.x2, solutionSet));
full_experience.Bonus_2_hotmelt = dummysol(:, 2);
full_experience.Bonus_2_nullifyhot = dummysol(:, 3);
full_experience.Bonus_2_changeyou = dummysol(:, 4);

clear X U dummysol

%% add RT

varOfConcern = 'Steps2Win';
Ts = T(:, {'SubNo', varOfConcern});

Ts.ID = strcat({'RT_chp_'}, cellstr(num2str(T.Chapter)),{'_lvl_'}, cellstr(num2str(T.Level)));
Ts.ID = categorical(Ts.ID);

U = unstack(Ts, varOfConcern, 'ID');
U = sortrows(U, 'SubNo');
U{:, 2:end} = U{:, 2:end} ./ U{:, 'RT_chp_2_lvl_2'};
full_experience = horzcat(full_experience, removevars(U, 'SubNo'));

%% add trait
Q = sortrows(Q, 'SubNo');
X = Q{:, surveyLabel};
[~,score,~, ~, ~, ~] = pca(zscore(X));

% save the first 2 components
full_experience = addvars(full_experience, score(:, 1), score(:, 2), 'Before', 1, 'NewVariableNames', {'GameFreq', 'GamePref'});
clear X Q U score
%% add experimental condition
full_experience = addvars(full_experience, P.Condition == 1, P.Condition == 2, P.Condition == 3, P.Condition == 4, ...
                        'Before', 1, 'NewVariableNames', {'experience_defeat_only', 'experience_defeat_hot', 'experience_hot_defeat', 'experience_hot_only'});
full_experience = addvars(full_experience, P.level4_withHot, P.level5_withHot, 'Before', 1, 'NewVariableNames', {'ch2_lvl4_type', 'ch2_lvl5_type'});



%% correlation

varlabels = full_experience.Properties.VariableNames;
varlabels = replace(varlabels, '_', '\_');
                        
[RHO,PVALUE] = corr(full_experience{:, :}, 'Type', 'Spearman', 'Rows', 'pairwise');
upper_tri = triu(ones(size(PVALUE), 'logical'));


%% with fdr correction
PVALUE(upper_tri) = nan;
p_list = PVALUE(:);
p_list = p_list(p_list > 0); % remove upper triangular values
p_list = sort(p_list);
[~,~,r] = unique(p_list,'sorted'); % ranks from lowest to highest
q = p_list * numel(p_list) ./ r;
q_index = find(q <= 0.05, 1, 'last');
p_bnd = p_list(q_index);
disp(q_index)
clear p_list r q q_index

%% without fdr correction
p_bnd = 0.05;

%% correlation plot
RHO(PVALUE > p_bnd) = nan;
RHO(upper_tri) = nan;

figure('Position', [0 0 1200 800]); 
h = heatmap(RHO, 'MissingDataColor',[0.5 0.5 0.5]);
colormap(h, jet);
caxis([-1 1]);
% figure(2); colormap(flip(autumn(256),1))
% hp = heatmap(PVALUE);
% colormap(hp, flip(autumn(256),1));

h.XDisplayLabels = varlabels;
h.YDisplayLabels = varlabels;
h.CellLabelFormat = '%.2f';
h.FontSize = 9;

%% scatter

var1 = 'Train_5_push_text_as_extension';
var2 = 'Train_5_nullify_you';

scatter(full_experience{:, var1} + 0.1 * rand(64, 1), full_experience{:, var2}, ...
                            'MarkerFaceColor', 'flat', ...
                            'MarkerFaceAlpha', 0.5, 'LineWidth', 1.5)
                        
xlabel(replace(var1, '_', '\_'))
ylabel(replace(var2, '_', '\_'))
                        
%% heatmap
full_experience.Condition = P.Condition;
ctab = heatmap(full_experience,'Condition', 'Train_4_destroy_you_seq');

[~,chi2,p] = crosstab(full_experience.Condition,full_experience.Train_4_destroy_you_seq);
disp(p)

ctab.XDisplayLabels = {'NN', 'NF', 'FN', 'FF'};
ctab.YDisplayLabels = {'before pushing book', 'before pushing text', 'after pushing text'};
%% regression

% 'Tutorial_4_push_sun_to_win ~ Tutorial_1_push_dice_to_win + Tutorial_3_push_dice_to_win + Tutorial_3_push_dice_counts'
% 'Train_1_when_push_text_from_mirror ~ -Tutorial_2_nullify_you)
% 'Train_5_nullify_you ~ Train_1_when_push_text_from_mirror + Train_5_push_text)
% 'Bonus_1_nullify_you ~ Train_1_nullify_you + Train_4_push_text)
% 'Bonus_hotmelt ~ Tutorial_2_when_move_outside_I_shape'
% 'Bonus_2_nullify_you ~ Train_1_nullify_you'
% 'Train_5_destroy_you_first ~ experience_defeat_hot -
% experience_hot_defeat - level4_withHot'
% 'Bonus_3_nullify_you ~ -level4_withHot' 

X = normalize(full_experience{:, :});
reg_data = array2table(X,'VariableNames', full_experience.Properties.VariableNames);

lf = fitlme(reg_data, 'Bonus_2_nullify_you ~ Tutorial_2_nullify_you + Tutorial_3_nullify_you + Train_1_nullify_you + Train_2_nullify_you + Train_5_nullify_you + Bonus_1_nullify_you');