function nmi = nmi(clustering1, clustering2)
    %%  Hanchuan Peng CODE from http://www.mathworks.com/matlabcentral/fileexchange/14888
%    nmi = (2*mutualinfo(clustering1,clustering2)/(entropy(clustering1)+entropy(clustering2)));
% calculate entropy(clustering1)
if ~isempty(clustering1)
    label1 = unique (clustering1);
    temp1 = tabulate (clustering1);
    prob1 = temp1 (:,3)/100;
    prob1(prob1 == 0) = 1;
    entropy1 = -sum(prob1 .* log2(prob1), 1);
    % calculate entropy(clustering2)
    temp2 = tabulate (clustering2);
    prob2 = temp2 (:,3)/100;
    prob2(prob2 == 0) = 1;

    entropy2 = -sum(prob2 .* log2(prob2), 1);
    % calculate H(clustering2|clustering1)
    entropy3 = zeros (length(label1), 1);
    for i = 1:length(label1)
        IDX = (clustering1 == label1(i));
        clustering3 = clustering2 (IDX);
        temp3 = tabulate (clustering3);
        prob3 = temp3 (:,3)/100;
        prob3(prob3 == 0) = 1;
        entropy3(i) = -sum(prob3 .* log2(prob3), 1);
    end
    con_entropy = sum(prob1.*entropy3, 1);
    MI = entropy2 - con_entropy;
    nmi = 2*MI/(entropy1+entropy2);
else
    nmi = 1;
end
end
