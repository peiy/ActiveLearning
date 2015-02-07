function [rawData, indices] = initialize(datasetPath, k)   
    %% Loading data 
    % reading data-set
    % data : values of features for each example without truth labels
    curFold = pwd;
    cd ..;
    rawData = load (datasetPath);
    Tlabels = rawData (:,end); % truth label
    classNum = length (unique(rawData(:,end))); % number of classes
    t=unique(Tlabels); 
    if (t~=(1:classNum)') % rearrange truth labels starting from 1
        for i = 1:classNum
            temp = rawData (:,end) == t(i);
            rawData(temp,end)=i;
        end
    end
    indices = crossvalind('Kfold', Tlabels, k);
    cd (curFold);
end