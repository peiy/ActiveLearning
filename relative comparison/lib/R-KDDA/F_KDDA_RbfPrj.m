function [mPrjWgt]=F_KDDA_RbfPrj(mTestData,mTrainData,mKDDASubSpace,rbf_var);
%
% Syntax: [mPrjWgt]=F_KDDA_RbfPrj(mTestData,mTrainData,mKDDASubSpace,rbf_var);
% - Project the test samples to the kernel discriminant subspace, mKDDASubSpace.
% - The projection uses the RBF kernel, k(x,y)=exp(-||x-y||^2/rbf_var).
%
% [Input]
% [mTestData]: test examples with each column vector being a test sample.
% [mTrainData]: training examples with each column vector being a training sample.
% [mKDDASubSpace]: the kernel discriminant subspace found by F_KDDA_Rbf().
% [rbf_var]: Gaussian variance for RBF kernel.
%
% [Output]
% mPrjWgt: the projection of the test samples in the kernel discriminant
% subspace.
%
% Author: Lu Juwei - Bell Canada Multimedia Lab, Dept. of ECE, U. of Toronto
% Created in 3 July 2001
% 

test_smp_num=size(mTestData,2);	%n, size of the test set
train_smp_num=size(mTrainData,2);	%m, size of the learning set

mL=zeros(train_smp_num,test_smp_num);

for j=1:test_smp_num
    for i=1:train_smp_num
        tmp=mTrainData(:,i)-mTestData(:,j);
        mL(i,j)=exp(-(tmp'*tmp)/rbf_var); 
    end
end

mPrjWgt=mKDDASubSpace*mL;
