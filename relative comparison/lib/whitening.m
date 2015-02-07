function data = whitening(data)
label = data (:, end);
dat = data (:, 1:end-1);
covs = cov (dat);
dat = dat * sqrtm(inv(covs));
data = [dat, label];
end

