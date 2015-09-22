
function OFT_Out_ClientData=HDM_OFT_IDT_PrepareClientData(OFT_In_ClientData)

HDM_OFT_Utils.OFT_DispTitle('prepare client data');

[OFT_ClientDataPath,OFT_ClientDataName,OFT_ClientDataExt] = fileparts(OFT_In_ClientData);
OFT_ClientDataDir=OFT_ClientDataPath;

OFT_xmlTaskFile='';

if (strfind(lower(OFT_In_ClientData), '.zip'))
OFT_ClientFiles = unzip(OFT_In_ClientData,OFT_ClientDataDir);
for ii=1:size(OFT_ClientFiles,2)
    OFT_ClientFiles(ii);
    found=strfind(OFT_ClientFiles(ii), 'IDTClientParams.xml');
    f=found{1,1};
    if(f>0)
        OFT_ClientParamsXML=OFT_ClientFiles(ii);
        OFT_xmlTaskFile=OFT_ClientParamsXML{1};
        %//!!!OFT_ClientDataDir=strcat(OFT_ClientDataDir,'/clientData/');
        OFT_ClientDataDir=strcat(OFT_ClientDataDir,'/');
        break;
    end
end
else% .xml
    OFT_xmlTaskFile=OFT_In_ClientData;
    OFT_ClientDataDir=strcat(OFT_ClientDataDir,'/');
end

IDTTaskData = HDM_OFT_IDTCreationData();

OFT_ClientParams=HDM_OFT_IDT_LoadFromXML(OFT_xmlTaskFile);%//!!! test
OFT_ClientParamsDOM = xmlread(OFT_xmlTaskFile);

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('ReportLog');
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

IDTTaskData.Report_In_Company=GetXMLNodeVal(thisListitem,'Company');
IDTTaskData.Report_In_Operator=GetXMLNodeVal(thisListitem,'Operator');
IDTTaskData.Report_In_email=GetXMLNodeVal(thisListitem,'e-mail');
IDTTaskData.Report_In_Time=GetXMLNodeVal(thisListitem,'Time');

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('DeviceLog');
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

IDTTaskData.Device_In_Camera=GetXMLNodeVal(thisListitem,'Camera');
IDTTaskData.Device_In_Spectrometer=GetXMLNodeVal(thisListitem,'Spectrometer');
IDTTaskData.Device_In_Comment=GetXMLNodeVal(thisListitem,'Comment');

sensorListItem= OFT_ClientParamsDOM_In.item(0).getElementsByTagName('Sensor');
IDTTaskData.Device_In_Sensor=str2num(GetXMLNodeVal(sensorListItem.item(0),'Diagonal'));

lensListItem= OFT_ClientParamsDOM_In.item(0).getElementsByTagName('Lens');
IDTTaskData.Device_In_Stop=GetXMLNodeVal(lensListItem.item(0),'Stop');
IDTTaskData.Device_In_FocalLength=str2num(GetXMLNodeVal(lensListItem.item(0),'FocalLength'));

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('SpectralResponse');
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

%//!!!workaround for bug, fixed 28.01.2015
% OFT_LineSpecPrefix='line_cal_spectrum-';
% OFT_LightSpecPrefix='light_cal_spectrum-';
% OFT_LineImgPrefix='line_cal_image-';
% OFT_LightImgPrefix='light_cal_image-';
OFT_LineSpecPrefix='';
OFT_LightSpecPrefix='';
OFT_LineImgPrefix='';
OFT_LightImgPrefix='';

IDTTaskData.SpectralResponse_In_LineCalibrationSpectrum=GetXMLNodeValOrExmptyString(thisListitem, 'LineCalibrationSpectrum', strcat(OFT_ClientDataDir, OFT_LineSpecPrefix));
IDTTaskData.SpectralResponse_In_LineCalibrationImage=GetXMLNodeValOrExmptyString(thisListitem, 'LineCalibrationImage', strcat(OFT_ClientDataDir, OFT_LineImgPrefix));
IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum=GetXMLNodeValOrExmptyString(thisListitem,'LightCalibrationSpectrum', strcat(OFT_ClientDataDir, OFT_LightSpecPrefix));
IDTTaskData.SpectralResponse_In_LightCalibrationImage=GetXMLNodeValOrExmptyString(thisListitem,'LightCalibrationImage', strcat(OFT_ClientDataDir, OFT_LightImgPrefix));

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('IDTCreationConstraints');
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

IDTTaskData.IDTCreationConstraints_In_WhitePoint=GetXMLNodeVal(thisListitem,'WhitePoint');
IDTTaskData.IDTCreationConstraints_In_ErrorMinimizationDomain=GetXMLNodeVal(thisListitem,'ErrorMinimizationDomain');
IDTTaskData.IDTCreationConstraints_In_PatchSet=GetXMLNodeVal(thisListitem,'PatchSet');  

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('Evaluation');
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

IDTTaskData.Evaluation_In_TestImage=strcat(OFT_ClientDataDir,GetXMLNodeVal(thisListitem,'TestImage')); 

OFT_ClientParamsDOM_Log = OFT_ClientParamsDOM.getElementsByTagName('PreLinearisaiton');%//!!!
OFT_ClientParamsDOM_In = OFT_ClientParamsDOM_Log.item(0).getElementsByTagName('In');

thisListitem = OFT_ClientParamsDOM_In.item(0);

%if ischar(thisListitem(1))//!!!
    IDTTaskData.PreLinearisation_In_LinFile=''; 
%else
    %IDTTaskData.PreLinearisation_In_LinFile=strcat(OFT_ClientDataDir,GetXMLNodeVal(thisListitem,'LinearizationFile'));
%end

OFT_Out_ClientData=IDTTaskData;

HDM_OFT_Utils.OFT_DispTitle('prepare client data finished');

%%

end

function retVal=GetXMLNodeVal(thisListitem,nodeName)

try
thisList = thisListitem.getElementsByTagName(nodeName);
retVal=char(thisList.item(0).getFirstChild.getData);
catch
    error('Unable to parse XML Node %s.',nodeName);    
end

end


%//!!! Hack around error when delivery color checker based XML with empty
%nodes
function retVal=GetXMLNodeValOrExmptyString(thisListitem, nodeName, prefix)

try
thisList = thisListitem.getElementsByTagName(nodeName);
if isempty(char(thisList.item(0).getFirstChild.getData))
    retVal='';
else
    retVal=strcat(prefix, char(thisList.item(0).getFirstChild.getData));
end
catch
    retVal='';
end

end
