function out=HDM_OFT_CameraSpectralResponse(OFT_In_IDTTaskData)

OFT_Env=HDM_OFT_InitEnvironment();

HDM_OFT_Utils.OFT_DispTitle('camera spectral response estimation');

OFT_Pixel2WavelengthLookUp=HDM_OFT_LineCalibration...
    (OFT_In_IDTTaskData.SpectralResponse_In_LineCalibrationSpectrum, OFT_In_IDTTaskData.SpectralResponse_In_LineCalibrationImage,...
    OFT_In_IDTTaskData.PreLinearisation_Out_LinCurve);

OFT_CameraResponse=HDM_OFT_LightCalibration...
    (OFT_Pixel2WavelengthLookUp,...
    OFT_In_IDTTaskData.SpectralResponse_In_LightCalibrationSpectrum, OFT_In_IDTTaskData.SpectralResponse_In_LightCalibrationImage,...
    OFT_In_IDTTaskData.PreLinearisation_Out_LinCurve, OFT_In_IDTTaskData.Device_In_Sensor, OFT_In_IDTTaskData.Device_In_FocalLength);

out=OFT_CameraResponse;

HDM_OFT_Utils.OFT_DispTitle('camera spectral response estimation succesfully finished');

end