function [uncertainPointRaw,nPairs, neighbor, nq] = uncertain_density(nq, neighbor, train, test, rawData, coassociation, flag1, flag2, dataset, num, nq_initial)
classNum = length(unique(rawData(:,end)));
neighborNum = length (neighbor);
n = length (rawData);
nPairs = [];
for i = 1:neighborNum
    neighborRaw{i} = train(neighbor{i});
end
NeighborPoints = [];
for i = 1:neighborNum
    NeighborPoints (end+1: end+length(neighborRaw{i})) = neighborRaw{i};
end
PtsNotInNeighbor = setdiff (1:n, NeighborPoints);
% p (y in Neighbor) y is points not included in neighborhood
probInNeighbor = zeros (length(PtsNotInNeighbor), length(neighbor));
for i = 1:length(neighbor)
    %for j = 1:length(PtsNotInNeighbor)
        probInNeighbor(:, i) = sum (coassociation (PtsNotInNeighbor, neighborRaw{i}), 2)/length (neighborRaw{i}); % average, max, exponential, incorporate neighborhood size into probability
    %end
end

if length(neighborRaw) == 1
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
data = rawData (:, 1:end-1);
distance = -1*ones (n);
if exist('specialPts', 'var')
    uncertainty (specialPts) = 1;
end

uncertainty_final = zeros (length(PtsNotInNeighbor), 1);
for i = 1:n 
    point = repmat (data(i, :), n ,1);
    dif = data - point;
    Dis = sum(dif.*dif,2);
    distance (:,i) = sqrt(Dis);
end    
distanceLine = reshape (distance, n*n, 1);
distanceLine (distanceLine == 0) = [];
distanceLine = sort (distanceLine);
distanceNotInNeighbor = distance (PtsNotInNeighbor, PtsNotInNeighbor);
if isequal (flag2, 'EPSILON')
    radius = distanceLine (ceil(length(distanceLine)/5));
    for i = 1:length(PtsNotInNeighbor)
        temp = (distanceNotInNeighbor (:,i) < radius);       
        uncertainty_final (i) = sum(uncertainty(temp));            
    end
elseif isequal (flag2, 'DECAY')
    sigma = distanceLine (ceil(length(distanceLine)/2)); 
    for i = 1:length(PtsNotInNeighbor)
        uncertainty_final (i) = sum(uncertainty.*exp(-distanceNotInNeighbor(:, i).^2/(2*sigma^2)));            
    end    
end




% denominator, expected number of queries
if isequal (flag1, 'EQNEW')
%     exNumQuery = zeros (length(PtsNotInNeighbor), 1);
%     for i = 1:length(PtsNotInNeighbor)  
%         for j = 1:length(neighbor)
%             exNumQuery(i) = exNumQuery(i) + j*probSorted(i,j);
%         end
%     end
    exNumQuery = probSorted * [1:length(neighbor)]';

elseif isequal (flag1, 'NEQNEW')
    exNumQuery = ones (length(PtsNotInNeighbor), 1);
end



% final objective function
fFunction = uncertainty_final./exNumQuery;

% record final objective function
if num == 1
    fFunctionRaw = -1*ones (n, 1);
    fFunctionRaw (PtsNotInNeighbor) = fFunction;
    fileName = [dataset, '-pt-new-RF-', flag1, '-', flag2, '-', num2str(nq_initial), '-1-uncertainty.data'];
    cd 'results';
    cd (dataset);
    dlmwrite (fileName, fFunctionRaw, '-append');
    cd ..;
    cd ..;
end


rp = randperm (length(PtsNotInNeighbor));
fFunction = fFunction(rp);
[~, ppp] = max (fFunction);
uncertainPoint = rp (ppp);
uncertainPointRaw = PtsNotInNeighbor (uncertainPoint);
i = 1;
% query this point
while nq>0 && i <=neighborNum
    flag = (rawData (neighborRaw{probSortedIndex(uncertainPoint,i)}(1), end) == rawData (uncertainPointRaw, end));
    nq = nq - 1;
    if flag == 0
        flag = flag - 1;
    end
    nPairs (end+1, :) = [neighborRaw{probSortedIndex(uncertainPoint,i)}(1), uncertainPointRaw, flag];
    if flag == 1
        neighbor{probSortedIndex(uncertainPoint,i)}(end+1) = find (train == uncertainPointRaw);
        break;
    elseif flag == -1 && i == neighborNum
        neighbor{end+1}(1) = find (train == uncertainPointRaw);
    end    
    i = i + 1;
    
end







end
