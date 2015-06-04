function out=HDM_OFT_GetIlluminantSpectrum(OFT_IlluminantSpectrum)

if(isempty(strfind(OFT_IlluminantSpectrum,'.')))
    switch OFT_IlluminantSpectrum
        case 'D50'
            OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetStandardDIllumination(5000);
        case 'D55'
            OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetStandardDIllumination(5500);
        case 'D65'
            OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetStandardDIllumination(6500);
        case 'C'
            OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetStandardCIllumination();%//!!!transpose avoid
        otherwise
    end
else
    OFT_Illuminant_Spectrum_1nm_CIE31Range=HDM_OFT_GetCIERange1nmSpectrumFromSpectralDataFile(OFT_IlluminantSpectrum);
end

out=OFT_Illuminant_Spectrum_1nm_CIE31Range;

end

