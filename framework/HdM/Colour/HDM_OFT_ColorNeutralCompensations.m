classdef HDM_OFT_ColorNeutralCompensations
    methods(Static)
        
        function out=ChromaticAdaptationBradfordType()
            out='ChromaticAdaptationBradford';
        end
        
        function out=ChromaticAdaptationCAT02Type()
            out='ChromaticAdaptationCAT02';
        end
        
        function out=ReIlluminationType()
            out='ReIllumination';
        end
        
        function out=NoneType()
            out='None';
        end

        function out = OFT_CompensateTristimuliForDifferentWhite(OFT_NeutralsCompensation, OFT_ColorCheckerTristimuli, OFT_Ww, OFT_w)
            
        switch OFT_NeutralsCompensation

        case HDM_OFT_ColorNeutralCompensations.ChromaticAdaptationBradfordType()

            %% 4.7.4.1 via chromatic adaptation
            %HDM_OFTP_Utils.OFT_DispTitle('4.7.4.1 via chromatic adaptation Bradford');

             %todo which matrix
            OFT_ChromaticAdaptation_Bradford=...
                [0.8950 0.2664 -0.1614;
                -0.7502 1.7135 0.0367;
                0.0389 -0.0685 1.0296];

            ChromaticAdaptationMatrix_Bradford=HDM_OFT_ColorNeutralCompensations.OFT_CreateChromaticAdaptationMatrix(OFT_ChromaticAdaptation_Bradford,OFT_Ww, OFT_w);

            OFT_ColorCheckerTristimuli_ChromaticAdaptedBradford=HDM_OFT_ColorNeutralCompensations.OFT_AdjustTristimuliForDifferentWhite(OFT_ColorCheckerTristimuli,ChromaticAdaptationMatrix_Bradford);

            OFT_ColorCheckerTristimuli_NeutralsCompensated=OFT_ColorCheckerTristimuli_ChromaticAdaptedBradford;

        case HDM_OFT_ColorNeutralCompensations.ChromaticAdaptationCAT02Type()

            %% 4.7.4.1 via chromatic adaptation
            HDM_OFT_Utils.OFT_DispSubTitle('4.7.4.1 via chromatic adaptation CAT02');

            OFT_ChromaticAdaptation_CAT02=...
                [0.7328 0.4296 -0.1624;
                -0.7036 1.6975 0.0061;
                0.0030 -0.0136 0.9834];

            ChromaticAdaptationMatrix_CAT02=HDM_OFTP_ColorNeutralCompensations.OFT_CreateChromaticAdaptationMatrix(OFT_ChromaticAdaptation_CAT02,OFT_Ww, OFT_w);

            OFT_ColorCheckerTristimuli_ChromaticAdaptedCAT02=HDM_OFTP_ColorNeutralCompensations.OFT_AdjustTristimuliForDifferentWhite(OFT_ColorCheckerTristimuli,ChromaticAdaptationMatrix_CAT02);

            OFT_ColorCheckerTristimuli_NeutralsCompensated=OFT_ColorCheckerTristimuli_ChromaticAdaptedCAT02;

        case HDM_OFT_ColorNeutralCompensations.ReIlluminationType()

            %% 4.7.4.2 reillumination
            HDM_OFTP_Utils.OFT_DispSubTitle('4.7.4.2 via reillumination');

            %todo the matrix below is an example???
            OFT_Reillumination=...
                [1.6160 -0.3591 -0.2569;
                -0.9542 1.8731 0.0811;
                0.0170 -0.0333  1.0163];

            OFT_ReIlluminationMatrix=HDM_OFTP_ColorNeutralCompensations.OFT_CreateReIlluminationMatrix(OFT_Reillumination,OFT_Ww);

            OFT_ColorCheckerTristimuli_ReIlluminated=HDM_OFTP_ColorNeutralCompensations.OFT_AdjustTristimuliForDifferentWhite(OFT_ColorCheckerTristimuli,OFT_ReIlluminationMatrix);

            OFT_ColorCheckerTristimuli_NeutralsCompensated=OFT_ColorCheckerTristimuli_ReIlluminatedd;

        otherwise

            HDM_OFT_Utils.OFT_DispSubTitle('4.7.4.1 ident');

            OFT_ColorCheckerTristimuli_NeutralsCompensated=OFT_ColorCheckerTristimuli;

        end    
        
        out=OFT_ColorCheckerTristimuli_NeutralsCompensated;
        
    end
        
    function out = OFT_AdjustTristimuliForDifferentWhite(OFT_ColorCheckerTristimuli,AdjustMatrix)

    NumberOfPatches=size(OFT_ColorCheckerTristimuli,2);

    OFT_ColorCheckerTristimuli_Adjusted=zeros(3,NumberOfPatches);
    for i=1:NumberOfPatches
        OFT_ColorCheckerTristimuli_Adjusted(:,i)=AdjustMatrix*OFT_ColorCheckerTristimuli(:,i);
    end

    out=OFT_ColorCheckerTristimuli_Adjusted;

    end

    function out = OFT_CreateReIlluminationMatrix(IDT_A,IDT_Ww)

    disp(IDT_A);
    disp(IDT_Ww);

    rgbMod=(IDT_A * IDT_Ww);

    disp('rgbNorm');
    disp(rgbMod);

    rgbMod=1./rgbMod;
    disp(rgbMod);

    disp(norm(rgbMod));

    disp(diag(rgbMod));

    out=inv(IDT_A) * diag(rgbMod) * IDT_A;

    end

    function out = OFT_CreateChromaticAdaptationMatrix(IDT_A,IDT_Ww, IDT_w)

    disp(IDT_A);
    disp(IDT_Ww);
    disp(IDT_w);

    rgbMod1=(IDT_A * IDT_Ww);

    rgbMod2=(IDT_A * IDT_w);

    %to be clarified if elementwise is needed
    %based on LMS and vanKries trafo

    out=inv(IDT_A) * diag(rgbMod2./rgbMod1) * IDT_A;

    end
        
    end
end