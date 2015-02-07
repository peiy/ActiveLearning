function [certainPoint, nPairs, neighbor, j] = certain_point_with_neighbor(cpt, nq, neighbor, train, test, rawData, n, flag2, conMat, cluster)
nPairs = [];
data = rawData(train, :);
classNum = length(unique(rawData(:,end)));
for i = 1:classNum
    neighborRaw{i} = train(neighbor{i});
end
NeighborPoints = [];
for i = 1:classNum
    NeighborPoints (end+1: end+length(neighborRaw{i})) = neighborRaw{i};
end

cpt (cpt==0) = 1;
entropy = sum (-cpt.*log2(cpt), 2);
entropy(NeighborPoints) = 100;
entropy(test) = 100;
rn = randperm (n);
entropy = entropy (rn);
[~, p] = min(entropy);
certainPoint = rn(p);




for i = 1:classNum
    neighborCentroids(i,:) = mean (data(neighbor{i}, 1:end-1), 1);
end

 
point = repmat (rawData(certainPoint, 1:end-1), classNum, 1);
diff = point - neighborCentroids;
dis = diag(diff * diff');
[~,index] = sort(dis,1,'ascend');
i = 1;

while nq>0 && i <=classNum
    flag = (rawData (neighborRaw{index(i)}(1), end) == rawData (certainPoint, end));
    nq = nq - 1;
    if flag == 0
        flag = flag - 1;
    end
    nPairs (end+1, :) = [neighborRaw{index(i)}(1), certainPoint, flag];
    if flag == 1
        neighbor{index(i)}(end+1) = find (train == certainPoint);
        break;
    end    
    i = i + 1;
end

j = nq;


end