function [p_YgivenX, coassMat] =  random_forest (data, Tlabels)
n = size (data, 1);
b= TreeBagger (50, data, Tlabels, 'oobpred','on','MinLeaf', 1);%round(n/10));
b = b.fillProximities;
coassMat = b.Proximity;
[~,p_YgivenX] = oobPredict (b);
hist(coassMat, 10);
end