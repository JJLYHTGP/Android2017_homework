I = imread('E13.jpg');
[row,col,dim]=size(I);
if(dim>1)
    I=rgb2gray(I);
end
imshow(I);
title('原图');
src= ootsu(I,row,col);%%用得到的阈值直接对图像进行二值化
[dst4,dst2]=trs(src);
% figure;
% imshow(dst2);
% title('仿射变换');
figure;
imshow(dst4);
title('双线性变换');

dst5=~dst4;
element1=strel('square',3);
element2=strel('disk',25);

Iopen=imopen(dst5,element1);
Iclose=imclose(Iopen,element2);
% figure;imshow(Iclose);
% title('开闭运算的图像');
%投影定位
dst6=projectLocation2(Iclose,dst4);
figure;imshow(dst6);
title('投影定位后截取的图像');


dst7=~dst6;%白1 黑0
%获取条空的宽度 
[m,n]=size(dst7);
number=0;
ii=1;

% total_len=zeros(m,60);
for i=round(0.05*m):round(0.75*m)
    k1=1;    width_idx=1;
    for j=1:n-1
        if dst7(i,j) ~= dst7(i,j+1)
            pos(ii,k1)=j;
            if k1>1
                width(ii,width_idx)=pos(ii,k1)-pos(ii,k1-1);
                width_idx=width_idx+1;
%             elseif k1 == 1
%                 width(ii,width_idx)=pos(ii,k1);
%                 width_idx=width_idx+1;
             end
            k1=k1+1;
        end
    end
%     width(ii,width_idx)=n-pos(ii,k1-1);

   if width_idx==60
       width(ii,60)=2333;
   end
   ii=ii+1;
end

[mm]=size(width,1);
ii=1;
for i= 1:mm
    if(width(i,60)==2333)
        width2(ii,1:59)=width(i,1:59);
        ii=ii+1;
    end
end

%获取单位模块的宽度
mm=size(width2,1);
nn=59;
final_width=zeros(1,nn);

for i=1:nn
    tmp=0;
    for k=1:mm
        tmp=tmp+width2(k,i); %该宽度的所有值求和
    end
     final_width(1,i)=tmp/mm;    %求均值
end
final_width2=sum(final_width,2)/95;

%获取条空的比例
%由条/宽的宽度除以单位模块宽度，即可求得条/宽的比例。
final_width3=round(final_width/final_width2);

%通过查找 进行译码
k=1;
for i=1:59
   if rem(i,2)
       for j=1:final_width3(i)
        bar_01(k)=1; 
        k=k+1;
       end
   else
       for j=1:final_width3(i)
        bar_01(k)=0; 
        k=k+1;
       end
   end
end

isCheck=0;
if(bar_01(1,1)==1&&bar_01(1,2)==0&&bar_01(1,3)==1&&bar_01(1,46)==0&&bar_01(1,47)==1&&bar_01(1,48)==0&&bar_01(1,49)==1&&bar_01(1,50)==0&&bar_01(1,93)==1&&bar_01(1,94)==0&&bar_01(1,95)==1)
  isCheck=1;
end
if isCheck==0
    msgbox('不满足EAN-13码的条件！');  %不满足则弹出msg框，同时终止程序
     return
end


j=1;
for i=4:7:39
    left(1,j)=bin2dec(num2str(bar_01(1:1,i:i+6)));
    j=j+1;
end
k=1;
for i=51:7:86
    right(1,k)=bin2dec(num2str(bar_01(1:1,i:i+6)));
    k=k+1; 
end

checkLeft=[13,25,19,61,35,49,47,59,55,11,39,51,27,33,29,57,5,17,9,23];
checkRight=[114,102,108,66,92,78,80,68,72,116];
firstNum=[31,20,18,17,12,6,3,10,9,5];
num_bar='';num_bar2='';
AB_check='';
%以下求得左边序列以及AB序列
for i=1:6
    for j=0:19
        if left(i)==checkLeft(j+1)
            if j>9
                AB_check=strcat(AB_check,'B');
            else
                AB_check=strcat(AB_check,'A');
            end
            num_bar=strcat(num_bar,num2str(mod(j,10)));
        end
    end
end
%以下根据Map得到对应的前置位
preMap = containers.Map({'AAAAAA','AABABB','AABBAB','AABBBA','ABAABB','ABBAAB','ABBBAA','ABABAB','ABABBA','ABBABA'},{'0','1','2','3','4','5','6','7','8','9'});
pre=preMap(AB_check); 
num_bar=strcat(pre,num_bar);
%以下求得右边序列以及AB序列
for i=1:6
    for j=0:9
        if right(i)==checkRight(j+1)
            num_bar2=strcat(num_bar2,num2str(mod(j,10)));
        end
    end
end
num_bar=strcat(num_bar,num_bar2);


%检查校验位是否正确
oddSum=0;evenSum=0;
for i=1:12
    if mod(i,2)==1
       oddSum=oddSum+str2num(num_bar(i));
    else
       evenSum=evenSum+str2num(num_bar(i));
    end
end

c=oddSum+3*evenSum; 
if mod(c,10)==0
    checkBit=0;
else
    checkBit=10-mod(c,10);
end
%如果checkBit和13位的最后一位相等，则识别正确，输出译码结果，否则错误。弹出相应信息

if num2str(checkBit)==num_bar(13)
    disp(num_bar);
%      msgbox('Correct');
else
    msgbox('Failed');
end
