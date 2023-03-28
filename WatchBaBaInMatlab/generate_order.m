function videoList = generate_order(num)
% generate a random video order of size num
videoList = cell (1,num);
videopath = [cd '\videos'];
filedir = dir(fullfile(videopath, '*.mp4')); %get the video files
filedir = filedir(randperm(numel(filedir),num));
for i = 1:num
    videoList(i) = {[filedir(i).folder '\' filedir(i).name]};
end
videoList = char(string(videoList));
end
