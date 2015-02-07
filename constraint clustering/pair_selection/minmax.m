function [neighborhood, selectPairs] = minmax (neighborhood, nq, data, pairs)
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RANDOM select a point x not in exsiting neighborhoods    
    %randomPoints = ceil(length(data) * rand(1));
    %while find(neighborPoints == randomPoints)
    %     randomPoints = ceil(length(data) * rand(1));
    %end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %min-max
    %for all xi not in the neighbor
    freePoints = setdiff (1:length(data), neighborPoints);
    %compute largest similarities P(Xs,xi) =  max sij
    sigma=1;
    PXx = zeros (size(freePoints));
    for i = 1:length(freePoints)
        freePointMatrix = repmat (data(freePoints(i), 1:end-1), length(neighborPoints), 1);
        diffMatrix = freePointMatrix - data(neighborPoints, 1:end-1);
        distanceDistribution = sum(diffMatrix.*diffMatrix, 2);
        %Gaussian kernel width is set to the 20th percentile of the distribution
        distance = min(distanceDistribution);
        %max sij means min ||xi-xj||^2
        PXx(i) = exp(-(distance/(2*sigma*sigma)));        
    end
    [~, argminIdx] = min(PXx);
    randomPoints = freePoints(argminIdx);    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

