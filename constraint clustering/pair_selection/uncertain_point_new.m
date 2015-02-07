function [uncertainPoint, nPairs, neighbor, nq] = uncertain_point_new(cpt, nq, neighbor, train, test, rawData, n, flag2)
% in this function, neighor index is for all data
nPairs = [];
data = rawData(train, :);
classNum = length(unique(rawData(:,end)));
NeighborPoints = [];
neighborNum = length (neighbor);
for i = 1:neighborNum
    NeighborPoints (end+1: end+length(neighbor{i})) = neighbor{i};
end
if isequal(flag2, 'EN')
    cpt (cpt==0) = 1;
    entropy = sum (-cpt.*log2(cpt), 2);
    entropy(NeighborPoints) = -1;
    entropy(test) = -1;
    rn = randperm (n);
    entropy = entropy (rn);
    [~, p] = max (entropy);
    uncertainPoint = rn(p);
end

for i = 1:neighborNum
    neighborCentroids(i,:) = mean (rawData(neighbor{i}, 1:end-1), 1);
end

point = repmat (rawData(uncertainPoint, 1:end-1), neighborNum, 1);
diff = point - neighborCentroids;
dis = diag(diff * diff');
[~,index] = sort(dis,1,'ascend');

for i = 1:neighborNum
    flag = rawData(neighbor{index(i)}(1), end) == rawData(uncertainPoint,end);
    nq = nq - 1;
    if flag == 0
        flag = flag -1;
    end
    nPairs (end+1, :) = [neighbor{index(i)}(1), uncertainPoint, flag];
    if flag == 1
        neighbor{index(i)}(end+1) = uncertainPoint;
        break;
    end
    if nq == 0
        break;
    end
end

if isempty(find (nPairs(:, end) == 1))
    neighbor{end+1}(1) = uncertainPoint;
end



end


