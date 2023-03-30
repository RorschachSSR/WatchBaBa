function [r_min,r_max] = get_r(split_proportion,split_num)
% calculate the min r of the correlation between the propotion and a
% split_point given the num of the points
r_min = 1;
r_max = -1;
num_bins = length(split_proportion);
split_results = split(num_bins,split_num);
    for i= 1 : size(split_results,1)
        r = corr(split_results(i,:)',split_proportion');
        if r < r_min
            r_min = r;
        end
        if r > r_max;
            r_max = r;
        end
    end
end

function split_results = split(num_bins, split_num)
    split_points = zeros(1, num_bins);
    split_results = search(split_points, split_num);
end

function split_results = search(split_points, split_num)
    if split_num == 0
        split_results = split_points;
    else
        split_results = [];
        for i = 1:length(split_points)
            split_points(i) = split_points(i) + 1;
            split_num = split_num - 1;
            sub_results = search(split_points, split_num);
            split_results = [split_results; sub_results];
            split_points(i) = split_points(i) - 1;
            split_num = split_num + 1;
        end
    end
end

