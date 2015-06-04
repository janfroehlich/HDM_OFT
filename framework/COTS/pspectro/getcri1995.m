function [Ra R] = getcri1995(testsourcespd,referencespd,range)
load CIETCS1nm
load cie1931xyz1nm 

%find starting point based on range input

cie1931xyz1nm = horzcat(range',interp1(cie1931xyz1nm (:,1),cie1931xyz1nm (:,[2 3 4]),range,'linear'));
CIETCS1nm = horzcat(range',interp1(CIETCS1nm(:,1),CIETCS1nm(:,2:end),range,'linear'));

startval = find(cie1931xyz1nm(:,1) == min(range));
endval = find(cie1931xyz1nm(:,1) == max(range));

startvaltcs = find(CIETCS1nm(:,1) == min(range));
endvaltcs = find(CIETCS1nm(:,1) == max(range));

startvalts = find(testsourcespd(:,1) == min(range));
endvalts = find(testsourcespd(:,1) == max(range));

startvalref = find(referencespd(:,1) == min(range));
endvalref = find(referencespd(:,1) == max(range));

%compute object color tristimulus data for test source and reference
testXYZ= zeros(3,15);

%calculate normalization constant k for perfect diffuse reflector of source
ktest = 100./sum(testsourcespd(startvalts:endvalts,end).*cie1931xyz1nm(startval:endval,3));
kreference = 100./sum(referencespd(startvalts:endvalts,end).*cie1931xyz1nm(startval:endval,3));

for j=1:3
    for i=1:15 %all 15 samples in CIETCS1nm
        testXYZ(j,i) = ktest.*sum(CIETCS1nm(startvaltcs:endvaltcs,i+1).*cie1931xyz1nm(startval:endval,j+1).*testsourcespd(startvalts:endvalts,end));
        i = i + 1;
    end
    j = j + 1;
end

referenceXYZ = zeros(3,15);
for j=1:3
    for i=1:15 %all 15 samples in CIETCS1nm
        referenceXYZ(j,i) = kreference.*sum(CIETCS1nm(startvaltcs:endvaltcs,i+1).*cie1931xyz1nm(startval:endval,j+1).*referencespd(startvalref:endvalref,end));
        i = i + 1;
    end
    j = j + 1;
end

%reformat spds for functions
testXYZ = testXYZ';
referenceXYZ = referenceXYZ';

%calculate chromaticity coordinates first is xy, then convert to uv
testxyzsamples = getxyz(testXYZ);
referencexyzsamples = getxyz(referenceXYZ);

uvtestsamples = xytouv(testxyzsamples);
uvreferencesamples = xytouv(referencexyzsamples);

%apply von Kries chromatic adaptation
%first calculate c and d for both sources
%this requires calculating the chromaticity in uv for the test source and
%reference source

uvtestsource = xytouv(getxyz(gettristimulus2degn(testsourcespd,range)));
%make sure yvtestsource is last sample (full spd)
uvtestsource = uvtestsource(end,:);

uvreferencesource = xytouv(getxyz(gettristimulus2degn(referencespd,range)));

%convert that last sample to [c_ref d_ref] and [c_test d_ref]
cdtestsource = uvtocd(uvtestsource);
cdreferencesource = uvtocd(uvreferencesource);

%convert TCS samples illuminated by test light to [c_test_i d_test_i]
cdtestsamples = uvtocd(uvtestsamples);

%apply chromatic transform 
% c_rt = cdreferencesource(:,1)/cdtestsource(:,1);
% d_rt = cdreferencesource(:,2)/cdtestsource(:,2);
% 
% uc_num = 10.872+(.404*c_rt.*cdtestsamples(:,1))-(4*d_rt.*cdtestsamples(:,2));
% uc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
% uc = uc_num./uc_den;
% 
% vc_num = 5.520;
% vc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
% 
% vc = vc_num./vc_den;

% uc_num = 10.872+(.404* cdreferencesource(:,1))-(4*cdreferencesource(:,2));
% uc_den = 16.518+(1.481* cdreferencesource(:,1))-(cdreferencesource(:,2));

uc = (10.872+.404.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-4.*(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2))...
    ./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));

vc = 5.520./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));

%create chromatically adapted uv matrix
uvc = horzcat(uc,vc);

%move uv coordinates into CIE1964 UVW color space

% %calculate Luv for object colors
% Wtestcr = 116.*((testXYZ(:,2)./100).^(1/3))-16;
% Utestcr = 13.*Wtestcr.*(uvtestsamples(:,1)-uvreferencesource(:,1));
% Vtestcr = 13.*Wtestcr.*(uvtestsamples(:,2)-uvreferencesource(:,2));
% UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);
% 
% %calculate Luv for reference illumant object colors
% Wref = 116.*((testXYZ(:,2)./100).^(1/3))-16;
% Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
% Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
% UVWref = horzcat(Uref,Vref,Wref);

%calculate UVW for chromatically adapted object colors
Wtestcr = 25.*(testXYZ(:,2).^(1/3))-17;
Utestcr = 13.*Wtestcr.*(uvc(:,1)-uvreferencesource(:,1));
Vtestcr = 13.*Wtestcr.*(uvc(:,2)-uvreferencesource(:,2));
UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);

%calculate UVW for reference illumance object colors
Wref = 25.*(referenceXYZ(:,2).^(1/3))-17;
Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
UVWref = horzcat(Uref,Vref,Wref);

deltaE = sqrt((UVWtestcr(:,1)-UVWref(:,1)).^2+(UVWtestcr(:,2)-UVWref(:,2)).^2+(UVWtestcr(:,3)-UVWref(:,3)).^2);
R = 100-(4.6.*deltaE);
Ra = (sum(R(1:8,:))/8);
% Ytest
% Ztest