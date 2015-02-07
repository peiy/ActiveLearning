function [concrete_sample] = gtSampling(p_YgivenX , conMat, neighb, num_neighbs)
    % p_YgivenX: the probability distribution table of P(C=c|X=x)
    % conMat: n*n matrix contains information regarding the must-link and 
    %                     cannot-link relations among data points ('1' represents must-link relation, 
    %                     '-1' represents cannot-link and '0' represents (no relation/information)
    %
    % To decide each sample should be assign to which cluster, we toss a k sided coin.
    % note that all data points with must-link relations must be assigned to the same cluster.
    % and those with cannot link relation must be assigned to different cluster.
    
    global n;
    global c;
    
    %-----------------------------------------------------------
    n_restart = 3; %c+1;
    %-----------------------------------------------------------
    
    concrete_sample = zeros(n,1);
    
    % for all neighborhoods
    if(num_neighbs>1)
        neighbAsgnentProb = cellfun(@(x){mean(p_YgivenX(x,:),1)},neighb);
        neighbCLrelations = cellfun(@(x){conMat(x(1),:)<-1}, neighb);
        
        for i=1:num_neighbs
            l = zeros(n_restart,1); % just to have a more stable results.
            for j=1:n_restart
                % deciding which cluster I should assign this neighbor 
                r = rand;
                sum = 0;
                for k = 1:c;
                    if((r>sum) && (r<=(sum+neighbAsgnentProb{i}(k))))
%                         concrete_sample(neighb{i}) = k;
                        l(i)=k;
                        break;
                    end
                    sum=sum+neighbAsgnentProb{i}(k);
                end
            end
            l = l(l>0);
            tl = argmax(accumarray(l, ones(length(l),1)));
            concrete_sample(neighb{i}) = tl;             
            
            if(any(concrete_sample(neighbCLrelations{i})== tl))
                i=i-1;
            end
        end
        
    end

    % for all single points
    for i=1:n;
        if(concrete_sample(i) == 0)
            l = zeros(n_restart,1); % just to have a more stable results.
            for j=1:n_restart
                % deciding which cluster I should assign this neighbor 
                r = rand;
                sum = 0;
                for k = 1:c;
                    if((r>sum) && (r<=(sum+p_YgivenX(i,k))))
%                         concrete_sample(i)=k;
                        l(i)=k;
                        break;
                    end
                    sum=sum+p_YgivenX(i,k);
                end
            end
            l = l(l>0);
            tl = argmax(accumarray(l, ones(length(l),1)));
            concrete_sample(i) = tl;             
            
            if(any(concrete_sample(conMat(i,:)<0)== tl))
                i = i-1; % there is a CL for (Xi,Xj) & Xj has been assigned before => find another assignment for Xi.
                concrete_sample(i) = 0; % removing our current assignment
            end
        end            
    end % for(i)
end







%     % OLD WAY OF DOING THINGS
%     concrete_sample = zeros(n,1);
%     % for all neighborhoods
%     if(num_neighbs>1)
%         neighbAsgnentProb = cellfun(@(x){mean(p_YgivenX(x,:),1)},neighb);
%         neighbCLrelations = cellfun(@(x){conMat(x(1),:)<-1}, neighb);
%         
%         for i=1:num_neighbs
%             % deciding which cluster I should assign this neighbor 
%             r = rand; sum = 0;
%             for k = 1:c;
%                 if((r>sum) && (r<=(sum+neighbAsgnentProb{i}(k)))) 
%                     concrete_sample(neighb{i})=k; break;
%                 end
%                 sum=sum+neighbAsgnentProb{i}(k);
%             end
%             
%             if(any(concrete_sample(neighbCLrelations{i})== concrete_sample(neighb{i}(1)))) i=i-1; end
%         end
%     end
% 
%     % for all single points
%     for i=1:n;
%         if(concrete_sample(i) == 0)
%             % deciding which cluster I should assign this neighbor 
%             r = rand; sum = 0;
%             for k = 1:c;
%                 if((r>sum) && (r<=(sum+p_YgivenX(i,k))))
%                     concrete_sample(i)=k; break;
%                 end
%                 sum=sum+p_YgivenX(i,k);
%             end
%             
%             if(any(concrete_sample(conMat(i,:)<0)== tl))
%                 i = i-1; % there is a CL for (Xi,Xj) & Xj has been assigned before => find another assignment for Xi.
%                 concrete_sample(i) = 0; % removing our current assignment
%             end
%         end            
%     end % for(i)
