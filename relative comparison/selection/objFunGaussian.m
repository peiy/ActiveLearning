function objVal = objFunGaussian(triple, data, weight, tripletYN, measureTriple, x, C, disFlag)
    n = size (data, 1);
    % compute sigma in Gaussian distribution
    dis_mat = zeros (n);    
    for iii = 1:n
        iMat = repmat(data (iii, 1:end-1), n, 1);
        diffMat = iMat - data (:, 1:end-1);
        dis_mat (:, iii) = ((diffMat.^2)*weight);
    end
    dis_vec = reshape (dis_mat, n*n, 1);
    dis_vec = sort (dis_vec);
    sigma = dis_vec (ceil(length(dis_vec)/5));
    
    i = triple (1);
    j = triple (2);
    k = triple (3);
    dis_ij = ((data (i,1:end-1) - data (j,1:end-1)).^2)*weight;
    dis_ik = ((data (i,1:end-1) - data (k,1:end-1)).^2)*weight;    
    if isequal (disFlag, 'gaussian')
        pRsY = normcdf(0,(dis_ij)-(dis_ik),2*sigma);
    elseif isequal (disFlag, 'logistic')
        pRsY = 1/(1+exp(dis_ij-dis_ik));
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
                weightY = svmDisLearning_yn (tripletNew1, C, data (:, 1:end-1), x0);
            else
                weightY = svmDisLearning_yn (tripletNew1, C, data (:, 1:end-1));
            end
        else
            weightY = weight;
        end        
        dis_ij_ruY = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 2),1:end-1)).^2)*weightY;
        dis_ik_ruY = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 3),1:end-1)).^2)*weightY;
        if isequal (disFlag, 'gaussian')
            probYRu = normcdf (0, (dis_ij_ruY)-(dis_ik_ruY), 2*sigma);
        elseif isequal (disFlag, 'logistic')
            probYRu = 1/(1+exp(dis_ij_ruY-dis_ik_ruY));
        end
        probYRu (probYRu == 0 | probYRu == 1) = [];        
        enRuY = sum (-probYRu.*log2(probYRu)-(1-probYRu).*log2(1-probYRu));
        if (dis_ij-dis_ik < 1 || isempty (tripletYN))
            tripletNew2 = vertcat (tripletYN, [i, k, j]);
            if ~isempty (x)
                x0 = [x; 0];
                weightN = svmDisLearning_yn (tripletNew2, C, data (:, 1:end-1), x0);
            else
                weightN = svmDisLearning_yn (tripletNew2, C, data (:, 1:end-1));
            end
        else
            weightN = weight;
        end
        dis_ij_ruN = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 2),1:end-1)).^2)*weightN;
        dis_ik_ruN = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 3),1:end-1)).^2)*weightN;
        if isequal (disFlag, 'gaussian')
            probNRu = normcdf (0, (dis_ij_ruN)-(dis_ik_ruN), 2*sigma);
        elseif isequal (disFlag, 'logistic')
            probNRu = 1/(1+exp(dis_ij_ruN-dis_ik_ruN));   
        end
        probNRu (probNRu == 0 | probNRu == 1) = [];
        enRuN = sum (-probNRu.*log2(probNRu)-(1-probNRu).*log2(1-probNRu));
        objVal  = enRuY*pRsY+enRuN*(1-pRsY);  
    elseif pRsY == 0
        if (dis_ij-dis_ik < 1 || isempty (tripletYN))
            tripletNew2 = vertcat (tripletYN, [i, k, j]);
            if ~isempty (x)
                x0 = [x; 0];
                weightN = svmDisLearning_yn (tripletNew2, C, data (:, 1:end-1), x0);
            else
                weightN = svmDisLearning_yn (tripletNew2, C, data (:, 1:end-1));
            end
        else
            weightN = weight;
        end
        dis_ij_ruN = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 2),1:end-1)).^2)*weightN;
        dis_ik_ruN = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 3),1:end-1)).^2)*weightN;
        if isequal (disFlag, 'gaussian')
            probNRu = normcdf (0, (dis_ij_ruN)-(dis_ik_ruN), 2*sigma);
        elseif isequal (disFlag, 'logistic')
            probNRu = 1/(1+exp(dis_ij_ruN-dis_ik_ruN));   
        end
        probNRu (probNRu == 0 | probNRu == 1) = [];
        objVal  = sum (-probNRu.*log2(probNRu)-(1-probNRu).*log2(1-probNRu));
    elseif pRsY == 1
        if (dis_ik-dis_ij < 1 || isempty (tripletYN))
            tripletNew1 = vertcat (tripletYN, [i, j, k]);    
            if ~isempty (x)
                x0 = [x; 0];           
                weightY = svmDisLearning_yn (tripletNew1, C, data (:, 1:end-1), x0);
            else 
                weightY = svmDisLearning_yn (tripletNew1, C, data (:, 1:end-1));
            end
        else
            weightY = weight;
        end        
        dis_ij_ruY = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 2),1:end-1)).^2)*weightY;
        dis_ik_ruY = ((data (measureTriple (:, 1),1:end-1) - data (measureTriple (:, 3),1:end-1)).^2)*weightY;
        if isequal (disFlag, 'gaussian')
            probYRu = normcdf (0, (dis_ij_ruY)-(dis_ik_ruY), 2*sigma);
        elseif isequal (disFlag, 'logistic')
            probYRu = 1/(1+exp(dis_ij_ruY-dis_ik_ruY));
        end
        probYRu (probYRu == 0 | probYRu == 1) = [];        
        objVal  = sum (-probYRu.*log2(probYRu)-(1-probYRu).*log2(1-probYRu));                        
    end                                                
end

