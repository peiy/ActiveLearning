function [uncertainPoint, nPairs] = uncertain_point_without_neighbor(cpt, nps, train, test, rawData, n, flag2, flag3, conMat, cluster, centroids)
nPairs = [];
classNum = length(unique(rawData(:,end)));
% find the most uncertain point
cpt (cpt==0) = 1;
entropy = sum (-cpt.*log2(cpt), 2);
entropy(test) = -1;
rn = randperm (n);
entropy = entropy (rn);
[~, p] = maxk(entropy, nps);
uncertainPoint = rn(p);
% find cluster of the other query point in the constraint pair
if (isequal (flag2, 'NP'))
    if size(centroids, 1) == classNum
        distance = sum ((centroids - repmat(rawData (uncertainPoint, 1:end-1), classNum, 1)).^2, 2);
        [~, index] = sort (distance, 'ascend');
        selectedCluster = index(1);    
    else
        selectedCluster = ceil(rand (1)*size(centroids, 1));
    end
elseif (isequal (flag2, 'MC'))
    clusterProb = cpt (uncertainPoint, :);
    [~, index] = sort (clusterProb, 'descend');
    selectedCluster = index(1);
end
existFlag = 1;
i = 1;
while (existFlag == 1 && i <= length(cluster{selectedCluster}))
    if (isequal (flag3, 'NP'))
        clusterPoint = rawData (cluster{selectedCluster}, 1:end-1);
        distance = sum ((clusterPoint - repmat (centroids (selectedCluster, :), size(clusterPoint, 1), 1)).^2, 2);
        [~, index] = sort (distance);
        anotherPoint = cluster{selectedCluster}(index(i));
    elseif (isequal (flag3, 'MC'))
        clusterCPT = cpt (cluster{selectedCluster}, selectedCluster);
        [~, index] = sort (clusterCPT, 'descend');
        anotherPoint = cluster{selectedCluster}(index(i));
    end
    if conMat (uncertainPoint, anotherPoint) == 0
        existFlag = 0;
    else
        i = i + 1;
    end
end

while existFlag == 1
    anotherPoint = ceil (rand(1) * n);
    if conMat (uncertainPoint, anotherPoint) == 0
       existFlag = 0;
    end
end

value = (rawData (uncertainPoint, end) == rawData (anotherPoint, end));
if value == 0
    value = value - 1;
end
nPairs = [uncertainPoint, anotherPoint, value];
end






