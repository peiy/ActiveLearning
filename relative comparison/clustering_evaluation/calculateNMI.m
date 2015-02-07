function nmis=calculateNMI(classid, clusterids)

[instnum,runnum] = size(clusterids);
class1=formw(classid, 1, instnum);
classProb1=sum(class1)/instnum;
entr_class1 = sum(classProb1 .* log(classProb1));

nmis = zeros(1, runnum);
for i=1:runnum
  class2=formw(clusterids(:,i), 1, instnum);
  classProb2=sum(class2)/instnum;
  entr_class2=sum(classProb2 .* log(classProb2));
  PIPJ = classProb1'*classProb2;
  N=class1'*class2/instnum;
  mi=sum(sum( N(find(N~=0)).*log(N(find(N~=0)) ./ PIPJ(find(N~=0))) ));
  nmis(1,i)=mi/sqrt(entr_class1*entr_class2);
end


function w=formw(idxs, r, instnum)
site=1;
for i=1:r
 idx = idxs(:,i);
 uniqueks=unique(idx(idx>0)); % 0 is considered to be the unclustered
 %mik=min(idx(idx>0));
 %mak=max(idx);
 t=zeros(instnum, length(uniqueks));
 t(find(repmat(idx, 1, length(uniqueks)) == repmat(uniqueks', instnum, 1)))=1;
 w(:, site:site+length(uniqueks)-1) = t;
 site=site+length(uniqueks);
end