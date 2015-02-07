function randPairList = random_pairs(conMat, test, n, nps)
    % randPairList: random selection of #nps pairs among avialable pairs.
    
    pairs = ones(n);
    pairs(conMat~=0) = 0;
    
    pairs (1:n, test) = 0;
    pairs (test, 1:n) = 0;
    
    [unused_i_indices, unused_j_indices] = find(triu(pairs,1)==1);
    unusedIndices = [unused_i_indices, unused_j_indices];
    
    if(nps>1)
        l = 1:length(unusedIndices);
        rands = [];
        while(length(rands) < nps)
            list = random('unid', length(l), (nps-length(rands)),1);
            list = unique(list);
            list = l(list);
            l = setdiff(l,list); 
            x = length (rands);
            rands (x+1:x+length(list)) = list;
        end
        randPairList = unusedIndices(rands, :);
    else
        randPairList = unusedIndices(random('unid', size(unusedIndices,1), nps,1), :);        
    end
end
