function acc = testTriAcc (test, tranData, label)
triNum = 40000;
correctNum = 0;
data = horzcat(tranData (test, :), label(test));
kkk = 0;
classNum = length(unique (label(test)));
triplet = [];
while (kkk <= triNum)
    while (1)
        p = randperm (classNum);
        ijNum = p(1);
        kNum = p(2);
        clusterOne = find (data (:, end) == ijNum);
        clusterTwo = find (data (:, end) == kNum);
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
        if (isequal (triplet(lll, :), [i, j, k]))
            flag = 1;
        end
    end
    if (flag == 0)
        triplet (end+1, :) = [i, j, k];
        kkk = kkk + 1;
        dis_ij = sum((data (i,1:end-1) - data (j,1:end-1)).^2);
        dis_ik = sum((data (i,1:end-1) - data (k,1:end-1)).^2);
        if dis_ij <= dis_ik
            correctNum = correctNum + 1;
        end        
    end
end
acc = correctNum/triNum;
end