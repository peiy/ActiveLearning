function acc = testYNDisper(trueData, data)
%triNum = n*(n-1)*(n-2)/2;
n = size (trueData, 1);
sampleNum = n*(n-1)*(n-2)/2;
sampleTriple = ones (sampleNum, 3);
upMat = ones (n-1);
upMat = triu (upMat, 1);
jkId = find (upMat==1);
kId = fix(jkId / (n-1))+1;
jId = jkId - (kId-1)*(n-1);
for i = 1:n
    jkPts = setdiff(1:n, i)';
    jPts = jkPts (jId);
    kPts = jkPts (kId);
    temp = [jPts, kPts];
    temp1 = i*ones ((n-1)*(n-2)/2,1);
    sampleTriple (1+(i-1)*(n-1)*(n-2)/2:i*(n-1)*(n-2)/2, :) = [temp1, temp];     
end

% sample sampleNum triples in test data to evaluate weight
% while (triNum > 0)
%    vec = random('unid',maxUni,triNum, 1);
%    % remove identical triples in sampling
%    vec = unique (vec);
%    vec =  vec - 1;
%    % remove triples in sampleTriple
%    if ~isempty(sampleTriple) && ~isempty (vec)
%       sampleTriVec = (sampleTriple (:, 1) - 1) * n^2 + (sampleTriple (:, 2) - 1) * n + (sampleTriple (:, 3) - 1);
%       sampleTriVec2 = (sampleTriple (:, 1) - 1) * n^2 + (sampleTriple (:, 3) - 1) * n + (sampleTriple (:, 2) - 1);
%       vec = setdiff (vec, sampleTriVec);
%       vec = setdiff (vec, sampleTriVec2);
%    end
%    % remove triple that i equal to j, j equal to k or k equal to i   
%    if ~isempty(vec)
%       vec = num2vec (vec, n);   
%       vec_i = (vec (:, 1)) + 1;
%       vec_j = (vec (:, 2)) + 1;
%       vec_k = (vec (:, 3)) + 1;
%       index_ijeq = (vec_i == vec_j);
%       index_ikeq = (vec_i == vec_k);
%       index_jkeq = (vec_j == vec_k);
%       index_eq = index_ijeq | index_ikeq | index_jkeq;
%       triplet = [vec_i, vec_j, vec_k];
%       triplet = triplet (~index_eq, :);
%       sampleTriple = vertcat (sampleTriple,triplet);       
%       triNum = triNum - size (triplet, 1);   
%    end
% end

i = sampleTriple (:, 1);
j = sampleTriple (:, 2);
k = sampleTriple (:, 3);
dis_ij = sum((data (i,:) - data (j,:)).^2, 2);
dis_ik = sum((data (i,:) - data (k,:)).^2, 2); 
dis_ijTrue = sum((trueData (i,:) - trueData (j,:)).^2, 2);
dis_ikTrue = sum((trueData (i,:) - trueData (k,:)).^2, 2);
corId = ((dis_ij <= dis_ik & dis_ijTrue <= dis_ikTrue) | (dis_ij > dis_ik & dis_ijTrue > dis_ikTrue));
acc = sum(corId)/sampleNum;

end

