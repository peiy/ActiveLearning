function f1 = fmeasure (labels, clustering, train, test)



if ~isempty(test)
    testLabels = labels(test);
    testCluster = clustering(test);
    n = length (testLabels);
else
    testLabels = labels(train);
    testCluster = clustering(train);
    n = length (testLabels);
end
k=1;
for i = 1:n
    for j = i+1:n
        l(k) = (testLabels(i) == testLabels (j));
        c(k) = (testCluster(i) == testCluster(j));
        k=k+1;
    end
end
precision = length(intersect(find(l==1),find(c==1)))/length(find(c==1));
recall = length(intersect(find(l==1),find(c==1)))/length(find(l==1));
f1 = 2*precision*recall/(precision+recall);
%f1 = 1;
end