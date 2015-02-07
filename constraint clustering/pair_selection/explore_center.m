function [neighbor, j, consPair] = explore_center (nq, train, test, wholeData)
classNum = length(unique(wholeData(:,end)));
neighbor = [];
consPair = [];
data = wholeData(train,:);
[IDX, centroids] = kmeans(data(:, 1:end-1), classNum);
startCluster = randi(classNum, 1, 1);
startPt = closest_point (startCluster, IDX, centroids, data); % find start point in training data
neighbor{1}(1) = startPt;
while (length(neighbor) < classNum)
    neighborPts = [];
    for i = 1:length(neighbor)
        neighborPts(end+1:end+length(neighbor{i})) = neighbor{i};
    end
    ClosestPt = zeros (classNum, 1);
    for i = 1:classNum
        ClosestPt(i) = closest_point (i, IDX, centroids, data);
    end
    farthest_center_point = farthest (neighborPts, ClosestPt, data); % index in train data
    while find (farthest_center_point == neighborPts)
        farthest_center_point = randi (length(data), 1, 1);
    end
    flag = -1;
    neighIndex = 1;
    while (flag == -1 && neighIndex <= length(neighbor))
    %Query this farthest point to every neighborhood
        flag = (data (neighbor{neighIndex}(1), end) == data (farthest_center_point, end));
        if flag == 0
            consPair (end+1, :) = [train(neighbor{neighIndex}(1)), train(farthest_center_point), -1];
        else
            consPair (end+1, :) = [train(neighbor{neighIndex}(1)), train(farthest_center_point), 1];
        end

        nq = nq-1;
        if flag == 0 % cannot link to 1st neighborhood, continue to query other neighborhoods
            flag = flag - 1;
            neighIndex = neighIndex + 1;
            if neighIndex > length(neighbor)
                neighbor{end+1}(1) = farthest_center_point;                
                break; % or flag = 0;
            end
        elseif flag == 1 % must link to 1st neighborhood, update first neighborhood
            neighbor{neighIndex}(end+1) = farthest_center_point;
            neighborPts = [neighborPts, farthest_center_point];
        end
       
    end
    if flag == 1 % must link, do kmeans again using exsiting neighborhoods to estimate the initial cluster center.
        % estimate initial centroids using exsiting neighborhoods
        initial_centroids = zeros (classNum, size(data, 2) - 1);
        for i = 1:length(neighbor)
            initial_centroids(i, :) = sum(data(neighbor{i}, 1:end-1), 1) / length(neighbor{i});
        end
        % randomly select rest initial centroids
        i = i + 1;
        
        previous_center_index = [];
        while i <= classNum 
            randomPtsPool = setdiff (1:size(data, 1), neighborPts);
            initial_centroids_index = randi (length(randomPtsPool), 1, 1);
            initial_centroids_index = randomPtsPool(initial_centroids_index);
            while (~isempty(find (initial_centroids_index == neighborPts))) || (~isempty(find (previous_center_index == initial_centroids_index)))
                initial_centroids_index = randi (length(randomPtsPool), 1, 1);
                initial_centroids_index = randomPtsPool(initial_centroids_index);
            end
            previous_center_index (end+1) = initial_centroids_index;
            initial_centroids(i, :) = data (initial_centroids_index, 1:end-1);
            i = i + 1;
        end

        [IDX, centroids] = kmeans(data(:, 1:end-1), classNum, 'start', initial_centroids);
        
        
    end
    
    
    
    
end
j = nq;

end
