function OFT_Out_D_Spectrum_1nm_CIE31Range=HDM_OFT_GetStandardDIllumination(OFT_In_Temperature)

OFT_Env=HDM_OFT_InitEnvironment();

HDM_OFT_Utils.OFT_DispTitle('standard D illumination estimation');

if(exist('OFT_In_Temperature','var')==0)   
    disp('using default temperature');
    OFT_DaylightTemperature=6500
else    
    default=0    
    disp('using given temperature');
    OFT_DaylightTemperature=OFT_In_Temperature
end

%% Daylight spectrum estimation
HDM_OFT_Utils.OFT_DispSubTitle('Daylight spectrum estimation');

%//!!!todo ausklammern
OFT_xd=-4.6070e9/OFT_DaylightTemperature^3+2.9678e6/OFT_DaylightTemperature^2+0.09911e3/OFT_DaylightTemperature+0.244063;%bis 7000K
OFTP_yd=-3.000 * OFT_xd * OFT_xd + 2.870 *OFT_xd -0.275;

OFT_M=0.0241 + 0.2562 * OFT_xd - 0.7341 * OFTP_yd;
OFT_M1=(-1.3515 - 1.7703 * OFT_xd + 5.9114 * OFTP_yd)/OFT_M;
OFT_M2=(0.0300 - 31.4424 * OFT_xd + 30.0717 * OFTP_yd)/OFT_M;

OFT_DPolynom_Coeffs=csvread(strcat(OFT_Env.OFT_ConstraintsPath,'/DIlluminants_02.csv'));

OFT_D_Spectrum=zeros(1,size(OFT_DPolynom_Coeffs,1));
for OFTP_CoeffSamples=1:size(OFT_DPolynom_Coeffs,1)  
    
    OFT_D_Spectrum(OFTP_CoeffSamples)=OFT_DPolynom_Coeffs(OFTP_CoeffSamples,2)+OFT_M1*OFT_DPolynom_Coeffs(OFTP_CoeffSamples,3)+OFT_M2*OFT_DPolynom_Coeffs(OFTP_CoeffSamples,4);
    
end

OFT_DPolynom_Wavelength=OFT_DPolynom_Coeffs(:,1);
OFT_DPolynom_Wavelength=OFT_DPolynom_Wavelength';

OFT_DPolynom_Wavelength_1nm=zeros(max(OFT_DPolynom_Wavelength)-min(OFT_DPolynom_Wavelength),1);
for DPolynom_WaveLength=min(OFT_DPolynom_Wavelength):max(OFT_DPolynom_Wavelength)
    
    OFT_DPolynom_Wavelength_1nm(DPolynom_WaveLength-min(OFT_DPolynom_Wavelength)+1)=DPolynom_WaveLength;
        
end 

OFTP_D_Spectrum_1nm = interp1( ...
OFT_DPolynom_Wavelength, ...
OFT_D_Spectrum, ...
min(OFT_DPolynom_Wavelength):1:max(OFT_DPolynom_Wavelength));

%scaling to 100
OFTP_D_Spectrum_1nm=OFTP_D_Spectrum_1nm./max(OFTP_D_Spectrum_1nm);

%shorten D light spectrum to cie31 range
OFT_CIE31_WaveLengthRangeSize=471;
OFT_D_Spectrum_1nm_CIE31Range=zeros(1,OFT_CIE31_WaveLengthRangeSize);
for i=1:OFT_CIE31_WaveLengthRangeSize
    OFT_D_Spectrum_1nm_CIE31Range(i)=OFTP_D_Spectrum_1nm(60+i);
end  

OFT_Out_D_Spectrum_1nm_CIE31Range=[360:1:830;OFT_D_Spectrum_1nm_CIE31Range];

if(exist('default','var')==0)
    figure
    plot(OFT_DPolynom_Wavelength_1nm',OFTP_D_Spectrum_1nm)
    xlabel('wavelength in nm')
    ylabel('relative power')
    title(strcat('Daylight estimation for ',num2str(OFT_DaylightTemperature),' K'));

    figure
    plot(OFT_Out_D_Spectrum_1nm_CIE31Range(1,:),OFT_Out_D_Spectrum_1nm_CIE31Range(2,:))
    xlabel('wavelength in nm')
    ylabel('relative power')
    title(strcat('Daylight estimation for ',num2str(OFT_DaylightTemperature),' K'));
end

HDM_OFT_Utils.OFT_DispTitle('standard D illumination estimation finished');

end

