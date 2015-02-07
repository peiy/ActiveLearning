function visualize (dataset)
cd ('Data-Sets');
cd (dataset);
fileName1 = [dataset, '.data'];
fileName2 = [dataset, '-true.data'];    
data = load (fileName1);
data_true = load (fileName2);
covs = cov (data);
covs = covs./(diag(covs)*diag(covs)');
covs_true = cov (data_true);
covs_true = covs_true./(diag(covs_true)*diag(covs_true)');
a = data * covs;
b = data_true * covs_true;
plot (a(:, 1), a(:, 2), '+');
figure (2);
plot (b(:, 1), b(:, 2), '+');
cd ..;
cd ..;
end
