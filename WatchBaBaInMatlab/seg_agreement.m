clear;

N=32; % total num of the videos;
seg_agree = zeros(1,N);
path = [cd '\SAVE'];
filedir = dir(fullfile(path, '*.mat')); %get the data files
for i = 1 : length(filedir)
   load([filedir(i).folder '\' filedir(i).name]); 
end