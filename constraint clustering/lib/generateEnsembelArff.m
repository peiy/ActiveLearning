function generateEnsembelArff (data, Tlabels, datasetName, flag)
cd wekaUT/weka-latest/data;
wholedata = [data, Tlabels];
if (flag == 1)
    fileName = [datasetName, '-ensemble.arff'];
elseif (flag == 0)
    fileName = [datasetName, '.arff'];
elseif (flag == 2)
    fileName = [datasetName, '-train.arff'];
end
fid = fopen (fileName, 'w+');
firstline = ['@relation ', datasetName];
fprintf (fid, '%s\n\n', firstline);
for i = 1:(size(wholedata, 2)-1)
    attributeLine = ['@attribute a', num2str(i), ' real'];
    fprintf (fid, '%s\n', attributeLine);
end
classNum = length(unique(Tlabels));
temp = [];
for j = 1:classNum
    temp = [temp, num2str(j)];
    if j ~= classNum
        temp = [temp, ','];
    end
end
attributeLine = ['@attribute class {' ,temp, '}'];
fprintf (fid, '%s\n\n', attributeLine);
fprintf (fid, '%s\n\n', '@data');
fclose (fid);
dlmwrite (fileName, wholedata,'-append');

    
cd ..;
cd ..;
cd ..;
end
