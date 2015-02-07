function objVal = objFunValue(triple, data, tripletYN, measureTriple, x, para, disFlag, disLearnMethod, dis_mat, gauStd)
    objVal = zeros (1, 3);
    n = size (data, 1);
    nVec = (1:n)';
    nMat = repmat (nVec, 1, n);
    a = reshape (nMat', n*n, 1);
    b = reshape (nMat,  n*n, 1);
    %if isequal(disFlag, 'gaussian')
        %dis_vec = reshape (dis_mat, n*n, 1);
        %dis_vec = sort (dis_vec);
        %gauStd = sqrt(dis_vec (ceil(length(dis_vec)/10)));
    %    gauStd = 2* max(max (dis_mat));
    %end    
    i = triple (1);
    j = triple (2);
    k = triple (3);
    dis_ij = dis_mat (i, j);
    dis_ik = dis_mat (i, k);    
    if isequal (disFlag, 'gaussian')
        pRsY = normcdf(0,dis_ij-dis_ik,sqrt(2)*gauStd);
    elseif isequal (disFlag, 'logistic')
        pRsY = 1./(1+exp(dis_ij-dis_ik));
    elseif isequal (disFlag, 'expo')
        pRsY = dis_ik./(dis_ij+dis_ik);
        pRsY (dis_ij+dis_ik == 0) = 0.5;
    end
    % remove the selected triple in measureTriple
    triYNvec = (i - 1) * n^2 + (j - 1) * n + (k - 1);
    triYNvec2 = (i - 1) * n^2 + (k - 1) * n + (j - 1);
    measureTripleVec = (measureTriple (:, 1) - 1) * n^2 + (measureTriple (:, 2) - 1) * n + (measureTriple (:, 3) - 1);
    measureTripleVec = setdiff (measureTripleVec, triYNvec);
    measureTripleVec = setdiff (measureTripleVec, triYNvec2);
    measureTriple = num2vec (measureTripleVec, n);
    measureTriple = measureTriple + 1;
    % compute entropy         
    if pRsY ~= 0 && pRsY ~= 1
        if (dis_ik-dis_ij < 1 || isempty (tripletYN))
            tripletNew1 = vertcat (tripletYN, [i, j, k]);    
            if ~isempty (x)
                x0 = [x; 0];
            else
                x0 = x;
            end
            [WY, ~] = metric_learning (disLearnMethod, data, tripletNew1, para, x0);                
            transDataY = data*WY;
            dis_matY = zeros (n);
            dis_matY ((a-1)*n+b) = sqrt(sum((transDataY (a, :) - transDataY (b, :)).^2, 2));
        else 
            dis_matY = dis_mat;
        end        
        dis_ij_ruY = dis_matY((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
        dis_ik_ruY = dis_matY((measureTriple (:, 1)-1)*n + measureTriple (:, 3));
        if isequal (disFlag, 'gaussian')
            probYRu = normcdf (0, dis_ij_ruY-dis_ik_ruY, sqrt(2)*gauStd);
        elseif isequal (disFlag, 'logistic')
            probYRu = 1./(1+exp(dis_ij_ruY-dis_ik_ruY));
        elseif isequal (disFlag, 'expo')
            probYRu = dis_ik_ruY./(dis_ij_ruY+dis_ik_ruY);
            probYRu (dis_ij_ruY+dis_ik_ruY == 0) = 0.5;
        end
        probYRu (probYRu == 0 | probYRu == 1) = [];        
        enRuY = sum (-probYRu.*log2(probYRu)-(1-probYRu).*log2(1-probYRu));
        if (dis_ij-dis_ik < 1 || isempty (tripletYN))
            tripletNew2 = vertcat (tripletYN, [i, k, j]);
            if ~isempty (x)
                x0 = [x; 0];
            else
                x0 = x;
            end
            [WN, ~] = metric_learning (disLearnMethod, data, tripletNew2, para, x0); 
            transDataN = data*WN;
            dis_matN = zeros (n);
            dis_matN ((a-1)*n+b) = sqrt(sum((transDataN (a, :) - transDataN (b, :)).^2, 2));
        else 
            dis_matN = dis_mat;
        end 
        dis_ij_ruN = dis_matN ((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
        dis_ik_ruN = dis_matN ((measureTriple (:, 1)-1)*n + measureTriple (:, 3));
        if isequal (disFlag, 'gaussian')
            probNRu = normcdf (0, dis_ij_ruN-dis_ik_ruN, sqrt(2)*gauStd);
        elseif isequal (disFlag, 'logistic')
            probNRu = 1./(1+exp(dis_ij_ruN-dis_ik_ruN));   
        elseif isequal (disFlag, 'expo')
            probNRu = dis_ik_ruN./(dis_ij_ruN+dis_ik_ruN);
            probNRu (dis_ij_ruN+dis_ik_ruN == 0) = 0.5;
        end
        probNRu (probNRu == 0 | probNRu == 1) = [];
        enRuN = sum (-probNRu.*log2(probNRu)-(1-probNRu).*log2(1-probNRu));
        objVal(1)  = enRuY*pRsY+enRuN*(1-pRsY);  
        objVal(2) = enRuY;
        objVal(3) = enRuN;
    elseif pRsY == 0
        if (dis_ij-dis_ik < 1 || isempty (tripletYN))
            tripletNew2 = vertcat (tripletYN, [i, k, j]);
            if ~isempty (x)
                x0 = [x; 0];
            else
                x0 = x;
            end
            [WN, ~] = metric_learning (disLearnMethod, data, tripletNew2, para, x0); 
            transDataN = data*WN;
            dis_matN = zeros (n);
            dis_matN ((a-1)*n+b) = sqrt(sum((transDataN (a, :) - transDataN (b, :)).^2, 2));            
        else 
            dis_matN = dis_mat;
        end
        dis_ij_ruN = dis_matN ((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
        dis_ik_ruN = dis_matN ((measureTriple (:, 1)-1)*n + measureTriple (:, 3));
        if isequal (disFlag, 'gaussian')
            probNRu = normcdf (0, dis_ij_ruN-dis_ik_ruN, sqrt(2)*gauStd);
        elseif isequal (disFlag, 'logistic')
            probNRu = 1./(1+exp(dis_ij_ruN-dis_ik_ruN));   
        elseif isequal (disFlag, 'expo')
            probNRu = dis_ik_ruN./(dis_ij_ruN+dis_ik_ruN);
            probNRu (dis_ij_ruN+dis_ik_ruN == 0) = 0.5;
        end
        probNRu (probNRu == 0 | probNRu == 1) = [];
        objVal(1)  = sum (-probNRu.*log2(probNRu)-(1-probNRu).*log2(1-probNRu));
        objVal(3) = objVal(1);
    elseif pRsY == 1
        if (dis_ik-dis_ij < 1 || isempty (tripletYN))
            tripletNew1 = vertcat (tripletYN, [i, j, k]);    
            if ~isempty (x)
                x0 = [x; 0];
            else
                x0 = x;
            end          
            [WY, ~] = metric_learning (disLearnMethod, data, tripletNew1, para, x0);   
            transDataY = data*WY;
            dis_matY = zeros (n);
            dis_matY ((a-1)*n+b) = sqrt(sum((transDataY (a, :) - transDataY (b, :)).^2, 2));
        else
            dis_matY = dis_mat;
        end        
        dis_ij_ruY = dis_matY((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
        dis_ik_ruY = dis_matY((measureTriple (:, 1)-1)*n + measureTriple (:, 3));
        if isequal (disFlag, 'gaussian')
            probYRu = normcdf (0, dis_ij_ruY-dis_ik_ruY, sqrt(2)*gauStd);
        elseif isequal (disFlag, 'logistic')
            probYRu = 1./(1+exp(dis_ij_ruY-dis_ik_ruY));
        elseif isequal (disFlag, 'expo')
            probYRu = dis_ik_ruY./(dis_ij_ruY+dis_ik_ruY);
            probYRu (dis_ij_ruY+dis_ik_ruY == 0) = 0.5;
        end
        probYRu (probYRu == 0 | probYRu == 1) = [];        
        objVal(1)  = sum (-probYRu.*log2(probYRu)-(1-probYRu).*log2(1-probYRu));     
        objVal(2) = objVal(1);
    end                                                
end

