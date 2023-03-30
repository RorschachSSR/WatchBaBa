clear;

N=40; % total num of the videos;
allcoarse = zeros(N,10000);
allfine = zeros(N,10000);
alltime = zeros(1,N);
playtimes = zeros(1,N);

videopath = [cd '\videos'];
videodir = dir(fullfile(videopath, '*.mp4')); %get the video files

path = [cd '\SAVE'];
filedir = dir(fullfile(path, '*.mat')); %get the data files

for i = 1 : length(filedir)
    load([filedir(i).folder '\' filedir(i).name]); 
   for j = 1 : size(splitPoint.video,3)
       videoname=splitPoint.video(:,:,j);
       video_no = find_video_no(videodir,videoname);
       videotime = splitPoint.time(j);
       coarse_split = split_in_bins(splitPoint.the_coarse(j,:),videotime);
       fine_split = split_in_bins(splitPoint.the_fine(j,:),videotime);
       allcoarse(video_no,:)=allcoarse(video_no,:)+[coarse_split,zeros(1,10000-length(coarse_split))];
       allfine(video_no,:)=allfine(video_no,:)+[fine_split,zeros(1,10000-length(fine_split))];
       alltime(video_no)=videotime;
       playtimes(video_no)=playtimes(video_no)+1;
   end
end

for i = 1 : N
    allcoarse(i,:)=allcoarse(i,:)./playtimes(i);
    allfine(i,:)=allfine(i,:)./playtimes(i);
    groupSplit.coarse=allcoarse(i,:);
    groupSplit.fine=allfine(i,:);
    filename = ['data_added_up\Video_NO_' num2str(i) '.mat'];
    save(filename,'groupSplit');
end