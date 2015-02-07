function [results, clustering, usedPairs] = pr_with_neighbor (nq, flag1, flag2, trainData, testData, wholeData, datasetName, num, )
    % nq: number of queries allowed to ask
    % flag1: a binary value that determines whether queries must be selected randomly or from based policy
    % flag2: MG for Gaussian Mixture, RF for random forest
    classNum = length(unique(wholeData(:,end)));
    global nps;
    n = size (wholeData, 1); % number of examples in the dataset
    results = zeros(ceil(nq/nps)+1,6); %  [NMI, ACCURACY, F1, ElapsedTime, Query Size]
    nq_initial = nq;
    bcount=1;
    count=0;
    ucount = 0;
    conMat = eye(n);
    nPairs = []; 
    usedPairs = [];
    classNum = length(unique(wholeData(:,end)));

    % update the belief of ground truth
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -O ', datasetName, 'Result.data']; % do MPCKM on data set and output to clusterResult file
    dos (x);   
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
    cd ..;
    cd ..;
    
    recordClustering (clustering, datasetName, flag1, flag2, nq_initial);    
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
    results(bcount,6) = count;   
    ['No contraints ', flag1,'-',flag2, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))] 
    
    % Explore phase of data    
    if (~isequal(flag1,'RP'))
        [neighborhood, nq, consPair] = explorer (nq, trainData, testData, wholeData);
        for i = 1:classNum
            neighborhood{i}=trainData(neighborhood{i});
        end
        expConsNum = size (consPair, 1);
        usedPairs (ucount+1:ucount+expConsNum,:) = consPair(:, 1:2);
        ucount = ucount + expConsNum;
        for i = 1:expConsNum 
            conMat = eye(n);
            conMat((consPair(1:i,2)-1)*n + consPair(1:i,1)) = consPair(1:i,3);
            conMat((consPair(1:i,1)-1)*n + consPair(1:i,2)) = consPair(1:i,3);
            conMat = transitive_closure (conMat, consPair(1:i,1:2), n);
            creatContraintsFile (conMat, datasetName);
  
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
            dos (x);
            [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
            cd ..;
            cd ..;      
            recordClustering (clustering, datasetName, flag1, flag2, nq_initial);
            count = count+1;
            bcount = bcount+1;
            results(bcount,1) = nmi(wholeData(:, end), clustering);
            results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
            results(bcount,3) = accuracy(wholeData(:, end), clustering);
            results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
            results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
            results(bcount,6) = count;       
            ['Explorer ', num2str(i) ,'-' , flag1,'-',flag2, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))] 
        end
    end
    
    if (isequal(flag2, 'MG'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif(isequal(flag2, 'RF'))
        cpt = random_forest(wholeData(:, 1:end-1), clustering);
    end 
    
    % our sequential method
    while(nq>0)
        if(nq < nps); nps=nq; end        
        if(isequal(flag1,'RP'))
            % select #nps random pair(s)
            nPairs = random_pairs(conMat, testData, n);
            nq = nq-nps;
        elseif(isequal(flag1,'BP1'))
            % find the most uncertain pair(s) to ask,
            nPairs = uncertain_pairs(cpt, conMat, testData, n, datasetName, nq_initial, flag1, flag2, num, neighborhood, classNum);
            nq = nq-nps;
        elseif(isequal(flag1,'IM'))
            % select nps pairs using expected informativeness
            nPairs = informativeness (cpt, conMat, testData, n, datasetName, nq_initial, flag1, flag2, num, neighborhood, classNum);
            nq = nq-nps;
        end
        
        usedPairs(ucount+1:ucount+nps,:) = nPairs;
        ucount = ucount + nps;
        
        % find the pair-wise relation of those(pair(s)) by asking user/data-set
        relations = oracle(nPairs, wholeData);
        % updating conMat
        conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = relations;
        conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = relations;
        % if achieve a must link, add this point to the neighborhood
        if (relations == 1)
            for i = 1:classNum
                if ~isempty(find(neighborhood{i}==nPairs(1), 1))
                    neighborhood{i}(end+1) = nPairs(2);
                elseif ~isempty(find(neighborhood{i}==nPairs(2), 1))
                    neighborhood{i}(end+1) = nPairs(1);
                end
            end
        end
            
            
        
        conMat = transitive_closure (conMat, nPairs, n);
        
        count = count+nps;
        bcount = bcount+1;
        
        % update the belief of ground truth
        creatContraintsFile (conMat, datasetName);
        
        clusterNum = 0;
        maxIter = 0;
        flag = 1;
        while ((classNum~=clusterNum || flag == 1) && maxIter~=10)
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
            dos (x);
            [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
            cd ..;
            cd ..;
            clusterNum = length(unique(clustering));
            if (classNum~=clusterNum)
                beep;
            end
            if (find(cluster_size<0.1*sum(cluster_size)))
                nPairs = random_pairs(conMat, testData, n);
                usedPairs (ucount-nps+1:ucount, :) = nPairs;
                conMat = eye(n);
                relations = oracle(usedPairs, wholeData);
                conMat((usedPairs(:,2)-1)*n + usedPairs(:,1)) = relations;
                conMat((usedPairs(:,1)-1)*n + usedPairs(:,2)) = relations;
                conMat = transitive_closure (conMat, nPairs, n);
                creatContraintsFile (conMat, datasetName);
                beep;
            else
                flag = 0;
            end
            maxIter=maxIter+1;
        end
        
        %clustering
        %Tlabels
        %testData
        
        if (isequal(flag2, 'MG'))
            cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
        elseif(isequal(flag2, 'RF'))
            cpt = random_forest(wholeData(:, 1:end-1), clustering);
        end 
        recordClustering (clustering, datasetName, flag1, flag2, nq_initial);
        
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
        results(bcount,3) = accuracy(wholeData(:, end), clustering);
        results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
        results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
        results(bcount,6) = count;           
            
        [flag1,'-',flag2, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]
    end
    relations = oracle(usedPairs, wholeData);
    cd results;
    cd (datasetName);
    fileName = [datasetName, '-pr-with-neighbor', flag1,'-',flag2,'-',num2str(nq_initial), '-', num2str(nps),'.data'];
    dlmwrite(fileName,results,'-append');
    visualName = [datasetName, '-pr-with-neighbor', flag1,'-',flag2,'-',num2str(nq_initial), '-', num2str(nps), '-constraints.data'];
    dlmwrite(visualName, [usedPairs, relations], '-append');
    cd ..;
    cd ..;

