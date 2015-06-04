classdef HDM_OFT_PatchSet
    methods(Static)

        function [OFT_PatchSet_SpectralCurve]=GetPatchSpectra(OFT_PatchSetType)
        
            OFT_Env=HDM_OFT_InitEnvironment();    
            
            if(exist('OFT_PatchSetType','var')==0 || strcmp(OFT_PatchSetType,''))
                OFT_MeasuredPatchFileName=strcat(OFT_Env.OFT_RootDataDir,'/chartMeasurementReference/GM_CCh_Spectra_02.csv');%PatchesMod.xlsx or GM_CCh_Spectra_02.csv
            elseif(strfind(lower(OFT_PatchSetType), lower(HDM_OFT_PatchSet.GretagMacbethColorChecker())))
                OFT_MeasuredPatchFileName=strcat(OFT_Env.OFT_RootDataDir,'/chartMeasurementReference/PatchesMod.xlsx');
            else
                OFT_MeasuredPatchFileName=OFT_PatchSetType;
            end
            
            %//!!!OFT_JoensuuFiles = untar('F:\usr\fuchs\OFTP\002Development\MatLab\framework\COTS\Joensuu\forest380_850_5.tar.gz',OFT_Env.OFT_ProcessPath);
            %//!!!OFT_JoensuuFiles = untar('ftp://ftp.cs.joensuu.fi/pub/color/spectra/forest/forest380_850_5.tar.gz',OFT_Env.OFT_ProcessPath);

            if(strfind(lower(OFT_MeasuredPatchFileName), '.xls'))

                [oft_ndata, oft_text, oft_alldata] =xlsread(OFT_MeasuredPatchFileName);

                OFT_BabelColor_GM_CCh_SpectralCurve=oft_ndata;

            else

                OFT_BabelColor_GM_CCh_SpectralCurve=csvread(OFT_MeasuredPatchFileName);

            end
            
            oft_newSampleRange=360:1:830;
            OFT_PatchSet_SpectralCurve=zeros(size(OFT_BabelColor_GM_CCh_SpectralCurve,1),size(oft_newSampleRange,2));
            
            for cur=2:size(OFT_BabelColor_GM_CCh_SpectralCurve,1)
                
                curInterpol=interp1(OFT_BabelColor_GM_CCh_SpectralCurve(1,:),OFT_BabelColor_GM_CCh_SpectralCurve(cur,:),360:1:830,'pchip',0);
                OFT_PatchSet_SpectralCurve(cur,:)=curInterpol;
                
            end
            
            OFT_PatchSet_SpectralCurve(1,:)=oft_newSampleRange;
        
        end
 
        function out = GretagMacbethColorChecker()
            out='Gretag Macbeth Color Checker';
        end
 
        function OFT_ColorCheckerPatchSetReference_xyY=GetCIE31_2Degress_D50_ColorChecker_BabelColorReferences()
            %D50 greatg macbeth colorchecker from PatchSet
            %//!!!TBD: read csv
            GMCC76_xyY_dark_skin = [0.4325	0.3788	10.34];
            GMCC76_xyY_light_skin = [0.4191	0.3748	35.25];
            GMCC76_xyY_blue_sky = [0.2761	0.3004	18.47];
            GMCC76_xyY_foliage = [0.3700	0.4501	13.35];
            GMCC76_xyY_blue_flower = [0.3020	0.2877	23.24];
            GMCC76_xyY_bluish_green = [0.2856	0.3910	41.74];
            GMCC76_xyY_orange = [0.5291	0.4075	31.17];
            GMCC76_xyY_purplish_blue = [0.2339	0.2155	11.40];
            GMCC76_xyY_moderate_red = [0.5008	0.3293	19.79];
            GMCC76_xyY_purple = [0.3326	0.2556	6.44];
            GMCC76_xyY_yellow_green = [0.3989	0.4998	44.35];
            GMCC76_xyY_orange_yellow = [0.4962	0.4428	43.58];
            GMCC76_xyY_blue = [0.2040	0.1696	5.79];
            GMCC76_xyY_green = [0.3270	0.5033	23.07];
            GMCC76_xyY_red = [0.5709	0.3298	12.68];
            GMCC76_xyY_yellow = [0.4694	0.4732	60.81];
            GMCC76_xyY_magenta = [0.4177	0.2704	20.07];
            GMCC76_xyY_cyan = [0.2151	0.3037	19.03];
            GMCC76_xyY_w = [0.3488	0.3628	91.29];
            GMCC76_xyY_g4 = [0.3451	0.3596	58.85];
            GMCC76_xyY_g3 = [0.3446	0.3590	35.95];
            GMCC76_xyY_g2 = [0.3438	0.3589	19.12];
            GMCC76_xyY_g1 = [0.3423	0.3576	8.93];
            GMCC76_xyY_b = [0.3439	0.3565	3.20];

            OFT_ColorCheckerPatchSetReference_xyY=...
                [GMCC76_xyY_dark_skin;
                GMCC76_xyY_light_skin;
                GMCC76_xyY_blue_sky;
                GMCC76_xyY_foliage;
                GMCC76_xyY_blue_flower;
                GMCC76_xyY_bluish_green;
                GMCC76_xyY_orange;
                GMCC76_xyY_purplish_blue;
                GMCC76_xyY_moderate_red;
                GMCC76_xyY_purple;
                GMCC76_xyY_yellow_green;
                GMCC76_xyY_orange_yellow;
                GMCC76_xyY_blue;
                GMCC76_xyY_green;
                GMCC76_xyY_red;
                GMCC76_xyY_yellow;
                GMCC76_xyY_magenta;
                GMCC76_xyY_cyan
                GMCC76_xyY_w;
                GMCC76_xyY_g4;
                GMCC76_xyY_g3;
                GMCC76_xyY_g2;
                GMCC76_xyY_g1;
                GMCC76_xyY_b];
        end
        
    end
end

