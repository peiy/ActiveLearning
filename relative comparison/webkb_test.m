addpath('./distance_learning', './lib', './selection', './clustering_evaluation'); % Code
nps = 50000;
qsize = 50000;        
datasetFolder =  'webkb';%webkb
datasetName =    'webkb';  
datasetPath = ['Data-Sets/', datasetFolder, '/', datasetName, '.data'];
cd results;
mkdir (datasetName);
cd ..;
repeatTime = 20;
fold_number = 10;
for i = 1:repeatTime
    [rawData, indices] = initialize(datasetPath, fold_number); 
    n = size (rawData, 1);
    temp = randperm (fold_number);
    trainDataIndex = [];
    for j = 1:7
        trainDataIndex = vertcat (trainDataIndex, find(indices == temp(j)));
    end
    testDataIndex = setdiff (1:n, trainDataIndex);     
    ['restart #', num2str((i-1)*fold_number+j)]
    svm_cluster (qsize, nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'random_partial');
    %svm_cluster (qsize, nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'exhauEntropy'); % exhausitve compute n^3 triples, using info entropy as crterion    
end