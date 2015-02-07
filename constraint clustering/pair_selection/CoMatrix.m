function coassociation = CoMatrix (rawData, consPairs, times, datasetName)
consPts = union (consPairs(:,1), consPairs (:,2));
restPts = setdiff (1:size(rawData,1), consPts);
nr = length(restPts);
n = length(rawData);
Co = zeros (length(rawData));
Num = zeros (length(rawData));
for kkk = 1:times
    samplePts = zeros (n, 1); 
    samplePts (1:length(consPts)) = consPts;
    %bagging for rest data
    samplePts (length(consPts)+1:end) = restPts(randi (nr, nr, 1));
    sampleData  = rawData (samplePts, :);
    consEnsemblePairs = zeros (size(consPairs));
    for i = 1:size(consEnsemblePairs, 1)
        consEnsemblePairs (i, 1) = find (samplePts==consPairs (i,1));
        consEnsemblePairs (i, 2) = find (samplePts==consPairs (i,2));
        consEnsemblePairs (i, 3) = consPairs (i,3);    
    end
    conEnsembleMat = eye (n);
    conEnsembleMat (consEnsemblePairs (:,1) + (consEnsemblePairs (:,2)-1)*n) = consEnsemblePairs (:, 3);
    conEnsembleMat (consEnsemblePairs (:,2) + (consEnsemblePairs (:,1)-1)*n) = consEnsemblePairs (:, 3);
    creatContraintsFile (conEnsembleMat, datasetName);
    generateEnsembelArff (sampleData(:,1:end-1), sampleData(:,end), datasetName, 1);
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '-ensemble.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
    dos (x);
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, sampleData);
    cd ..;
    cd ..;
    clusterNum = length(cluster);
    for i = 1:clusterNum
        for j = 1:length(cluster{i})
            for k = j+1:length(cluster{i})
                Co (samplePts(cluster{i}(j)), samplePts(cluster{i}(k))) = Co (samplePts(cluster{i}(j)), samplePts(cluster{i}(k))) + 1;
                Co (samplePts(cluster{i}(k)), samplePts(cluster{i}(j))) = Co (samplePts(cluster{i}(k)), samplePts(cluster{i}(j))) + 1;
            end
        end
    end
    for i = 1:n
        for j = i+1:n
            Num (samplePts(i), samplePts(j)) = Num (samplePts(i), samplePts(j)) + 1;
            Num (samplePts(j), samplePts(i)) = Num (samplePts(j), samplePts(i)) + 1;
        end
    end
end
coassociation = Co./Num;
temp = eye (size(rawData, 1));
coassociation (temp==1) = 1;
coassociation (coassociation == Inf) = -1;
end


