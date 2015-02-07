function [nPairs, neighbor, nq] = uncertain_pairs_huang (nq, neighbor, rawData, cpt, flag, conMat, cluster, clustering)
classNum = length(unique(rawData(:,end)));
neighborNum = length (neighbor);
n = length (rawData);
nPairs = [];
NeighborPoints = [];
for i = 1:neighborNum
    NeighborPoints (end+1: end+length(neighbor{i})) = neighbor{i};
end
PtsNotInNeighbor = setdiff (1:n, NeighborPoints);
n = size (rawData, 1); 
pML = (cpt * cpt'); % P(MustLink | (di,dj)) = Sum(Ck:1:K) {P(Ck|Xi) * P(CK|Xj)}
pCL = 1-pML;        % P(CannotLink | (di,dj))
H = -pML.*log2(pML) -pCL.*log2(pCL);  % entropy/uncertainty in pairwise relation of (di,dj)
H(pML==0) = 0;
H(pCL==0) = 0;    

H(conMat~=0) = -1;
% only consider the pair with one unlabeled points and this points belonged
% to cluster's neighborhoods
H(PtsNotInNeighbor,PtsNotInNeighbor) = -1;
H(NeighborPoints, NeighborPoints) = -1;
% for i = 1:length(PtsNotInNeighbor)
%     curPt = PtsNotInNeighbor (i);
%     curCluster = clustering (curPt);
%     curClusterPts = find (clustering == curCluster);
%     for j = 1:length(neighborRaw)
%         curClusterPtsInNeighbor = intersect (curClusterPts, neighborRaw{j});
%         if isempty (curClusterPtsInNeighbor)
%             H(curPt, neighborRaw{j}) = -1;
%             H(neighborRaw{j}, curPt) = -1;
%         end
%     end
% end

temp = ones(size(H));
temp = triu(temp, 1); 

H(temp == 0) = -1;

H = reshape (H, n*n, 1);

% random permutate the H vector
rp=randperm(n*n);
H=H(rp);
[v,p]=max(H);
p=rp(p);

js = ceil(p/n);
is = p - (js-1)*n;

neighborQueryOrder = size (neighborNum, 1);
if find (is == NeighborPoints)
    uncertainPointRaw = js;
    for i = 1:neighborNum
        if find(is==neighbor{i})
            neighborQueryOrder (1) = i;
            neighborQueryOrder (2:neighborNum) = setdiff (1:neighborNum, i);
            break;
        end
    end
elseif find (js == NeighborPoints)
    uncertainPointRaw = is;
    for i = 1:neighborNum
        if find(js==neighbor{i})
            neighborQueryOrder (1) = i;
            neighborQueryOrder (2:neighborNum) = setdiff (1:neighborNum, i);
            break;
        end
    end
end
i = 1;

if ~exist ('uncertainPointRaw','var')
    ['111']
end

while nq>0 && i <=neighborNum
    flag = (rawData (neighbor{neighborQueryOrder(i)}(1), end) == rawData (uncertainPointRaw, end));
    nq = nq - 1;
    if flag == 0
        flag = flag - 1;
    end
    nPairs (end+1, :) = [neighbor{neighborQueryOrder(i)}(1), uncertainPointRaw, flag];
    if flag == 1
        neighbor{neighborQueryOrder(i)}(end+1) = uncertainPointRaw;
        break;
    elseif flag == -1 && i == neighborNum
        neighbor{end+1}(1) = uncertainPointRaw;
    end    
    i = i + 1;    
end

end
