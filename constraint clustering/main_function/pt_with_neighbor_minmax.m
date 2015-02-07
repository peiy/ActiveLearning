function pt_with_neighbor_minmax (nq, nps, trainData, testData, wholeData, datasetName, num, flag1, flag2, exploreMethod)
n1 = length(trainData);
n2 = length(testData);
n = n1+n2;
bcount = 0;
count = 0;
results = zeros(nq/nps+1,6);
conMat = eye (n);

cd wekaUT/weka-latest;
x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -O ', datasetName, 'Result.data'];
dos (x);   
[~, ~, ~, clustering] = getResult (datasetName, wholeData);
cd ..;
cd ..;

bcount = bcount+1;
results(bcount,1) = nmi(wholeData(:, end), clustering);
results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
results(bcount,3) = accuracy(wholeData(:, end), clustering);
results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
results(bcount,6) = count;   

[flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   

if isequal (exploreMethod, 'normal')
    [neighborhood, j, selectPairs] = explorer (nq, trainData, testData, wholeData);
elseif isequal (exploreMethod, 'plus')
    [neighborhood, j, selectPairs] = explorer_plus (nq, trainData, testData, wholeData);
end
kkkk = 25;
cccc = min (kkkk,j);
[neighborhood, selectPairs] = minmax (neighborhood, cccc, wholeData, selectPairs, trainData);
pairNumFarthest = size(selectPairs, 1);

for i = 1:pairNumFarthest
    conMat = eye(n);
    conMat((selectPairs(1:i,2)-1)*n + selectPairs(1:i,1)) = selectPairs(1:i, 3);
    conMat((selectPairs(1:i,1)-1)*n + selectPairs(1:i,2)) = selectPairs(1:i, 3);
    conMat = transitive_closure (conMat, selectPairs(1:i,1:2), n);
    creatContraintsFile (conMat, datasetName);
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
    dos (x);
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
    cd ..;
    cd ..;
    bcount = bcount+1;
    count = count+1;
    results(bcount,1) = nmi(wholeData(:, end), clustering);
    results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
    results(bcount,3) = accuracy(wholeData(:, end), clustering);
    results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
    results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
    results(bcount,6) = count;       
    [flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
end

usedPairs = [];
j = nq-pairNumFarthest;
while (j>0)
    if (isequal(flag1, 'GM'))
        cpt = ground_truth(cluster, cluster_size, centroids, wholeData(:, 1:end-1));
    elseif (isequal(flag1, 'RF'))
        cpt = random_forest(wholeData(:, 1:end-1), clustering);
    end     
    % find the most uncertain points to ask,
    if (isequal(flag2, 'EN') || isequal (flag2, 'MS'))
        [uncertainPoint, nPairs, neighborhood] = uncertain_point_with_neighbor(cpt, nps, neighborhood, trainData, testData, wholeData, n, flag2, conMat, cluster);
        j = j-nps;
    elseif (isequal(flag2, 'ENF'))
        [uncertainPoint, nPairs, neighborhood, numOfQuery] = uncertain_point_with_neighbor_multi(cpt, nps, neighborhood, trainData, testData, wholeData, n, flag2, conMat, cluster);
        j = j-numOfQuery;
    end
    for xxx = 1:size(nPairs, 1)
        conMat((nPairs(1:xxx,2)-1)*n + nPairs(1:xxx,1)) = nPairs(1:xxx, 3);
        conMat((nPairs(1:xxx,1)-1)*n + nPairs(1:xxx,2)) = nPairs(1:xxx, 3);
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

        [flag1,'-',flag2,'-', exploreMethod, ' #Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
        usedPairs (end+1, :) = nPairs(xxx, :);
    end
end
cd results;
cd (datasetName);
if isequal (exploreMethod, 'normal') 
    fileName = [datasetName, '-pt-with-neighbor-minmax-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps),'.data'];
    visualName = [datasetName, '-pt-with-neighbor-minmax-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-constraints.data'];
elseif isequal (exploreMethod, 'plus') 
    fileName = [datasetName, '-pt-with-neighbor-minmax-plus-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps),'.data'];
    visualName = [datasetName, '-pt-with-neighbor-minmax-plus-', flag1,'-',flag2,'-',num2str(nq), '-', num2str(nps), '-constraints.data'];
end
dlmwrite(fileName,results,'-append');
dlmwrite(visualName, [selectPairs; usedPairs], '-append');
cd ..;
cd ..;
