function [cluster, cluster_size, centroids, clustering] = getResult (datasetName, rawData)
    result = load ([datasetName, 'Result.data']);
    classNum = length (unique(rawData(:,end)));    
    cluster = cell (1,classNum);
    centroids = zeros(classNum, 1);
    c = result (:, 2);
    if (find(c==0))
        c=c+1;
    end
    for i = 1:length (unique(c));
        cluster {i} = find(c==i);
    end
    clustering = c;
    table = tabulate (c);
    cluster_size = transpose(table (:,2,:));
    for i = 1:classNum
        centroids(i, :) = mean(rawData(c==i,1:end-1));
    end
end
