% The key episode location in time domain using FEKE
function [episode_result] = Key_episodeLocation(mainpath,DNPmin, DNPmax, DMPmax)
% mainpath: the path of the flow data
% DNPmin: the low threshold of DNP
% DNPmax: the high threshold of DNP
% DMPmax: the high threshold of DMP
mainpath = 'F:\exp\data\flow\';
DNPmin=3000;
DNPmax=30000;
DMPmax= 80000000;
x_path = [mainpath,'\x\'];
y_path = [mainpath,'\y\'];
episode_frame = zeros(1,150);
Files = dir(strcat(x_path,'*.jpg'));
for i = 1:150 %length(Files)
    t = t+1;
    x = imread(strcat(x_path,Files(i).name));
    y = imread(strcat(y_path,Files(i).name));
    flow = sqrt((double(x)-128).^2 + (double(y)-128).^2);
    [m,n]=size(flow);
    [r,c]=find(flow>0);
    ind = sub2ind(size(flow),r,c);
    flow(ind)=0;
    bw_dist = ones(m,n);
    bw_dist(ind)=0;
    D = bwdist(bw_dist);
    DMP(t) = sum(sum(D));
    DNP(t) = find_np(flow);
    if  DMP(t)<DMPmax && DNP(t)>DNPmin && DNP(t)<DNPmax
        episode_frame(t)=1;
    end  
end
if sum(episode_frame)>75
    episode_result = 1;
else
    episode_result = 0;
end
end

function num_np = find_np(flow)
%counting the number of nursing pixels
num_np = 0;
[m,n]=size(flow);
for i = 1:m
    for j = 1:n
        if flow(i,j)>5 && flow(i,j)<30
          num_np = num_np+1;
        end
    end
end
end





