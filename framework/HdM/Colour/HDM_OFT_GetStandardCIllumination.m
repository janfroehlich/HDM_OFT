function out=HDM_OFT_GetStandardCIllumination()

OFT_Env=HDM_OFT_InitEnvironment();

%StandardIlluminantsFromcie.15.2004.tables.xlsx
stdIlluminatsFile=fullfile(OFT_Env.OFT_ConstraintsPath,'StandardIlluminantsFromcie.15.2004.tables.xlsx');
[ndata, text, alldata] =xlsread(stdIlluminatsFile);

indexWL = strfind(text, 'nm');
i=find(~cellfun(@isempty,indexWL));
indexIll = strfind(text, 'Illuminant C');
k=find(~cellfun(@isempty,indexIll));

IlluminatIntensityAgainstWavelength=ndata(k,:);
IlluminatIntensityAgainstWavelength=1/max(IlluminatIntensityAgainstWavelength)*IlluminatIntensityAgainstWavelength;

IlluminatIntensityAgainstWavelength=[ndata(i,:);IlluminatIntensityAgainstWavelength];

normIntensity=interp1(IlluminatIntensityAgainstWavelength(1,:), IlluminatIntensityAgainstWavelength(2,:),360:1:830,'pchip',0);
normIntensity=1/max(normIntensity)*normIntensity;

nmBase=360:830;
IlluminatIntensityAgainstWavelength_CIERange_1nm = [nmBase;normIntensity];

if(exist('default','var')==0)
    figure
    plot(IlluminatIntensityAgainstWavelength(1,:),IlluminatIntensityAgainstWavelength(2,:),'b--x',...
    	IlluminatIntensityAgainstWavelength_CIERange_1nm(1,:),IlluminatIntensityAgainstWavelength_CIERange_1nm(2,:),'r')
    xlabel('wavelength in nm')
    ylabel('relative power')
    title(strcat('Standard C Illumination'));
end

out=IlluminatIntensityAgainstWavelength_CIERange_1nm;

end

