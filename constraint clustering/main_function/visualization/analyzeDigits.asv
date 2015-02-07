function analyzeDigits (startPos, endPos)
ppp = {'og', '+m', 'xb', '*r', 'squarey', 'diamondk'};
cd ..;
x = 'Data-Sets/digits-389';
cd (x);
x = 'digits-389.data';
rawData = load (x);
n = length(rawData);
data = rawData (:, 1:end-1);
sigma=cov(data);
v=pcacov(sigma);
reduceData= data* [v(:,1),v(:,3)]; 
reducerawData = [reduceData, rawData(:,end)];
class_num = length(unique(rawData(:,end)));
for i = 1 : class_num
    plot (reduceData(reducerawData(:,end)==i, 1), reduceData(reducerawData(:,end)==i, 2), ppp{i});
    hold on;
end
n1 = [1964, 2051, 1909, 1406, 1624, 1950, 1574, 1301, 1997, 1739, 1724, 1827, 1921, 1982];
n2 = [3048, 2847, 3076, 2840];
n3 = [708];
plot (reduceData(n1, 1), reduceData (n1, 2), '*r');
hold on;
plot (reduceData(n2, 1), reduceData (n2, 2), 'squarey');
hold on;
plot (reduceData(n3, 1), reduceData (n3, 2), 'diamondk');




% cd ..;
% cd ..;
% cd 'results';
% cd 'digits-389';
% cluster = load ('digits-389-pt-new-RF-EQNEW-150-1-cluster.data');
% neighbor = load ('digits-389-pt-new-RF-EQNEW-150-1-neighbor.data');
% result = load ('digits-389-pt-new-RF-EQNEW-150-1.data');
% iterNum = length(find (result (1:startPos, 6) == 0));
% startPos = (iterNum-1)*n+statPair;
% endPos = (iterNum-1)*n+endPair;








