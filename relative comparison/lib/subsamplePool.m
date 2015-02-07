function sampleTripleId = subsamplePool(n, sampleNum, tripletId)
% SUBSAMPLEPOOL Summary of this function goes here
% sample triplets index from active learning pool
%   Detailed explanation goes here
% n: number of triplets in the pool
% sampleNum: the number of triplets to be sampled
% tripletId: existing triplets index that should not be sampled again
triNum = sampleNum;
sampleTripleId = [];
while (triNum > 0)
   vec = random('unid',n,triNum,1);
   % remove identical triples in sampling
   vec = unique (vec);  
   % remove triples in tripletYN
   if ~isempty(tripletId) && ~isempty (vec)
      vec = setdiff (vec, tripletId);
   end 
   % remove triples in sampleTriple
   if ~isempty(sampleTripleId) && ~isempty (vec)
      vec = setdiff (vec, sampleTripleId);
   end
   % remove triple that i equal to j, j equal to k or k equal to i
   if ~isempty (vec)    
      sampleTripleId = vertcat (sampleTripleId,vec);       
      triNum = triNum - length (vec);
   end
end
end

