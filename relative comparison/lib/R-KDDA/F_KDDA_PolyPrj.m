function [mPrjWgt]=F_KDDA_PolyPrj(mTestData,mTrainData,mKDDASubSpace,poly_deg,poly_a,poly_b);
%
% Syntax: [mPrjWgt]=F_KDDA_PolyPrj(mTestData,mTrainData,mKDDASubSpace,poly_deg,poly_a,poly_b);
% - Project the test samples to the kernel discriminant subspace, mKDDASubSpace.
% - The projection uses the polynomial kernel, k(x,y)=(a(x.y)+b)^d.
%
% [Input]
% [mTestData]: test examples with each column vector being a test sample.
% [mTrainData]: training examples with each column vector being a training sample.
% [mKDDASubSpace]: the kernel discriminant subspace found by F_KDDA_Poly().
% [poly_deg,poly_a,poly_b]: polynomial parameters.
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
        mL(i,j) = (poly_a*(mTrainData(:,i)'*mTestData(:,j))+poly_b)^poly_deg;
    end
end

mPrjWgt=mKDDASubSpace*mL;
