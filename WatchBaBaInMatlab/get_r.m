function [r_min,r_max] = get_r(split_proportion,split_num)
% calculate the min r of the correlation between the propotion and a
% split_point given the num of the points

num_bins = length(split_proportion);
min_split = zeros(1,num_bins);
max_split = zeros(1,num_bins);
[~,order] = sort(split_proportion);
min_split(order(1:split_num))=1;
max_split(order(end-split_num+1:end))=1;
r_min = corr(split_proportion',min_split');
r_max = corr(split_proportion',max_split');
end

