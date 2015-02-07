function weight = svmDisLearning (triplet, C, data, A)
triNum = size (triplet,1);
fNum = size (data, 2);
xNum = fNum + triNum;

% Assign H, A, f, b in the standard quadratic programming problem  
% min 0.5*x'*H*x + f'*x   subject to:  A*x <= b 
if ~isempty (triplet)
    if nargin == 3 % L is identity matrix
        H = zeros (xNum);
        H (1:fNum, 1:fNum) = eye(fNum);
        f = zeros (xNum, 1);
        f (fNum+1:end) = C;
        b = -1 * ones (triNum, 1);
        A = zeros (triNum, xNum);
        for i = 1:triNum  
            delta_ij = (data (triplet (i, 1), :) - data (triplet (i, 2), :)).^2;
            delta_ik = (data (triplet (i, 1), :) - data (triplet (i, 3), :)).^2;
            A (i, 1:fNum) = delta_ij - delta_ik;
            A (i, fNum+i) = -1;
        end
        lb = zeros (xNum, 1);
        ub = Inf*ones(xNum, 1);
    end
    options = optimset('MaxIter',10000, 'algorithm', 'active-set', 'display', 'off');
    % use quadprog function to solve
    %[x,fval,exitflag,output] = quadprog(H,f,A,b,[],[],lb,ub,[],options);
    % use fmincon function to solve
    startPoint = zeros (xNum, 1);
    x = fmincon (@(x) 0.5*x'*H*x+f'*x, startPoint, A, b, [], [], lb, ub, [], options);
    weight = x(1:fNum);
else
    weight = ones (1, fNum);
end
    
end