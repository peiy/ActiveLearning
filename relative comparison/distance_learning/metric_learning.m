function [W, x] = metric_learning(disMethod, data, triple, parameter, oldSol)
%METRIC_LEARNING Summary of this function goes here
%W: transformation matrix s.t. X' = XW.
%x: solution to optimization problem
%Detailed explanation goes here
if isequal (disMethod, 'joachims') % Joachism's learning algorithm
    [W, x] = svmDisLearning_yn (triple, parameter, data, oldSol);  
elseif isequal (disMethod, 'romer') % Romer's learning algorithm
    triRomer = triple;
    triRomer (:, end+1) = 1;
    [~, W, x] = romer_lp(data, triRomer, parameter, oldSol);  
    fNum = size (data, 2);
    index = [];
    zer = zeros (fNum, 1);
    for i = 1:fNum
        if ~isequal (W (:, i), zer)
            index(end+1) = i;
        end
    end
    temp = eye (fNum);
    W (temp == 1) = diag (W) + 0.00001;
    WW = W (index, index);
    BB = chol (WW);
    if ~isempty (WW)
        A = zeros (size (BB, 1), fNum);
        A (:, index) = BB;
        W = A'; 
    else
        W = zeros (fNum);
    end
  
end
end

