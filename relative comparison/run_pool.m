tic
addpath('./distance_learning', './lib', './selection', './clustering_evaluation', './cplex'); % Code
nps = [5, 5, 5, 5, 5, 15, 200, 100];
qsize = [50, 50, 50, 50, 50, 100, 1000, 500];
sampleFlag = 'diff';
for kkk = 1
    switch kkk
        case 1
            datasetFolder =  'iris';
            datasetName =    'iris';
        case 2
            datasetFolder =  'wine';
            datasetName =    'wine';
        case 3 
            datasetFolder =  'hayes';
            datasetName =    'hayes';
        case 4            
            datasetFolder =  'BreastTissue';
            datasetName =    'BreastTissue';
        case 5
            datasetFolder =  'synthetic';
            datasetName =    'synthetic';  
        case 6 
            datasetFolder =  'digits-0.1-389';
            datasetName =    'digits-0.1-389';  
        case 7            
            datasetFolder =  'madelon';
            datasetName =    'madelon';  
        case 8 
            datasetFolder =  'mfeat';
            datasetName =    'mfeat';   
    end
    datasetPath = ['Data-Sets/', datasetFolder, '/', datasetName, '.data'];    
    cd results;
    if (~exist(datasetName, 'dir'))        
        mkdir (datasetName);
    end
    cd ..;
    repeatTime = 20;
    fold_number = 2;
    for i = 1:repeatTime
        [rawData, indices] = initialize(datasetPath, fold_number); 
        covMat = cov (rawData (:, 1:end-1));
        avg = mean (rawData (:, 1:end-1), 1);
        rawData (:, 1:end-1) = (rawData (:, 1:end-1) - repmat (avg, size (rawData, 1), 1))./(repmat(diag(covMat)'.^0.5, size (rawData, 1), 1));
        trainDataIndex = find (indices == 1);
        testDataIndex = setdiff(1:length(indices), trainDataIndex);       
%         for j = 1:fold_number
%             if fold_number == 1
%                 testDataIndex = find(indices ~= j);
%                 trainDataIndex = find(indices == j);
%             else
%                 testDataIndex = find(indices == j);
%                 trainDataIndex = find(indices ~= j);
%             end        

        %['restart #', num2str((i-1)*fold_number+j)]
        ['restart #', num2str(i)]          
        trainData = rawData (trainDataIndex, :);
        poolTri = generatePool(trainData);
        if isequal (sampleFlag, 'same')
            sampleNum = size (poolTri, 1);
            sampleTripleId = subsamplePool (size(poolTri, 1), sampleNum, []); 
        elseif isequal (sampleFlag, 'diff')
            sampleTripleId = [];
        end                  
        %random_main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'joachims', 'gaussian', sampleTripleId, poolTri);      
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exRejSam', 'joachims', 'gaussian', sampleTripleId, poolTri, 5);                 
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exRejSam', 'joachims', 'logistic', sampleTripleId, poolTri, 5);     
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'uncertainSampling', 'joachims', 'gaussian', sampleTripleId, poolTri, 5);     
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'uncertainSampling', 'joachims', 'logistic', sampleTripleId, poolTri, 5);           
        
        
        %random_main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'romer', 'gaussian', sampleTripleId, poolTri);          
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exRejSam', 'romer', 'gaussian', sampleTripleId, poolTri, 5);   
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'certainRej', 'romer', 'gaussian', sampleTripleId, poolTri, 5);      
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exRejSam', 'romer', 'logistic', sampleTripleId, poolTri, 5);            
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'uncertainSampling', 'romer', 'gaussian', sampleTripleId, poolTri, 5);      
        %main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'uncertainSampling', 'romer', 'logistic', sampleTripleId, poolTri, 5);       
        
        main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exRejSam', 'romer', 'gaussian', sampleTripleId, poolTri, 5);   
        main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'certainRej', 'romer', 'expo', sampleTripleId, poolTri, 5);      
        main_pool (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'uncertainSampling', 'romer', 'expo', sampleTripleId, poolTri, 5);      
        
    end
end
toc
