function [neighbor, j, consPair] = new_explore (nq, train, test, wholeData, datasetName)
classNum = length(unique(wholeData(:,end)));
consPair = [];
data = wholeData(train,:);
neighbor = [];
generateEnsembelArff (data (:, 1:end-1), data (:, end), datasetName, 2);
conMat = eye (size(data, 1));
while length(neighbor) < classNum && nq > 0
    neighborPts = [];
    for i = 1:length(neighbor)
        neighborPts(end+1:end+length(neighbor{i})) = neighbor{i};
    end
    if isempty (neighbor) || length(neighborPts) == 1
        [cluster, cluster_size, centroids, IDX] = MPCKmeans ([datasetName, '-train'], data);                
    else
        [cluster, cluster_size, centroids, IDX] = MPCKmeans ([datasetName, '-train'], data, conMat);                
    end
    clusterNum = length(cluster);
    ClosestPt = zeros (clusterNum, 1);
    for i = 1:clusterNum
        ClosestPt(i) = closest_point (i, IDX, centroids, data);
    end
    if isempty(neighbor)
        temp = randi (classNum, 1, 1);
        neighbor{1}(1) = ClosestPt(temp);
    else
        farthest_center_point = farthest (neighborPts, ClosestPt, data);
        while find (farthest_center_point == neighborPts)
            farthest_center_point = find_farthest (neighborPts, data);
        end
        flag = -1;
        ijk = 1;
        % query this point with all existing neighborhoods according to the
        % distance between this point and the neighborhood
        neighborCentroids = zeros (length(neighbor), size(data,2)-1);
        for i = 1:length(neighbor)
            neighborCentroids(i,:) = mean (data(neighbor{i}, 1:end-1), 1);
        end
        point = repmat (data(farthest_center_point, 1:end-1), length(neighbor), 1);
        diff = point - neighborCentroids;
        dis = diag(diff * diff');
        [~,index] = sort(dis,1,'ascend');
        
        
        while (flag == -1 && ijk <= length(neighbor))
            flag = (data (neighbor{index(ijk)}(1), end) == data (farthest_center_point, end));
            if flag == 0
                consPair (end+1, :) = [train(neighbor{index(ijk)}(1)), train(farthest_center_point), -1];
                conMat (neighbor{index(ijk)}(1), farthest_center_point) = -1;
                conMat (farthest_center_point, neighbor{index(ijk)}(1)) = -1;
            else
                consPair (end+1, :) = [train(neighbor{index(ijk)}(1)), train(farthest_center_point), 1];
                conMat (neighbor{index(ijk)}(1), farthest_center_point) = 1;
                conMat (farthest_center_point, neighbor{index(ijk)}(1)) = 1;
            end
            nq = nq-1;
            if flag == 0 % cannot link to 1st neighborhood, continue to query other neighborhoods
                flag = flag - 1;
                ijk = ijk + 1;
                if ijk > length(neighbor)
                    neighbor{end+1}(1) = farthest_center_point;                
                    break; % or flag = 0;
                end
            elseif flag == 1 % must link to 1st neighborhood, update first neighborhood
                neighbor{index(ijk)}(end+1) = farthest_center_point;
                neighborPts = [neighborPts, farthest_center_point];
            end
        end
    end   
end
j = nq;
end
