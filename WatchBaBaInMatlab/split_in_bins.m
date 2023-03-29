function Split_bin = split_in_bins(splitpoint,te)
% calculate the split result in 1-sec bins

Split_bin = zeros(1,ceil(te));
num_sp=sum(double(splitpoint>0)); % num of the splited points
num_bins=0; % num of the bin that have been used
for i=1:num_sp
    while splitpoint(i)>num_bins+1
        num_bins=num_bins+1;
    end
    Split_bin(num_bins+1)=Split_bin(num_bins+1)+1;
end

end

