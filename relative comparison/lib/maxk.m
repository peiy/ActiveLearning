function [m,n] = maxk (a, b)
[x,y] = sort(a, 'descend');
m=x(1:b);
n=y(1:b);
end