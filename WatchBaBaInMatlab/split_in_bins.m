function Split_bin = split_in_bins(splitpoint,te)
% calculate the split result in 1-sec bins

Split_bin = zeros(1,ceil(te));
Split_bin(ceil(splitpoint(splitpoint>0)))=1;

end

