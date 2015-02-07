function [accDif1, accDif0] = testDKNper(data, weight)
tripletYN = [];
tripletDKN = [];
n = size (data, 1);
kkk = 1;
triNum = 1000;
correctNumDif1 = 0;
correctNumDif0 = 0;
while (kkk <= triNum)    
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
        dis_ij = ((data (i,1:end-1) - data (j,1:end-1)).^2)*weight;
        dis_ik = ((data (i,1:end-1) - data (k,1:end-1)).^2)*weight;        
        if (data(i, end)==data(j, end) && data(i, end)~=data(k, end))
            tripletYN (end+1, :) = [i, j, k];
            if dis_ij <= dis_ik - 1
                correctNumDif1 = correctNumDif1 + 1;                                                
            end            
            if dis_ij < dis_ik
                correctNumDif0 = correctNumDif0 + 1;
            end
        elseif (data(i, end)~=data(j, end) && data(i, end)==data(k, end))
            tripletYN (end+1, :) = [i, k, j];
            if dis_ik <= dis_ij - 1
                correctNumDif1 = correctNumDif1 + 1;                                                
            end
            if dis_ik < dis_ij
                correctNumDif0 = correctNumDif0 + 1;
            end
        else
            tripletDKN (end+1, :) = [i, j, k];
            if abs(dis_ij-dis_ik) <= 1
                correctNumDif0 = correctNumDif0 + 1;   
                correctNumDif1 = correctNumDif1 + 1;
            end
        end
        kkk = kkk + 1;    
    end
end
accDif1 = correctNumDif1/triNum;
accDif0 = correctNumDif0/triNum;
end

