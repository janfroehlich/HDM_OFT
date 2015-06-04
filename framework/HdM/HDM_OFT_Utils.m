classdef HDM_OFT_Utils
    methods(Static)
        function OFT_DispTitle(toShow)
        disp('******************************************************')
        disp(strcat('***   ',toShow));
        disp('******************************************************')
        end
        
        function OFT_DispSubTitle(toShow)
        disp(strcat('***   ',toShow));
        end
    end
end