function [tripletYN, tripletDKN] = oracle (data, query, tripletYN, tripletDKN)
iEQj = data (query (:, 1), end) == data (query (:, 2), end);
iEQk = data (query (:, 1), end) == data (query (:, 3), end);
jEQk = data (query (:, 2), end) == data (query (:, 3), end);
temp1 = query (iEQj == 1 & iEQk == 0, :);
temp2 = query (iEQj == 0 & iEQk == 1, :);
temp2 (:, [2,3]) = temp2 (:, [3,2]);
tripletYN = vertcat (tripletYN, temp1);
tripletYN = vertcat (tripletYN, temp2);
temp1 = query (iEQj == 1 & iEQk == 1, :);
temp2 = query (iEQj == 0 & iEQk == 0 & jEQk == 0, :);
temp3 = query (iEQj == 0 & jEQk == 1, :);
tripletDKN = vertcat (tripletDKN, temp1);
tripletDKN = vertcat (tripletDKN, temp2);
tripletDKN = vertcat (tripletDKN, temp3);
end
