function [p_YgivenX, coassMat] =  random_forest (data, Tlabels)
b= TreeBagger (50, data, Tlabels, 'oobpred','on');
b = b.fillProximities;
coassMat = b.Proximity;
[~,p_YgivenX] = oobPredict (b);
end