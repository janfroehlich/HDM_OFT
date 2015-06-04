function [cct mindistance] = getuvbbCCT(input)
load uvbbCCT

finddistance = sqrt((input(:,1)-uvbbCCT(:,2)).^2+(input(:,2)-uvbbCCT(:,3)).^2);
[mindistance row] = min(finddistance);

cct = uvbbCCT(row,1);

% if mindistance < 5.4e-3
%     cct = uvcctcoords(row,1);
% else
%     cct = 'False';
% end

