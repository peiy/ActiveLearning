function main (nq, nps, trainData, testData, wholeData, datasetName, num, flag, disLearnMethod, probFlag)
n1 = length(trainData);
n2 = length(testData);
n = n1+n2;
classNum = length(unique(wholeData(:, end)));
fNum = size (wholeData, 2) - 1;
c1 = 1;
nu = 1;
train = wholeData (trainData, :);
test = wholeData (testData, :);
if isequal (disLearnMethod, 'joachims')
    loopNum = length(c1);
    loopVec = c1;
    fileLabel = '-c1-';
elseif isequal (disLearnMethod, 'romer')
    loopNum = length(nu);
    loopVec = nu;
    fileLabel = '-nu-';
end

for kkk = 1:loopNum
    bcount = 1;
    results = zeros (nq/nps+1, 5);
    para = loopVec(kkk);
    resultFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-', probFlag, '.data'];
    tripletYN = [];
    tripletDKN = [];
    transTrainData = train (:, 1:end-1);
    transTestData = test (:, 1:end-1);
    for triNum = 0:nps:nq
        if triNum ~= 0
            if isequal (flag, 'random')
                query = random_policy (train (:, end), triNum);
                [tripletYN, tripletDKN] = oracle (train, query, [], []);
            elseif isequal (flag, 'exhauEntropy')
                newQuery = exhau_active (transTrainData, nps, clusteringTrain, 'entropy', tripletYN, tripletDKN, probFlag); % applicable to dkn, cross validation
                [tripletYN, tripletDKN] = oracle (train, newQuery, tripletYN, tripletDKN);
%           elseif isequal (flag, 'random_complete')
%                 [tripletYN, tripletDKN] = random_complete (train (:, end), triNum);
            elseif isequal (flag, 'exEntropyP1P2')
                newQuery = exhau_active (transTrainData, nps, clusteringTrain, 'entropyP1P2', tripletYN, tripletDKN, probFlag); % applicable to dkn, cross validation
                [tripletYN, tripletDKN] = oracle (train, newQuery, tripletYN, tripletDKN);
            elseif isequal (flag, 'approxGini_seq')
                newQuery = approx_gini_seq (train, clusteringTrain, tripletYN, tripletDKN); % not applicable to dkn, applicable to cross validation
                [tripletYN, tripletDKN] = oracle (train, newQuery, tripletYN, tripletDKN);
            elseif isequal (flag, 'extreme')
                newQuery = exhau_active (transTrainData, nps, clusteringTrain, 'extreme', tripletYN, tripletDKN, probFlag); % applicable to dkn, cross validation
                [tripletYN, tripletDKN] = oracle (train, newQuery, tripletYN, tripletDKN);
            elseif isequal (flag, 'infoLabel')
                newQuery = infoLabelSelect (transTrainData, nps, clusteringTrain, [], tripletYN, tripletDKN, probFlag); % applicable to dkn, cross validation
                [tripletYN, tripletDKN] = oracle (train, newQuery, tripletYN, tripletDKN);
            end            
            [W, x] = metric_learning (disLearnMethod, train (:, 1:end-1), tripletYN, para, []); 
            transTrainData = train (:, 1:end-1) * W;
            transTestData = test (:, 1:end-1) * W;
            clusteringTrain = kmeans (transTrainData, classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
        else
            clusteringTrain = kmeans (train (:,1:end-1), classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
        end
        clustering = kmeans(vertcat (transTrainData, transTestData), classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
        
        results(bcount,1) = testYNPoolper (transTestData, test(:,end));
        results(bcount,2) = knn (transTrainData, transTestData, train (:, end), test (:, end));
        results(bcount,3) = nmi (clustering, vertcat (train (:, end), test (:, end)));
        if triNum ~= 0
            results(bcount, 4) = size (tripletYN, 1)/triNum;
        else
            results (bcount, 4) = 0;
        end
        results(bcount, 5) = triNum;
   
        [disLearnMethod, '-', flag,' #Q = ', num2str(triNum), fileLabel, num2str(loopVec(kkk)),' triplet test acc : ', num2str(results(bcount,1)), ', 1nn: ', num2str(results(bcount,2))]   
        bcount = bcount + 1;
    end
    cd results;
    cd (datasetName);
    dlmwrite(resultFile,results,'-append');
    %dlmwrite(tripleFile, triplet, '-append');
    %dlmwrite(tripleFile, [-1, -1, -1], '-append');
    cd ..;
    cd ..;
    % record selected triples
end


end