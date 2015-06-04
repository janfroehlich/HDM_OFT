classdef HDM_OFT_IDT_ReferenceCamera   
    methods(Static)
        
         function [M,w]=GetDefinition(CameraType)
            switch CameraType
                case HDM_OFT_IDT_ReferenceCamera.RICDType();
                    [M,w]=HDM_OFT_IDT_ReferenceCamera.RICD();
                case HDM_OFT_IDT_ReferenceCamera.CIEType();
                    [M,w]=HDM_OFT_IDT_ReferenceCamera.CIEIdent();
                otherwise
                    [M,w]=HDM_OFT_IDT_ReferenceCamera.CIEIdent();
            end
        end       
        
        function [M,w]=RICD()

            M=...
                [0.9525523959 0 0.0000936786 ;
                0.3439664498  0.7281660966 -0.0721325464;
                0 0 1.0088251844];

            w=M * [100 100 100]';
        end
        
        function [M,w]=CIEIdent()
            
            M=...
                [1 0 0 ;
                0  1 0;
                0 0 1];

            w=M * [100 100 100]';
            
        end
        
        function out=RICDType()
            out='RICD';
        end
        
        function out=CIEType()
            out='CIE';
        end
    end
    
    properties

    end
end