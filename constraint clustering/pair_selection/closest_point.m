function cPtTrain = closest_point (clusterNum, IDX, centroids, trainData)
center = centroids (clusterNum, :);
cluster = find (IDX == clusterNum);
diff = trainData (cluster, 1:end-1) - repmat (center, length(cluster), 1);
distance = sum(diff.*diff, 2);
[~, cPtCluster] = min (distance);
cPtTrain = cluster(cPtCluster);
end
