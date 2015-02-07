function nPairs = info_closure (cpt, test, n, conMat, interval, name, nq_initial, flag1, flag2, num)
global nps;

pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
pCL = 1-pML;        % P(CannotLink | (di,dj))

infoMatrix = (cpt * cpt');
[~, clusterLabel]=max(cpt, [], 2);

% for i = 1:n
%     for j = i+1:n
%         if (clusterLabel(i) == clusterLabel(j))
%             infoMatrix(i,j) = 1-infoMatrix(i,j);
%         else
%             infoMatrix(i,j) = infoMatrix(i,j);
%         end
%     end
% end

A = zeros(size(cpt));
for i=1:size(cpt,2)
    A (clusterLabel==i, i)=1;
end
CM = A*A';
infoMatrix(CM==1) = 1-infoMatrix(CM==1);
infoMatrix(conMat~=0) = -1;
infoMatrix(test,1:n)=-1;
infoMatrix(1:n, test)=-1;

temp = ones(size(infoMatrix));
temp = triu(temp, 1); 
ppp=infoMatrix(temp==1);
infoMatrix (temp==0)=-1;

if (num == 1)   
    fileName = [name, '-', flag1, '-', flag2, '-', num2str(nq_initial), '-', num2str(nps), '-informativeness.data'];
    cd results;
    cd (name);
    dlmwrite(fileName,ppp,'-append');
    cd ..;
    cd ..;
end

infoMatrix = reshape (infoMatrix, n*n, 1);
max_value = max (infoMatrix);
infoMatrix = infoMatrix-(max_value-interval);
ties = find(infoMatrix>=0);
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

%random permutate the infoMatrix
rp=randperm(length(t));
t=t(rp);
[~,p]=maxk(t,nps);
p=rp(p);
nPairs = pairs(p,:);
end
