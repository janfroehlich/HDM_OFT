%clear classes %commented out due to in arg preserving
delete(findall(0,'Type','figure'));
clc;
commandwindow;

I = double(imread('Take005_Img0000005.TIF'));
[X,C] = CCFind(I) %end

csvwrite('Take005_Img0000005.TIF.GMCC.csv',C);
% visualizecc(I.^(1/2.2),X);

