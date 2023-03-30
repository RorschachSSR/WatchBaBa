function video_no = find_video_no(videodir,videoname)

for i =1 : length(videodir)
    if([videodir(i).folder,'\',videodir(i).name]==videoname)
        video_no=i;
        break;
    end
end

