function fathest_first_plus (nq, nps, trainData, testData, wholeData, datasetName, num, clusterMethod, secondPhase)
n1 = length(trainData);
n2 = length(testData);
n = n1+n2;
results = zeros(nq/nps+1,6);
bcount = 0;
for i = 0:nps:nq
    conMat = eye (n);
    if i == 0 
        if isequal (clusterMethod, 'MPCKmeans')
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -O ', datasetName, 'Result.data'];
            dos (x);   
            [~, ~, ~, clustering] = getResult (datasetName, wholeData);
            cd ..;
            cd ..;
        elseif isequal (clusterMethod, 'ccskl')
            clustering = ccskl ([], wholeData);
        elseif isequal (clusterMethod, 'sl')
            clustering = sl ([], wholeData);
        end
        count = i;  
        bcount = bcount + 1;
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
        results(bcount,3) = accuracy(wholeData(:, end), clustering);    
        results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
        results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
        results(bcount,6) = count;   
        [secondPhase, '++#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]  
    elseif i>0
        [neighborhood, j, selectPairs] = explorer_plus (i, trainData, testData, wholeData);
        if j > 0
            if isequal (secondPhase, 'consolidate')
                [neighborhood, selectPairs] = consolidate (neighborhood, j, wholeData, selectPairs, trainData);
            elseif isequal (secondPhase, 'minmax')
                [neighborhood, selectPairs] = minmax (neighborhood, j, wholeData, selectPairs, trainData);
            end
        end
        % creat constraint files
        conMat((selectPairs(:,2)-1)*n + selectPairs(:,1)) = selectPairs(:, 3);
        conMat((selectPairs(:,1)-1)*n + selectPairs(:,2)) = selectPairs(:, 3);
        [conMat, augPairs] = transitive_closure (conMat, selectPairs(:,1:2), n);
        
        if isequal (clusterMethod, 'MPCKmeans')
            creatContraintsFile (conMat, datasetName);
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data'];
            dos (x);   
            [~, ~, ~, clustering] = getResult (datasetName, wholeData);
            cd ..;
            cd ..;
        elseif isequal (clusterMethod, 'ccskl')
            clustering = ccskl (augPairs, wholeData);
        elseif isequal (clusterMethod, 'sl')
            clustering = sl (augPairs, wholeData);
        end
        count = i;
        bcount = bcount + 1;
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = nmi(wholeData(testData, end), clustering(testData));
        results(bcount,3) = accuracy(wholeData(:, end), clustering);    
        results(bcount,4) = accuracy(wholeData(testData, end), clustering(testData));
        results(bcount,5) = fmeasure(wholeData(:, end), clustering, trainData, testData);
        results(bcount,6) = count;   
        [secondPhase, '++#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    end
end
cd results;
cd (datasetName);
if isequal (secondPhase, 'consolidate')
    fileName = [datasetName, '-farthest-first-plus-',num2str(nq), '-', num2str(nps), '-', clusterMethod,'.data'];
    visualName = [datasetName, '-farthest-first-plus-',num2str(nq), '-', num2str(nps), '-constraints.data'];
elseif isequal (secondPhase, 'minmax')
    fileName = [datasetName, '-minmax-plus-',num2str(nq), '-', num2str(nps), '-', clusterMethod,'.data'];
    visualName = [datasetName, '-minmax-plus-',num2str(nq), '-', num2str(nps), '-constraints.data'];
end   
dlmwrite(fileName,results,'-append');
dlmwrite(visualName, selectPairs, '-append');
cd ..;
cd ..;
end





