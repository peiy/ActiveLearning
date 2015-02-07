function acc = tripleAcc (triplet, data)
triNum = size (triplet, 1);
count = 0;
for l = 1:triNum
    i = triplet (l, 1);
    j = triplet (l, 2);
    k = triplet (l, 3);
    disij = sum((data (i, :) - data (j, :)).^2);
    disik = sum((data (i, :) - data (k, :)).^2);
    if (disij <= disik - 1)
        count = count + 1;
    end    
end
acc = count/triNum;
end