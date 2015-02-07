function pt_with_neighbor (nq, nps, trainData, testData, wholeData, datasetName, num, flag1, flag2, exploreMethod)
% neighborhood ~ the index in train data
n1 = length(trainData);
n2 = length(testData);
n = n1+n2;
bcount = 0;
count = 0;
results = [];
conMat = eye (n);

if isequal (exploreMethod, 'normal') 
    fileName = [datasetName, '-pt-with-neighbor-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps),'.data'];
    visualName = [datasetName, '-pt-with-neighbor-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-constraints.data'];
    clusterName = [datasetName, '-pt-with-neighbor-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-cluster.data'];
    neighborName = [datasetName, '-pt-with-neighbor-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-neighbor.data'];
    oFuncName = [datasetName, '-pt-with-neighbor-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-obFunction.data'];
else
    fileName = [datasetName, '-pt-with-neighbor-', exploreMethod ,'-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps),'.data'];
    visualName = [datasetName, '-pt-with-neighbor-', exploreMethod ,'-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-constraints.data'];
    clusterName = [datasetName, '-pt-with-neighbor-', exploreMethod ,'-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-cluster.data'];
    neighborName = [datasetName, '-pt-with-neighbor-', exploreMethod ,'-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-neighbor.data']; 
    oFuncName = [datasetName, '-pt-with-neighbor-', exploreMethod, '-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-obFunction.data'];
end

[~, ~, ~, clustering] = MPCKmeans (datasetName, wholeData);

bcount = bcount+1;
results(bcount,1) = nmi(wholeData(:, end), clustering);
results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
results(bcount,3) = accuracy(wholeData(:, end), clustering);
results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
results(bcount,5) = f1(wholeData(:, end)', clustering');
results(bcount,6) = count;   

% cd results;
% cd (datasetName);
% dlmwrite(clusterName, clustering, '-append');
% cd ..;
% cd ..;


[flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   

if isequal (exploreMethod, 'normal')
    [neighborhood, j, selectPairs] = explorer (nq, trainData, testData, wholeData);
elseif isequal (exploreMethod, 'plus')
    [neighborhood, j, selectPairs] = explorer_plus (nq, trainData, testData, wholeData);
elseif isequal (exploreMethod, 'center')
    [neighborhood, j, selectPairs] = explore_center (nq, trainData, testData, wholeData);
elseif isequal (exploreMethod, 'new')
    [neighborhood, j, selectPairs] = new_explore (nq, trainData, testData, wholeData, datasetName);
end
pairNumExplore = size(selectPairs, 1);

for i = 1:pairNumExplore
    conMat = eye(n);
    conMat((selectPairs(1:i,2)-1)*n + selectPairs(1:i,1)) = selectPairs(1:i, 3);
    conMat((selectPairs(1:i,1)-1)*n + selectPairs(1:i,2)) = selectPairs(1:i, 3);
    %conMat = transitive_closure (conMat, selectPairs(1:i,1:2), n);

    [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);

    bcount = bcount+1;
    count = count+1;
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;       
    
    cd results;
    cd (datasetName);
    dlmwrite(clusterName, clustering, '-append');
    cd ..;
    cd ..;
    
    [flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   

end
usedPairs = [];
while (j>0)
    if (isequal(flag1, 'GM'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag1, 'RF'))
        [cpt, coassMat] = random_forest(wholeData(:, 1:end-1), clustering);
    elseif (isequal(flag1, 'Ensemble'))
        ensemblePairs = [selectPairs;usedPairs];
        [uncertainPoint, nPairs, neighborhood, j] = ensemble(nps, j, neighborhood, trainData, testData, wholeData, n, conMat, ensemblePairs, datasetName, flag2);
    end     
    % find the most uncertain points to ask,
    if (isequal(flag2, 'EN') || isequal (flag2, 'MS'))
        [uncertainPoint, nPairs, neighborhood] = uncertain_point_with_neighbor(cpt, nps, neighborhood, trainData, testData, wholeData, n, flag2, conMat, cluster);
        j = j-nps;
    elseif (isequal(flag2, 'ENF'))
        [uncertainPoint, nPairs, neighborhood, numOfQuery] = uncertain_point_with_neighbor_multi(cpt, nps, neighborhood, trainData, testData, wholeData, n, flag2, conMat, cluster);
        j = j-numOfQuery;
    elseif (isequal(flag2, 'EQRF')) || (isequal(flag2, 'NEQRF'))
        [uncertainPoint, nPairs, neighborhood, j] = uncertain_query_with_neighbor (j, neighborhood, trainData, testData, wholeData, coassMat, flag2, datasetName, oFuncName);
    elseif (isequal(flag2, 'Certain'))
        [certainPoint, nPairs, neighborhood, j] = certain_point_with_neighbor (cpt, j, neighborhood, trainData, testData, wholeData, n, flag2, conMat, cluster);
    end
    conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = nPairs(:, 3);
    conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = nPairs(:, 3);

    [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);

    bcount = bcount+1;
    count = count+size(nPairs, 1);
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;   
    [flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    usedPairs (end+1:end+size(nPairs, 1), :) = nPairs;
    cd results;
    cd (datasetName);
    dlmwrite(clusterName, clustering, '-append');
    for ijk = 1:length(neighborhood)
        dlmwrite (neighborName, trainData(neighborhood{ijk}), '-append');
        dlmwrite (neighborName, -1, '-append');
    end
    dlmwrite (neighborName, [-10; (nq-j)], '-append');
    cd ..;
    cd ..;
end
cd results;
cd (datasetName);
dlmwrite (neighborName, [-100; num], '-append');

dlmwrite(fileName,results,'-append');
dlmwrite(visualName, [selectPairs; usedPairs], '-append');

cd ..;
cd ..;
