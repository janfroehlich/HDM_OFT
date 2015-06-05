function [OFT_IDT_File, OFT_IDT_B, OFT_IDT_b]=HDM_OFT_IDT_MinimumError...
    (OFT_In_PatchMeasurementFile, ...
    OFT_In_CameraMeasurementFile, ...
    OFT_In_PreLinearisationCurve, ...
    OFT_In_NeutralsCompensation, ...
    OFT_In_ErrorMinimizationDomain, ...
    OFT_In_IlluminantSpectrum,...
    OFT_In_ReferenceDomain,...
    OFT_In_StandardObserver)

%% defaults
OFT_Env=HDM_OFT_InitEnvironment(); 

HDM_OFT_Utils.OFT_DispTitle('start IDT creation');

if(exist('OFT_In_PatchMeasurementFile','var')==0)
    disp('using reference patch mesurements');
    OFT_In_PatchMeasurementFile=HDM_OFT_PatchSet.GretagMacbethColorChecker();
else
    disp(OFT_In_PatchMeasurementFile);
end

if(exist('OFT_In_CameraMeasurementFile','var')==0)
    disp('using reference camera mesurements');
    OFT_MeasuredCameraResponseFileName=strcat(OFT_Env.OFT_RootDataDir,'/cameraMeasurementReference/arri_d21_spectral_response_02.csv');
    %OFT_MeasuredCameraResponseFileName=strcat(OFT_Env.OFT_RootDataDir,'/cameraImagesReference/sTake005_Img0000005.TIF');
else
    OFT_MeasuredCameraResponseFileName=OFT_In_CameraMeasurementFile;
end

if(exist('OFT_In_PreLinearisationCurve','var')==0)
    disp('using no linearization');
    OFT_In_PreLinearisationCurve='';
end

if(exist('OFT_In_NeutralsCompensation','var')==0)
    disp('using default neutral compensation');
    OFT_NeutralsCompensation=HDM_OFT_ColorNeutralCompensations.ChromaticAdaptationBradfordType();  
else
    OFT_NeutralsCompensation=OFT_In_NeutralsCompensation;  
end

if(exist('OFT_In_ErrorMinimizationDomain','var')==0)
    disp('using default neutral compensation');
    OFT_ErrorMinimizationDomain='XYZ';
else
    OFT_ErrorMinimizationDomain=OFT_In_ErrorMinimizationDomain;
    disp(OFT_In_ErrorMinimizationDomain);  
end

if(exist('OFT_In_IlluminantSpectrum','var')==0)
    disp('using default neutral compensation');   
    OFT_IlluminantSpectrum='D55';    
else
    OFT_IlluminantSpectrum=OFT_In_IlluminantSpectrum;  
end

if(exist('OFT_In_ReferenceDomain','var')==0)
    disp('using default reference domain');   
    OFT_ReferenceDomain=HDM_OFT_IDT_ReferenceCamera.CIEType();   
else
    OFT_ReferenceDomain=OFT_In_ReferenceDomain;  
end

if(exist('OFT_In_StandardObserver','var')==0)
    disp('using default standard');   
    OFT_StandardObserver=HDM_OFT_CIEStandard.StandardObserver1931_2Degrees();   
else
    OFT_StandardObserver=OFT_In_StandardObserver;  
end

%%reference camera
HDM_OFT_Utils.OFT_DispSubTitle('setup reference camera');

global gOFT_PatchSetTristimuli_NeutralsCompensated
global gOFT_PatchSetCameraTristimuli

%XYZ to RICD 
global gOFT_M;
global gOFT_w;
[gOFT_M,gOFT_w]=HDM_OFT_IDT_ReferenceCamera.GetDefinition(OFT_ReferenceDomain);

%% illuminat spectrum aquisition
HDM_OFT_Utils.OFT_DispSubTitle('illuminat spectrum aquisition');
OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetIlluminantSpectrum(OFT_IlluminantSpectrum);

%%patches spectrum aquisition
%10 nm resolution
HDM_OFT_Utils.OFT_DispSubTitle('read patch spectra');
OFT_PatchSet_SpectralCurve=HDM_OFT_PatchSet.GetPatchSpectra(OFT_In_PatchMeasurementFile);

par4gOFT_w=gOFT_w;

% parpool(2) disabled due to global env condition
% spmd

%% 4.7.2-4.7.4 reference tristimuli
HDM_OFT_Utils.OFT_DispSubTitle('4.7.2 - 4.7.4 prepare reference tristumuli');
[parOFT_PatchSetTristimuli_NeutralsCompensated,referenceWhite] = ComputeReferenceTristimuli4PatchSet...
    (OFT_StandardObserver, HDM_OFT_GetIlluminantSpectrum('D50'),OFT_PatchSet_SpectralCurve,...%OFT_Illuminant_Spectrum_1nm_CIE31Range ,OFT_PatchSet_SpectralCurve,...//!!!
    OFT_NeutralsCompensation, par4gOFT_w);

%% 4.7.5 and 6 camera tristumuli
HDM_OFT_Utils.OFT_DispSubTitle('4.7.5 and 6 prepare camera tristumuli');
[parOFT_PatchSetCameraTristimuli, OFT_IDT_b] = ComputeCameraTristimuli4PatchSet...
    (OFT_MeasuredCameraResponseFileName, OFT_In_PreLinearisationCurve, OFT_Illuminant_Spectrum_1nm_CIE31Range,OFT_PatchSet_SpectralCurve);

% end
% delete(gcp)

gOFT_PatchSetTristimuli_NeutralsCompensated=parOFT_PatchSetTristimuli_NeutralsCompensated;

if(strcmp(OFT_NeutralsCompensation, HDM_OFT_ColorNeutralCompensations.NoneType()))
    gOFT_w=referenceWhite;
end

gOFT_PatchSetCameraTristimuli=parOFT_PatchSetCameraTristimuli;

%% 4.7.7 B estimation precise
%//!!!todo weight implementation
HDM_OFT_Utils.OFT_DispSubTitle('4.7.7 B estimation');
[OFT_IDT_B, OFT_resnormBEstimation]=EstimateIDTMatrix(OFT_ErrorMinimizationDomain);

disp('reference matrix');
gOFT_M

disp('estimated matrix');
OFT_IDT_B

disp('reference matrix by estimated matrix');
gOFT_M*OFT_IDT_B

%% write idt profile file and append results to statistics
HDM_OFT_Utils.OFT_DispTitle('write idt profile file and append results to statistics');
OFT_IDT_File = WriteIDTProfileAndStatEntry...
    (OFT_Env, OFT_MeasuredCameraResponseFileName, OFT_resnormBEstimation, OFT_IDT_B, OFT_IDT_b,...
    OFT_NeutralsCompensation, OFT_IlluminantSpectrum, OFT_ErrorMinimizationDomain);

%%white check
[OFT_MRef,OFT_wRef]=HDM_OFT_IDT_ReferenceCamera.GetDefinition(OFT_ReferenceDomain);
OFT_Reference2StandardPrimaries=OFT_MRef;
OFT_MOverall=OFT_Reference2StandardPrimaries*OFT_IDT_B;

whitePatchCameraRelatedE=parOFT_PatchSetCameraTristimuli(:,19);

whitePatchCameraRelatedE_bScaled=(OFT_IDT_b./min(OFT_IDT_b)).*whitePatchCameraRelatedE;

xyzNormScaled=whitePatchCameraRelatedE_bScaled(1)+whitePatchCameraRelatedE_bScaled(2)+whitePatchCameraRelatedE_bScaled(3);

wPxS=whitePatchCameraRelatedE_bScaled(1)/xyzNormScaled;
wPyS=whitePatchCameraRelatedE_bScaled(2)/xyzNormScaled;
wPzS=whitePatchCameraRelatedE_bScaled(3)/xyzNormScaled;


whitePatchCameraRelatedE_BConverted=OFT_MOverall*whitePatchCameraRelatedE_bScaled;

xyzNorm=whitePatchCameraRelatedE_BConverted(1)+whitePatchCameraRelatedE_BConverted(2)+whitePatchCameraRelatedE_BConverted(3);

wPx=whitePatchCameraRelatedE_BConverted(1)/xyzNorm;
wPy=whitePatchCameraRelatedE_BConverted(2)/xyzNorm;
wPz=whitePatchCameraRelatedE_BConverted(3)/xyzNorm;



HDM_OFT_Utils.OFT_DispTitle('idt profile successfully created');

end

function [OFT_PatchSetReferenceTristimuli, referenceWhite] = ComputeReferenceTristimuli4PatchSet...
    (OFT_StandardObserver, OFT_Illuminant_Spectrum_1nm_CIE31Range, OFT_PatchSet_SpectralCurve,...
    OFT_NeutralsCompensation, OFT_w)

%% CIE31 curves
HDM_OFT_Utils.OFT_DispSubTitle('setup CIE standard observers curves');
OFT_CIEStandardObserver_SpectralCurves=HDM_OFT_CIEStandard.GetStandardObserverCurves(OFT_StandardObserver);

figure 
subplot(2,2,1)
plot(OFT_CIEStandardObserver_SpectralCurves(1,:),OFT_CIEStandardObserver_SpectralCurves(2:4,:))
%semilogy(OFT_CIEStandardObserver_SpectralCurves(1,:),OFT_CIEStandardObserver_SpectralCurves(2:4,:))
xlabel('wavelength in nm')
ylabel('relative sensitivity of standard observer')
legend({'x','y','z'})
title(OFT_StandardObserver);

%% 4.7.2 patches
HDM_OFT_Utils.OFT_DispSubTitle('4.7.2 compute tristimuli for patches');
[OFT_PatchSetTristimuli,OFT_PatchSetTristimuli_ColorValueParts]=...
        HDM_OFT_TristimuliCreator.CreateFromSpectrum(...
                OFT_CIEStandardObserver_SpectralCurves,...
                OFT_Illuminant_Spectrum_1nm_CIE31Range,...
                OFT_PatchSet_SpectralCurve);

%% plausibility check xyY //!!! for other patch sets must be ignored
HDM_OFT_Utils.OFT_DispSubTitle('xyY plausibility check for CIE1931 2 degress With Babelcolor ColorChecker for D50');

[OFT_CIE31_colorValuePartsWaveLength,...
OFT_CIE31_colorValueParts_x,OFT_CIE31_colorValueParts_y,OFT_CIE31_colorValueParts_z]=...
HDM_OFT_CIEStandard.ColorValuePartsForSpectralColoursCurve(HDM_OFT_CIEStandard.StandardObserver1931_2Degrees);  
OFT_ColorCheckerPatchSetReference_xyY=HDM_OFT_PatchSet.GetCIE31_2Degress_D50_ColorChecker_BabelColorReferences();

subplot(2,2,2)
%figure
%scatter(OFT_PatchSetTristimuli_ColorValueParts(1,:),OFT_PatchSetTristimuli_ColorValueParts(2,:))
plot([OFT_CIE31_colorValueParts_x;OFT_CIE31_colorValueParts_x(1)],[OFT_CIE31_colorValueParts_y;OFT_CIE31_colorValueParts_y(1)],'-',...
    OFT_PatchSetTristimuli_ColorValueParts(1,:),OFT_PatchSetTristimuli_ColorValueParts(2,:),'r+',...
    OFT_ColorCheckerPatchSetReference_xyY(:,1),OFT_ColorCheckerPatchSetReference_xyY(:,2),'bx')

xlabel('x')
ylabel('y')
title('CIE31 x y color value parts');

%% 4.7.3 scene adopted white tristimulus, here the illumination source
HDM_OFT_Utils.OFT_DispSubTitle('4.7.3 setup tristimuli for scene adopetd white currently daylight from above used');
%figure
subplot(2,2,3)
plot(OFT_Illuminant_Spectrum_1nm_CIE31Range(1,:),OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:))
xlabel('wavelength in nm')
ylabel('relative illumination power distribution')
title('Daylight for CIE31 range');

OFT_Illumination_Scale=1;
OFT_Illumination_Norm=1;

OFT_Xw=OFT_Illumination_Scale*trapz(OFT_CIEStandardObserver_SpectralCurves(2,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:))/OFT_Illumination_Norm;
OFT_Yw=OFT_Illumination_Scale*trapz(OFT_CIEStandardObserver_SpectralCurves(3,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:))/OFT_Illumination_Norm;
OFT_Zw=OFT_Illumination_Scale*trapz(OFT_CIEStandardObserver_SpectralCurves(4,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:))/OFT_Illumination_Norm;

OFT_WwUnscaled=[OFT_Xw,OFT_Yw,OFT_Zw]';
OFT_Ww=100*(OFT_WwUnscaled./OFT_WwUnscaled(2));
HDM_OFT_Utils.OFT_DispTitle('Daylight XYZ plausibility check');
disp(OFT_Ww);

OFT_WwxyY=[OFT_Xw/(OFT_Xw + OFT_Yw + OFT_Zw),OFT_Yw/(OFT_Xw + OFT_Yw + OFT_Zw),OFT_Zw/(OFT_Xw + OFT_Yw + OFT_Zw)]';
disp(OFT_WwxyY);


OFT_PatchSetTristimuliNorm=100*(OFT_PatchSetTristimuli./OFT_WwUnscaled(2));

OFT_PatchSetTristimuli=OFT_PatchSetTristimuliNorm;
referenceWhite=OFT_Ww;

%% 4.7.4 adjust tristimuli of training colours to compensate scene adopted
HDM_OFT_Utils.OFT_DispSubTitle('4.7.4 adjust tristimuli of training colours to compensate scene adopted');
OFT_PatchSetReferenceTristimuli=...
    HDM_OFT_ColorNeutralCompensations.OFT_CompensateTristimuliForDifferentWhite(OFT_NeutralsCompensation, OFT_PatchSetTristimuli, OFT_Ww, OFT_w);

end

function [OFT_PatchSetCameraTristimuli, OFT_IDT_b] = ComputeCameraTristimuli4PatchSet...
    (OFT_MeasuredCameraResponseFileName, OFT_PreLinearisationCurve, OFT_Illuminant_Spectrum_1nm_CIE31Range, OFT_PatchSet_SpectralCurve)

    %not aequidistant

    if(strfind(OFT_MeasuredCameraResponseFileName, '.csv'))

        HDM_OFT_Utils.OFT_DispSubTitle('start camera spectral response based tristimuli computation');    

        OFT_CameraSpectralResponse=csvread(OFT_MeasuredCameraResponseFileName);
        OFT_CameraSpectralResponse_Wavelength=OFT_CameraSpectralResponse(:,1)';

        %to be discussed relative values doesnt really correspond with RGB raw
        %values

        OFT_CameraSpectralResponse_Rrelative=OFT_CameraSpectralResponse(:,2)';

        if(size(OFT_CameraSpectralResponse,2)==4)
            OFT_CameraSpectralResponse_Grelative=OFT_CameraSpectralResponse(:,3)';
            OFT_CameraSpectralResponse_Brelative=OFT_CameraSpectralResponse(:,4)';
        else
            OFT_CameraSpectralResponse_G1relative=OFT_CameraSpectralResponse(:,3)';
            OFT_CameraSpectralResponse_G2relative=OFT_CameraSpectralResponse(:,4)';
            OFT_CameraSpectralResponse_Grelative=0.5 * (OFT_CameraSpectralResponse_G1relative+OFT_CameraSpectralResponse_G2relative);
            OFT_CameraSpectralResponse_Brelative=OFT_CameraSpectralResponse(:,5)';
        end

        %to be discussed borders are zero in relative values
        %maxmimum correct?
        %in near ir it increases! correction vector additive

        OFT_CameraSpectralResponse=...
            [OFT_CameraSpectralResponse_Wavelength;
            OFT_CameraSpectralResponse_Rrelative;
            OFT_CameraSpectralResponse_Grelative;
            OFT_CameraSpectralResponse_Brelative];

        OFT_CameraSpectralResponse_1nm_CIE31Range=...
            [360:1:830;
            interp1(OFT_CameraSpectralResponse(1,:),OFT_CameraSpectralResponse(2,:),360:1:830,'pchip',0);
            interp1(OFT_CameraSpectralResponse(1,:),OFT_CameraSpectralResponse(3,:),360:1:830,'pchip',0);
            interp1(OFT_CameraSpectralResponse(1,:),OFT_CameraSpectralResponse(4,:),360:1:830,'pchip',0)];
        
        subplot(2,2,4)
        plot(OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(4,:),...
            OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(3,:),...
            OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(2,:));
        xlabel('wavelength in nm')
        ylabel('relative spectral response')
        legend({'b','g','r'})
        %title('spectral response of camera system');
        
        figure
        plot(OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(4,:),...
            OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(3,:),...
            OFT_CameraSpectralResponse_1nm_CIE31Range(1,:),OFT_CameraSpectralResponse_1nm_CIE31Range(2,:));
        xlabel('wavelength in nm')
        ylabel('relative spectral response')
        legend({'b','g','r'})
        grid on
        grid minor
        %title('spectral response of camera system');

        %% 4.7.5 camera system white balance factors
        HDM_OFT_Utils.OFT_DispTitle('4.7.5 camera system white balance factors');
        
        OFT_CAM_XwE=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(2,:));
        OFT_CAM_YwE=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(3,:));
        OFT_CAM_ZwE=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(4,:));

        OFT_CAM_Xw=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(2,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));
        OFT_CAM_Yw=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(3,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));
        OFT_CAM_Zw=trapz(OFT_CameraSpectralResponse_1nm_CIE31Range(4,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));

        OFT_CAM_WwUnscaled=[OFT_CAM_Xw;OFT_CAM_Yw;OFT_CAM_Zw]
        OFT_CAM_Ww=100*(OFT_CAM_WwUnscaled./OFT_CAM_WwUnscaled(2));

        OFT_IDT_bScaled=OFT_CAM_Ww./min(OFT_CAM_Ww);

        %% 4.7.6 compute white balanced linearized camera system response values of
        %%training colours
        HDM_OFT_Utils.OFT_DispTitle('4.7.6 compute white balanced linearized camera system response values of training colours');
        [OFT_PatchSetCameraTristimuli,OFT_PatchSetCameraTristimuli_ColorValueParts]=...
                HDM_OFT_TristimuliCreator.CreateFromSpectrum(...
                        OFT_CameraSpectralResponse_1nm_CIE31Range,...%//!!!
                        OFT_Illuminant_Spectrum_1nm_CIE31Range,...
                        OFT_PatchSet_SpectralCurve);
         
        
        OFT_PatchSetCameraTristimuli2=OFT_PatchSetCameraTristimuli;       
        OFT_IDT_bFromWPatch=OFT_PatchSetCameraTristimuli(:,19);
        
        OFT_IDT_b=1./OFT_IDT_bScaled;
        OFT_PatchSetCameraTristimuli=100*(OFT_PatchSetCameraTristimuli./OFT_CAM_WwUnscaled(2));
        OFT_PatchSetCameraTristimuliW=OFT_PatchSetCameraTristimuli.*repmat(OFT_IDT_b,[1,size(OFT_PatchSetCameraTristimuli,2)]);
        
        OFT_PatchSetCameraTristimuli=OFT_PatchSetCameraTristimuliW;
        
        %OFT_IDT_b=OFT_PatchSetCameraTristimuli(:,19);
        
%         OFT_PatchSetCameraTristimuli(1,:)=scaleB(1,1).*OFT_PatchSetCameraTristimuli(1,:);
%         OFT_PatchSetCameraTristimuli(2,:)=scaleB(2,1).*OFT_PatchSetCameraTristimuli(2,:);
%         OFT_PatchSetCameraTristimuli(3,:)=scaleB(3,1).*OFT_PatchSetCameraTristimuli(3,:);

    elseif(isempty(strfind(lower(OFT_MeasuredCameraResponseFileName), '.tif'))||isempty(strfind(lower(OFT_MeasuredCameraResponseFileName), '.dpx')))%//!!!

        %% annex B estimation by test chart image from camera
        HDM_OFT_Utils.OFT_DispTitle('start camera rgb image based tristimuli computation (Annex B)');    

        % //!!!open colour domain for camera image
        HDM_OFT_Utils.OFT_DispSubTitle('search for test chart in image');
        OFT_cameraImageOfTestChartOrigin=HDM_OFT_ImageExportImport.ImportImage(OFT_MeasuredCameraResponseFileName, OFT_PreLinearisationCurve);
        
        subplot(2,2,4) ,imshow(OFT_cameraImageOfTestChartOrigin);
        
        OFT_cameraImageOfTestChart = double(OFT_cameraImageOfTestChartOrigin);
        [OFT_cameraImageOfTestChart_PatchLocations,OFT_cameraImageOfTestChart_PatchColours] = CCFind(OFT_cameraImageOfTestChart);
        %visualizecc(OFT_cameraImageOfTestChart,OFT_cameraImageOfTestChart_PatchLocations);

        %///!!!white point scale
        % //!!! Preprocess rgb tupel linear white point
        OFT_PatchSetCameraTristimuli=OFT_cameraImageOfTestChart_PatchColours;
        %OFT_PatchSetCameraTristimuli=100*(OFT_cameraImageOfTestChart_PatchColours./OFT_cameraImageOfTestChart_PatchColours(2,19));

        OFT_CAM_Ww=OFT_PatchSetCameraTristimuli(:,19);

        OFT_IDT_b=[1;1;1];%1./OFT_CAM_Ww;

    end

end

function [OFT_IDT_B,OFT_resnormBEstimation]=EstimateIDTMatrix(OFT_In_ErrorMinimizationDomain)

    OFT_IDT_BStart = ...
        [1 0 0;
        0 1 0;
        0 0 1];

    switch OFT_In_ErrorMinimizationDomain
        case 'Lab'
            [OFT_IDT_B,OFT_resnormBEstimation] = lsqnonlin(@OFT_IDT_MeritFunctionCoreLab,OFT_IDT_BStart);
        case 'Luv'
            [OFT_IDT_B,OFT_resnormBEstimation] = lsqnonlin(@OFT_IDT_MeritFunctionCoreLuv,OFT_IDT_BStart);
        case 'XYZ'
            [OFT_IDT_B,OFT_resnormBEstimation] = lsqnonlin(@OFT_IDT_MeritFunctionCoreXYZ,OFT_IDT_BStart);
        otherwise
    end

end

function F = OFT_IDT_MeritFunctionCoreLuv(B0)

global gOFT_M
global gOFT_w
global gOFT_PatchSetTristimuli_NeutralsCompensated
global gOFT_PatchSetCameraTristimuli

k = 1:size(gOFT_PatchSetTristimuli_NeutralsCompensated,2);

F = HDM_OFT_ColorConversions.OFT_CIELuv(gOFT_PatchSetTristimuli_NeutralsCompensated(:,k),gOFT_w)-...
    HDM_OFT_ColorConversions.OFT_CIELuv(gOFT_M*B0*gOFT_PatchSetCameraTristimuli(:,k),gOFT_w);

end

function F = OFT_IDT_MeritFunctionCoreLab(B0)

global gOFT_M
global gOFT_w
global gOFT_PatchSetTristimuli_NeutralsCompensated
global gOFT_PatchSetCameraTristimuli

k = 1:size(gOFT_PatchSetTristimuli_NeutralsCompensated,2);

F = HDM_OFT_ColorConversions.OFT_CIELab(gOFT_PatchSetTristimuli_NeutralsCompensated(:,k),gOFT_w)-...
    HDM_OFT_ColorConversions.OFT_CIELab(gOFT_M*B0*gOFT_PatchSetCameraTristimuli(:,k),gOFT_w);

end

function F = OFT_IDT_MeritFunctionCoreXYZ(B0)

global gOFT_PatchSetTristimuli_NeutralsCompensated
global gOFT_PatchSetCameraTristimuli

l=0;
u=0;
k = 1+l:(size(gOFT_PatchSetTristimuli_NeutralsCompensated,2)-u);

F = gOFT_PatchSetTristimuli_NeutralsCompensated(:,k)-B0*gOFT_PatchSetCameraTristimuli(:,k);

end

function OFT_IDTProfileFileName = WriteIDTProfileAndStatEntry...
    (OFT_Env, OFT_MeasuredCameraResponseFileName, OFT_resnormBEstimation, OFT_IDT_B, OFT_IDT_b,...
    OFT_NeutralsCompensation, OFT_IlluminantSpectrum, OFT_ErrorMinimizationDomain)

    if(isempty(strfind(OFT_IlluminantSpectrum,'.')))
        IlluminantStr=strcat('Illuminant_',OFT_IlluminantSpectrum);
    else
        [OFT_IlluminantSpectrumPath,OFT_IlluminantSpectrumName,OFT_IlluminantSpectrumExt] = fileparts(OFT_IlluminantSpectrum);
        IlluminantStr=strcat('Illuminant_FromFile_',OFT_IlluminantSpectrumName);
    end

    fin = fopen(strcat(OFT_Env.OFT_ConstraintsPath,'/IDT_Template.txt'));
    idtCreationDateStr=datestr(now,'yyyy-mm-dd_HH.MM.SS.FFF');
    OFT_IDT_File=strcat(OFT_Env.OFT_ProcessPath,'/IDT_',IlluminantStr,'_',idtCreationDateStr,'.ctl');
    fout = fopen(OFT_IDT_File,'wt');

    if ~exist(strcat(OFT_Env.OFT_StatisticsPath,'/IDTStat.csv'),'file')
        foutStat = fopen(strcat(OFT_Env.OFT_StatisticsPath,'/IDTStat.csv'),'wt');
        fprintf(foutStat,'idt file\t\t , measurement file\t\t , resnorm , B11 , B12 , B13 , B21 , B22 , B23 , B31 , B32 , B33 , scene adopted white, neutrals compensation, colour domain for error minimization\n');
    else
        foutStat = fopen(strcat(OFT_Env.OFT_StatisticsPath,'/IDTStat.csv'),'at');
    end

    fprintf(foutStat,'%s\t , ', strcat('IDT_',IlluminantStr,'_',idtCreationDateStr,'.ctl'));
    [~,OFT_MeasuredCameraResponseName,OFT_MeasuredCameraResponseExt] = fileparts(OFT_MeasuredCameraResponseFileName);
    fprintf(foutStat,'%s\t , ', strcat(OFT_MeasuredCameraResponseName,OFT_MeasuredCameraResponseExt));
    fprintf(foutStat,'%e , ', OFT_resnormBEstimation);

    while ~feof(fin)
       S = fgetl(fin);
       %s = strrep(s, '118520', '118521');

       if(strfind(S, '%'))

            if(strfind(S, '%IDT_DATE%'))

               fprintf(fout,'// Creation Date: %s\n',idtCreationDateStr);

            elseif (strfind(S, '%IDT_ILLUMINANT%'))

               fprintf(fout,'// Illuminant %s\n', OFT_IlluminantSpectrum);

            elseif(strfind(S, '%const float b['))

               fprintf(fout,'\tconst float b[] = { %f, %f, %f };\n',OFT_IDT_b(1),OFT_IDT_b(2),OFT_IDT_b(3));

            elseif(strfind(S, '%const float B1'))

               fprintf(fout,'\tconst float B[][] =     { { %f, %f, %f },\n',OFT_IDT_B(1,1),OFT_IDT_B(1,2),OFT_IDT_B(1,3));

               fprintf(foutStat,'%f , %f , %f , ',OFT_IDT_B(1,1),OFT_IDT_B(1,2),OFT_IDT_B(1,3));

            elseif(strfind(S, '%const float B2'))

               fprintf(fout,'\t\t\t  { %f, %f, %f },\n',OFT_IDT_B(2,1),OFT_IDT_B(2,2),OFT_IDT_B(2,3));

               fprintf(foutStat,'%f , %f , %f , ',OFT_IDT_B(2,1),OFT_IDT_B(2,2),OFT_IDT_B(2,3));

            elseif(strfind(S, '%const float B3'))

               fprintf(fout,'\t\t\t  { %f, %f, %f }};\n',OFT_IDT_B(3,1),OFT_IDT_B(3,2),OFT_IDT_B(3,3));

               fprintf(foutStat,'%f , %f , %f , ',OFT_IDT_B(3,1),OFT_IDT_B(3,2),OFT_IDT_B(3,3));

               fprintf(foutStat,'%s , %s , %s', OFT_IlluminantSpectrum, OFT_NeutralsCompensation, OFT_ErrorMinimizationDomain);

           end

       else

            fprintf(fout,'%s\n',S);

       end
    end

    fprintf(foutStat,'\n');

    fclose(fin);
    fclose(fout);
    fclose(foutStat);
    
    OFT_IDTProfileFileName=OFT_IDT_File;

end


