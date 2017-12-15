function [dst4,dst2]=trs(src2)
src=~src2;
[row,col]=size(src);
element1=strel('square',3);
element2=strel('disk',25);
im1=imopen(src,element1);
im2=imclose(im1,element2);
im3=imdilate(im2,element1);
im4=im3-im2;
[Hr1,Hc1]=Hough1(im4);
H=Hough2(im4);
line1(1:2,:)=lineseek(Hr1,2);
line1(3:4,:)=lineseek(Hc1,2);
line1(1:2,2)=line1(1:2,2)-46;
line1(3:4,2)=line1(3:4,2)+44;
line1(:,1)=line1(:,1)-(row+col);
% figure;
% imshow(src2);
% hold on;
% for i=1:4
%     if (i<3)
%         line([0,col],[line1(i,1),line1(i,1)+tan((line1(i,2)*pi)/180)*col],'color','red');
%     else
%         line([line1(i,1),line1(i,1)+row/tan((line1(i,2)*pi)/180)],[0,row],'color','red');
%     end
% end

%极坐标
line2(1:2,:)=lineseek(H(:,1:90),2);
line2(3:4,:)=lineseek(H(:,91:end),2);
line2(3:4,2)=line2(3:4,2)+90;
line2(:,1)=line2(:,1)-round(sqrt(row^2+col^2));
%  figure;
%  imshow(src2);
%  hold on;
%  for i=1:4
%     if (i<3)
%         line([0,col],[line2(i,1)/sin((line2(i,2)*pi)/180),(line2(i,1)-col*cos((line2(i,2)*pi)/180))/sin((line2(i,2)*pi)/180)],'color','blue');
%     else
%         line([line2(i,1)/cos((line2(i,2)*pi)/180),(line2(i,1)-row*sin((line2(i,2)*pi)/180))/cos((line2(i,2)*pi)/180)],[0,row],'color','blue');
%     end
% end


point=drpoint(line2);
[point,point2,rotflag]=p2p(point);
[dst2]=affinty(src2,point,point2,rotflag);
[dst4]=bilinear3(src2,point,point2,rotflag);
%  figure;
%  imshow(dst4);
end
