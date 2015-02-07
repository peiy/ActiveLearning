function pt_without_neighbor (nq, nps, trainData, testData, wholeData, datasetName, num, flag1, flag2, flag3)
n1 = length(trainData);
n2 = length(testData);
n = n1+n2;
nq_initial = nq;
bcount = 0;
count = 0;
results = zeros(nq/nps+1,6);
conMat = eye (n);

cd wekaUT/weka-latest;
x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -O ', datasetName, 'Result.data'];
dos (x);   
[cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
cd ..;
cd ..;

bcount = bcount+1;
results(bcount,1) = nmi(wholeData(:, end), clustering);
results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
results(bcount,3) = accuracy(wholeData(:, end), clustering);
results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
results(bcount,6) = count;   

[flag1,'-',flag2, '-', flag3, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   

usedPairs = zeros (nq, 3);
while (nq>0)
    if (isequal(flag1, 'GM'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag1, 'RF'))
        cpt = random_forest(wholeData(:, 1:end-1), clustering);
    end     
    % find the most uncertain points to ask,
    [uncertainPoint,nPairs] = uncertain_point(cpt, nps, trainData, testData, wholeData, n, flag2, flag3, conMat, cluster, centroids);
    nq = nq-nps;
    conMat((nPairs(:,2)-1)*n + nPairs(:,1)) = nPairs(:, 3);
    conMat((nPairs(:,1)-1)*n + nPairs(:,2)) = nPairs(:, 3);
    conMat = transitive_closure (conMat, nPairs(:,1:2), n);    
    creatContraintsFile (conMat, datasetName);
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
    dos (x);
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
    cd ..;
    cd ..;
    bcount = bcount+1;
    count = count+nps;
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
    results(bcount,6) = count;   
    [flag1,'-',flag2, '-', flag3, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    usedPairs (nq_initial-nq, :) = nPairs;
end
cd results;
cd (datasetName);
fileName = [datasetName, '-pt-without-neighbor-', flag1, '-', flag2, '-', flag3, '-', num2str(nq_initial), '-', num2str(nps), '.data'];
dlmwrite(fileName,results,'-append');
if (num == 1)
    visualName = [datasetName, '-pt-without-neighbor-', flag1,'-',flag2, '-', flag3, num2str(nq_initial), '-', num2str(nps), '-constraints.data'];
    dlmwrite(visualName, usedPairs);
end
cd ..;
cd ..;
