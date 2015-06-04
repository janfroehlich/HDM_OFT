classdef HDM_OFT_TristimuliCreator
    methods(Static)
        
        function [OFT_ColorCheckerTristimuli,OFT_ColorCheckerTristimuli_ColorValueParts]=...
                CreateFromSpectrum(OFT_Observer_SpectralCurves,...
                OFT_Illuminant_Spectrum_1nm_CIE31Range,...
                OFT_PatchSet_SpectralCurve)
            
            OFT_Illumination_Norm=1;%//!!!trapz(OFT_Observer_SpectralCurve_y .* OFT_Illuminant_Spectrum_1nm_CIE31Range);
            OFT_Illumination_Scale=1;%//!!!100

            %OFT_Illumination_Norm=trapz(OFT_Observer_SpectralCurve_y .* OFT_Illuminant_Spectrum_1nm_CIE31Range);
            %OFT_Illumination_Scale=100;
            NumberOfPatches=size(OFT_PatchSet_SpectralCurve,1)-1;
            OFT_ColorCheckerTristimuli=zeros(3,NumberOfPatches);
            OFT_ColorCheckerTristimuli_ColorValueParts=zeros(3,NumberOfPatches);

            if OFT_Illuminant_Spectrum_1nm_CIE31Range=='E'
                for patchIndex=2:(NumberOfPatches+1)

                    X=trapz(OFT_Observer_SpectralCurves(2,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:));
                    OFT_ColorCheckerTristimuli(1,patchIndex-1)=OFT_Illumination_Scale*X/OFT_Illumination_Norm;
                    Y=trapz(OFT_Observer_SpectralCurves(3,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:));
                    OFT_ColorCheckerTristimuli(2,patchIndex-1)=OFT_Illumination_Scale*Y/OFT_Illumination_Norm;
                    Z=trapz(OFT_Observer_SpectralCurves(4,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:));
                    OFT_ColorCheckerTristimuli(3,patchIndex-1)=OFT_Illumination_Scale*Z/OFT_Illumination_Norm;

                    OFT_ColorCheckerTristimuli_ColorValueParts(1,patchIndex-1)=X/(X+Y+Z);
                    OFT_ColorCheckerTristimuli_ColorValueParts(2,patchIndex-1)=Y/(X+Y+Z);
                    OFT_ColorCheckerTristimuli_ColorValueParts(3,patchIndex-1)=Z/(X+Y+Z);

                end;                 
            else
                for patchIndex=2:(NumberOfPatches+1)

                    X=trapz(OFT_Observer_SpectralCurves(2,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));
                    OFT_ColorCheckerTristimuli(1,patchIndex-1)=OFT_Illumination_Scale*X/OFT_Illumination_Norm;
                    Y=trapz(OFT_Observer_SpectralCurves(3,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));
                    OFT_ColorCheckerTristimuli(2,patchIndex-1)=OFT_Illumination_Scale*Y/OFT_Illumination_Norm;
                    Z=trapz(OFT_Observer_SpectralCurves(4,:) .* OFT_PatchSet_SpectralCurve(patchIndex,:) .* OFT_Illuminant_Spectrum_1nm_CIE31Range(2,:));
                    OFT_ColorCheckerTristimuli(3,patchIndex-1)=OFT_Illumination_Scale*Z/OFT_Illumination_Norm;

                    OFT_ColorCheckerTristimuli_ColorValueParts(1,patchIndex-1)=X/(X+Y+Z);
                    OFT_ColorCheckerTristimuli_ColorValueParts(2,patchIndex-1)=Y/(X+Y+Z);
                    OFT_ColorCheckerTristimuli_ColorValueParts(3,patchIndex-1)=Z/(X+Y+Z);

                end;    
            end
        end
    end
end