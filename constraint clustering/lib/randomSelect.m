function [pairs, neighbor] = randomSelect(data, numPair)
n = size (data, 1);
if (numPair > 0)
    maxUni = n^2;
    triNum = numPair;
    pairs = zeros (numPair, 3);
    count = 0;
    while (triNum > 0)
        vec = random('unid',maxUni,triNum,1);
        vec = unique (vec);
        vec =  vec - 1;
        if ~isempty(pairs) && ~isempty (vec)
            pairVec1 = (pairs (:, 1) - 1) * n^2 + (pairs (:, 2) - 1) * n + (pairs (:, 3) - 1);
            pairVec2 = (pairs (:, 1) - 1) * n^2 + (pairs (:, 3) - 1) * n + (pairs (:, 2) - 1);
            vec = setdiff (vec, pairVec1);
            vec = setdiff (vec, pairVec2);
        end
        if ~isempty (vec)
            vec = num2Pair (vec, n);
            vec_i = (vec (:, 1)) + 1;
            vec_j = (vec (:, 2)) + 1;
            index_ijeq = (vec_i == vec_j);
            pairTemp = [vec_i,vec_j,data(vec_i,end)==data(vec_j,end)];
            pairTemp (pairTemp (:, 3) == 0, 3) = -1;
            pairTemp = pairTemp (~index_ijeq, :);
            pairs (count+1:count+size (pairTemp, 1), :) = pairTemp;       
            triNum = triNum - size (pairTemp, 1);
            count = count + size (pairTemp, 1);
        end
    end
    if ~isempty (pairs)
        neighbor = generateNeighbor (pairs);
    else
        neighbor = [];
    end
else
    pairs = [];
    a = randi (n,1,1);
    neighbor{1} = a;
end
end

function vec = num2Pair (num, n)
vec = zeros (length(num), 2);
vec (:,2) = mod (num, n);
vec (:,1) = (num - vec (:,2))./n;
end

function neighbor = generateNeighbor (pairs)
    idxML = (pairs (:, 3) == 1);
    idxCL = (pairs (:, 3) == -1);
    if sum (idxCL)~= 0
        a = find (idxCL == 1);
        neighbor=cell(1,2);
        neighbor{1}(1) = pairs (a(1), 1);
        neighbor{2}(1) = pairs (a(1), 2);
    else
        b = find (idxML == 1);
        neighbor=cell(1,1);
        neighbor{1}(1) = pairs (b(1), 1);
        neighbor{1}(2) = pairs (b(1), 2);
    end     
end
