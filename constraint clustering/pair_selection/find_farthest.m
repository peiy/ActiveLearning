function fPoint = find_farthest (NeighborPoints, data)
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

[~,fPoint] = max(eculiDis);

end
