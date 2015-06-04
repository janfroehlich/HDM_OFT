function XYZ = gettristimulus2degn(input,range)
load cie1931xyz1nm 

%CIE 1931 2-deg CMFs (CIE, 1932)
%CIE. (1926). Commission Internationale de l'Eclairage Proceedings, 1924. Cambridge: Cambridge University Press.
%CIE. (1932). Commission Internationale de l'Eclairage Proceedings, 1931. Cambridge: Cambridge University Press.
%Guild, J. (1931). The colorimetric properties of the spectrum. Philosophical Transactions of the Royal Society of London, A230, 149-187.

%interpolate based on input and save variable
cie1931xyz1nm = horzcat(range',interp1(cie1931xyz1nm (:,1),cie1931xyz1nm (:,[2 3 4]),range,'linear'));

%find starting point based on range input
startval = find(cie1931xyz1nm(:,1) == min(range));
endval = find(cie1931xyz1nm(:,1) == max(range));

inputstartval = find(input(:,1) == min(range));
inputendval = find(input(:,1) == max(range));



% if exist(cie1931xyz1nm) == 0
%     load cie1931xyz1nm
% end

XYZ = zeros(size(input,2)-1,3);
for j=1:size(input,2)-1
    for i=1:size(cie1931xyz1nm,2)-1
        XYZ(j,i) = (100./dot(cie1931xyz1nm(startval:endval,3),input(inputstartval:inputendval,j+1))).*dot(cie1931xyz1nm(startval:endval,i+1),input(inputstartval:inputendval,j+1));
        %XYZ(j,i) = dot(cie1931xyz1nm(startval:endval,i+1),input(inputstartval:inputendval,j+1));
        i = i + 1;
    end
    j = j + 1;
end