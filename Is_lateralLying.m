function [ ly_flag] = Is_lateralLying(bwpath,areath,pwlth )
% areath = 30000;
% pwlth = 2.5;
% bwpath = 'F:\exp4\data\';
ly_flag = [];
side_ly=[];
Files = dir(strcat(bwpath,'*.png'));
vd_num = 0;
k = 0;
for i = 1:length(Files)
    k = k+1;
    sowbw = imread(strcat(bwpath,Files(i).name));
    sowbw = post_process(sowbw);
    imwrite(sowbw,[bwpath,Files(i).name]);
    [r, c]=find(sowbw==255);  
    [rectx,recty,area,perimeter] = minboundrect(c,r,'a');
    [img1,newrectx,newrecty] = ImageDrawRectangle(sowbw, rectx, recty);
    s = length(r);
    A1 = [newrectx(1),newrecty(1)];
    A2 = [newrectx(2),newrecty(2)];
    A3 = [newrectx(3),newrecty(3)];
    dist12 = norm(A2-A1);
    dist23 = norm(A2-A3);
    pwl = dist12/dist23;
    if s>=areath && pwl<=pwlth
     side_ly(k)=1;
    else
     side_ly(k)=0;   
    end 
    if k ==150 || i == length(Files)
        vd_num = vd_num+1;
        if sum(side_ly)>=length(side_ly)/2
            ly_flag(vd_num) = 1;
        else
            ly_flag(vd_num) = 0;
        end
        k = 0;
        side_ly = [];
    end
end
end

