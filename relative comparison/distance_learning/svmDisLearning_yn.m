function [W, x] = svmDisLearning_yn (triplet, C, data, oldSolution, L)
triNum = size (triplet,1);
fNum = size (data, 2);
xNum = fNum + triNum;
W = eye (fNum);
x = ones (xNum, 1);
% Assign H, A, f, b in the standard quadratic programming problem  
% min 0.5*x'*H*x + f'*x   subject to:  A*x <= b 
if ~isempty (triplet)
    if nargin < 5 % L is identity matrix
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
    
    % use ibm cplex to solve
    % options = cplexoptimset;
    % options.diagnostics = 'on';
    [x,fval,exitflag,output,lambda] = cplexqp(H,f,A,b,[],[],lb,ub,oldSolution);
    % use matlab quadprog to solve
    %if isempty (oldSolution)
    %   options = optimset('Algorithm','interior-point-convex','Display','off');
    %else 
    %   options = optimset('Algorithm','active-set','Display','off'); 
    %end
    %[x,fval,exitflag,output] = quadprog(H,f,A,b,[],[],lb,ub,oldSolution,options);
    %x (x < 0 & x > -0.00001) = 0;
    W (W == 1) = sqrt(x(1:fNum));
end    
end

