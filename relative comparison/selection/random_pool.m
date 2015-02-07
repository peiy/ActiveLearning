function [triplet, tripleId] = random_pool(sampleNum, poolTri, sampleTripleId)
if isempty (sampleTripleId)
    n = size (poolTri, 1);   
else
    n = length (sampleTripleId);
end
triNum = sampleNum;
tripleId = [];
while (triNum > 0)
    vec = random('unid',n,triNum,1);
    vec = unique (vec);  
    if ~isempty(tripleId) && ~isempty (vec)
        vec = setdiff (vec, tripleId);
    end
    if ~isempty (vec)    
        tripleId = vertcat (tripleId,vec);       
        triNum = triNum - length (vec);
    end
end
if ~isempty (sampleTripleId)
    tripleId = sampleTripleId (tripleId);
end
triplet = poolTri (tripleId, :); 
end

