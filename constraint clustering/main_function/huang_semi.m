function huang_semi (nq, nps, wholeData, datasetName, num, flag1, flag2, neighbor, randPair)
n = length(wholeData);
bcount = 0;
count = 0;
results = [];
conMat = eye (n);
fileName = [datasetName, '-huang-semi-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps),'.data'];
visualName = [datasetName, '-huang-semi-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-constraints.data'];
[cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData);
bcount = bcount+1;
results(bcount,1) = nmi(wholeData(:, end), clustering);
results(bcount,2) = -1;
results(bcount,3) = accuracy(wholeData(:, end), clustering);
results(bcount,4) = -1;
results(bcount,5) = f1(wholeData(:, end)', clustering');
results(bcount,6) = count;   

['Huang-semi ', flag1,'-',flag2,'#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   

usedPairs = [];
while (nq>0)
    if (isequal(flag1, 'GM'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag1, 'RF'))
        cpt = random_forest(wholeData(:, 1:end-1), clustering);
    end    
    [nPairs, neighbor, nq] = uncertain_pairs_huang (nq, neighbor, wholeData, cpt, flag2, conMat, cluster, clustering);
    conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = nPairs(:, 3);
    conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = nPairs(:, 3);
    if ~isempty (randPair)
        conMat((randPair(:,2)-1)*n + randPair(:,1)) = randPair(:, 3);
        conMat((randPair(:,1)-1)*n + randPair(:,2)) = randPair(:, 3);
    end
    [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat);
    bcount = bcount+1;
    count = count+size(nPairs, 1);
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = -1;
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = -1;
    results(bcount,5) = f1(wholeData(:, end)', clustering');
    results(bcount,6) = count;   
    ['Huang-semi ', flag1,'-',flag2,'#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    usedPairs (end+1:end+size(nPairs, 1), :) = nPairs;    
end

cd results;
cd (datasetName);
dlmwrite(fileName,results,'-append');
dlmwrite(visualName, usedPairs, '-append');
cd ..;
cd ..;

end
