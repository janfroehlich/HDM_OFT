classdef HDM_OFT_ColorConversions
    methods(Static)
        
        function out=OFT_CIELab(OFT_Tristimuli,OFT_White)
            
        epsilon=216/24389;
        kappa=24389/27;

        OFT_TristimuliByRefWhite=[OFT_Tristimuli(1,:)./OFT_White(1);
                                  OFT_Tristimuli(2,:)./OFT_White(2);
                                  OFT_Tristimuli(3,:)./OFT_White(3)];

        NoP=size(OFT_TristimuliByRefWhite,2);
        OFT_LabOut=zeros(size(OFT_TristimuliByRefWhite));

        for patchIndex=1:NoP                        

            if(OFT_TristimuliByRefWhite(1,patchIndex)>epsilon)

                fx=OFT_TristimuliByRefWhite(1,patchIndex)^(1/3);

            else

                fx=((kappa*OFT_TristimuliByRefWhite(1,patchIndex))+16)/116;

            end

            if(OFT_TristimuliByRefWhite(2,patchIndex)>epsilon)

                fy=OFT_TristimuliByRefWhite(2,patchIndex)^(1/3);

            else

                fy=((kappa*OFT_TristimuliByRefWhite(2,patchIndex))+16)/116;

            end

            if(OFT_TristimuliByRefWhite(3,patchIndex)>epsilon)

                fz=OFT_TristimuliByRefWhite(3,patchIndex)^(1/3);

            else

                fz=((kappa*OFT_TristimuliByRefWhite(3,patchIndex))+16)/116;

            end

            OFT_LabOut(1,patchIndex)=116*fy-16;
            OFT_LabOut(2,patchIndex)=500*(fx-fy);
            OFT_LabOut(3,patchIndex)=200*(fy-fz);
        end;                          

        out=OFT_LabOut;

        end
        
        
        function out=OFT_CIELuv(OFT_Tristimuli,OFT_White)

        OFT_uw=4*OFT_White(1)/(OFT_White(1)+15*OFT_White(2)+3*OFT_White(3));
        OFT_vw=9*OFT_White(2)/(OFT_White(1)+15*OFT_White(2)+3*OFT_White(3));

        %OFT_u=4*OFT_Tristimuli(1)/(OFT_Tristimuli(1)+15*OFT_Tristimuli(2)+3*OFT_Tristimuli(3));
        %OFT_v=9*OFT_Tristimuli(2)/(OFT_Tristimuli(1)+15*OFT_Tristimuli(2)+3*OFT_Tristimuli(3));

        OFT_u=4*OFT_Tristimuli(1,:)./(OFT_Tristimuli(1,:)+15*OFT_Tristimuli(2,:)+3*OFT_Tristimuli(3,:));
        OFT_v=9*OFT_Tristimuli(2,:)./(OFT_Tristimuli(1,:)+15*OFT_Tristimuli(2,:)+3*OFT_Tristimuli(3,:));

        NoP=size(OFT_Tristimuli,2);
        OFT_Lstar=zeros(1,NoP);

        for patchIndex=1:NoP

            if(OFT_Tristimuli(2,patchIndex)/OFT_White(2)>(216/24389))

                OFT_Lstar(patchIndex)=116*((OFT_Tristimuli(2,patchIndex)./OFT_White(2)).^(1/3))-16;

            else

                OFT_Lstar(patchIndex)=24389/27*(OFT_Tristimuli(2,patchIndex)./OFT_White(2));

            end

        end;

        % if(OFT_Tristimuli(2,:)/OFT_White(2)>(216/24389))
        % 
        %     OFT_DispTitle('root')
        %     OFT_Lstar=116*((OFT_Tristimuli(2,:)./OFT_White(2)).^(1/3))-16;
        % 
        % else
        % 
        %     OFT_DispTitle('lin')
        %     OFT_Lstar=24389/27*(OFT_Tristimuli(2,:)./OFT_White(2));
        % 
        % end

        OFT_ustar=13*OFT_Lstar.*(OFT_u-OFT_uw);
        OFT_vstar=13*OFT_Lstar.*(OFT_v-OFT_vw);

        out=...
            [OFT_Lstar;
            OFT_ustar;
            OFT_vstar];

        end
        
    end
end