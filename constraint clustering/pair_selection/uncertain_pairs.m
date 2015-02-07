function [mostUncertainPairList, uncertainties, MLprobs] = uncertain_pairs(cpt, nps, conMat, test, n, datasetName, nq_initial, flag1, flag2, num)
    % cpt: the n*k ground truth table of p(Cj|Xi)s 
    % s: the number of uncertain data-pairs we want to select
    % 
    % mostUncertainPairList: the list of pairs of indices of most uncertain pairs
        
    pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
    pCL = 1-pML;        % P(CannotLink | (di,dj))
    H = -pML.*log2(pML) -pCL.*log2(pCL);  % entropy/uncertainty in pairwise relation of (di,dj)
    H(pML==0) = 0;
    H(pCL==0) = 0;      
    % remove the duplicates and (di,di) data-pairs
    
    % remove used data-pair indices;
    H(conMat~=0) = -1;
    H(test,1:n)=-1;
    H(1:n,test)=-1;
    % remove the diagonal and down triangel in matrix, write ppp in the
    % file
    temp = ones(size(H));
    temp = triu(temp, 1); 
    ppp = H(temp == 1);
    
    H(temp == 0) = -1;
    H = reshape (H, n*n, 1);

    % random permutate the H vector
    rp=randperm(n*n);
    H=H(rp);
    [v,p]=maxk(H,nps);
    p=rp(p);
   
    js = ceil(p/n);
    is = p - (js-1)*n;
    mostUncertainPairList = [is,js];
    uncertainties = v;
    MLprobs = pML(is,js);
end
