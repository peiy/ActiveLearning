function pt_new (nq, nps, wholeData, datasetName, num, flag1, flag2, flag3, neighbor, randPair)
n = length(wholeData);
bcount = 0;
count = 0;
results = [];
nq_initial = nq;
conMat = eye(n);
[cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData);
fileName = [datasetName, '-pt-new-', flag1,'-',flag2,'-',flag3,'-',num2str(nq_initial), '-', num2str(nps),'.data'];
visualName = [datasetName, '-pt-new-', flag1,'-',flag2,'-',flag3,'-',num2str(nq_initial), '-', num2str(nps), '-constraints.data'];
clusterName =  [datasetName, '-pt-new-', flag1,'-',flag2,'-',flag3,'-',num2str(nq_initial), '-', num2str(nps), '-cluster.data'];
neighborName = [datasetName, '-pt-new-', flag1,'-',flag2,'-',flag3,'-',num2str(nq_initial), '-', num2str(nps), '-neighbor.data'];

bcount = bcount+1;
results(bcount,1) = nmi(wholeData(:, end), clustering);
results(bcount,2) = -1;
results(bcount,3) = accuracy(wholeData(:, end), clustering);
results(bcount,4) = -1;
results(bcount,5) = f1(wholeData(:, end)', clustering');
results(bcount,6) = count;   

[flag1,'-',flag2,' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
usedPairs = [];

while (nq>0)
    if (isequal(flag1, 'GM'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag1, 'RF'))
        [cpt, coassMat] = random_forest(wholeData(:, 1:end-1), clustering);
    end
    if (isequal (flag2, 'MatMax') || isequal (flag2, 'MatMin') || isequal (flag2, 'MatMean'))
        [uncertainPoint, nPairs, neighbor, nq] = uncertain_query_mat (nq, neighbor, wholeData, coassMat, flag2, flag3, datasetName, num, nq_initial);
    elseif (isequal (flag2, 'PtMax') || isequal (flag2, 'PtMin') || isequal (flag2, 'PtMean'))
        [uncertainPoint, nPairs, neighbor, nq] = uncertain_query_point (nq, neighbor, wholeData, cpt, flag2, flag3, datasetName, num, nq_initial);
    end
    conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = nPairs(:, 3);
    conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = nPairs(:, 3);
    if ~isempty (randPair)
        conMat((randPair(:,2)-1)*n + randPair(:,1)) = randPair(:, 3);
        conMat((randPair(:,1)-1)*n + randPair(:,2)) = randPair(:, 3);
    end
    [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);
    bcount = bcount+1;
    count = count+size(nPairs,1);
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = -1;
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = -1;
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;   

    [flag1,'-',flag2,'#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    usedPairs (end+1:end+size(nPairs,1), :) = nPairs;
    cd results;
    cd (datasetName);
    dlmwrite(clusterName, clustering, '-append');
    for ijk = 1:length(neighbor)
      dlmwrite (neighborName, (neighbor{ijk}), '-append');
      dlmwrite (neighborName, -1, '-append');
    end
    dlmwrite (neighborName, [-10; (nq_initial-nq)], '-append');
    cd ..;
    cd ..;                
end
cd results;
cd (datasetName);
dlmwrite(fileName,results,'-append');
dlmwrite(visualName, usedPairs, '-append');
cd ..;
cd ..;

end