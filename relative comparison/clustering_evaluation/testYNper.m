function [accDif1, accDif0] = testYNper (data, weight)
triNum = 1000;
correctNumDif1 = 0;
correctNumDif0 = 0;
kkk = 1;
label = unique (data (:, end));
classNum = length(label);
triplet = [];
while (kkk <= triNum)
    while (1)
        p = randperm (classNum);
        ijNum = label(p(1));
        kNum = label(p(2));
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
        dis_ij = ((data (i,1:end-1) - data (j,1:end-1)).^2)*weight;
        dis_ik = ((data (i,1:end-1) - data (k,1:end-1)).^2)*weight;
        if dis_ij <= dis_ik - 1
            correctNumDif1 = correctNumDif1 + 1;
        end
        if dis_ij < dis_ik
            correctNumDif0 = correctNumDif0 + 1;
        end
    end
end
accDif1 = correctNumDif1/triNum;
accDif0 = correctNumDif0/triNum;
end