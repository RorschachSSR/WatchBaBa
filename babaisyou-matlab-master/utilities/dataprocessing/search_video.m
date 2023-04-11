function video_exist = search_video(exp_date,name,chp,lvl)

label = table('Size',[15 5],'VariableTypes',{'double','string','double','double','double'},'VariableNames',{'exp_date','name','chp','lvl','idx'});
label.chp = 2*ones(15,1);
label.lvl = [ones(3,1);2*ones(3,1);3*ones(3,1);4*ones(3,1);5*ones(3,1)];
label.exp_date=[20220328;20220226;20220117;20220224;20220223;20220222;20220118;20220327;20220223;20220327;20220328;20220329;20220118;20220227;20220226];
label.name = ['ljy';'kyh';'lyx';'sxq';'lrn';'lmm';'clx';'zwx';'fsq';'zmy';'mqg';'ljl';'hbh';'wsy';'ljy'];
label.idx = repmat([1;2;3],5,1);

if ~any(((sum(label.name==name,2)==3)+(label.exp_date==exp_date)+(label.chp==chp)+(label.lvl==lvl))==4)
    video_exist= 0;
else
    video_exist = 1;
end

end

