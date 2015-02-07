function IDX = svad_clustering (rawData, triplet, lr, mon)
t = 1;
maxIter = 100;
classNum = length(unique(rawData(:, end)));
fNum = size (rawData, 2) - 1;
gammaT = 1;
delta = 1;
n = size (rawData, 1);
wMat = 1/classNum*ones (classNum, fNum);
% Step 2: randomly assign the data points to K clusters
[clustering, centroid] =  kmeans (rawData (:, 1:end-1), classNum, 'Replicates', 10, 'EmptyAction', 'singleton');
while (t <= maxIter)
    % Step 3: computer the centroids
    for i = 1:classNum
        centroid (i, :) = mean(rawData (clustering == i, 1:end-1), 1);
    end
    % Step 4: determine the set of unsatisfied inequalities I(W, C)
    Iwc = [];
    for i = 1:size (triplet, 1)
        xi = rawData (triplet (i, 1), 1:end-1);
        xj = rawData (triplet (i, 2), 1:end-1);
        xk = rawData (triplet (i, 3), 1:end-1);
        dwij = sum(wMat(clustering(triplet(i,2)), :).*((xi-xj).^2));
        dwik = sum(wMat(clustering(triplet(i,3)), :).*((xi-xk).^2));
        if dwij > dwik
            Iwc = vertcat (Iwc, i);
        end                        
    end        
    dataIwcI = rawData (triplet (Iwc, 1), 1:end-1);
    dataIwcJ = rawData (triplet (Iwc, 2), 1:end-1);
    dataIwcK = rawData (triplet (Iwc, 3), 1:end-1);
    % Step 5: compute the intermediate weights wj'
    wMatUp = zeros (classNum, fNum);   
    for i = 1:classNum
        ithCluster = find (clustering == i);
        center = repmat (centroid(i, :), length(ithCluster), 1);
        Vju = sum((rawData (ithCluster, 1:end-1) - center).^2, 1);
        x1iInClusterj = intersect (triplet (Iwc, 1), ithCluster);
        Vjt = zeros (1, fNum);
        for j = 1:length(x1iInClusterj)             
            temp = (triplet (Iwc, 1) == x1iInClusterj(j));        
            Vjt = Vjt + sum((dataIwcJ (temp, :) - dataIwcI (temp, :)).^2 - (dataIwcK (temp, :) - dataIwcI (temp, :)).^2, 1);                       
        end
        wMatUp (i, :) = exp (-(Vju+gammaT*Vjt)/delta);
        wMatUp (i, :) = wMatUp (i,:) / sum (wMatUp (i, :));
    end
    % Step 6: update the weight wj
    wMat = (1-lr)*wMat + lr*wMatUp;
    % Step 7: update lr(t)
    lr = mon * lr;            
    % Step 8: reassign the data points
    for i = 1:n
        temp = repmat (rawData (i, 1:end-1), classNum, 1);
        disPtCen = sum(wMat.^((temp - centroid).^2), 2);
        [~, clusterNum] = min (disPtCen);
        clustering (i) = clusterNum;                
    end
    t = t + 1;
end    
IDX = clustering;
    



end