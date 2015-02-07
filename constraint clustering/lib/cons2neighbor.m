function neighbor = cons2neighbor (cons, data)
classNum = length(unique(data(:, end)));
n = length (data);
numCons = size (cons, 1);
neighbor = zeros (numCons, n+1);
for i = 1:numCons
    if i == 1
        link = cons (i, 3);
        if link == 1
            neighbor (i, cons (i, 1) + 1) = 1;
            neighbor (i, cons (i, 2) + 1) = 1;
            neighbor (i, 1) = i;
        else
            neighbor (i, cons (i, 1) + 1) = 1;
            neighbor (i, cons (i, 2) + 1) = 2;
            neighbor (i, 1) = i;
        end
    else
        neighbor (i, 2:end) = neighbor (i-1, 2:end);
        numCurNeigh = max (neighbor (i, 2:end));
        link = cons (i, 3);
        if link == 1
            neighbor (i, cons (i, 2) + 1) = neighbor (i, cons (i, 1) + 1);
            neighbor (i, 1) = i;
        else
            p = 0;
            q = 0;
            cannotlinks = cons (i-numCurNeigh+1:i, :);
            if (sum(cannotlinks (:, 3) == -1) == size (cannotlinks, 1))
                p = 1;
            end
            if (sum(cannotlinks (:, 2) == cons (i, 2)) == size (cannotlinks, 1))
                q = 1;
            end
            if (p == 1 && q == 1)
                neighbor (i, cons (i, 2) + 1) = numCurNeigh + 1;
                neighbor (i, 1) = i;
            end          
        end
    end
end
temp = (find (neighbor (:, 1) == 0));
neighbor (temp, :) = [];
end