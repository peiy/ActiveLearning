function sampleTriple = random_policy (label, nq)
n = size (label, 1);
triNum = nq;
maxUni = n^3;
sampleTriple = [];
while (triNum > 0)
   vec = random('unid',maxUni,triNum,1);
   % remove identical triples in sampling
   vec = unique (vec);
   vec =  vec - 1;
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