function average_Dist = AvgDist(coarse_split,fine_split)
coarse_num = length(coarse_split);
sumDist = 0;
for i = 1:coarse_num
    Min = fine_split<coarse_split(i);
    Max = fine_split>=coarse_split(i);
    min_loca=find(Min);
    max_loca=find(Max);
    if sum(min_loca)~=0 && sum(max_loca)~=0
        sumDist = sumDist + min(coarse_split(i)-fine_split(min_loca(end)),fine_split(max_loca(1))-coarse_split(i));
    elseif sum(min_loca)==0
        sumDist = sumDist + fine_split(1)-coarse_split(i);
    elseif sum(max_loca)==0
        sumDist = sumDist + coarse_split(i)-fine_split(end);
    end
end
average_Dist=sumDist/coarse_num;
end

