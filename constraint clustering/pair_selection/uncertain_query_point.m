function [uncertainPointRaw,nPairs, neighbor, nq] = uncertain_query_point(nq, neighbor, rawData, cpt, flag1, flag2, dataset, num, nq_initial)
classNum = length(unique(rawData(:,end)));
neighborNum = length (neighbor);
n = length (rawData);
nPairs = [];
NeighborPoints = [];
for i = 1:neighborNum
    NeighborPoints (end+1: end+length(neighbor{i})) = neighbor{i};
end
coassociation = cpt * cpt';
if length (NeighborPoints) ~= 1
    PtsNotInNeighbor = setdiff (1:n, NeighborPoints);
    % p (y in Neighbor) y is points not included in neighborhood
    probInNeighbor = zeros (length(PtsNotInNeighbor), length(neighbor));
    for i = 1:length(neighbor)
        %for j = 1:length(PtsNotInNeighbor)
        if isequal (flag1, 'PtMean')
            probInNeighbor(:, i) = sum (coassociation (PtsNotInNeighbor, neighbor{i}), 2)/length (neighbor); % average, max, exponential, incorporate neighborhood size into probability
        elseif isequal (flag1, 'PtMax')
            probInNeighbor(:, i) = max (coassociation (PtsNotInNeighbor, neighbor{i}), [], 2);
        elseif isequal (flag1, 'PtMin')
            probInNeighbor(:, i) = min (coassociation (PtsNotInNeighbor, neighbor{i}), [], 2);
        end
    end
    
    if length(neighbor) == 1
        specialPts = (sum (probInNeighbor, 2) == 0);
    end

    % normalize probInNeighbor
    for i = 1:length(PtsNotInNeighbor)
        if sum(probInNeighbor(i,:), 2)~= 0 
            probInNeighbor(i,:) = probInNeighbor(i,:)/sum(probInNeighbor(i,:), 2);
        else
            probInNeighbor(i,:) = 1/length(neighbor);
        end
    end

    [probSorted, probSortedIndex] = sort (probInNeighbor, 2, 'descend');

    % decide which point to query
    % enumerator, entropy of point included in neighborhood
    % uncertainty = zeros (length(PtsNotInNeighbor), 1);
    probInNeighbor (probInNeighbor == 0) = 1;
    % for i = 1:length(PtsNotInNeighbor)
    %     uncertainty(i) = sum (-probInNeighbor(i,:).*log2(probInNeighbor(i,:)), 2);
    % end
    uncertainty = sum(-probInNeighbor .* log2 (probInNeighbor), 2);


    % denominator, expected number of queries
    if isequal (flag2, 'normal')
    %     exNumQuery = zeros (length(PtsNotInNeighbor), 1);
    %     for i = 1:length(PtsNotInNeighbor)  
    %         for j = 1:length(neighbor)
    %             exNumQuery(i) = exNumQuery(i) + j*probSorted(i,j);
    %         end
    %     end
        exNumQuery = probSorted * [1:length(neighbor)]';
    elseif isequal (flag2, 'unnormal')
        exNumQuery = ones (length(PtsNotInNeighbor), 1);
    end

    if exist ('specialPts', 'var')
        uncertainty (specialPts) = 1;
    end
    % final objective function
    fFunction = uncertainty./exNumQuery;

    %record final objective function
%     if num == 1
%         fFunctionRaw = -1*ones (n, 1);
%         fFunctionRaw (PtsNotInNeighbor) = fFunction;
%         fileName = [dataset, '-pt-new-RF-', flag, '-', num2str(nq_initial), '-1-uncertainty.data'];
%         cd 'results';
%         cd (dataset);
%         dlmwrite (fileName, fFunctionRaw, '-append');
%         cd ..;
%         cd ..;
%     end
    rp = randperm (length(PtsNotInNeighbor));
    fFunction = fFunction(rp);
    [~, ppp] = max (fFunction);
    uncertainPoint = rp (ppp);
    uncertainPointRaw = PtsNotInNeighbor (uncertainPoint);
    i = 1;
    % query this point
    while nq>0 && i <=neighborNum
        flag = (rawData (neighbor{probSortedIndex(uncertainPoint,i)}(1), end) == rawData (uncertainPointRaw, end));
        nq = nq - 1;
        if flag == 0
            flag = flag - 1;
        end
        nPairs (end+1, :) = [neighbor{probSortedIndex(uncertainPoint,i)}(1), uncertainPointRaw, flag];
        if flag == 1
            neighbor{probSortedIndex(uncertainPoint,i)}(end+1) = uncertainPointRaw;
            break;
        elseif flag == -1 && i == neighborNum
            neighbor{end+1}(1) = uncertainPointRaw;
        end    
        i = i + 1;
    end
else
    aaa = coassociation (NeighborPoints, :);
    aaa (NeighborPoints) = 100;
    [~, uncertainPointRaw] = min (aaa);
    flag = (rawData (NeighborPoints, end) == rawData (uncertainPointRaw, end)); 
    if flag == 0
        flag = flag - 1;
    end
    nPairs = [NeighborPoints, uncertainPointRaw, flag];
    if flag == 1
        neighbor{1}(end+1) = uncertainPointRaw;
    else
        neighbor{end+1}(1) = uncertainPointRaw;
    end
    nq = nq - 1;   
end
end



