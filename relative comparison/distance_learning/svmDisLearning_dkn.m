function weight = svmDisLearning_dkn (tripletYN, tripletDKN, C1, C2, data, L)
triNumYN = size (tripletYN, 1);
triNumDKN = size (tripletDKN, 1);
triNum = triNumYN + triNumDKN;
fNum = size (data, 2);
xNum = fNum + triNum;

% Assign H, A, f, b in the standard quadratic programming problem  
% min 0.5*x'*H*x + f'*x   subject to:  A*x <= b 
if ~isempty (tripletYN) || ~isempty (tripletDKN)
    if nargin == 5 % L is identity matrix
        H = (zeros (xNum));
        H (1:fNum, 1:fNum) = eye(fNum);
        f = (zeros (xNum, 1));        
        f (fNum+1:fNum+triNumYN) = C1;
        f (fNum+triNumYN+1:end) = C2;
        b = (ones (triNum+triNumDKN, 1));
        b (1:triNumYN) = -1;
        A = (zeros (triNum+triNumDKN, xNum));
        for i = 1:triNumYN
            delta_ij = (data (tripletYN (i, 1), :) - data (tripletYN (i, 2), :)).^2;
            delta_ik = (data (tripletYN (i, 1), :) - data (tripletYN (i, 3), :)).^2;
            A (i, 1:fNum) = delta_ij - delta_ik;
            A (i, fNum+i) = -1;
        end
        for i = 1:triNumDKN            
            delta_ij = (data (tripletDKN (i, 1), :) - data (tripletDKN (i, 2), :)).^2;
            delta_ik = (data (tripletDKN (i, 1), :) - data (tripletDKN (i, 3), :)).^2;
            A (i+triNumYN, 1:fNum) = delta_ij - delta_ik;
            A (i+triNumYN, fNum+triNumYN+i) = -1;
            A (i+triNumYN+triNumDKN, 1:fNum) = delta_ik - delta_ij;
            A (i+triNumYN+triNumDKN, fNum+triNumYN+i) = -1;                                    
        end
        lb = (zeros (xNum, 1));
        ub = (Inf*ones(xNum, 1));
    end
  
    
    %options = optimset('Algorithm','interior-point','Display','iter','GradObj','on','GradConstr','on','Hessian','user-supplied','HessFcn',@(x)H);
    % use quadprog function to solve
    options = optimset('Algorithm','interior-point-convex','Display','iter');
    [x,fval,exitflag,output] = quadprog(H,f,A,b,[],[],lb,ub,[],options);
    % use fmincon function to solve
    %startPoint = (zeros (xNum, 1));
    %x = fmincon (@(x) 0.5*x'*H*x+f'*x, startPoint, A, b, [], [], lb, ub, [], options);
    weight = x(1:fNum);
else
    weight = ones (fNum, 1);
end
    
end