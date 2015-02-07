function [uncertainPoint,nPairs, neighbor] = uncertain_point_with_neighbor(cpt, nps, neighbor, train, test, rawData, n, flag2, conMat, cluster)
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

if isequal (flag2, 'EN')
    cpt (cpt==0) = 1;
    entropy = sum (-cpt.*log2(cpt), 2);
    entropy(NeighborPoints) = -1;
    entropy(test) = -1;
    rn = randperm (n);
    entropy = entropy (rn);
    [~, p] = maxk(entropy, nps);
    uncertainPoint = rn(p);
end


for i = 1:classNum
    neighborCentroids(i,:) = mean (data(neighbor{i}, 1:end-1), 1);
end
 
point = repmat (rawData(uncertainPoint, 1:end-1), classNum, 1);
diff = point - neighborCentroids;
dis = diag(diff * diff');
[~,index] = sort(dis,1,'ascend');

% query this most certain point
for i = 1:length(index)
    while conMat (uncertainPoint, train(neighbor{index(i)}(1))) ~= 0
        i = i+1;
    end
    if i == length(index) + 1
        break;
    end
    flag = data(neighbor{index(i)}(1), end) == rawData(uncertainPoint,end);
    nps = nps - 1;
    if flag == 0
        flag = flag -1;
    end
    nPairs (end+1, :) = [train(neighbor{index(i)}(1)), uncertainPoint, flag];
    if flag == 1
        neighbor{index(i)}(end+1) = find (train == uncertainPoint);
    end
    if nps == 0
        break;
    end
end
end