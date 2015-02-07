function [mostInformativePairs, pair_informativeness] = informativeness (cpt, conMat, test, n, datasetName, nq_initial, flag1, flag2, num)
global nps;
    
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
    fileName = [datasetName, '-', flag1, '-', flag2, '-', num2str(nq_initial), '-', num2str(nps), '-Informativeness.data'];
    cd results;
    cd (datasetName);
    dlmwrite(fileName,ppp,'-append');
    cd ..;
    cd ..;
end

infoMatrix = reshape (infoMatrix, n*n, 1);

%random permutate the infoMatrix
rp=randperm(n*n);
infoMatrix=infoMatrix(rp);
[v,p]=maxk(infoMatrix,nps);
p=rp(p);

js = ceil(p/n);
is = p - (js-1)*n;
mostInformativePairs = [is,js];
pair_informativeness = v;
end