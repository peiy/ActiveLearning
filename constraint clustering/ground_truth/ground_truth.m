function p_YgivenX = ground_truth(cluster, cluster_size, means, data)
    % p_YgivenX: the conditional probability table ~ P(Y=y|X=x)
    %
    %GROUND_TRUTH
    % given data-set of n data-points, and the cluster labels for each data-point 
    % (assuming P(X=x|C=c) follows the multivariate gaussian distribution)
    % this function finds probability distribution function {P(C=c|X=x)} for each data point x and each cluster c.
    % P(C=c|X=x) = P(X=x|C=c)*P(C=c) / P(X=x)
    %            = MVN(X,Mean(C), Var(X|C))*P(C=c) / Sum_(C=1:c){P(X=x|C=c)*P(C=c)}
    
 
%check for empty or singleton clusters
tcluster=cluster;
tclustersize=cluster_size;
i = 1;
% while (i <= size(cluster, 2))
%     if length(cluster{i})<2
%         cluster(i)=[];
%         i = i-1;
%     end
%     i = i+1;
% end
cluster_size(cluster_size<2)=[];
    for i=1:length(cluster)
        covs{i}= cov(data(cluster{i},:));
  %     covs = cellfun(@(x) {cov(data(x,:))}, cluster);
    end
    for i=1:length(cluster)
         [R,err] = cholcov(covs{i},0);
         if err ~= 0 
              covs{i} = addEigen(covs{i});
         end
    end
    %x = addEigen (@(x){x});
    %y = addEigen (@(y){y});
    for i=1: length(cluster)
        if size(covs{i}, 1) ~= size(covs{i}, 2)
            fprintf ('not square matrix');
            covs{i}
        end
        if size(data, 2) ~= size(covs{i}, 1)
            fprintf ('size not match');
        end
        p_XgivenY(:,i)=mvnpdf(data, means(i,:), covs{i});
    end
%    p_XgivenY = cellfun(@(x,y) {mvnpdf(data,x,y)},mat2cell(means,ones(1,c),f)',covs);
    prior = cluster_size/sum(cluster_size);
    p_YgivenX = p_XgivenY * diag(prior);
    p_YgivenX = diag(1./sum(p_YgivenX,2)) * p_YgivenX; 
    cluster=tcluster;
    cluster_size=tclustersize;
end





%     % OLD Way of doing things
%     prior = cluster_size/n;
%     p_XgivenY = zeros(n,c);    
%     for i=1:c;
%         ck = cluster{i};
%         
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %         % dealing with small cluster size
% %         if(size(ck,1) < f)
% %             for i=1:ceil((f-size(ck,1))/3)
% %                 ck = [ck; ck(1,:)+random('unif', -.1,.1, 1, length(ck(1,:)))];
% %                 ck = [ck; ck(floor(end/2),:)+random('unif', -.1,.1, 1, length(ck(1,:)))];
% %                 ck = [ck; ck(end,:)+random('unif', -.1,.1, 1, length(ck(1,:)))];
% %             end
% %         end
% %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         covarianceMat = cov(ck);
%         
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % deaing with zero row/columns in cov. matrix /fixed-value features in cluster
%         epsilon = 10^(-3);
%         m = length(covarianceMat);
%         min_eig = min(eig(covarianceMat));
%         while(min_eig < (10^(-10)))
%             covarianceMat = covarianceMat - ((min_eig-epsilon) * eye(m));
%             min_eig = min(eig(covarianceMat));
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         p_XgivenY(:,i) = mvnpdf(data , means(i,:), covarianceMat);
%     end
%     
%     p_YgivenX = p_XgivenY * diag(prior);
%     p_YgivenX = diag(1./sum(p_YgivenX, 2)) * p_YgivenX;
