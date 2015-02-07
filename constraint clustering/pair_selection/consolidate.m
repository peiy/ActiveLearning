function [neighborhood, selectPairs] = consolidate (neighborhood, nq, data, pairs)
classNum = length(unique(data(:,end)));
neighborCentroids = zeros(classNum, size(data,2) -1);
neighborPoints = [];
while nq > 0
    neighborPoints = [];
    for i = 1:classNum
        neighborPoints (end+1: end+length(neighborhood{i})) = neighborhood{i};
    end
    if (length(neighborPoints) == length(data))
        break;
    end
    % estimate centroids for each neighborhood
    for i = 1:classNum
        neighborCentroids(i,:) = mean (data(neighborhood{i}, 1:end-1), 1);
    end
    % random select a point x not in exsiting neighborhoods    
    randomPoints = randi (length(data), 1, 1);
    while find(neighborPoints == randomPoints)
         randomPoints = randi (length(data), 1, 1);
    end
    % sort the distances between point and centroids
    point = repmat (data(randomPoints, 1:end-1), classNum, 1);
    diff = point - neighborCentroids;
    dis = diag(diff * diff');
    [~,index] = sort(dis,1,'ascend');
    for j = 1:length(index)
        flag = data(neighborhood{index(j)}(1), end) == data(randomPoints,end);
        nq = nq-1; 
        if flag == 0
            flag = flag -1;
        end
        pairs (end+1,:) = [(neighborhood{index(j)}(1)), (randomPoints), flag];
        if flag == 1
            neighborhood{index(j)}(end+1) = randomPoints;
            break;
        end
        if nq == 0
            break;
        end
    end
end
selectPairs = pairs;
end

