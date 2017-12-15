function dst = projectLocation2(look_up_answer,src)
[m,n] = size(look_up_answer);
for y=1:n
    Sy(y)=sum(look_up_answer(1:m,y));
end
for y=1:n-1
    Sy(y)=0.7*Sy(y)+0.3*Sy(y+1);
end
for x=1:m
    Sx(x)=sum(look_up_answer(x,1:n));
end
for x=1:m-1
    Sx(x)=0.7*Sx(x)+0.3*Sx(x+1);
end
%figure,subplot(211),plot(Sy);
%subplot(212),plot(Sx);
Y =1:n;
X = find(Sx>mean(Sx));
dst = src(X,Y);
