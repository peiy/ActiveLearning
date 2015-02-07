function triplet = random_complete_dis (triNum, trueData, sampleTriple)
if isempty (sampleTriple)
    tripletRaw = subsample (trueData, triNum, []);  
else
    tripleNum = triNum;
    tripleId = [];
    while (tripleNum > 0)
        index = random('unid',size (sampleTriple, 1),tripleNum, 1);
        index = unique (index);
        if ~isempty (tripleId)
            index = setdiff (index, tripleId);
        end
        tripleNum = tripleNum - length(index);
        tripleId = vertcat(tripleId, index);        
    end
    tripletRaw = sampleTriple (tripleId, :);
end
dis_ij = sum((trueData (tripletRaw (:, 1), :) - trueData (tripletRaw (:, 2), :)).^2, 2);
dis_ik = sum((trueData (tripletRaw (:, 1), :) - trueData (tripletRaw (:, 3), :)).^2, 2);
indexY = (dis_ij <= dis_ik);
indexN = find (dis_ij > dis_ik);
tripletY = tripletRaw (indexY, :);
tripletN = horzcat(tripletRaw(indexN, 1),tripletRaw(indexN,3),tripletRaw (indexN,2));
triplet = vertcat (tripletY, tripletN);        
end
