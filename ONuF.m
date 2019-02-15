function [ features] = ONuF( udderpath, ly_ind,rotate_angle,pigletarea_th )
% get the features: ONuF
% input:
% udderpath: the key region path
% ly_ind:the index for the image
% isrotate_angle: the rotated angel
% pigletarea_th: the piglet area
% output: features including orentation_change frequency and occupation index

features = [];
consistant = 0;
frame_consistant = [];
dir_frame = [];
sam = 0;
fram_dir = [];
frame_consitant_inten = [];
features = [];
x_path = [udderpath,'x\'];
y_path = [udderpath,'y\'];
bw_path = [udderpath,'sg\'];
Files = dir(strcat(x_path,'*.png'));
occupation_indx = [];
t = 0;
if ly_ind<ceil(length(Files)/150)
    pic_num = ly_ind*150;
else
    pic_num = length(Files);
end
for i = 38:150%(ly_ind-1)*150+1:pic_num
    bw = imread(strcat(bw_path,Files(i).name));
    x_flow = imread(strcat(x_path,Files(i).name));
    y_flow = imread(strcat(y_path,Files(i).name));
    [rs,cs]=find(bw==128);
    inds = sub2ind(size(bw),rs,cs);
    bw(inds)=0;
    [roi_ind,roi_flag]= get_roi(bw);
    t = t+1;
    if roi_flag ==1
        
        [flow_inten, little_motion]= get_flow_inten(x_flow,y_flow,roi_ind);
        [ flow_dir] = get_flow_dir(x_flow,y_flow,little_motion);
        [roi_i,roi_j]=find(flow_dir~=400);
        dir_roi_ind = sub2ind(size(flow_dir),roi_i,roi_j);
        for u = 1:length(dir_roi_ind)
            flow_dir(dir_roi_ind(u))=flow_dir(dir_roi_ind(u))+rotate_angle(i);
            if flow_dir(dir_roi_ind(u))>360
                flow_dir(dir_roi_ind(u))=flow_dir(dir_roi_ind(u))-360;
            else if flow_dir(dir_roi_ind(u))<0
                    flow_dir(dir_roi_ind(u))=360+flow_dir(dir_roi_ind(u));
                end
            end
        end
        
        [pixels, initial_dir] = track_same_dir(flow_dir);
        pixel_intensity_dir(i) = sum(flow_inten([pixels{2};pixels{3};pixels{4};pixels{5}]));
        pixel_intensity_ver_dir(i) = sum(flow_inten([pixels{8};pixels{9};pixels{10};pixels{11}]));
        pixel_intensity_horizol(i) = sum(flow_inten([pixels{1};pixels{6};pixels{7};pixels{12}]));
        if initial_dir ==1
            temp = pixel_intensity_dir(i);
        else if initial_dir ==-1
                temp = pixel_intensity_ver_dir(i);
            else
                temp = pixel_intensity_horizol(i);
            end
        end
        
        fram_dir(i,:) = initial_dir;
        
        if sam ==0
            sam = sam+1;
            frame_consistant(sam)=1;
            frame_consitant_inten(sam) = temp;
        else
            if fram_dir(i-1,:) ~= initial_dir
                sam = sam +1;
                frame_consistant(sam)=1;
            else
                frame_consistant(sam)=frame_consistant(sam)+1;
            end
        end
        pixels = [];
        initial_dir = [];
        [indx,indy]=find(flow_inten~=0);
        occupation_indx(i) = length(indx)/pigletarea_th;
    else
       occupation_indx(i) = 0;
       occupation_indx(i) = 0;
    end
end
dir_var = var(frame_consistant);% orentation_change frequency
features(1,1) = dir_var; 
occupation_indx = sort(occupation_indx);
features(1,2) = occupation_indx(length(occupation_indx)/2);%occupation index

end

