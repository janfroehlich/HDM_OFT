function OFT_Out_Env=HDM_OFT_InitEnvironment(OFT_In_ProcessSubDir,OFT_In_Test)

global globalOFT_Env;

if(isempty(globalOFT_Env))

[OFT_IDTProcessorPath,OFT_ProcessorName,OFT_ProcessorExt] = fileparts(mfilename('fullpath'));

ffsubdir=strfind(OFT_IDTProcessorPath, '/framework/HdM');
if(~isempty(ffsubdir))
    OFT_IDTProcessorPath=OFT_IDTProcessorPath(1:ffsubdir(1));
end

addpath(genpath(strcat(OFT_IDTProcessorPath,'/framework/HdM')));
addpath(strcat(OFT_IDTProcessorPath,'/framework/COTS/CCFind'));
addpath(strcat(OFT_IDTProcessorPath,'/framework/COTS/DPXReader'));
addpath(strcat(OFT_IDTProcessorPath,'/framework/COTS/AlexaTools'));

OFT_Env=HDM_OFT_Environment();

OFT_Env.OFT_RootDataDir=strcat(OFT_IDTProcessorPath,'/appData')
OFT_Env.OFT_RootScriptDir=OFT_IDTProcessorPath;
OFT_Env.OFT_ConstraintsPath=strcat(OFT_IDTProcessorPath,'/appData/constraints');
OFT_Env.OFT_ProcessPath=strcat(OFT_IDTProcessorPath,'/workingDir/IDTProcess');
OFT_Env.OFT_StatisticsPath=strcat(OFT_IDTProcessorPath,'/workingDir/IDTProcess');

if(~exist('OFT_In_Test','var'))
    OFT_Env.OFT_ProcessPath=strcat(OFT_Env.OFT_ProcessPath,'/',OFT_In_ProcessSubDir);
else
    OFT_Env.OFT_ProcessPath=strcat(OFT_Env.OFT_ProcessPath,'/test');
    OFT_Env.OFT_StatisticsPath=strcat(OFT_Env.OFT_StatisticsPath,'/testStat');
end

OFT_Out_Env=OFT_Env;
globalOFT_Env=OFT_Env;

%clear classes %commented out due to in arg preserving
delete(findall(0,'Type','figure'));
clc;
commandwindow;

format shortEng

else
    OFT_Out_Env=globalOFT_Env;    
end

end
        

        
