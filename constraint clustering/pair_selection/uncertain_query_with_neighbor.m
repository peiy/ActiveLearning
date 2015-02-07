function [uncertainPointRaw,nPairs, neighbor, nq] = uncertain_query_with_neighbor(nq, neighbor, train, test, rawData, coassociation, flag, datasetName, fileName)
classNum = length(unique(rawData(:,end)));
n = length (rawData);
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
% p (y in Neighbor) y is points not included in neighborhood
probInNeighbor = zeros (length(PtsNotInNeighbor), length(neighbor));
for i = 1:length(neighbor)
    for j = 1:length(PtsNotInNeighbor)
        probInNeighbor(j, i) = sum (coassociation (PtsNotInNeighbor(j), neighborRaw{i}), 2)/length (neighborRaw); % average, max, exponential, incorporate neighborhood size into probability
    end
end

% normalize probInNeighbor
for i = 1:length(PtsNotInNeighbor)
    if sum(probInNeighbor(i,:), 2) ~= 0
        probInNeighbor(i,:) = probInNeighbor(i,:)/sum(probInNeighbor(i,:), 2);
    else
        probInNeighbor(i,:) = 0;
    end
end
flagLabel = sum(probInNeighbor, 2) == 0;
[probSorted, probSortedIndex] = sort (probInNeighbor, 2, 'descend');

% decide which point to query
% enumerator, entropy of point included in neighborhood
uncertainty = zeros (length(PtsNotInNeighbor), 1);
probInNeighbor (probInNeighbor == 0) = 1;
for i = 1:length(PtsNotInNeighbor)
    uncertainty(i) = sum (-probInNeighbor(i,:).*log2(probInNeighbor(i,:)), 2);
end
% denominator, expected number of queries
if isequal (flag, 'EQRF')
    exNumQuery = zeros (length(PtsNotInNeighbor), 1);
    for i = 1:length(PtsNotInNeighbor)  
        for j = 1:length(neighbor)
%             if j ~= length(neighbor)
%                 exNumQuery(i) = exNumQuery(i) + j*probSorted(i,j);
%             else
%                 exNumQuery(i) = exNumQuery(i) + (j-1)*probSorted(i,j);
%             end
            exNumQuery(i) = exNumQuery(i) + j*probSorted(i,j);
        end
    end
elseif isequal (flag, 'NEQRF')
    exNumQuery = ones (length(PtsNotInNeighbor), 1);
end
cd results;
cd (datasetName);
% final objective function
fFunction = uncertainty./exNumQuery;
fFunction (flagLabel) = 100;
probRaw = ones (n,1) * -1;
probRaw (PtsNotInNeighbor) = probSorted (:, 1);
fFunctionRaw = ones (n ,1) * -1;
fFunctionRaw (PtsNotInNeighbor) = fFunction;


rp = randperm (length(PtsNotInNeighbor));
fFunction = fFunction(rp);
[~, ppp] = max (fFunction);
uncertainPoint = rp (ppp);
uncertainPointRaw = PtsNotInNeighbor (uncertainPoint);
i = 1;

% query this point
while nq>0 && i <=classNum
    flag = (rawData (neighborRaw{probSortedIndex(uncertainPoint,i)}(1), end) == rawData (uncertainPointRaw, end));
    
    %dlmwrite (fileName, [probRaw, fFunctionRaw], '-append');
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
cd ..;
cd ..;






end
