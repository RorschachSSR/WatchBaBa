function [practiceList_coarse,practiceList_fine] = practiceList(num)
% generate a random video order of size num
practiceList_coarse = cell (1,num);
practiceList_fine =cell(1,num);
videopath = [cd '\practice_video'];
filedir_coarse = dir(fullfile(videopath, '*_coarse.mp4')); %get the video files
filedir_fine = dir(fullfile(videopath, '*_fine.mp4')); %get the video files
for i = 1:num
    practiceList_coarse(i) = {[filedir_coarse(i).folder '\' filedir_coarse(i).name]};
    practiceList_fine(i) = {[filedir_fine(i).folder '\' filedir_fine(i).name]};
end
practiceList_coarse = char(string(practiceList_coarse));
practiceList_fine = char(string(practiceList_fine));
end
