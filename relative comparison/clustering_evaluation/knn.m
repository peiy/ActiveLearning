function acc = knn(train, test, labelTrain, labelTest)
predictLabel = zeros(size(test, 1), 1);
for i = 1: size (test, 1)
    temp = repmat (test (i, :), size (train, 1), 1);
    disAll = sum((temp - train).^2, 2);
    [~, index] = min (disAll);
    predictLabel (i) = labelTrain (index);
end
flag = (predictLabel == labelTest);
acc = sum(flag)/size(labelTest, 1);
end

