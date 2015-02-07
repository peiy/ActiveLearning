function [accuracy, labeling] = accuracy(labels, clustering)
    % labels: the true labels for the data
    % clustering: our clustering result (I turn this clustering to labeling result based on 
    %             majority vote in each cluster.
    % n: number of datapoints in the cluster.
    % c: the number of clusters.
    %
    % accuracy: the percentage of currectly labeled samples over all samples
    
    c = length (unique (labels));
    n = length (clustering);
    labeling = zeros(n,1);
    for k = 1:c;
        Ck = (clustering==k);
        Ck_labels = labels(Ck);
        s = size(Ck_labels,1);
        [v, label] = max(sum((repmat(Ck_labels,1,c) == repmat(1:c,s,1)),1));
        labeling(Ck) = label;
    end
    
    accuracy = sum(labeling == labels)/n;
end
