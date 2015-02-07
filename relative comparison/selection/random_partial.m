function triplet = random_partial (label, nq)
classNum = length (label);
kkk = 1;
triplet = [];
while (kkk <= nq)
    while (1)
        p = randperm (classNum);
        ijNum = label(p(1));
        kNum = label(p(2));
        clusterOne = find (label == ijNum);
        clusterTwo = find (label == kNum);
        if length(clusterOne) >= 2
            break;
        end
    end
    p = randperm (length(clusterOne));
    i = clusterOne(p(1));
    j = clusterOne(p(2));
    p = randperm (length(clusterTwo));
    k = clusterTwo(p(1));
    flag = 0;
    for lll = 1:size(triplet, 1)
        if (isequal (triplet(lll, :), [i, j, k]) || isequal (triplet (lll, :), [i, k, j]))
            flag = 1;
        end
    end
    if (flag == 0)
        triplet (end+1, :) = [i, j, k];
        kkk = kkk + 1;
    end
end
end
