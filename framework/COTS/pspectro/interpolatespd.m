function newspd = interpolatespd(input,range)

spd = interp1(input(:,1),input(:,2:end),range,'linear');
spd = spd';
range = range';
newspd = horzcat(range,spd);