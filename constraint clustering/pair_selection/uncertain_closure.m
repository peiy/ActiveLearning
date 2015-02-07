function nPairs = uncertain_closure (cpt, test, n, conMat, interval, name, nq_initial, flag1, flag2, num)
global nps;

pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
pCL = 1-pML;        % P(CannotLink | (di,dj))
H = -pML.*log2(pML) -pCL.*log2(pCL);  % entropy/uncertainty in pairwise relation of (di,dj)
H(pML==0) = 0;
H(pCL==0) = 0;      
% remove the duplicates and (di,di) data-pairs
    
% removing used data-pair indices;
H(conMat~=0)=-1;
H(test,1:n)=-1;
H(1:n,test)=-1;
% removing diagonal and down triangle
temp = ones(size(H));
temp = triu(temp, 1); 
ppp = H(temp == 1);
    
H(temp == 0) = -1;
H = reshape (H, n*n, 1);

if (num == 1)   
    fileName = [name, '-', flag1, '-', flag2, '-', num2str(nq_initial), '-', num2str(nps), '-Entropy.data'];
    cd results;
    cd (name);
    dlmwrite(fileName,ppp,'-append');
    cd ..;
    cd ..;
end

max_value = max (H);
H = H-(max_value-interval);

ties = find(H>=0);
js = ceil(ties/n);
is = ties - (js-1)*n;
pairs = [is, js];

t = zeros (1,size(ties,1));

for i = 1:size(ties,1)
    % Assume the new pair is a must link pair
    conMat_ML = conMat;  conMat_ML (pairs(i,1), pairs(i,2)) = 1; conMat_ML (pairs(i,2), pairs(i,1)) = 1;
    conMat_ML = transitive_closure (conMat_ML, pairs(i,:), n); 
    % Assume the new pair is a cannot link pair
    conMat_CL = conMat;  conMat_CL (pairs(i,1), pairs(i,2)) = -1; conMat_CL (pairs(i,2), pairs(i,1)) = -1;
    conMat_CL = transitive_closure (conMat_CL, pairs(i,:), n); 
    t(i) = pML(pairs(i,1), pairs(i,2))*length(find(conMat_ML~=0)) + pCL(pairs(i,1), pairs(i,2))*length(find(conMat_CL~=0));
end

rp=randperm(length(t));
t=t(rp);
[~,p]=maxk(t,nps);
p=rp(p);

nPairs = pairs(p,:);
end