function [neighbor, j, consPair] = explorer_plus (nq, train, test, wholeData)
classNum = length(unique(wholeData(:,end)));
consPair = [];
data = wholeData(train,:);
neighbor = cell(1,classNum);
startpoint = randi(length(data), 1, 1);
neighbor{1}(1) = startpoint;
while (nq>0 && isempty(neighbor{classNum}))
    NeighborPoints = [];
    for i = 1:classNum
        NeighborPoints (end+1: end+length(neighbor{i})) = neighbor{i};
    end
    farthestPoint = find_farthest_plus(NeighborPoints, data);
    % check farthestPoint cannot link or must link...
    flag = 0;
    i = 1;
    while (~isempty(neighbor{i}) && flag ~= 1)
        flag = (data(farthestPoint, end) == data(neighbor{i}(1), end));
        nq = nq - 1;
        if flag == 1
            neighbor{i}(end+1) = farthestPoint;
            consPair(end+1,:) = [train(farthestPoint), train(neighbor{i}(1)), 1];
        else
            consPair(end+1,:) = [train(farthestPoint), train(neighbor{i}(1)), -1];
        end
        i = i+1;
    end
    if flag == 0
        for i = 1:classNum
            if isempty (neighbor{i})
                neighbor{i}(1) = farthestPoint;
                break;
            end
        end
    end
end
j = nq;

end
