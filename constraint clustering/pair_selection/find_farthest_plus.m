function fPoint = find_farthest_plus (NeighborPoints, data)
traveseSet = data(NeighborPoints, 1:end-1);
[a,b] = size(data);
[c,d] = size(traveseSet);
eculiDis = zeros(1,a);
for i = 1:a
    point = repmat (data(i, 1:end-1), c ,1);
    dif = traveseSet - point;
    Dis = sum(dif.*dif,2);
    eculiDis(i) = min(Dis); 
end
Dx_square = eculiDis.*eculiDis;
Dx_square = Dx_square/sum(Dx_square);
for i = 1:length(Dx_square)
    cdf(i) = sum (Dx_square(1:i));
end
temp = rand(1);
for i = 1:length(cdf)
    if temp <= cdf(i)
        fPoint = i;
        break;
    end
end
end