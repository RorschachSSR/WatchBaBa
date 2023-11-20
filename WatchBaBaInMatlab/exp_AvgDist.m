function exp_averageDist = exp_AvgDist(fine_split)
exp_averageDist=0;
for i=1:length(fine_split)
    if i ==1
        exp_averageDist = exp_averageDist + 1/2*fine_split(i)^2;
    else
        exp_averageDist = exp_averageDist + 1/2*(fine_split(i)-fine_split(i-1))^2;
    end
end
exp_averageDist = exp_averageDist/fine_split(end);
end

