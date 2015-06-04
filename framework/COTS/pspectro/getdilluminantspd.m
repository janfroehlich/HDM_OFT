function daylightspd = getdilluminantspd(input,range)
load DSPD

%linearly interpolate DSPD
DSPD = horzcat(range',interp1(DSPD(:,1),DSPD(:,[2 3 4]),range,'linear'));

daylightspd = zeros(length(range),4);

%calculate x_d,y_d based on input color temperature
if input <= 7000
    xd = .244063 + .09911*(1e3/input) + 2.9678*(1e6/(input^2)) - 4.6070*(1e9/(input^3));
else 
    xd = .237040 + .24748*(1e3/input) + 1.9018*(1e6/input^2) - 2.0064*(1e9/input^3);
end

yd = -3.000*xd^2 + 2.870*xd - 0.275;

%calculate relatative SPD
M = 0.0241 + 0.2562*xd - 0.7341*yd;
M1 = (-1.3515 - 1.7703*xd + 5.9114*yd)/M;
M2 = (0.03000 - 31.4424*xd + 30.0717*yd)/M;

daylightspd = horzcat(DSPD(:,1),DSPD(:,2) + M1.*DSPD(:,3) + M2.*DSPD(:,4));

