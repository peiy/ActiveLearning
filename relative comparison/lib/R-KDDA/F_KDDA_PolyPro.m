function [mKDDASubSpace]=F_KDDA_PolyPro(mTrainData,vEachclass_num,poly_deg,poly_a,poly_b)
%
% Syntax:
% [mKDDASubSpace]=F_KDDA_PolyPro(mTrainData,vEachclass_num,poly_deg,poly_a,poly_b);
% - To build a kernel discriminant subspace using the polynomial kernel,
%   k(x,y)=(a(x.y)+b)^d.
%
% [Input]
% mTrainData: Input training data, should be a matrix with each column
%   vector being a training sample.
% vEachclass_num: the number of training samples per class, should be a
%   vector.
% poly_deg,poly_a,poly_b: polynomial parameters.
% stRegParam.Eta_Sw: the regularization parameter for ill-posed Sw
% stRegParam.Threshold_EigVal_Sb: see below.
% stRegParam.Update_EigVal_Sb: see below.
%
% [Output]
% mKDDASubSpace: the found kernel discriminant subspace.
%
% Author: Lu Juwei - Bell Canada Multimedia Lab, Dept. of ECE, U. of Toronto
% Created in 3 July 2001
% Modified in 11 May 2004
%

% ***********************************************************************
% The user should set the values of stRegParam according to the L value.
% ***********************************************************************
I=find(vEachclass_num<=2);
sss_rate=sum(vEachclass_num(I))/sum(vEachclass_num);
if sss_rate>=0.5
    % For L=2; L is the number of training samples per subject.
    stRegParam=struct('Eta_Sw',{1},'Threshold_EigVal_Sb',{0.02},'Update_EigVal_Sb',{0.05},'RemainEigVec',{1});
else
    % For L>2;
    stRegParam=struct('Eta_Sw',{1e-3},'Threshold_EigVal_Sb',{0.02},'Update_EigVal_Sb',{0.2},'RemainEigVec',{0.8});
end

% regularization parameter for ill-posed within-class scatter matrix.
% smaller number of training samples per subject need stronger regularizer.
% \eta \in [0,1]. Try different values of eta to find the best one.
% For simplicity, set eta_sw=1e-3; 
eta_sw=stRegParam.Eta_Sw;

% The threshold is used to determine which small eigenvalues of Sb need to
% be adjusted. For simplicity, set thresh_eigval_sb=0.02 (of the biggest 
% eigenvalue of Sb).
thresh_eigval_sb=stRegParam.Threshold_EigVal_Sb;

% The the new value for those eigvalues of Sb needed to be adjusted.
% For simplicity, set update_eigval_sb=0.2 (of the biggest eigenvalue of
% Sb).
update_eigval_sb=stRegParam.Update_EigVal_Sb;

% The rate of remaining eigenvectors of Sb, others will be thrown away.
% For simplicity, set remain_eigvec=1, i.e. keep all the eigenvectors.
remain_eigvec=stRegParam.RemainEigVec;

class_num=length(vEachclass_num);
[samp_dim,samp_num]=size(mTrainData);

% kernel matrix - mK
mK=zeros(samp_num,samp_num);
for i=1:samp_num
    for j=1:samp_num
        mK(i,j) = (poly_a*(mTrainData(:,i)'*mTrainData(:,j))+poly_b)^poly_deg;
    end
end

% Definition of special matrix - m1_Nc,mA_Nc,mB
m1_Nc=ones(samp_num,class_num);
mA_Nc=zeros(samp_num,class_num);
A_idx=1;
for i=1:class_num
	t=ones(vEachclass_num(i),1)/vEachclass_num(i);
    mA_Nc(A_idx:A_idx+vEachclass_num(i)-1,i)=t;
    A_idx=A_idx+vEachclass_num(i);
end

mB=diag(vEachclass_num.^(1/2));
clear('t');

% Eigen-analysis of between-class scatter - mSb=Phi_b*Phi_b' - a inf x inf matrix
% First calculate mVarSb=Phi_b'*Phi_b - a class_num x class_num matrix

t1=mA_Nc'*mK*mA_Nc;
t2=mA_Nc'*mK*m1_Nc/samp_num;
t4=m1_Nc'*mK*m1_Nc/(samp_num*samp_num);

mVarSb=mB*(t1-t2-t2'+t4)*mB/samp_num;
mVarSb=(mVarSb+mVarSb')/2;

clear('t1','t2','t4');

[mEigvec_Sb,vEigval_Sb]=F_EigenSys(mVarSb);

% discard those with eigenvalues sufficient close to 0 and 
% extract first m_b eigenvectors corresponding to largest eigenvalues
%m_b=min([(class_num-1) rank(mVarSb)]); 

% Eigenvalue adjustment method 1: The following is a simple way to throw 
% those eigenvectors of Sb corresponding to those smallest eigenvalues 
% (close to zeros).
m_b=round((class_num-1)*remain_eigvec); 

% Eigenvalue adjustment method 2: increase those smallest eigenvalues to a
% bigger value (update_eigval_sb), so as to reduce their influence.
aa=vEigval_Sb/vEigval_Sb(1);
bb=find(aa<thresh_eigval_sb);
vEigval_Sb(bb)=vEigval_Sb(1)*update_eigval_sb; % (v1) seems better than (v2).
%vEigval_Sb=vEigval_Sb+vEigval_Sb(1)*update_eigval_sb; % (v2)

vEigval_Sb=vEigval_Sb(:,1:m_b);
mE=mEigvec_Sb(:,1:m_b);

vD=vEigval_Sb.^(-1);
mNormE=mE*diag(vD);

clear('vD','vEigval_Sb','mEigvec_Sb','mE','mVarSb');

% Eigen-analysis of within-class scatter: mSw and total scatter: mStot
% *** Definition of special matrix - m1_Nc,mA_Nc,mB ***
mW=zeros(samp_num,samp_num);
w_idx=1;
for i=1:class_num
   W_i=ones(vEachclass_num(i),vEachclass_num(i))/vEachclass_num(i);
   mW(w_idx:w_idx+vEachclass_num(i)-1,w_idx:w_idx+vEachclass_num(i)-1)=W_i;
   w_idx=w_idx+vEachclass_num(i);
end

mK2_3=mK*(eye(samp_num)-mW)*mK;
t1=mA_Nc'*mK2_3*mA_Nc;
t2=mA_Nc'*mK2_3*m1_Nc/samp_num;
t4=m1_Nc'*mK2_3*m1_Nc/(samp_num*samp_num);

% -- JJ1=Phi_b'*Sw*Phi_b --
JJ1=mB*(t1-t2-t2'+t4)*mB/(samp_num*samp_num);
J3=mB*(mA_Nc'-m1_Nc'/samp_num);

clear('t1','t2','t4','mK2_3');
clear('mW','mB','mA_Nc','m1_Nc');

mU_St_U=mNormE'*JJ1*mNormE;

clear('JJ1');

mU_St_U=(mU_St_U+mU_St_U')/2;
[mEigvec_St,vEigval_St]=eig(mU_St_U);

vEigval_St=abs(diag(vEigval_St)');
[vEigval_St,I]=sort(vEigval_St);
mP=mEigvec_St(:,I);

% Regularized eigenvalues of Sw
mD_t=diag((eta_sw+vEigval_St).^(-1/2)); % or mD_t=mP'*mU_St_U*mP;
mKDDASubSpace=(mNormE*mP*mD_t)'*J3/sqrt(samp_num);
