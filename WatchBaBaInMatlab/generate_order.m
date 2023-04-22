function [videoList_coarse,videoList_fine,order] = generate_order(num)
% generate a random video order of size num
videoList_coarse = cell (1,num);
videoList_fine = cell (1,num);
videopath = [cd '\videos'];
filedir_coarse = dir(fullfile(videopath, '*_coarse.mp4')); %get the video files
filedir_fine = dir(fullfile(videopath, '*_fine.mp4')); %get the video files
order = randperm(num);
filedir_coarse = filedir_coarse(order);
filedir_fine = filedir_fine(order);
for i = 1:num
    videoList_coarse(i) = {[filedir_coarse(i).folder '\' filedir_coarse(i).name]};
    videoList_fine(i) = {[filedir_fine(i).folder '\' filedir_fine(i).name]};
end
videoList_coarse = char(string(videoList_coarse));
videoList_fine = char(string(videoList_fine));
end
