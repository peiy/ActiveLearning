%% Variable Initializations
%% DATASET CONFIGURATIONS
%datasetFolder =  'parkinsons'; %'digits-0.1-389' %'iris' %'wine' %'sonar' %'ecoli' %'letter-0.1-IJL' %'parkinsons' 
%datasetName =    'parkinsons'; %'digits-0.1-389' %'iris' %'wine' %'sonar' %'ecoli' %'letter-0.1-IJL' %'parkinsons'

addpath('./clustering_evaluation', './pair_selection', './initialize', './ground_truth', './lib', './ccskl', './main_function', 'c:/hello'); % Code
nps = 1;
qsize = [100, 100, 150, 100, 150, 150, 150, 150, 150, 100, 100, 100, 100, 150, 150, 150];

for kkk = [15]%,7,9,10,13,14,15]
    repeatTime = 50; % number of experiments of each policy
    fold_number = 1; % number of fold in cross validation 
    switch kkk
        case 1
            datasetFolder =  'iris';
            datasetName =    'iris';
        case 2
            datasetFolder =  'digits-0.1-389';
            datasetName =    'digits-0.1-389';
        case 3
            datasetFolder =  'parkinsons';
            datasetName =    'parkinsons';
        case 4   
            datasetFolder =  'wine';
            datasetName =    'wine';
        case 5
            datasetFolder =  'sonar';
            datasetName =    'sonar';
        case 6
            datasetFolder =  'ecoli';
            datasetName =    'ecoli';
        case 7
            datasetFolder =  'glass';
            datasetName =    'glass';
        case 8
            datasetFolder = 'diabetes';
            datasetName = 'diabetes';
        case 9
            datasetFolder = 'heart';   
            datasetName = 'heart';
        case 10
            datasetFolder = 'breast';
            datasetName = 'breast';
        case 11
            datasetFolder =  'synDataThreeImb';
            datasetName =    'synDataThreeImb';
        case 12
            datasetFolder =  'synDataTwo';
            datasetName =    'synDataTwo';
        case 13
            datasetFolder =  'synDataTwoNoise';
            datasetName =    'synDataTwoNoise';            
        case 14
            datasetFolder = 'segment';
            datasetName = 'segment';
        case 15
            datasetFolder = 'digits-389';
            datasetName = 'digits-389';   
        case 16
            datasetFolder = 'synDataFive';
            datasetName = 'synDataFive'; 
    end
    datasetPath = ['Data-Sets/', datasetFolder, '/', datasetName, '.data'];
    cd results;
    mkdir (datasetName);
    cd ..;

    for i = 1:repeatTime
        [rawData, indices] = initialize(datasetPath, fold_number);
        for j = 1:fold_number
            if fold_number == 1
                testDataIndex = find(indices ~= j);
                trainDataIndex = find(indices == j);
            else
                testDataIndex = find(indices == j);
                trainDataIndex = find(indices ~= j);
            end
            %qsize = round(size(trainDataIndex, 1)-mod(size(trainDataIndex, 1),10));     % specifying the maximum number of querys that can be asked.  
            %nps = round(qsize/10);         % number of pair selection in each cycle 
            ['restart #', num2str((i-1)*fold_number+j)]
            %random policy
            
            %random_policy (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans');
            %random_policy (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'sl');
            %random_policy (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'ccskl', 'constrained');
            %random_policy (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'ccskl', 'unconstrained');


            %pr_with_neighbor(qsize(kkk), 'RP', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);      
           
            %farthest first policy
            %pr_without_neighbor(qsize(kkk), nps, 'RP', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);

            %farthest_first (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans', 'normal', 'consolidate');
            %farthest_first (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans', 'normal', 'minmax');
            %huang_semi (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN');
            
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EQRF', 'normal');
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NEQRF', 'normal');
                       
            pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EQNEW');
            pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NEQNEW');
            %pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NEQEPSILON');
            %pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EQEPSILON');
            %pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NEQDECAY');
            %pt_new (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EQDECAY');
            


            
            %pr_with_neighbor(qsize(kkk), 'BP1', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            



            %point uncertainty with neighborhood
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'EN');
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', 'normal');
            %pt_with_neighbor_consolidate (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', 'normal');
            %pt_with_neighbor_minmax (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', 'normal');

            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', 'new');
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EQ', 'new');

            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', 'plus');
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'ENF'); % find the most uncertainty point, query it until a must link is achieved.
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'MS');
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MS');
            
            %point uncertainty without neighborhood
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'NP', 'NP'); % NP means nearest point, MC means cluster with maximal probablity
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'NP', 'MC');
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'MC', 'NP');
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'GM', 'MC', 'MC');
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NP', 'NP'); 
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NP', 'MC');
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MC', 'NP');
            %pt_without_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MC', 'MC');
            
            %pair uncertainty with neighborhood
            %pr_with_neighbor(qsize(kkk), 'BP1', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_with_neighbor(qsize(kkk), 'IM', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);    
            %pr_with_neighbor(qsize(kkk), 'BP1', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_with_neighbor(qsize(kkk), 'IM', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);      
            
           
            %pair uncertainty without neighborhood
            %pr_without_neighbor(qsize(kkk), nps, 'BP1', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'BAL', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'IM', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'ET', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'IT', 'MG', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'BP1', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'BAL', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'IM', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'ET', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            %pr_without_neighbor(qsize(kkk), nps, 'IT', 'RF', trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j);
            
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'Ensemble', 'EQ', 'normal'); %ensemble method generate co-association matrix, use expected number of queries to choose point
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'Ensemble', 'NEQ', 'normal'); %ensemble method generate co-association matrix, use expected number of queries to choose point
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'Ensemble', 'EQ', 'center'); %ensemble method generate co-association matrix, use expected number of queries to choose point
            %pt_with_neighbor (qsize(kkk), nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'Ensemble', 'NEQ', 'center'); %ensemble method generate co-association matrix, use expected number of queries to choose point


            %main_ccskl (qsize, nps, trainDataIndex, testDataIndex, rawData, datasetName, (i-1)*fold_number+j, 'farthest-first', ratioVec (rrr));
        end
    end
end

beep



