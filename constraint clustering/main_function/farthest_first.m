function farthest_first (nq, nps, wholeData, datasetName, num, clusterMethod, exploreMethod, secondPhase, neighbor, randPair)
n = length(wholeData);
results = zeros(nq/nps+1,6);
bcount = 0;
for i = 0:nps:nq
    conMat = eye (n);
    if i == 0 
        if isequal (clusterMethod, 'MPCKmeans')
            [~, ~, ~, clustering] = MPCKmeans (datasetName, wholeData);
        end
        count = i;  
        bcount = bcount + 1;
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = -1;
        results(bcount,3) = accuracy(wholeData(:, end), clustering);    
        results(bcount,4) = -1;
        results(bcount,5) = f1(wholeData(:, end)', clustering');
        results(bcount,6) = count;   
        [exploreMethod, '-', secondPhase, '#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]  
    elseif i > 0
            if isequal (exploreMethod, 'normal')
                [neighborhood, j, selectPairs] = explorer (i, wholeData, neighbor, randPair);
            %elseif isequal (exploreMethod, 'plus')
            %    [neighborhood, j, selectPairs] = explorer_plus (i, trainData, testData, wholeData);
            %elseif isequal (exploreMethod, 'new')
            %    [neighborhood, j, selectPairs] = new_explore (i, trainData, testData, wholeData, datasetName);
            end
        if j > 0
            if isequal (secondPhase, 'consolidate')
                [neighborhood, selectPairs] = consolidate (neighborhood, j, wholeData, selectPairs);
            elseif isequal (secondPhase, 'minmax')
                [neighborhood, selectPairs] = minmax (neighborhood, j, wholeData, selectPairs);
            end
        end
        % creat constraint files
        conMat((selectPairs(:,2)-1)*n + selectPairs(:,1)) = selectPairs(:, 3);
        conMat((selectPairs(:,1)-1)*n + selectPairs(:,2)) = selectPairs(:, 3);        
        if isequal (clusterMethod, 'MPCKmeans')
            [~, ~, ~, clustering] = MPCKmeans (datasetName, wholeData, conMat);
        end
        count = i;
        bcount = bcount + 1;
        results(bcount,1) = nmi(wholeData(:, end), clustering);
        results(bcount,2) = -1;
        results(bcount,3) = accuracy(wholeData(:, end), clustering);    
        results(bcount,4) = -1;
        results(bcount,5) = f1(wholeData(:, end)', clustering');
        results(bcount,6) = count;   
        [exploreMethod, '-', secondPhase, '#Q = ', num2str(count), ': NMI: ', num2str(results(bcount,1)), ', ACC: ', num2str(results(bcount,3)), ', F1:', num2str(results(bcount,5))]   
    end
end
cd results;
cd (datasetName);
fileName = [datasetName, '-', exploreMethod, '-', secondPhase, '-', clusterMethod, '-', num2str(nq), '-', num2str(nps),'.data'];                 
visualName = [datasetName, '-', exploreMethod, '-', secondPhase, '-', clusterMethod, '-', num2str(nq), '-', num2str(nps),'-constraints.data'];                 
dlmwrite(visualName, selectPairs, '-append');
dlmwrite(fileName,results,'-append');
cd ..;
cd ..;
end





