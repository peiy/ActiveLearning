function triplet = generatePool(wholeData)
% GENERATEPOOL Summary of this function goes here
% generate triplet pool for active learning, all triplets (i, j, k) such
% that label(i) = label (j) and label (j) ~= label (k)
%   Detailed explanation goes here
%   wholeData: data points with last column as labels
%   triplet: the pool of triplets
labelSet = unique (wholeData (:, end));
labels = wholeData (:, end);
classNum = length (labelSet);
triplet = [];
for i = 1:classNum
    label_ij = labelSet (i);
    label_k = setdiff (labelSet, label_ij);
    for j = 1:length(label_k)
        index_ij = find (labels == label_ij);
        if length(index_ij) >= 2
            triK = find (labels == label_k(j));
            n_ij = length(index_ij);
            ijIndex = nchoosek (1:n_ij, 2);
            triIj = index_ij (ijIndex);
            if size (triIj, 2) == 1
                triIj = triIj';
            end
            n_ijk = size (ijIndex, 1) * length (triK);
            temp1 = repmat (triIj, length (triK), 1);
            temp2 = repmat (triK, 1, size (ijIndex, 1));
            temp2 = reshape (temp2', n_ijk, 1);
            tri_ijk = [temp1, temp2];       
            triplet = vertcat (triplet, tri_ijk);
        end
    end    
end    
end

