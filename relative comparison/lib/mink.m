function [m,n] = mink (a, b)
[x,y] = sort(a);
m=x(1:b);
n=y(1:b);
end