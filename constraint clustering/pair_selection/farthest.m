function fPoint = farthest (NeighborPoints, candidatePts, data)
traveseSet = data(NeighborPoints, 1:end-1);
candidateData = data (candidatePts, :);
[a,b] = size(candidateData);
[c,d] = size(traveseSet);
eculiDis = zeros(1,a);
for i = 1:a
    point = repmat (candidateData(i, 1:end-1), c ,1);
    dif = traveseSet - point;
    Dis = sum(dif.*dif,2);
    eculiDis(i) = min(Dis); 
end

[~,fPoint] = max(eculiDis);
fPoint = candidatePts (fPoint);
end