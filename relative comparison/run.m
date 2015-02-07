tic
addpath('./distance_learning', './lib', './selection', './clustering_evaluation', './cplex'); % Code
nps = [5, 5, 5, 5, 5, 5, 5, 5];
qsize = [50, 50, 50, 50, 50, 50, 50, 50];
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
            datasetFolder =  'heart';
            datasetName =    'heart';  
        case 6
            datasetFolder =  'parkinsons';
            datasetName =    'parkinsons';  
        case 7
            datasetFolder =  'ionosphere';
            datasetName =    'ionosphere';  
        case 8            
            datasetFolder =  'madelon';
            datasetName =    'madelon';  
        case 9 
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
        %ddd = rawData (:, 1:end-1);
        %covMat = cov (ddd);
        %ind = diag(covMat ~= 0);
        %variance = diag(covMat);
        %variance = variance(ind);
        %ddd = ddd (:, ind);
        %avg = mean (ddd);
        %ddd = (ddd - repmat (avg, size (rawData, 1), 1))./(repmat(variance'.^0.5, size (rawData, 1), 1));
        %rawData = [ddd,rawData(:,end)];        
        
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
            %main (qsize(kkk), nps(kkk), trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'random_partial', 'joachims');
            %main (qsize(kkk), nps(kkk), trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'random_complete', 'joachims');
            %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'exhauEntropy', 'svm_dkn');
            %main (qsize(kkk), nps(kkk), trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'random_complete', 'svm_dkn');
            %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'exhauEntropy', 'joachims'); % exhausitve compute n^3 triples, using info entropy as crterion.
        if isequal (sampleFlag, 'same')
            sampleNum = ceil((length(trainDataIndex)/15)^3);
            sampleTriple = subsample (rawData (trainDataIndex, :), sampleNum, []); 
        elseif isequal (sampleFlag, 'diff')
            sampleTriple = [];
        end    
        %main_dis (qsize(kkk), nps(kkk), trainDataIndex, testDataIndex, rawData, datasetName, i, 'random_complete', 'joachims', 'rd', sampleTriple); 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rejSam', 'joachims', 'gaussian', sampleTriple); 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rejSam', 'joachims', 'logistic', sampleTriple);                 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rankSelect', 'joachims', 'gaussian', sampleTriple); 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rankSelect', 'joachims', 'logistic', sampleTriple); 
           
        
        main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'random', 'joachims', []); 
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exhauEntropy', 'joachims', 'rf'); 
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exhauEntropy', 'joachims' ,'gmm');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exEntropyP1P2', 'joachims' ,'rf');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exEntropyP1P2', 'joachims' ,'gmm');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'extreme', 'joachims' ,'rf');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'extreme', 'joachims' ,'gmm');

        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'infoLabel', 'joachims' ,'rf');

        

        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'random', 'romer', []); 
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exhauEntropy', 'romer', 'rf'); 
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exhauEntropy', 'romer', 'gmm');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exEntropyP1P2', 'romer' ,'rf');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'exEntropyP1P2', 'romer' ,'gmm');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'extreme', 'romer' ,'rf');
        %main (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'extreme', 'romer' ,'gmm');

       
        %main_dis (qsize(kkk), nps(kkk), trainDataIndex, testDataIndex, rawData, datasetName, i, 'random_complete', 'romer', 'rd', sampleTriple);                 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rejSam', 'romer', 'gaussian', sampleTriple); 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rejSam', 'romer', 'logistic', sampleTriple);  
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rankSelect', 'romer', 'gaussian', sampleTriple); 
        %main_dis (qsize(kkk), 1, trainDataIndex, testDataIndex, rawData, datasetName, i, 'rankSelect', 'romer', 'logistic', sampleTriple);                    
    end
end
toc
