function [tripletIdUp, val, triDis] = exRejSamPool (data, poolTri, transData, disFunc, tripletId, x, para, disLearnMethod, sampleTripleId, num, disPtFile, ruPerFile, ruNumFile, datasetName, minMaxFlag)
% rejection sampling on explicit distribution
n = size (data, 1);
if isempty (sampleTripleId)
    sampleNum = 200;
    sampleTripleId = subsamplePool (size (poolTri, 1), sampleNum, tripletId);
else
    if ~isempty(tripletId)
        sampleTripleId = setdiff (sampleTripleId, tripletId);
    end
end
tripletYN = poolTri (tripletId, :);
%sampleTripleId = setdiff (1:size (poolTri, 1), tripletId);
sampleTriple = poolTri (sampleTripleId, :);
sampleNum = size (sampleTriple, 1);
sampleTriObj = zeros (sampleNum, 3);

measureNum = ceil(size (poolTri, 1)/5);
measureTripleId = subsamplePool (size (poolTri, 1), measureNum, tripletId);
measureTriple = poolTri (measureTripleId, :);
%measureTriple = poolTri;

nVec = (1:n)';
nMat = repmat (nVec, 1, n);
a = reshape (nMat', n*n, 1);
b = reshape (nMat,  n*n, 1);
dis_mat = zeros (n);
dis_mat ((a-1)*n+b) = sqrt(sum((transData (a, :) - transData (b, :)).^2, 2));  

dis_mat_true = sqrt(sum((data (a, :) - data (b, :)).^2, 2));  

dis_ij_mea = dis_mat ((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
dis_ik_mea = dis_mat ((measureTriple (:, 1)-1)*n + measureTriple (:, 3));
gauStd = [];
if isequal(disFunc, 'gaussian')
    %dis_vec = reshape (dis_mat, n*n, 1);
    %dis_vec = sort (dis_vec);
    %gauStd = sqrt(dis_vec (ceil(length(dis_vec)/10)));
    gauStd = 2* max(max (dis_mat_true));
end   
if isequal (disFunc, 'gaussian')
    probYRuR = normcdf(0,dis_ij_mea-dis_ik_mea,sqrt(2)*gauStd);
elseif isequal (disFunc, 'logistic')
    probYRuR = 1./(1+exp(dis_ij_mea-dis_ik_mea));  
elseif isequal (disFunc, 'expo')        
    probYRuR = dis_ik_mea./(dis_ij_mea+dis_ik_mea);
    probYRuR (dis_ij_mea+dis_ik_mea == 0) = 0.5;
end

probYRuR (probYRuR == 0 | probYRuR == 1) = [];
HRuR = sum(-probYRuR.*log2(probYRuR)-(1-probYRuR).*log2(1-probYRuR));

for iii = 1:sampleNum
    sampleTriObj (iii, :) = objFunValue (sampleTriple (iii, :), data, tripletYN, measureTriple, x, para, disFunc, disLearnMethod, dis_mat, gauStd);
end


sampleTriObj1 = sampleTriObj (:, 1);
rp = randperm (sampleNum);
sampleTriObj1=sampleTriObj1(rp);
if isequal (minMaxFlag, 'exRejSam')
    [val,p]=min(sampleTriObj1);
elseif isequal (minMaxFlag, 'certainRej')
    [val,p]=max(sampleTriObj1);
end
val = val/measureNum;
p=rp(p);
triDis = sampleTriObj1/measureNum;
tripletIdUp = vertcat (tripletId, sampleTripleId (p));
cd results;
cd (datasetName);
if num == 1
   dlmwrite (disPtFile, dis_mat, 'newline', 'pc', '-append', 'delimiter',' ');   
   abc = vertcat (HRuR, sampleTriObj1);
   cde = vertcat (HRuR, sampleTriObj (:, 2));
   efg = vertcat (HRuR, sampleTriObj (:, 3));
   abcd = horzcat (abc, cde, efg);
   dlmwrite (ruNumFile, abcd', '-append', 'delimiter', ' ');
end
perGreat = sum(HRuR-sampleTriObj1>0.0001)/size (sampleTriObj1, 1);
perGreatEqual = sum(HRuR-sampleTriObj1>=0.0001)/size (sampleTriObj1, 1);
dlmwrite (ruPerFile, [perGreat, perGreatEqual], '-append', 'delimiter',' ');
cd ..;
cd ..;
end
