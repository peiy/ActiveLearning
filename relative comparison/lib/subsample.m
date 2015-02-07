function sampleTriple = subsample(data, sampleNum, tripletYN)
n = size (data, 1);
triNum = sampleNum;
maxUni = n^3;
sampleTriple = [];
while (triNum > 0)
   vec = random('unid',maxUni,triNum,1);
   % remove identical triples in sampling
   vec = unique (vec);
   vec =  vec - 1;
   % remove triples in tripletYN
   if ~isempty(tripletYN) && ~isempty (vec)
      triYNvec = (tripletYN (:, 1) - 1) * n^2 + (tripletYN (:, 2) - 1) * n + (tripletYN (:, 3) - 1);
      triYNvec2 = (tripletYN (:, 1) - 1) * n^2 + (tripletYN (:, 3) - 1) * n + (tripletYN (:, 2) - 1);
      vec = setdiff (vec, triYNvec);
      vec = setdiff (vec, triYNvec2);
   end 
   % remove triples in sampleTriple
   if ~isempty(sampleTriple) && ~isempty (vec)
      sampleTriVec = (sampleTriple (:, 1) - 1) * n^2 + (sampleTriple (:, 2) - 1) * n + (sampleTriple (:, 3) - 1);
      sampleTriVec2 = (sampleTriple (:, 1) - 1) * n^2 + (sampleTriple (:, 3) - 1) * n + (sampleTriple (:, 2) - 1);
      vec = setdiff (vec, sampleTriVec);
      vec = setdiff (vec, sampleTriVec2);
   end
   % remove triple that i equal to j, j equal to k or k equal to i
   if ~isempty (vec)
      vec = num2vec (vec, n);
      vec_i = (vec (:, 1)) + 1;
      vec_j = (vec (:, 2)) + 1;
      vec_k = (vec (:, 3)) + 1;
      index_ijeq = (vec_i == vec_j);
      index_ikeq = (vec_i == vec_k);
      index_jkeq = (vec_j == vec_k);
      index_eq = index_ijeq | index_ikeq | index_jkeq;
      triplet = [vec_i, vec_j, vec_k];
      triplet = triplet (~index_eq, :);
      sampleTriple = vertcat (sampleTriple,triplet);       
      triNum = triNum - size (triplet, 1);
   end
end
end

