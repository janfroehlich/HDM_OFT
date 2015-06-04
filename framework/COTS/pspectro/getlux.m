function [lux] = getlux(input,range)
load vl1924e1nm

%interpolate based on input and save variable
vl1924e1nm = horzcat(range',interp1(vl1924e1nm(:,1),vl1924e1nm(:,2),range,'linear')');

startval = find(vl1924e1nm(:,1) == min(range));
endval = find(vl1924e1nm(:,1) == max(range));

inputstartval = find(input(:,1) == min(range));
inputendval = find(input(:,1) == max(range));

lux = zeros(1,size(input,2)-1);
%LER = zeros(1,size(input,2)-1);

for i=1:size(input,2)-1
    lux(:,i) = (683*dot(vl1924e1nm(startval:endval,2),input(inputstartval:inputendval,i+1)));
    %LER(:,i) = lumens(:,i)/sum(input(inputstartval:inputendval,i+1));
    i = i + 1;
end