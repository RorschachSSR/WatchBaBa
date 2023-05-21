clear;

N=15; % total num of the videos;
coarse_seg_agree = [];
fine_seg_agree = [];
allAvgDist = [];
allexpAvgDist = [];
creaPoint = [];


datapath = [cd '\SAVE'];
filedir = dir(fullfile(datapath, '*.mat')); %get the data files

groupdatapath = [cd '\data_added_up'];
groupfiledir = dir(fullfile(groupdatapath, '*.mat')); %get the group data files

for i = 1 : length(filedir)
   load([filedir(i).folder '\' filedir(i).name]); 
   coarse_seg_agree = [coarse_seg_agree;zeros(1,N)];
   fine_seg_agree = [fine_seg_agree;zeros(1,N)];
   allAvgDist = [allAvgDist;zeros(1,N)];
   allexpAvgDist = [allexpAvgDist;zeros(1,N)];
   [~,creaOrder]=sort(splitPoint.order);
   creaPoint = [creaPoint;splitPoint.creaPoint(creaOrder)];
   for j = 1 : N
       video_no = splitPoint.order(j);
       videotime = splitPoint.time(j);
       coarse_split = split_in_bins(splitPoint.the_coarse(j,:),videotime);
       fine_split = split_in_bins(splitPoint.the_fine(j,:),videotime);
       load([groupfiledir(video_no).folder '\' groupfiledir(video_no).name]);
       coarse_r=corr(coarse_split',groupSplit.coarse(1:length(coarse_split))');
       fine_r=corr(fine_split',groupSplit.fine(1:length(fine_split))');
       [coarse_r_min,coarse_r_max]=get_r(groupSplit.coarse(1:length(coarse_split)),sum(coarse_split));
       [fine_r_min,fine_r_max]=get_r(groupSplit.fine(1:length(fine_split)),sum(fine_split));
       coarse_seg_agree(i,video_no)=(coarse_r-coarse_r_min)/(coarse_r_max-coarse_r_min);
       fine_seg_agree(i,video_no)=(fine_r-fine_r_min)/(fine_r_max-fine_r_min);
       allAvgDist(i,video_no)=AvgDist(splitPoint.the_coarse(j,1:sum(coarse_split)),splitPoint.the_fine(j,1:sum(fine_split)));
       allexpAvgDist(i,video_no)=exp_AvgDist(splitPoint.the_fine(j,1:sum(fine_split)));
   end
end
save('finalData\creaPoint.mat','creaPoint');
save('figure\data\creaPoint.mat','creaPoint');
save('finalData\coarse_seg_agree.mat','coarse_seg_agree');
save('figure\data\coarse_seg_agree.mat','coarse_seg_agree');
save('finalData\fine_seg_agree','fine_seg_agree');
save('figure\data\fine_seg_agree','fine_seg_agree');
save('finalData\allAvgDist','allAvgDist');
save('figure\data\allAvgDist','allAvgDist');
save('finalData\allexpAvgDist','allexpAvgDist');
save('figure\data\allexpAvgDist','allexpAvgDist');