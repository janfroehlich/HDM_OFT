function cd = uvtocd(input)

cd = horzcat((4-input(:,1)-10.*input(:,2))./input(:,2),...
(1.708.*input(:,2)-1.481.*input(:,1)+.404)./input(:,2));