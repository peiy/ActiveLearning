function random_policy (nq, nps, wholeData, datasetName, num, clusterMethod, startPair)
n = length(wholeData);
bcount = 0;
results = zeros(nq/nps+1,6);
for i = 0:nps:nq
    conMat = eye (n);
    pairs = eye(n);
    pairs = ~pairs;
    if ~isempty(startPair)
        pairs ((startPair(:,1)-1)*n+startPair(:,2)) = 0;
        pairs ((startPair(:,2)-1)*n+startPair(:,1)) = 0;
    end
    [i_indices, j_indices] = find(triu(pairs,1)==1);
    Indices = [i_indices, j_indices];
    if(i>1)
        l = 1:length(Indices);
        rands = [];
        while(length(rands) < nps)
            list = random('unid', length(l), (i-length(rands)),1);
            list = unique(list);
            list = l(list);
            l = setdiff(l,list); 
            x = length (rands);
            rands (x+1:x+length(list)) = list;
        end
        randPairList = Indices(rands, :);
    else
        randPairList = Indices(random('unid', size(Indices,1), i,1), :);        
    end   
    if i ~= 0 
        relations = oracle(randPairList, wholeData);
        conMat ((randPairList(:,1)-1)*n+randPairList(:,2)) = relations;
        conMat ((randPairList(:,2)-1)*n+randPairList(:,1)) = relations;
        if ~isempty(startPair)
            conMat ((startPair(:,2)-1)*n+startPair(:,1)) = startPair(:,3);
            conMat ((startPair(:,1)-1)*n+startPair(:,2)) = startPair(:,3);
        end
        if isequal (clusterMethod, 'MPCKmeans')         
            [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);
        end
    else
        if isequal (clusterMethod, 'MPCKmeans')
            [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData);
        end
    end
    count = i;  
    bcount = bcount+1;
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = -1;
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = -1;
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;         
    ['Random #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
end
cd results;
cd (datasetName);
fileName = [datasetName, '-random-',num2str(nq), '-', num2str(nps), '-', clusterMethod, '.data'];
dlmwrite(fileName,results,'-append');
if num == 1
    visualName = [datasetName, '-random-',num2str(nq), '-', num2str(nps), '-constraints.data'];
    dlmwrite(visualName, [randPairList, relations]);
end
cd ..;
cd ..;
end








    