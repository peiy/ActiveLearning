function dist =  distance_(X, Y)
[d, n]=size(X);
[d, k]=size(Y);
for i=1:k
    z=X-repmat(Y(:, i), 1, n);
    dist(:,i)=(sum(z.^2))';
end