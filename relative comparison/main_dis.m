function main_dis (nq, nps, trainData, testData, wholeData, datasetName, num, flag, disLearnMethod, disFunc, sampleTriple)
fNum = size (wholeData, 2) - 1;
c1 = 1;
c2 = [0.1, 0.5, 1, 5];
nu = 1;
train = wholeData (trainData, :);
test = wholeData (testData, :);
if isequal (disLearnMethod, 'joachims')
    loopNum = length(c1);
    loopVec = c1;
    fileLabel = '-c1-';
elseif isequal (disLearnMethod, 'svm_dkn')
    loopNum = length(c2);
    loopVec = c2;
    fileLabel = '-c2-';
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
    results = zeros (nq/nps+1, 3);
    triVal = -1*ones (nq, 1);
    resultFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '.data'];
    tripleFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '-triple.data'];
    folderFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '-folder.data'];
    distriFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '-distri.data'];
    disPtFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '-disPt.data'];
    ruPerFile = [datasetName, '-', disLearnMethod, '-', flag,'-' ,num2str(nq), '-', num2str(nps), fileLabel, num2str(loopVec(kkk)), '-trueDis-', disFunc, '-ruPer.data'];
    tripletYN = [];
    tripletDKN = [];
    para = loopVec(kkk);
    transTrainData = train (:, 1:end-1);
    transTestData = test (:, 1:end-1);
    x = []; 
    cd results;
    cd (datasetName);
    dlmwrite (distriFile, num*100, '-append');       
    cd ..;
    cd ..;
    for triNum = 0:nps:nq
        if triNum ~= 0 
            if isequal (flag, 'rejSam')
                [newQuery, value, triDis] = exDisRejSam (train (:, 1:end-1), transTrainData, disFunc, tripletYN, x, para, disLearnMethod, sampleTriple, num, disPtFile, ruPerFile, datasetName);            
                tripletYN  = oracle_dis (newQuery, tripletYN, trueData (trainData, :));
                triVal (triNum) = value;
                cd results;
                cd (datasetName);
                dlmwrite (distriFile, [-triNum; triDis], '-append');       
                cd ..;
                cd ..;                
            elseif isequal (flag, 'random_complete')
                tripletYN  = random_complete_dis (triNum, trueData (trainData, :), sampleTriple);
            elseif isequal (flag, 'rankSelect')             
                [newQuery, value, triDis] = rankSelect (train (:, 1:end-1), transTrainData, disFunc, tripletYN, x, para, disLearnMethod, sampleTriple, num, disPtFile, ruPerFile, datasetName);
                tripletYN  = oracle_dis (newQuery, tripletYN, trueData (trainData, :));
                triVal (triNum) = value;
                cd results;
                cd (datasetName);
                dlmwrite (distriFile, [-triNum; triDis], '-append');       
                cd ..;
                cd ..;                                
            end
            [W, x] = metric_learning (disLearnMethod, train (:, 1:end-1), tripletYN, para, []); 
            transTrainData = train (:, 1:end-1) * W;
            transTestData = test (:, 1:end-1)* W;
            % elseif isequal (disLearnMethod, 'svm_dkn')
            %    [w, x] = svmDisLearning_dkn (tripletYN, tripletDKN, c1, loopVec(kkk), train (:, 1:end-1));     
        end
        results(bcount,1) = testYNDisper(trueData(testData, :), transTestData);
        results(bcount,2) = knn (transTrainData, transTestData, train (:, end), test (:, end));
        results(bcount,3) = triNum;   
        [disLearnMethod, '-', flag,' #Q = ', num2str(triNum), fileLabel, num2str(loopVec(kkk)),' acc ', num2str(results(bcount,1)), ' 1NN ', num2str(results(bcount,2))]   
        bcount = bcount + 1;
    end
    header = [-num, -num, -num, -num];
    cd results;
    cd (datasetName);
    dlmwrite(resultFile,results, '-append');  
    % record selected triples
    tripletYN = horzcat (tripletYN, triVal);
    dlmwrite (tripleFile, [header; tripletYN], '-append');
    % record the folder split
    dlmwrite (folderFile, [-num; trainData], '-append');
    dlmwrite (ruPerFile, -num, '-append');
    cd ..;
    cd ..;     
end
end

