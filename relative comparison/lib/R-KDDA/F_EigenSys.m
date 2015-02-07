function [eVec,eVal]=F_EigenSys(M);
%
% Syntax: [eVec,eVal]=F_EigenSys(M);
% - Eigen values and vectors of M, sorted by decreasing eigen values.
%
% Author: Lu Juwei - U of Toronto
% Created in 27 May 2001
% Modified in 6 August 2003
%

[eVec,eVal]=eig(M);
eVal=abs(diag(eVal)');

[eVal,Index]=sort(eVal);
eVal=fliplr(eVal);
eVec=fliplr(eVec(:,Index));
