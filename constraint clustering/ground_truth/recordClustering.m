function recordClustering (clustering, datasetName, flag1, flag2, nq_initial)
global nps;
global repeatTime;
global fold_number;
cd results;
cd (datasetName);
fileName = [datasetName, '-', flag1, '-', flag2, '-', num2str(nq_initial), '-', num2str(nps), '-clustering.data'];
if (repeatTime*fold_number == 1)    
    dlmwrite(fileName,clustering,'-append');
end
cd ..;
cd ..;
end