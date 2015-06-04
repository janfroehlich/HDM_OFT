function out=HDM_OFT_GetCIERange1nmSpectrumFromSpectralDataFile(OFT_In_File)

some=false;

if(exist('OFT_In_File','var')==0)    
    delete(findall(0,'Type','figure'));
    clc;
	commandwindow;
    
    OFT_File=strcat(HDM_OFTP_Environment.GetRootDataDir(),'/cameraLineCalibrationReference/LineCali15042014.xls');
    disp(OFT_File);
else
    OFT_File=OFT_In_File;
    some=true;
end

HDM_OFT_Utils.OFT_DispTitle('read spectral data file into CIE Range 1nm');

disp('using spectrum file');
disp(OFT_File);  

[status,sheets,xlFormat]  = xlsfinfo(OFT_File);
[ndata, text, alldata] =xlsread(OFT_File);

if isempty(text)
    OFT_IntenityAgainstWavelength=ndata(1:2,:);
else
    waveLength=strrep(text(1,:), 'nm', '');
    wvSize=size(waveLength);
    waveLength2=str2double(waveLength(2:wvSize(2)));
    OFT_IntenityAgainstWavelength=[waveLength2;ndata];
end

if(~some)
figure
plot(OFT_IntenityAgainstWavelength(1,:),OFT_IntenityAgainstWavelength(2,:))
xlabel('wavelength in nm')
ylabel('intensity in W/(nm * m^2)')
title(strcat('spectrum',OFT_File));
end

nmBase=360:830;
normIntensity=interp1(OFT_IntenityAgainstWavelength(1,:), OFT_IntenityAgainstWavelength(2,:),360:1:830,'pchip',0);
normIntensity=1/max(normIntensity)*normIntensity;
OFT_IntenityAgainstWavelength_1nm = [nmBase;normIntensity];

if(~some)
figure
plot(OFT_IntenityAgainstWavelength_1nm(1,:),OFT_IntenityAgainstWavelength_1nm(2,:))
xlabel('wavelength in nm')
ylabel('intensity in W/(nm * m^2)')
title(strcat('spectrum 1 nm base of ',OFT_File));
end

out=OFT_IntenityAgainstWavelength_1nm;

HDM_OFT_Utils.OFT_DispTitle('read spectral data file into CIE Range 1nm finished');

end