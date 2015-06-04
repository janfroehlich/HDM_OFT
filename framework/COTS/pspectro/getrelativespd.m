function relativespd = getrelativespd(input,range,wavelength)

startval = find(input(:,1) == min(range));
endval = find(input(:,1) == max(range));

wavelengthindex = find(input(:,1) == wavelength);

%relativespd = horzcat(range',100.*(input(:,2)./input(wavelengthindex,2)));
relativespd = horzcat(range',1.*(input(:,2)./input(wavelengthindex,2)));
