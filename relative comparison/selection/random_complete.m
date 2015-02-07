function [tripletYN, tripletDKN] = random_complete (label, nq)
% rejection sampling
n = length(label);
kkk = 1;
tripletYN = [];
tripletDKN = [];
while (kkk <= nq)
    p = randperm (n);
    i = p(1);
    j = p(2);
    k = p(3);
    flag = 0;
    for lll = 1:size(tripletYN, 1)
        if (isequal (tripletYN(lll, :), [i, j, k]) || isequal (tripletYN (lll, :), [i, k, j]))
            flag = 1;
        end
    end
    for lll = 1:size(tripletDKN, 1)
        if (isequal (tripletDKN(lll, :), [i, j, k]) || isequal (tripletDKN (lll, :), [i, k, j]))
            flag = 1;
        end
    end
    if (flag == 0)
        if (label(i)==label(j) && label(i)~=label(k))
            tripletYN (end+1, :) = [i, j, k];
        elseif (label(i)~=label(j) && label(i)==label(k))
            tripletYN (end+1, :) = [i, k, j];
        else
            tripletDKN (end+1, :) = [i, j, k];
        end
        kkk = kkk + 1;    
    end
end
end