%% Variable Initializations
%% DATASET CONFIGURATIONS
%datasetFolder =  'parkinsons'; %'digits-0.1-389' %'iris' %'wine' %'sonar' %'ecoli' %'letter-0.1-IJL' %'parkinsons' 
%datasetName =    'parkinsons'; %'digits-0.1-389' %'iris' %'wine' %'sonar' %'ecoli' %'letter-0.1-IJL' %'parkinsons'

addpath('./clustering_evaluation', './pair_selection', './initialize', './ground_truth', './lib', './ccskl', './main_function', 'c:/hello'); % Code
nps = 1;
qsize = [100, 100, 150, 100, 150, 150, 150, 150, 150, 100, 100, 100, 100, 150, 150, 150];

for kkk = 7
    repeatTime = 20; % number of experiments of each policy
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
            ['restart #', num2str((i-1)*fold_number+j)]
            %random policy
            [randPair, neighbor] = randomSelect (rawData, 0);
            % Random
            % random_policy (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans', randPair);
            % E & C
            % farthest_first (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans', 'normal', 'consolidate', neighbor, randPair);
            % Min-Max
            % farthest_first (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'MPCKmeans', 'normal', 'minmax', neighbor, randPair);
            % Huang
            % huang_semi (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'EN', neighbor, randPair);                                      
            % Normalized uncertainty
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMax', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMin', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMean', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMax', 'unnormal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMin', 'unnormal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'MatMean', 'unnormal', neighbor, randPair);
            
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMax', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMin', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMean', 'normal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMax', 'unnormal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMin', 'unnormal', neighbor, randPair);
            pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'PtMean', 'unnormal', neighbor, randPair);
            
            % Uncertainty
            % pt_new (qsize(kkk), nps, rawData, datasetName, (i-1)*fold_number+j, 'RF', 'NEQNEW', neighbor, randPair);
        end
    end
end

beep



