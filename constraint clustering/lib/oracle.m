function pairwise_relations = oracle(pairs, rawData)
    % labels: the given label for our data-set
    % pairs: the list of data-pairs we are interested to find their relations
    %
    % pairwise_relations: contains a list of mustlink(+1) and cannotlink(-1) relations assigned to 
    %                     different pairs in the datapair-list
    %
    % Given set of labels, and a data-pair set, This function would return the pairwise relation
    % that those pairs should have based on the given labels.
    labels = rawData(:,end);
    
    L1 = labels(pairs(:,1));
    L2 = labels(pairs(:,2));
    
    ML = (L1==L2);

    pairwise_relations = -1 * ones(size(pairs,1),1);
    pairwise_relations(ML) = 1;
end

