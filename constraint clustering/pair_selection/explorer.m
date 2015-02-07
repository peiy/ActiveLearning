function [neighbor, j, consPair] = explorer (nq, data, neighbor, randPair)
classNum = length(unique(data(:,end)));
consPair = randPair;
neighborNum = length(neighbor);
while (nq > 0 && neighborNum < classNum)
    NeighborPoints = [];
    for i = 1:neighborNum
        NeighborPoints (end+1:end+length(neighbor{i})) = neighbor{i};
    end
    farthestPoint = find_farthest(NeighborPoints, data);
    % check farthestPoint cannot link or must link...
    flag = 0;
    i = 1;
    while (i <= neighborNum && flag ~= 1 && nq > 0)
        flag = (data(farthestPoint, end) == data(neighbor{i}(1), end));
        nq = nq - 1;
        if flag == 1
            neighbor{i}(end+1) = farthestPoint;
            consPair(end+1,:) = [farthestPoint, neighbor{i}(1), 1];
        else
            consPair(end+1,:) = [farthestPoint, neighbor{i}(1), -1];
        end
        i = i+1;
    end
    if flag == 0
        neighbor{end+1}(1) = farthestPoint;
    end
    neighborNum = length(neighbor);
end
j = nq;
end
