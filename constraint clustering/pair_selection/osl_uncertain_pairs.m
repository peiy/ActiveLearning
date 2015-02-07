function OSL_MUpairs = osl_uncertain_pairs(conMat, cpt, usedPairs, centroids, num_neighbs, neighboring, neighb, NSizes, NMeans)
    global n;
    global nps;
    
    % One step look ahead uncertainty pruning
    pairs = ones(n);
    if(~isempty(usedPairs))
        pairs((usedPairs(:,2)-1)*n+usedPairs(:,1)) = 0;
        pairs((usedPairs(:,1)-1)*n+usedPairs(:,2)) = 0;
    end
    [is, js] = find(triu(pairs,1)==1);
    possiblePairs = [is, js];      
    
    pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
    pCL = 1-pML;        % P(CannotLink | (di,dj))

    OSL_uncertainties = inf(size(possiblePairs,1),1);
    for i=1:size(possiblePairs,1)
        p = possiblePairs(i,:);
        % Assuming that pair has a mustlink relation
            % updating connectivity matrix
            conMat_ML = conMat; conMat_ML(p(1),p(2)) = 1; conMat_ML(p(2),p(1)) = 1;
            % updating the cpt using this information
            [clustering, conMat_ML, centroid, cluster, cluster_size] = RRestartPCKmeans(conMat_ML, p, 1, centroids, num_neighbs, neighboring, neighb, NSizes, NMeans);
            cpt = ground_truth(cluster, cluster_size, centroid);
            % calculating new entropies
            p_ml=(cpt*cpt'); p_cl=1-p_ml;
            H_ML = -p_ml.*log(p_ml) -p_cl.*log(p_cl);

        % Assuming that pair has a cannotlink relation
            % updating connectivity matrix
            conMat_CL = conMat; conMat_CL(p(1),p(2)) = -1; conMat_CL(p(2),p(1)) = -1;
            % updating the cpt using this information
            [clustering, conMat_CL, centroid, cluster, cluster_size] = RRestartPCKmeans(conMat_CL, p, -1, centroids, num_neighbs, neighboring, neighb, NSizes, NMeans);
            cpt = ground_truth(cluster, cluster_size, centroid);
            % calculating new entropies
            p_ml=(cpt*cpt'); p_cl=1-p_ml;
            H_CL = -p_ml.*log(p_ml) -p_cl.*log(p_cl);

        % calculating expected uncertainties
        H = pML(p(1),p(2))*H_ML + pCL(p(1),p(2))*H_CL;
        % % H = triu(H,1);
        % % if(~isempty(usedPairs))
        % %     H((usedPairs(:,2)-1)*n+usedPairs(:,1)) = 0;
        % %     H((usedPairs(:,1)-1)*n+usedPairs(:,2)) = 0;
        % % end

        OSL_uncertainties(i) = sum(sum(H));
    end

    % Selecting #nps pairs that reduce total uncertainty in dataset (Having high information Gain)
%     rp=randperm(n*n);
%     OSL_uncertainties=OSL_uncertainties(rp);
    if(nps>1)
        [v,pos]=mink(OSL_uncertainties,nps);
    else
        [v,pos]=min(OSL_uncertainties);
    end
%     pos=rp(pos);
    
    OSL_MUpairs = possiblePairs(pos,:);
end
