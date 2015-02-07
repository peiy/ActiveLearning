function [query, val, triDis] = rankSelect (data, transData, disFunc, tripletYN, x, para, disLearnMethod, sampleTriple, num, disPtFile, ruPerFile, datasetName)
n = size (data, 1);
measureNum = ceil((n/3)^3);
measureTriple = subsample (data, measureNum, []);
if isempty (sampleTriple)
    sampleNum = ceil((n/5)^3);
    sampleTriple = subsample (data, sampleNum, tripletYN);
else
    if ~isempty(tripletYN)
        tripletYNVec = (tripletYN (:, 1) - 1) * n^2 + (tripletYN (:, 2) - 1) * n + (tripletYN (:, 3) - 1);    
        tripletYNVec2 = (tripletYN (:, 1) - 1) * n^2 + (tripletYN (:, 3) - 1) * n + (tripletYN (:, 2) - 1);    
        sampleTriVec = (sampleTriple (:, 1) - 1) * n^2 + (sampleTriple (:, 2) - 1) * n + (sampleTriple (:, 3) - 1);
        sampleTriVec = setdiff (sampleTriVec, tripletYNVec);
        sampleTriVec = setdiff (sampleTriVec, tripletYNVec2);
        sampleTriple = num2vec (sampleTriVec, n);
        sampleTriple = sampleTriple + 1;
    end
end

nVec = (1:n)';
nMat = repmat (nVec, 1, n);
a = reshape (nMat', n*n, 1);
b = reshape (nMat,  n*n, 1);
dis_mat = zeros (n);
dis_mat ((a-1)*n+b) = sqrt(sum((transData (a, :) - transData (b, :)).^2, 2));  

if isequal(disFunc, 'gaussian')
    dis_vec = reshape (dis_mat, n*n, 1);
    dis_vec = sort (dis_vec);
    gauStd = dis_vec (ceil(length(dis_vec)/10));
end    
dis_ij = dis_mat ((sampleTriple (:, 1)-1)*n + sampleTriple (:, 2));
dis_ik = dis_mat ((sampleTriple (:, 1)-1)*n + sampleTriple (:, 3));
dis_ij_mea = dis_mat ((measureTriple (:, 1)-1)*n + measureTriple (:, 2));
dis_ik_mea = dis_mat ((measureTriple (:, 1)-1)*n + measureTriple (:, 3));

if isequal (disFunc, 'gaussian')
    probY = normcdf(0,dis_ij-dis_ik,sqrt(2)*gauStd);
    probYRuR = normcdf(0,dis_ij_mea-dis_ik_mea,sqrt(2)*gauStd);
elseif isequal (disFunc, 'logistic')
    probY = 1./(1+exp(dis_ij-dis_ik));
    probYRuR = 1./(1+exp(dis_ij_mea-dis_ik_mea));    
end

probYRuR (probYRuR == 0 | probYRuR == 1) = [];
HRuR = sum(-probYRuR.*log2(probYRuR)-(1-probYRuR).*log2(1-probYRuR));
tempId = (probY == 0) | (probY == 1);      
objSamTriple = -probY.*log2(probY)-(1-probY).*log2(1-probY);
objSamTriple (tempId) = 0;
[sortSamUncertain, sortId] = sort (objSamTriple, 1, 'descend');
numOfk = ceil((n/15)^3);
rankTri = sampleTriple (sortId (1:numOfk), :);
objRankTri = zeros (numOfk, 1);


for iii = 1:numOfk
    objRankTri (iii) = objFunValue (rankTri (iii, :), data, tripletYN, measureTriple, x, para, disFunc, disLearnMethod, dis_mat);
end

rp = randperm (numOfk);
objRankTri=objRankTri(rp);
[val,p]=min(objRankTri);
val = val/measureNum;
p=rp(p);
query = rankTri (p, :);
triDis = objRankTri/measureNum;
cd results;
cd (datasetName);
if num == 1
   dlmwrite (disPtFile, dis_mat, '-append');   
end

percent = sum(HRuR-objRankTri>0)/size (objRankTri, 1);
dlmwrite (ruPerFile, percent, '-append');
cd ..;
cd ..;
    
end

