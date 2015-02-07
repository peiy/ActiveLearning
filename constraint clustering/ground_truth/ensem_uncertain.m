function uncertainty = ensem_uncertain(conMat, data, datasetName, Tlabels, iterNum)
objectNum = size (data, 1);
dimNum = size (data, 2);
uncertainty = zeros(objectNum);
for i = 1:objectNum
    for j = i:objectNum
        uncertainty (j, i) = -1;
    end
end
%combination = nchoosek ([1:dimNum], ceil(dimNum/2));
reducedD = ceil(dimNum/2);
for i = 1:iterNum
    selected = randperm(dimNum);
    partial_data = data(:, selected(1:reducedD));
    generateEnsembelArff (partial_data, Tlabels, datasetName);
    creatContraintsFile (conMat, datasetName);
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/',datasetName, '-ensemble.arff -f -C data/' ,datasetName, '.constraints -O clusterResult.data']
    dos (x);
    rawResult = load ('clusterResult.data');
    for j = 1:objectNum
        for k = j+1:objectNum
            if (rawResult (j, 2) == rawResult(k, 2))
                uncertainty (j, k) = uncertainty (j, k) + 1/iterNum;
            end
        end
    end
    cd ..;
    cd ..;
end
uncertainty (find(conMat == 1)) = -1;
uncertainty (find(conMat == -1)) = -1;
end

