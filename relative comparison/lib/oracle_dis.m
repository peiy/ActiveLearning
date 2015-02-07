function newTriplet  = oracle_dis (newQuery, triplet, trueData)
dis_ij = sum((trueData (newQuery (:, 1), :) - trueData (newQuery (:, 2), :)).^2, 2);
dis_ik = sum((trueData (newQuery (:, 1), :) - trueData (newQuery (:, 3), :)).^2, 2);
indexY = (dis_ij <= dis_ik);
indexN = find (dis_ij > dis_ik);
tripletY = newQuery (indexY, :);
tripletN = horzcat(newQuery(indexN, 1),newQuery(indexN,3),newQuery (indexN,2));
newTriplet = vertcat (triplet, tripletY);
newTriplet = vertcat (newTriplet, tripletN);
end

