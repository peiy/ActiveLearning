function [cluster, cluster_size, centroids, clustering] = MPCKmeans (datasetName, wholeData, conMat)
if nargin == 3
    creatContraintsFile (conMat, datasetName);
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -C data/' ,datasetName, '.constraints -O ', datasetName, 'Result.data -i 200'];
    dos (x);
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
    cd ..;
    cd ..;
elseif nargin == 2
    cd wekaUT/weka-latest;
    x = ['java weka/clusterers/MPCKMeans -D data/', datasetName, '.arff -O ', datasetName, 'Result.data -i 200'];
    dos (x);   
    [cluster, cluster_size, centroids, clustering] = getResult (datasetName, wholeData);
    cd ..;
    cd ..;
end


