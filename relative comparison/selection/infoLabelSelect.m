function queries = infoLabelSelect (data, triNum, clustering, flag, tripletYN, tripletDKN, probFlag)
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
classNum = size (cpt,2);
n = size (data, 1);
InfoCell = cell (n, 1);
for i = 1:n
    InfoCell{i} = ones (n);
end
for i = 1:n
    for j = 1:n
        for k = j+1:n
            if (j~=k && i~=k && i~=j && InfoCell{i}(j, k)==1 && InfoCell{i}(k, j)==1)
                a = cpt (i, :);
                b = cpt (j, :);
                c = cpt (k, :);                                          
                p1 = sum(a.*b)-sum(a.*b.*c);
                p2 = sum(a.*c)-sum(a.*b.*c);
                p3 = 1-p1-p2;                   
                aTemp = a (a~=0);
                bTemp = b (b~=0);
                cTemp = c (c~=0);                
                firTerm = (sum (-aTemp.*log2(aTemp)) + sum (-bTemp.*log2(bTemp)) + sum (-cTemp.*log2(cTemp))) * (1-p3);
                secVec = zeros (1, classNum*(classNum-1));
                for lll = 1:classNum                    
                    secVec ((lll-1)*(classNum-1)+1:lll*(classNum-1)) = a(lll)*b(lll).*c(setdiff(1:classNum, lll));
                end
                if sum(secVec)~=0
                    secVec = secVec/sum(secVec);
                end
                secVec (secVec == 0) = [];
                if ~isempty (secVec)
                    secTerm = p1*sum(log2(secVec).*secVec);                                
                else
                    secTerm = 0;
                end
                thirdVec = zeros (1, classNum*(classNum-1));
                for lll = 1:classNum                    
                    thirdVec ((lll-1)*(classNum-1)+1:lll*(classNum-1)) = a(lll)*c(lll).*b(setdiff(1:classNum, lll));
                end
                
                if sum(thirdVec)~=0
                    thirdVec = thirdVec/sum(thirdVec);
                end
                thirdVec (thirdVec == 0) = [];
                if ~isempty (thirdVec)
                    thirdTerm = p2*sum(log2(thirdVec).*thirdVec);                
                else
                    thirdTerm = 0;
                end
                InfoCell{i}(j,k) = firTerm+secTerm+thirdTerm;
            end
        end 
    end
    InfoCell{i} = InfoCell{i}.*InfoCell{i}';
    temp = eye (n);
    InfoCell{i}(temp == 1) = -1;         
    InfoCell{i}(i, :) = -1;
    InfoCell{i}(:, i) = -1;
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
