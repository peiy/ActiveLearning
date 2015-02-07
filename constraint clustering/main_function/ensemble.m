function [uncertainPointRaw, nPairs, neighbor, nq] = ensemble(nps, nq, neighbor, train, test, rawData, n, conMat, consPairs, datasetName, flag)
classNum = length(unique(rawData(:,end)));
nPairs = [];
for i = 1:classNum
    neighborRaw{i} = train(neighbor{i});
end
NeighborPoints = [];
for i = 1:classNum
    NeighborPoints (end+1: end+length(neighborRaw{i})) = neighborRaw{i};
end
PtsNotInNeighbor = setdiff (1:n, NeighborPoints);
% ensemble method to calculate coassocation matrix
coassociation = CoMatrix (rawData, consPairs, 50, datasetName);
% p (y in Neighbor) y is points not included in neighborhood
probInNeighbor = zeros (length(PtsNotInNeighbor), length(neighbor));
for i = 1:length(neighbor)
    for j = 1:length(PtsNotInNeighbor)
        probInNeighbor(j, i) = sum (coassociation (PtsNotInNeighbor(j), neighborRaw{i}), 2)/length (NeighborPoints); % average, max, exponential, incorporate neighborhood size into probability
    end
end

% normalize probInNeighbor
for i = 1:length(PtsNotInNeighbor)
    probInNeighbor(i,:) = probInNeighbor(i,:)/sum(probInNeighbor(i,:), 2);
end
[probSorted, probSortedIndex] = sort (probInNeighbor, 2, 'descend');

% decide which point to query
% enumerator, entropy of point included in neighborhood
uncertainty = zeros (length(PtsNotInNeighbor), 1);
probInNeighbor (probInNeighbor == 0) = 1;
for i = 1:length(PtsNotInNeighbor)
    uncertainty(i) = sum (-probInNeighbor(i,:).*log2(probInNeighbor(i,:)), 2);
end
% denominator, expected number of queries
if isequal (flag, 'EQ')
    exNumQuery = zeros (length(PtsNotInNeighbor), 1);
    for i = 1:length(PtsNotInNeighbor)  
        for j = 1:length(neighbor)
            if j ~= length(neighbor)
                exNumQuery(i) = exNumQuery(i) + j*probSorted(i,j);
            else
                exNumQuery(i) = exNumQuery(i) + (j-1)*probSorted(i,j);
            end
        end
    end
elseif isequal (flag, 'NEQ')
    exNumQuery = ones (length(PtsNotInNeighbor), 1);
end

% final objective function
fFunction = uncertainty./exNumQuery;
[~, uncertainPoint] = max (fFunction);
uncertainPointRaw = PtsNotInNeighbor (uncertainPoint);
i = 1;
% query this point
while nq>0 && i <=classNum
    flag = (rawData (neighborRaw{probSortedIndex(uncertainPoint,i)}(1), end) == rawData (uncertainPointRaw, end));
    nq = nq - 1;
    if flag == 0
        flag = flag - 1;
    end
    nPairs (end+1, :) = [neighborRaw{probSortedIndex(uncertainPoint,i)}(1), uncertainPointRaw, flag];
    if flag == 1
        neighbor{probSortedIndex(uncertainPoint,i)}(end+1) = find (train == uncertainPointRaw);
        break;
    end    
    i = i + 1;
end


end