function uv = xytouv(input)

uv = horzcat((4.*input(:,1))./((12.*input(:,2))-(2.*input(:,1))+3),...
    (6.*input(:,2))./((12.*input(:,2))-(2.*input(:,1))+3));
