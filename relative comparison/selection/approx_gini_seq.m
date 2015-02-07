function queries = approx_gini_seq (data, clustering, triplet)
cpt=random_forest (data (:, 1:end-1), clustering);
n = size (data, 1);
classNum = size (cpt, 2);
optA = zeros (1, classNum);
optA (1) = 0.5;
optA (2) = 0.5;
optMatA = repmat (optA, n, 1);
if (~isempty (triplet))
    cpt (triplet (:, 1), :)=-ones (size (triplet, 1), classNum);
end
  
% find point A
cptSort = sort (cpt, 2, 'descend');
diffSum = sum(abs (cptSort-optMatA), 2);
p = randperm (length(diffSum));
diffSum = diffSum (p);
[~, indexOfA] = min (diffSum);
indexOfA = p(indexOfA);
% find point B
probA = cpt (indexOfA, :);
[~, indexOfBC] = sort (probA, 2, 'descend');
clusterOfB = indexOfBC (1);
clusterOfC = indexOfBC (2);
probB = cpt (clusterOfB);
probB (indexOfA) = -1;
p = randperm (length(probB));
probB = probB (p);
[~, indexOfB] = max(probB);
indexOfB = p(indexOfB);
% find point C
probC = cpt (clusterOfC);
probC (indexOfA) = -1;
probC (indexOfB) = -1;
p = randperm (length(probC));
probC = probC (p);
[~, indexOfC] = max(probC);
indexOfC = p (indexOfC);
queries = [indexOfA, indexOfB, indexOfC];                   
end
