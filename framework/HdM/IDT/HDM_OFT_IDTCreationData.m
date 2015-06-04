classdef HDM_OFT_IDTCreationData   
    properties
        Report_In_Company;
        Report_In_Production;
        Report_In_Operator;
        Report_In_email;
        Report_In_Time;     
        
        Device_In_Camera;
        Device_In_Sensor;
        Device_In_FocalLength;
        Device_In_Stop;
        Device_In_Spectrometer;
        Device_In_Comment;
        
        ServerOutDir;
        
        PreLinearisation_In_LinFile;
        PreLinearisation_Out_LinCurve;
        
        SpectralResponse_In_LineCalibrationSpectrum;
        SpectralResponse_In_LineCalibrationImage;
        SpectralResponse_In_LightCalibrationSpectrum;
        SpectralResponse_In_LightCalibrationImage;
        
        SpectralResponse_Out_SpectralResponseFile;
        
        IDTCreationConstraints_In_WhitePoint;
        IDTCreationConstraints_In_ErrorMinimizationDomain;
        IDTCreationConstraints_In_PatchSet;
        
        IDTCreationConstraints_Out_IDTFiles;
        
        Evaluation_In_TestImage;
        Evaluation_Out_ProfiledImages;
        
    end
end