function [tripletIdUp, val, uncertainDistri] = uncertainSamplePool (data, poolTri, transData, disFunc, tripletId, sampleTripleId, num, disPtFile, datasetName)
n = size (data, 1);
if isempty (sampleTripleId)
    sampleNum = 5000;
    sampleTripleId = subsamplePool (size (poolTri, 1), sampleNum, tripletId);
else
    if ~isempty(tripletId)
        sampleTripleId = setdiff (sampleTripleId, tripletId);
    end
end
sampleTriple = poolTri (sampleTripleId, :);
sampleNum = size (sampleTriple, 1);

nVec = (1:n)';
nMat = repmat (nVec, 1, n);
a = reshape (nMat', n*n, 1);
b = reshape (nMat,  n*n, 1);
dis_mat = zeros (n);
dis_mat ((a-1)*n+b) = sqrt(sum((transData (a, :) - transData (b, :)).^2, 2));  

dis_ij = dis_mat ((sampleTriple (:, 1)-1)*n + sampleTriple (:, 2));
dis_ik = dis_mat ((sampleTriple (:, 1)-1)*n + sampleTriple (:, 3));

dis_mat_true = sqrt(sum((data (a, :) - data (b, :)).^2, 2));  

if isequal(disFunc, 'gaussian')
    %dis_vec = reshape (dis_mat, n*n, 1);
    %dis_vec = sort (dis_vec);
    %gauStd = sqrt(dis_vec (ceil(length(dis_vec)/10)));
    gauStd = 2* max(max (dis_mat_true));
end   


if isequal (disFunc, 'gaussian')
    probY = normcdf(0,dis_ij-dis_ik,sqrt(2)*gauStd);
elseif isequal (disFunc, 'logistic')
    probY = 1./(1+exp(dis_ij-dis_ik));    
elseif isequal (disFunc, 'expo')
    probY = dis_ik./(dis_ij+dis_ik);   
    probY (dis_ij+dis_ik == 0) = 0.5;
end

sampleTriObj = -probY.*log2(probY)-(1-probY).*log2(1-probY);
sampleTriObj (probY == 1 | probY == 0) = 0;


rp = randperm (sampleNum);
sampleTriObj=sampleTriObj(rp);
[val,p]=max(sampleTriObj);
p=rp(p);
uncertainDistri = sampleTriObj;
tripletIdUp = vertcat (tripletId, sampleTripleId (p));
cd results;
cd (datasetName);
if num == 1
   dlmwrite (disPtFile, dis_mat, 'newline', 'pc', '-append', 'delimiter',' ');   
end
cd ..;
cd ..;
end

