function [ im_udder,bw_udder,x_udder,y_udder,udder_area,rotate_angle,rot,headdir] = get_keyRegion( im,bw,xflow,yflow,pigletlength )
% get key region/udder 
%input:
% im: the rgb image
% bw: the segmentation result
% xflow: the x_optical flow
% yflow: the y_optical flow
% pigletlength : the length of the piglets
%output:
%im_udder,bw_udder,x_udder,y_udder: the image of the udder zone
%udder_area: the coordinates of the udder
%rotate_angle: the rotated angle
%rot: whether the udder pointing to down or up
%headdir: the direction of the head, 1 for right, 0 for left


udder_area=[];
original_bw = bw;
sow_bw = get_sow_bw(bw);
erode_bw = sow_bw;
se = strel('disk',15);  
erode_bw = imerode(erode_bw,se);
erode_bw = remove_smallobject(erode_bw);
bw = imdilate(erode_bw,se);

[r, c]=find(bw==255);
[rectx,recty,area,perimeter] = minboundrect(c,r,'a');

[img1,newrectx,newrecty] = ImageDrawRectangle(bw, rectx, recty);
y = newrecty(2)-newrecty(1);
x = newrectx(2)-newrectx(1);
rotate_angle1 = y/x;
angle1 = atan(rotate_angle1)*180/pi; 
rotateimage = imrotate(im, angle1); 
rotatebw = imrotate(bw, angle1);
rotateflow = imrotate(xflow,angle1);
yrotateflow = imrotate(yflow,angle1);
rotate_original_bw = imrotate(original_bw,angle1);
headrate = 1/3;
s = regionprops(rotatebw , 'centroid');
cd=s(255);
centroid = cd.Centroid;
[r,c]=find(rotatebw ~=0);
rmin = min(r);
cmin = min(c);
rmax = max(r);
cmax = max(c);
sowlen = cmax-cmin;
sowwidth = round(rmax-rmin);
left = centroid(1)-cmin;
right = cmax-centroid(1);
cuthead = headrate*sowlen-15;
cuttail = 0;
bodyrectlen = round(sowlen-cuthead-cuttail);
if left>right 
    bodyrectx = round(cmin+cuthead);
    headdir = 1;
else
    bodyrectx = round(cmin+cuttail);
    headdir = 0;
end
bodyrecty = rmin;

midx = bodyrectx;
midy = rmin+(rmax-rmin)/2;
body = round([bodyrectx,bodyrecty]);
mid = round([midx,midy]);
[flag,top_bottom]=com_avggray(angle1,rotatebw,rotateimage,body,mid,bodyrectlen,sowwidth);
fubuminy = top_bottom(2);
fubumaxy = top_bottom(4);
fubuminx = top_bottom(1);
fubumaxx = top_bottom(3);

if flag == 0
    fubunewrectx = fubuminx;
    fubunewrecty = fubuminy;
    newrectwidth = fubumaxx -fubuminx;
    newrectheight = fubumaxy-centroid(2)+pigletlength;
else 
    fubunewrectx = fubuminx;
    fubunewrecty = fubuminy-pigletlength;
    newrectwidth = fubumaxx -fubuminx;
    newrectheight = fubumaxy - fubunewrecty;
end

udder_area = [fubunewrectx,fubunewrecty,newrectwidth,newrectheight];
[colorfubu]=imcrop(rotateimage,udder_area);
[xflowfubu]=imcrop(rotateflow,udder_area);
[bwfubu]=imcrop(rotate_original_bw,udder_area);
[yflowfubu]=imcrop(yrotateflow,udder_area);

if flag==1
    colorfubu = imrotate(colorfubu,pi*180/pi);
    bwfubu = imrotate(bwfubu,pi*180/pi);
    xflowfubu = imrotate(xflowfubu,pi*180/pi);
    yflowfubu = imrotate(yflowfubu,pi*180/pi);
end
im_udder = colorfubu;
bw_udder = bwfubu;
x_udder = xflowfubu;
y_udder = yflowfubu;
rotate_angle = angle1;
rot = flag;

end

function sow_bw = get_sow_bw(bw)
[r,c]=find(bw<255);
ind = sub2ind(size(bw),r,c);
bw(ind)=0;
sow_bw = bw;
end

function processed_bw = remove_smallobject(bw)
processed_bw = uint8(zeros(size(bw)));
[L, num] = bwlabel(bw);

if num>0
    max_area = 0;
    final_label = 0;
    for i = 1:num
    [r,c]=find(L==i);
    area = length(r);
    if max_area<area
        max_area = area;
        final_label = i;
    end
    end
    [r,c]=find(L==final_label);
    ind = sub2ind(size(L),r,c);
    processed_bw(ind)=255;
else
    processed_bw = bw;
    
end


end

