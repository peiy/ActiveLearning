function vec = num2vec(num, n)
vec = zeros (length(num), 3);
vec (:,3) = mod (num, n);
temp = (num - vec (:,3))./n;
vec (:,2) = mod (temp, n);
vec (:,1) = (temp - vec (:,2))./n;
end

