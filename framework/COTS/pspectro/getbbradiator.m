function mlambda = getbbradiator(input,range)
%use approximate form of blackbody radiator from w&s pp 13

rangenm = range.*1e-9;

c1 = 3.7418e-16;
c2 = 1.438775225e-2;
%c2 = 1.4388e-2;

mlambda = horzcat(range',c1./(rangenm.^5.*(exp(c2./(rangenm.*input))-1))');

% %normalize at wavelength specified
% wavelengthindex = find(mlambda(:,1) == wavelength);
% mlambda = horzcat(range',mlambda(:,2)./mlambda(wavelengthindex,2));