function selectPairs = batch_active_learning (flag, conMat, cpt, used_indices, name, test, rawData)
    global nps;
    selectPairs = ones(nps, 2);
    n = size (rawData, 1);
    
    pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
    pCL = 1-pML;        % P(CannotLink | (di,dj))
    H = -pML.*log2(pML) -pCL.*log2(pCL);  % entropy/uncertainty in pairwise relation of (di,dj)
    
    % remove the duplicates and (di,di) data-pairs
    H = triu(H,1);
  
    % removing used data-pair indices;
    if(~isempty(used_indices))
        H((used_indices(:,2)-1)*n+used_indices(:,1)) = 0;
        H((used_indices(:,1)-1)*n+used_indices(:,2)) = 0;
        H((selectPairs(:,2)-1)*n+selectPairs(:,1)) = 0;
        H((selectPairs(:,1)-1)*n+selectPairs(:,2)) = 0;
    end
    H(test,test) = 0;
    % finding #nps datapairs with maximum entropies
    H=reshape(H,n*n,1);
    
    rp=randperm(n*n);
    H=H(rp);
    [~,p]=max(H);  
    p=rp(p);
   
    js = ceil(p/n);
    is = p - (js-1)*n;
    selectPairs (1,:)= [is,js];
    
    % select this most uncertain pair
    
    used_indices = [used_indices; is,js];
    
    for i=2:nps
            p = [is,js];
        % Assuming that pair has a mustlink relation
            % updating connectivity matrix
            conMat_ML = conMat; conMat_ML(p(1),p(2)) = 1; conMat_ML(p(2),p(1)) = 1;
            % updating the cpt using this information
            creatContraintsFile (conMat_ML, name);
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/',name, '.arff -f -C data/' ,name, '.constraints -O ', name, 'Result.data'];
            dos (x);
            [cluster, cluster_size, centroids, clustering] = getResult (datasetName, rawData);
            cd ..;
            cd ..;
            
            if (isequal(flag, 'MG'))
                cpt = ground_truth(cluster, cluster_size, centroids, rawData(:, 1:end-1));
            elseif (isequal(flag, 'RF'))
                cpt = random_forest(rawData(:, 1:end-1), clustering);
            end
            % calculating new entropies
            p_ml=(cpt*cpt'); p_cl=1-p_ml;
            H_ML = -p_ml.*log2(p_ml) -p_cl.*log2(p_cl);

        % Assuming that pair has a cannotlink relation
            % updating connectivity matrix
            conMat_CL = conMat; conMat_CL(p(1),p(2)) = -1; conMat_CL(p(2),p(1)) = -1;
            % updating the cpt using this information
            creatContraintsFile (conMat_CL, name);
            cd wekaUT/weka-latest;
            x = ['java weka/clusterers/MPCKMeans -D data/',name, '.arff -f -C data/' ,name, '.constraints -O ', name, 'Result.data'];
            dos (x);
            [cluster, cluster_size, centroids, clustering] = getResult (datasetName, rawData);
            cd ..;
            cd ..;
            if (isequal(flag, 'MG'))
                cpt = ground_truth(cluster, cluster_size, centroids, rawData(:, 1:end-1));
            elseif (isequal(flag, 'RF'))
                cpt = random_forest(rawData(:, 1:end-1), clustering);
            end
            % calculating new entropies
            p_ml=(cpt*cpt'); p_cl=1-p_ml;
            H_CL = -p_ml.*log2(p_ml) -p_cl.*log2(p_cl);

        % calculating expected uncertainties
        H1 = pML(p(1),p(2))*H_ML + pCL(p(1),p(2))*H_CL;
     
        H1 = triu(H1,1);
            if(~isempty(used_indices))
                H1((used_indices(:,2)-1)*n+used_indices(:,1)) = 0;
                H1((used_indices(:,1)-1)*n+used_indices(:,2)) = 0;
                H((selectPairs(:,2)-1)*n+selectPairs(:,1)) = 0;
                H((selectPairs(:,1)-1)*n+selectPairs(:,2)) = 0;
            end
        H1 (test,test) = 0;  
        
        H1=reshape(H1,n*n,1);
        H (H>H1) = H1 (H>H1); % get the minimum entory between H(original matrix) and H1(add one more pair)
        
     	rp=randperm(n*n);
        H=H(rp);
        [~,p]=max(H);  
        p=rp(p);
        
        js = ceil(p/n);
        is = p - (js-1)*n;
        selectPairs(i, :) = [is,js];
    end
end