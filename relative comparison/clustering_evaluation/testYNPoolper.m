function acc = testYNPoolper(data, label)
n = size (data, 1);
    if n < 500
        poolTri = generatePool ([data, label]);
        i = poolTri (:,1);
        j = poolTri (:,2);
        k = poolTri (:,3);
        dis_ij = sum ((data (i, :) - data (j, :)).^2, 2);
        dis_ik = sum ((data (i, :) - data (k, :)).^2, 2);
        acc = sum(dis_ij < dis_ik)/length(dis_ik);
    else
        triplet = [];
        triNum = 10000;
        sampleNum = triNum;
        while sampleNum > 0
            temp = subsample(data, sampleNum, triplet);
            iLabel = label (temp (:, 1));
            jLabel = label (temp (:, 2));
            kLabel = label (temp (:, 3));
            idxY = (iLabel == jLabel) & (iLabel ~= kLabel);
            idxN = (iLabel == kLabel) & (iLabel ~= jLabel);
            triplet1 = temp (idxY, :);
            triplet2 = temp (idxN, :);
            triplet2 = [triplet2(:,1),triplet2(:,3),triplet2(:,2)];
            triplet = vertcat (triplet,triplet1,triplet2);            
            sampleNum = sampleNum - size (triplet1, 1) - size (triplet2, 1);        
        end
        i = triplet (:,1);
        j = triplet (:,2);
        k = triplet (:,3);
        dis_ij = sum ((data (i, :) - data (j, :)).^2, 2);
        dis_ik = sum ((data (i, :) - data (k, :)).^2, 2);
        acc = sum(dis_ij < dis_ik)/length(dis_ik);
    end
end

