function [conMatTrans, conPairs] = transitive_closure (conMat, newAddPairs, n)
iterSum = size (newAddPairs, 1);
trans_pairs = newAddPairs;
for i = 1:iterSum 
    rowIndex = trans_pairs (i,1);
    columnIndex = trans_pairs (i,2);
    for j = 1:n
        if (conMat(j, rowIndex) == 1 && conMat(rowIndex, columnIndex) == 1 && conMat (j, columnIndex) == 0 && j ~= columnIndex)
            conMat (j, columnIndex) = 1;
            conMat (columnIndex, j) = 1;
            trans_pairs (iterSum+1, :) = [j, columnIndex];
            iterSum = iterSum + 1;
        end
        if (conMat(j, rowIndex) == -1 && conMat(rowIndex, columnIndex) == 1 && conMat (j, columnIndex) == 0 && j ~= columnIndex)
            conMat (j, columnIndex) = -1;
            conMat (columnIndex, j) = -1;
            trans_pairs (iterSum+1, :) = [j, columnIndex];
            iterSum = iterSum + 1;
        end
        if (conMat(j, rowIndex) == 1 && conMat(rowIndex, columnIndex) == -1 && conMat (j, columnIndex) == 0 && j ~= columnIndex)
            conMat (j, columnIndex) = -1;
            conMat (columnIndex, j) = -1;
            trans_pairs (iterSum+1, :) = [j, columnIndex];
            iterSum = iterSum + 1;
        end
        if (conMat (rowIndex, columnIndex) == 1 && conMat(columnIndex, j) == 1 && conMat (rowIndex, j) == 0 && j ~= rowIndex)
            conMat (rowIndex, j) = 1;
            conMat (j, rowIndex) = 1;
            trans_pairs (iterSum+1, :) = [rowIndex, j];
            iterSum = iterSum + 1;
        end
        if (conMat (rowIndex, columnIndex) == -1 && conMat(columnIndex, j) == 1 && conMat (rowIndex, j) == 0 && j ~= rowIndex)
            conMat (rowIndex, j) = -1;
            conMat (j, rowIndex) = -1;
            trans_pairs (iterSum+1, :) = [rowIndex, j];
            iterSum = iterSum + 1;
        end
        if (conMat (rowIndex, columnIndex) == 1 && conMat(columnIndex, j) == -1 && conMat (rowIndex, j) == 0 && j ~= rowIndex)
            conMat (rowIndex, j) = -1;
            conMat (j, rowIndex) = -1;
            trans_pairs (iterSum+1, :) = [rowIndex, j];
            iterSum = iterSum + 1;
        end
    end 
end
conMatTrans = conMat;
conPairs = trans_pairs;
conPairs (:, 3) = conMat (trans_pairs(:,1) + (trans_pairs (:,2)-1)*n);
end