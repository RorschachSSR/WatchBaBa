clear;

N=40; % total num of the videos;
coarse_seg_agree = zeros(1,N);
fine_seg_agree = zeros(1,N);
allAvgDist = zeros(1,N);
allexpAvgDist = zeros(1,N);

videopath = [cd '\videos'];
videodir = dir(fullfile(videopath, '*.mp4')); %get the video files

datapath = [cd '\SAVE'];
filedir = dir(fullfile(datapath, '*.mat')); %get the data files

groupdatapath = [cd '\data_added_up'];
groupfiledir = dir(fullfile(groupdatapath, '*.mat')); %get the group data files

for i = 1 : length(filedir)
   load([filedir(i).folder '\' filedir(i).name]); 
   for j = 1 : size(splitPoint.video,3)
       videoname=splitPoint.video(:,:,j);
       video_no = find_video_no(videodir,videoname);
       videotime = splitPoint.time(j);
       coarse_split = split_in_bins(splitPoint.the_coarse(j,:),videotime);
       fine_split = split_in_bins(splitPoint.the_fine(j,:),videotime);
       load([groupfiledir(i).folder '\' groupfiledir(i).name]);
       coarse_r=corr(coarse_split',groupSplit.coarse');
       fine_r=corr(fine_split',groupSplit.fine');
       [coarse_r_min,coarse_r_max]=get_r(groupSplit.coarse,sum(coarse_split));
       [fine_r_min,fine_r_max]=get_r(groupSplit.fine,sum(fine_split));
       coarse_seg_agree(i,video_no)=(coarse_r-coarse_r_min)/(coarse_r_max-coarse_r_min);
       fine_seg_agree(i,video_no)=(fine_r-fine_r_min)/(fine_r_max-fine_r_min);
       allAvgDist(i,video_no)=AvgDist(splitPoint.the_coarse(j,:),splitPoint.the_fine(j,:));
       allexpAvgDist(i,video_no)=exp_AvgDist(splitPoint.the_fine(j,:));
       coarse_seg_agree = [coarse_seg_agree;zeros(1,N)];
       fine_seg_agree = [fine_seg_agree;zeros(1,N)];
       allAvgDist = [allAvgDist;zeros(1,N)];
       allexpAvgDist = [allexpAvgDist;zeros(1,N)];
   end
end

save('finalData\coarse_seg_agree.mat','coarse_seg_agree');
save('finalData\fine_seg_agree','fine_seg_agree');
save('finalData\allAvgDist','allAvgDist');
save('finalData\allexpAvgDist','allexpAvgDist');