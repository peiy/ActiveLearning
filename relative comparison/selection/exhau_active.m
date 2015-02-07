function queries = exhau_active (data, triNum, clustering, flag, tripletYN, tripletDKN, probFlag)
if isequal (probFlag, 'rf')
    cpt=random_forest (data, clustering);
elseif isequal (probFlag, 'gmm')
    k=length(unique(clustering));
    covariace = cov (data);
    ind = (diag(covariace) > 0);
    data = data (:, ind);
    covariace = cov (data);
    minEigVal = min(eig (covariace));
    options = statset('MaxIter',200);
    % remove constant columns
    if minEigVal < 0
        reNum =  abs(minEigVal)+1e-5;
    else
        reNum = 1e-5;
    end 
    data = data * covariace^(-0.5);
    aa=gmdistribution.fit(data,k, 'Regularize', reNum, 'Replicates', 10, 'CovType', 'diagonal', 'Options', options);
    cpt=aa.posterior (data);
end
n = size (data, 1);
InfoCell = cell (n, 1);
for i = 1:n
    InfoCell{i} = -ones (n);
end
for i = 1:n
    if isequal (flag, 'entropy')
        aProb = cpt (i, :);
        sumAB = aProb * cpt';
        temp = repmat (aProb, n, 1);
        temp = temp.*cpt;
        sumABC = temp * cpt';
        temp = repmat (sumAB', 1, n);
        p1Mat = temp - sumABC;
        temp = repmat (sumAB, n, 1);
        p2Mat = temp - sumABC;
        Index1 = (p1Mat == 0);
        Index2 = (p2Mat == 0);
        InfoCell{i} = -p1Mat.*log2(p1Mat./(p1Mat+p2Mat))-p2Mat.*log2(p2Mat./(p1Mat+p2Mat));
        InfoCell{i}(Index1) = 0;
        InfoCell{i}(Index2) = 0;
        temp = eye (n);
        InfoCell{i}(temp == 1) = -1;
        InfoCell{i}(i, :) = -1;
        InfoCell{i}(:, i) = -1;
    elseif isequal (flag, 'entropyP1P2')
        aProb = cpt (i, :);
        sumAB = aProb * cpt';
        temp = repmat (aProb, n, 1);
        temp = temp.*cpt;
        sumABC = temp * cpt';
        temp = repmat (sumAB', 1, n);
        p1Mat = temp - sumABC;
        temp = repmat (sumAB, n, 1);
        p2Mat = temp - sumABC;
        Index1 = (p1Mat == 0);
        Index2 = (p2Mat == 0);
        InfoCell{i} = -p1Mat.*log2(p1Mat)-p2Mat.*log2(p2Mat);
        InfoCell{i}(Index1) = 0;
        InfoCell{i}(Index2) = 0;
        temp = eye (n);
        InfoCell{i}(temp == 1) = -1;
        InfoCell{i}(i, :) = -1;
        InfoCell{i}(:, i) = -1;                      
    elseif isequal (flag, 'extreme')
        aProb = cpt (i, :);
        sumAB = aProb * cpt';
        temp = repmat (aProb, n, 1);
        temp = temp.*cpt;
        sumABC = temp * cpt';
        temp = repmat (sumAB', 1, n);
        p1Mat = temp - sumABC;
        temp = repmat (sumAB, n, 1);
        p2Mat = temp - sumABC;
        InfoCell{i} = p1Mat + p2Mat;
        temp = eye (n);
        InfoCell{i}(temp == 1) = -1;
        InfoCell{i}(i, :) = -1;
        InfoCell{i}(:, i) = -1;        
    end
    
%    InfoCell{i} = -ones (n);

%     for j = 1:n
%         for k = 1:n
%             if (isequal (flag, 'entropy'))
%                 if (j~=k && i~=k && i~=j && InfoCell{i}(j, k)==-1 && InfoCell{i}(k, j)==-1)
%                     p1 = sum(cpt (i, :).*cpt (j, :))-sum(cpt(i, :).*cpt (j, :).*cpt (k, :));
%                     p2 = sum(cpt (i, :).*cpt (k, :))-sum(cpt(i, :).*cpt (j, :).*cpt (k, :));
%                     if (p1~=0 && p2~=0)
%                         InfoCell{i}(j, k) = -p1*log2(p1/(p1+p2))-p2*log2(p2/(p1+p2));
%                         InfoCell{i}(k, j) = -p1*log2(p1/(p1+p2))-p2*log2(p2/(p1+p2));       
%                     else
%                         InfoCell{i}(j, k) = 0;
%                         InfoCell{i}(k, j) = 0;
%                     end                
%                 end 
%             end
%         end
%     end
end

triplet = vertcat (tripletYN, tripletDKN);
for i = 1:size (triplet, 1)
    InfoCell{triplet (i, 1)}(triplet (i, 2), triplet (i, 3)) = -1;
    InfoCell{triplet (i, 1)}(triplet (i, 3), triplet (i, 2)) = -1;
end

% begin to find new queries
candiValue = zeros (n, triNum); % triNum largest values for each cell
candiIndex = zeros (n, triNum); % triNum index of largest values for each cell

for i = 1:n
    H = InfoCell{i};
    temp = ones (n);
    temp = triu(temp, 1); 
    H(temp == 0) = -1;
    H = reshape (H, n*n, 1);
    rp=randperm(n*n);
    H=H(rp);
    [v,p]=maxk(H,triNum);
    p=rp(p);
    candiValue (i, :) = v;
    candiIndex (i, :) = p;    
end

H=candiValue;
H=reshape (H,n*triNum,1);
rp=randperm(n*triNum);
H=H(rp);
[aaa,q]=maxk(H,triNum);
q=rp(q);
js=ceil(q/n);
iIndex=q-(js-1)*n;
jkIndex=candiIndex((js-1)*n+iIndex);
kIndex=ceil(jkIndex/n);
jIndex=jkIndex-(kIndex-1)*n;


queries = [iIndex, jIndex, kIndex];


end
