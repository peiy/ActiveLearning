function [uncertainPoint,nPairs, neighbor, num] = uncertain_point_with_neighbor_multi(cpt, nps, neighbor, train, test, rawData, n, flag2, conMat, cluster)
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

if isequal(flag2, 'EN') || isequal (flag2, 'ENF')
    cpt (cpt==0) = 1;
    entropy = sum (-cpt.*log2(cpt), 2);
    entropy(NeighborPoints) = -1;
    entropy(test) = -1;
    rn = randperm (n);
    entropy = entropy (rn);
    [~, p] = maxk(entropy, nps);
    uncertainPoint = rn(p);
elseif isequal (flag2, 'MS')
    y = sort (cpt, 2, 'descend');
    margin = y(:,1) - y(:,2);
    margin (test) = 100;
    margin (NeighborPoints) = 100;
    rn = randperm (n);
    margin = margin (rn);
    [~, p] = min (margin);
    uncertainPoint = rn(p);
end

[~, max_cluster_index] = max (cpt(uncertainPoint, :));

cluster_max_points = cluster{max_cluster_index};

% given points in the cluster with maximal probably, we should find the
% neighbor it contains

neighbor_flag = zeros (1, classNum);

for i = 1:classNum
    if ~isempty (intersect (cluster_max_points, neighborRaw{i}))
        neighbor_flag(i) = 1;
    end
end

for i = 1:classNum
    neighborCentroids(i,:) = mean (data(neighbor{i}, 1:end-1), 1);
end

% if sum (neighbor_flag == 1) == 1
%     neighbor_index = (neighbor_flag == 1);
%     flag = data(neighbor{neighbor_index}(1), end) == rawData(uncertainPoint,end);
%     if flag == 0
%         flag = flag - 1;
%     end
%     nPairs (end+1, :) = [train(neighbor{neighbor_index}(1)), uncertainPoint, flag];
%     if flag == 1
%          neighbor{neighbor_index}(end+1) = find (train == uncertainPoint);
%     end
% else 
%     neighbor_index = (neighbor_flag == 1);
%     point = repmat (rawData(uncertainPoint, 1:end-1), classNum, 1);
%     diff = point - neighborCentroids;
%     dis = diag(diff * diff');
%     dis = dis (neighbor_index);
%     [~,index] = sort(dis,1,'ascend');
%     flag = data(neighbor{index(i)}(1), end) == rawData(uncertainPoint,end);
%     if flag == 0
%         flag = flag - 1;
%     end
%     nPairs (end+1, :) = [train(neighbor{index(i)}(1)), uncertainPoint, flag];
%     if flag == 1
%          neighbor{index(i)}(end+1) = find (train == uncertainPoint);
%     end
% end

 
point = repmat (rawData(uncertainPoint, 1:end-1), classNum, 1);
diff = point - neighborCentroids;
dis = diag(diff * diff');
[~,index] = sort(dis,1,'ascend');
num = 0;

for i = 1:length(index)
    while conMat (uncertainPoint, train(neighbor{index(i)}(1))) ~= 0
        i = i+1;
    end
    if i == length(index) + 1
        break;
    end
    flag = data(neighbor{index(i)}(1), end) == rawData(uncertainPoint,end);
    num = num+1;
    nps = nps - 1;
    if flag == 0
        flag = flag -1;
    end
    nPairs (end+1, :) = [train(neighbor{index(i)}(1)), uncertainPoint, flag];
    if flag == 1
        neighbor{index(i)}(end+1) = find (train == uncertainPoint);
        break;
    end
    
end
end
