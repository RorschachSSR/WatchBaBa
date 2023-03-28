function practiceList = practiceList(num)
% generate a random video order of size num
practiceList = cell (1,num);
videopath = [cd '\practice_video'];
filedir = dir(fullfile(videopath, '*.mp4')); %get the video files
for i = 1:num
    practiceList(i) = {[filedir(i).folder '\' filedir(i).name]};
end
practiceList = char(string(practiceList));
end
