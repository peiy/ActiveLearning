function [results, clustering, usedPairs] = pr_without_neighbor (nq, nps, flag1, flag2, trainData, testData, wholeData, datasetName, num)
    % nq: number of queries allowed to ask
    % flag1: a binary value that determines whether queries must be selected randomly or from based policy
    % flag2: MG for Gaussian Mixture, RF for random forest
    
    n = size (wholeData, 1); % number of examples in the dataset
    results = []; 
    nq_initial = nq;
    bcount=1;
    count=0;
    ucount = 0;
    conMat = eye(n);
    nPairs = []; 
    usedPairs = [];
    classNum = length(unique(wholeData(:,end)));

    % update the belief of ground truth
    [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData);

    
    if (isequal(flag2, 'MG') && ~isequal (flag1, 'RP'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag2, 'RF') && ~isequal (flag1, 'RP'))
        cpt = random_forest(wholeData(:, 1:end-1), clustering);
    end 
    %recordClustering (clustering, datasetName, flag1, flag2, nq_initial);    
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;      
    ['No contraints ', flag1,'-',flag2, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))] 
    
       % our sequential method
    while(nq>0)
        if(nq < nps); nps=nq; end        
        if(isequal(flag1,'RP'))
            % select #nps random pair(s)
            nPairs = random_pairs(conMat, testData, n, nps);
            nq = nq-nps;
        elseif(isequal(flag1,'BP1'))
            % find the most uncertain pair(s) to ask,
            nPairs = uncertain_pairs(cpt, nps, conMat, testData, n, datasetName, nq_initial, flag1, flag2, num);
            nq = nq-nps;
        elseif(isequal(flag1,'BAL'))
            % select nps pairs at once we should revise batch method to
            % make compatiable
            %nPairs = batch_active_learning (flag2, conMat, cpt, transitive_pairs, datasetName, testData, wholeData);
            %nq = nq-nps;
        elseif(isequal(flag1,'IM'))
            % select nps pairs using expected informativeness
            nPairs = informativeness (cpt, conMat, testData, n, datasetName, nq_initial, flag1, flag2, num);
            nq = nq-nps;
        elseif(isequal(flag1,'ET'))
            % select nps pairs using expected number of transitive clousure
            % with entropy
            nPairs = uncertain_closure (cpt, testData, n, conMat, 0.05, datasetName, nq_initial, flag1, flag2, num);
            nq = nq-nps;
        elseif(isequal(flag1,'IT'))
            % select nps paris using expected number of transtive closure
            % with informativeness
            nPairs = info_closure (cpt, testData, n, conMat, 0.05, datasetName, nq_initial, flag1, flag2, num);
            nq = nq-nps;
        end
        
        usedPairs(ucount+1:ucount+nps,:) = nPairs;
        ucount = ucount + nps;
        
        % find the pair-wise relation of those(pair(s)) by asking user/data-set
        relations = oracle(nPairs, wholeData);
        % updating conMat
        conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = relations;
        conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = relations;       
        
        count = count+nps;
        bcount = bcount+1;
        
        % update the belief of ground truth
        [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);

        %clustering
        %Tlabels
        %testData
        
        if (isequal(flag2, 'MG') && ~isequal (flag1, 'RP'))
            cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
        elseif(isequal(flag2, 'RF') && ~isequal (flag1, 'RP'))
            cpt = random_forest(wholeData(:, 1:end-1), clustering);
        end 
        %recordClustering (clustering, datasetName, flag1, flag2, nq_initial);
        
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
        results(bcount,3) = accuracy(wholeData(:, end), clustering);
        results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
        results(bcount,5) = f1(wholeData(:, end)', clustering');
        results(bcount,6) = count;       
            
        [flag1,'-',flag2, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]
    end
    relations = oracle(usedPairs, wholeData);
    cd results;
    cd (datasetName);
    fileName = [datasetName, '-pr-without-neighbor-', flag1,'-',flag2,'-',num2str(nq_initial), '-', num2str(nps),'.data'];
    dlmwrite(fileName,results,'-append');
    visualName = [datasetName, '-pr-without-neighbor-', flag1,'-',flag2,'-',num2str(nq_initial), '-', num2str(nps), '-constraints.data'];
    dlmwrite(visualName, [usedPairs, relations], '-append');
    cd ..;
    cd ..;

