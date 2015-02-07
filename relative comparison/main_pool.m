function main_pool (nq, nps, trainData, testData, wholeData, datasetName, num, flag, disLearnMethod, disFunc, sampleTripleId, poolTri, randNum)
[n, fNum] = size (wholeData);
c1 = 1;
nu = 1;
train = wholeData (trainData, :);
test = wholeData (testData, :);
classNum = length (unique (wholeData (:, end)));
if isequal (disLearnMethod, 'joachims')
    loopNum = length(c1);
    loopVec = c1;
    fileLabel = '-c1-';
elseif isequal (disLearnMethod, 'romer')
    loopNum = length(nu);
    loopVec = nu;
    fileLabel = '-nu-';
end
cd 'Data-Sets';
cd (datasetName);
fileName = [datasetName, '-true.data'];
trueData = load (fileName);
cd ..;
cd ..;
for kkk = 1:loopNum
    bcount = 1;
    results = zeros (nq/nps+1, 4);
    triVal = -1*ones (nq, 1);
    resultFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '.data'];
    tripleFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-triple.data'];
    folderFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-folder.data'];
    distriFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-distri.data'];
    disPtFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-disPt.data'];
    ruPerFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-ruPer.data'];
    ruNumFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-ruNum.data'];
    transDataFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-pool-', disFunc, '-transData.data'];
    tripletId = [];
    tripletYN = [];
    para = loopVec(kkk);
    transTrainData = train (:, 1:end-1);
    transTestData = test (:, 1:end-1);
    x = []; 
    cd results;
    cd (datasetName);
    dlmwrite (distriFile, num*100, '-append');       
    cd ..;
    cd ..;
    for triNum = 0:nps:randNum
        if triNum ~= 0         
            [tripletYN, tripletId] = random_pool (triNum, poolTri, sampleTripleId);                                                     
            [W, x] = metric_learning (disLearnMethod, train (:, 1:end-1), tripletYN, para, []); 
            transTrainData = train (:, 1:end-1) * W;
            transTestData = test (:, 1:end-1)* W;   
        end
        if num == 1
            transD = zeros (n, fNum);
            transD (trainData, 1:size (transTrainData, 2)) = transTrainData;
            transD (testData, 1:size (transTestData, 2)) = transTestData;    
            transD (:, end) = wholeData (:, end);
            cd results;
            cd (datasetName);
            dlmwrite (transDataFile, transD, '-append', 'delimiter',' ');
            cd ..;
            cd ..;   
        end
        clustering = kmeans(vertcat (transTrainData, transTestData), classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
        
        results(bcount,1) = testYNPoolper (transTestData, test(:,end));
        %results(bcount,1) = testYNDisper(trueData(testData, :), transTestData);
        results(bcount,2) = knn (transTrainData, transTestData, train (:, end), test (:, end));
        results(bcount,3) = nmi (clustering, vertcat (train (:, end), test (:, end)));
        results(bcount,4) = triNum;   
        [disLearnMethod, '-', flag,' #Q = ', num2str(triNum), fileLabel, num2str(loopVec(kkk)),' acc ', num2str(results(bcount,1)), ' 1NN ', num2str(results(bcount,2))]   
        bcount = bcount + 1;               
    end
    for triNum = randNum+1:nps:nq
        if isequal (flag, 'exRejSam') || isequal (flag, 'certainRej')
            [tripletId, value, triDis] = exRejSamPool (train (:, 1:end-1), poolTri, transTrainData, disFunc, tripletId, x, para, disLearnMethod, sampleTripleId, num, disPtFile, ruPerFile, ruNumFile, datasetName, flag);                            
            triVal (triNum) = value;
            tripletYN = poolTri (tripletId, :);
            cd results;
            cd (datasetName);
            dlmwrite (distriFile, [-triNum; triDis], '-append', 'delimiter',' ');       
            cd ..;
            cd ..;                                              
        elseif isequal (flag, 'uncertainSampling')
            [tripletId, value, triDis] = uncertainSamplePool (train (:, 1:end-1), poolTri, transTrainData, disFunc, tripletId, sampleTripleId, num, disPtFile, datasetName);                            
            triVal (triNum) = value;
            tripletYN = poolTri (tripletId, :);
            cd results;
            cd (datasetName);
            dlmwrite (distriFile, [-triNum; triDis], '-append', 'delimiter',' ');       
            cd ..;
            cd ..;               
        end
        [W, x] = metric_learning (disLearnMethod, train (:, 1:end-1), tripletYN, para, []); 
        transTrainData = train (:, 1:end-1) * W;
        transTestData = test (:, 1:end-1)* W;
        if num == 1
            transD = zeros (n, fNum);
            transD (trainData, 1:size (transTrainData, 2)) = transTrainData;
            transD (testData, 1:size (transTestData, 2)) = transTestData;   
            transD (:, end) = wholeData (:, end);
            cd results;
            cd (datasetName);
            dlmwrite (transDataFile, transD, '-append', 'delimiter',' ');
            cd ..;
            cd ..;   
        end
        clustering = kmeans(vertcat (transTrainData, transTestData), classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
        
        results(bcount,1) = testYNPoolper (transTestData, test(:,end));
        %results(bcount,1) = testYNDisper(trueData(testData, :), transTestData);
        results(bcount,2) = knn (transTrainData, transTestData, train (:, end), test (:, end));
        results(bcount,3) = nmi (clustering, vertcat (train (:, end), test (:, end)));
        results(bcount,4) = triNum;   
        [disLearnMethod, '-', flag,' #Q = ', num2str(triNum), fileLabel, num2str(loopVec(kkk)),' acc ', num2str(results(bcount,1)), ' 1NN ', num2str(results(bcount,2))]   
        bcount = bcount + 1;
    end
    header = [-num, -num, -num, -num];
    cd results;
    cd (datasetName);
    dlmwrite(resultFile,results, '-append', 'delimiter',' ');  
    % record selected triples
    tripletYN = trainData (tripletYN);
    tripletYN = horzcat (tripletYN, triVal);
    dlmwrite (tripleFile, [header; tripletYN], '-append', 'delimiter',' ');
    % record the folder split
    dlmwrite (folderFile, [-num; trainData], '-append', 'delimiter',' ');
    dlmwrite (ruPerFile, [-num, -num], '-append', 'delimiter',' ');
    cd ..;
    cd ..;     
end
end