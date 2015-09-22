function OFT_IDTFiles=HDM_OFT_IDT_ProfilesGeneration...
    (IDTTaskData)

if isempty(IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum)
    OFT_Illuminations={IDTTaskData.IDTCreationConstraints_In_WhitePoint};
else
    OFT_Illuminations={IDTTaskData.IDTCreationConstraints_In_WhitePoint, IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum};
end

OFT_IDTFiles=cell(size(OFT_Illuminations));

HDM_OFT_Utils.OFT_DispTitle('start IDT profile creation');

for curIlluminandIndex=1:size(OFT_Illuminations,2)
    
    IlluminantStr=OFT_Illuminations{curIlluminandIndex};
    HDM_OFT_Utils.OFT_DispSubTitle(strcat('create idt profile for illuminant: ',IlluminantStr));
    
    %//!!! IDTCreationConstraints_In_WhitePoint;  
    [OFT_IDTFile, OFT_IDT_B, OFT_IDT_b]=...
        HDM_OFT_IDT_MinimumError...
        (IDTTaskData.IDTCreationConstraints_In_PatchSet,...
        IDTTaskData.SpectralResponse_Out_SpectralResponseFile,IDTTaskData.PreLinearisation_Out_LinCurve, HDM_OFT_ColorNeutralCompensations.ChromaticAdaptationBradfordType(),...%//!!!
        IDTTaskData.IDTCreationConstraints_In_ErrorMinimizationDomain,IlluminantStr,...
        HDM_OFT_IDT_ReferenceCamera.RICDType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());

    OFT_IDTFiles{curIlluminandIndex}=OFT_IDTFile;    

    disp(strcat('idt file: ', OFT_IDTFile));
    disp('estimated matrix');
    disp(OFT_IDT_B);
    
    OFT_SpectralDataBasedTransformedImage2View=HDM_OFT_EvaluateIDTProfiledChartImage...
    (OFT_IDT_B, OFT_IDT_b, IDTTaskData.Evaluation_In_TestImage,IDTTaskData.PreLinearisation_Out_LinCurve, IlluminantStr,...
    HDM_OFT_IDT_ReferenceCamera.RICDType(),HDM_OFT_ColorNeutralCompensations.ChromaticAdaptationBradfordType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());
    
end

HDM_OFT_Utils.OFT_DispSubTitle('create spectral based idt profile for technical xyz based evaluation');

[OFT_IDTFile_TechTest, OFT_IDT_B_TechTest, OFT_IDT_b]=...
    HDM_OFT_IDT_MinimumError...
    (IDTTaskData.IDTCreationConstraints_In_PatchSet,...
    IDTTaskData.SpectralResponse_Out_SpectralResponseFile,IDTTaskData.PreLinearisation_Out_LinCurve, HDM_OFT_ColorNeutralCompensations.NoneType(),...%//!!!
    IDTTaskData.IDTCreationConstraints_In_ErrorMinimizationDomain,IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum,...
    HDM_OFT_IDT_ReferenceCamera.CIEType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());

OFT_SpectralDataBasedTransformedImage2View=HDM_OFT_EvaluateIDTProfiledChartImage...
  (OFT_IDT_B_TechTest, OFT_IDT_b ,IDTTaskData.Evaluation_In_TestImage,IDTTaskData.PreLinearisation_Out_LinCurve, 'D50',...%IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum,...//!!!
   HDM_OFT_IDT_ReferenceCamera.CIEType(),HDM_OFT_ColorNeutralCompensations.NoneType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());

HDM_OFT_Utils.OFT_DispSubTitle('create annex b idt profile for technical xyz based evaluation');

[OFT_IDTFile_TechTestAnnexB, OFT_IDT_B_TechTestAnnexB, OFT_IDT_b]=...
    HDM_OFT_IDT_MinimumError...
    (IDTTaskData.IDTCreationConstraints_In_PatchSet,...
    IDTTaskData.Evaluation_In_TestImage,IDTTaskData.PreLinearisation_Out_LinCurve, HDM_OFT_ColorNeutralCompensations.NoneType(),...%//!!!
    IDTTaskData.IDTCreationConstraints_In_ErrorMinimizationDomain,IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum,...
    HDM_OFT_IDT_ReferenceCamera.CIEType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());

HDM_OFT_EvaluateIDTProfiledChartImage...
    (OFT_IDT_B_TechTestAnnexB, OFT_IDT_b,IDTTaskData.Evaluation_In_TestImage,IDTTaskData.PreLinearisation_Out_LinCurve, 'D50',...%IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum,...//!!!
    HDM_OFT_IDT_ReferenceCamera.CIEType(),HDM_OFT_ColorNeutralCompensations.NoneType(),HDM_OFT_CIEStandard.StandardObserver1931_2Degrees());%, OFT_SpectralDataBasedTransformedImage2View);


HDM_OFT_Utils.OFT_DispTitle('finish IDT profile creation');

end