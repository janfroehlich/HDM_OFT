function OFT_Out_LinFunction=HDM_OFT_CameraLinearization(OFT_In_LinChartImage)

OFT_Env=HDM_OFT_InitEnvironment();

if(exist('OFT_In_LinChartImage','var')==0)
    disp('using default linearization');
    OFT_LinChartImage=strcat(OFT_Env.OFT_RootDataDir,'/linearizationReference/140513_OETF_2K_v1_noIndex.tif');
else
    OFT_LinChartImage=OFT_In_LinChartImage;
end

HDM_OFT_Utils.OFT_DispTitle('start linearization aquisition');

OFT_Out_LinFunction='';

HDM_OFT_Utils.OFT_DispTitle('finish linearization aquisition');

end
