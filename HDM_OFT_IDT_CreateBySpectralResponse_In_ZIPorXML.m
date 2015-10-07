function HDM_OFT_IDT_CreateBySpectralResponse_In_ZIPorXML(OFT_In_ClientData, OFT_In_ServerOutDir, OFT_In_TaskID)

try
    
if(~exist('OFT_In_TaskID','var'))
    OFT_In_TaskID='0CC9E082-69AF-44ED-A057-1C6B09E4E404';
    OFT_Env=HDM_OFT_InitEnvironment(OFT_In_TaskID, ''); 
else
    OFT_Env=HDM_OFT_InitEnvironment(OFT_In_TaskID);
end
    
if(~exist('OFT_In_ClientData','var'))
    
    %test production
    OFT_In_ClientData=strcat(OFT_Env.OFT_RootScriptDir,'/testData/testproduktion/16042015/ClientDataSample/',OFT_In_TaskID,...        
        '/AA+ZUP40/AA+ZUP40-cc_testimage-clean.xml');
    
    %'/AA+ZUP40/AA+ZUP40-nocc.xml');
    
    % '/AA+ZUP40/AA+ZUP40-cc_testimage-clean.xml');
    
    %'/AA+BUL25/AA+BUL25.xml');
    %'/AA+BUL75/AA+BUL75.xml');
    %'/AA+ZUP28/AA+ZUP28.xml');
    %'/AA+ZUP40/AA+ZUP40.xml');%D5000
    %'/SF55+BL25/SF55+BL25.xml');%D5000
    %'/SF55+ZUP40/SF55+ZUP40.xml');%D5000
    
    %non test production
    %zip based test
    %OFT_In_ClientData=strcat(OFT_Env.OFT_RootScriptDir,'/testData/IndustryCameraMeasurements/20141208/ClientDataSample/',OFT_In_TaskID,'/',OFT_In_TaskID,'.upload.zip');
    %xml based test
    %OFT_In_ClientData=strcat(OFT_Env.OFT_RootScriptDir,'/testData/IndustryCameraMeasurements/20141208/ClientDataSample/',OFT_In_TaskID,...        
    %    '/IDTClientParamsIndustryCameraWithNewGrating.xml');
    %'/IDTClientParams.xml');
    %'/IDTClientParamsAlexaTif.xml');
    %'/IDTClientParamsAlexaDPX.xml');
    %'/IDTClientParamsIndustryCameraWithNewGrating.xml');
end

if(~exist('OFT_In_ServerOutDir','var'))
   % OFT_In_ServerOutDir=strcat(OFT_Env.OFT_RootScriptDir,'/testData/IndustryCameraMeasurements/20141208/ClientDataSample/out/',OFT_In_TaskID,'/');
    OFT_In_ServerOutDir=strcat(OFT_Env.OFT_RootScriptDir,'/testData/testproduktion/16042015/ClientDataSample/out/',...
        OFT_In_TaskID,'/AA+ZUP40/');
    %OFT_In_ServerOutDir=strcat(OFT_Env.OFT_RootScriptDir,'/testData/IndustryCameraMeasurements/20141208/ClientDataSample/out/',OFT_In_TaskID,'/');
end

HDM_OFT_Utils.OFT_DispTitle('start task');
HDM_OFT_Utils.OFT_DispSubTitle(strcat('ID: ',OFT_In_TaskID));
HDM_OFT_Utils.OFT_DispSubTitle(strcat('client data: ',OFT_In_ClientData));
HDM_OFT_Utils.OFT_DispSubTitle(strcat('output directory: ',OFT_In_ServerOutDir));

OFT_LogFileName=strcat(OFT_In_ServerOutDir,'/',OFT_In_TaskID,'.status.xml');
OFT_ProgressLogger=HDM_OFT_XML_Logger(OFT_LogFileName);
OFT_ProgressLogger.LogUserMessage('start camera characterization');

[OFT_ClientDataPath,OFT_ClientDataName,OFT_ClientDataExt] = fileparts(OFT_In_ClientData);
copyfile(OFT_ClientDataPath,OFT_Env.OFT_ProcessPath);
IDTTaskData=HDM_OFT_IDT_PrepareClientData(strcat(OFT_Env.OFT_ProcessPath,'/',OFT_ClientDataName,OFT_ClientDataExt));
IDTTaskData.ServerOutDir=OFT_In_ServerOutDir;

OFT_ProgressLogger.LogUserMessage('estimate camera linearization');

IDTTaskData.PreLinearisation_Out_LinCurve=HDM_OFT_CameraLinearization(IDTTaskData.PreLinearisation_In_LinFile);
if(~strcmp(IDTTaskData.PreLinearisation_Out_LinCurve,''))
    copyfile(IDTTaskData.PreLinearisation_Out_LinCurve, OFT_In_ServerOutDir);   
end

OFT_ProgressLogger.LogUserMessage('estimate camera spectral response');


% Decide use case: Spectral or color checker based method
if isempty(IDTTaskData.SpectralResponse_In_LineCalibrationSpectrum) && isempty(IDTTaskData.SpectralResponse_In_LineCalibrationImage) && isempty(IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum)
    IDTTaskData.SpectralResponse_Out_SpectralResponseFile=IDTTaskData.SpectralResponse_In_LightCalibrationImage;
else
    OFT_CameraResponse=HDM_OFT_CameraSpectralResponse(IDTTaskData);

    OFT_CameraReponseFile='/cameraResponse.csv';    
    IDTTaskData.SpectralResponse_Out_SpectralResponseFile=strcat(OFT_Env.OFT_ProcessPath,'/',OFT_CameraReponseFile);
    csvwrite(IDTTaskData.SpectralResponse_Out_SpectralResponseFile, OFT_CameraResponse');%//!!!why here
    copyfile(IDTTaskData.SpectralResponse_Out_SpectralResponseFile, OFT_In_ServerOutDir);   

    disp(strcat('camera spectral response file: ',IDTTaskData.SpectralResponse_Out_SpectralResponseFile));
end


OFT_ProgressLogger.LogUserMessage('compute IDT profiles');    

IDTTaskData.IDTCreationConstraints_Out_IDTFiles=HDM_OFT_IDT_ProfilesGeneration(IDTTaskData);

for i=1:size(IDTTaskData.IDTCreationConstraints_Out_IDTFiles,2)
    copyfile(IDTTaskData.IDTCreationConstraints_Out_IDTFiles{i}, OFT_In_ServerOutDir);
end

OFT_ProgressLogger.LogUserMessage('finish camera characterization');

HDM_OFT_Utils.OFT_DispTitle('task finished');
HDM_OFT_Utils.OFT_DispSubTitle(strcat('ID: ',OFT_In_TaskID));
HDM_OFT_Utils.OFT_DispSubTitle(strcat('client data: ',OFT_In_ClientData));
HDM_OFT_Utils.OFT_DispSubTitle(strcat('output directory: ',OFT_In_ServerOutDir));
commandwindow;

catch err
    commandwindow;
    disp(getReport(err));
    OFT_ProgressLogger.LogUserMessage('error during camera characterization');
end

end
        

        
