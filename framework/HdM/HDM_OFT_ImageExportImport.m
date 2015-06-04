classdef HDM_OFT_ImageExportImport
    methods(Static)
        function OFT_Out_Image=ImportImage(OFT_In_Image,OFT_In_Linearization)

            %% defaults
            OFT_Env=HDM_OFT_InitEnvironment(); 

            HDM_OFT_Utils.OFT_DispTitle('import image');

            if(exist('OFT_In_Image','var')==0)
                disp('using reference image');
                oft_testImageFile='/Alexa/H_20140626_162719_R10D_l.tiff';
                %oft_testImageFile='/Alexa/H_20140626_150821_R10D_l.dpx';
                oft_testImageFile='/Alexa/H_20140625_082202_R10D_l.dpx';
                OFT_Image=strcat(OFT_Env.OFT_RootDataDir,'/cameraImagesReference',oft_testImageFile);
            else
                oft_default=0;
                OFT_Image=OFT_In_Image;
            end

            if(exist('OFT_In_Linearization','var')==0)
                disp('using default linearization');
                OFT_Linearization=strcat(OFT_Env.OFT_RootDataDir,'/linearizationReference/140513_OETF_2K_v1_noIndex.tif');
            else
                OFT_Linearization=OFT_In_Linearization;
            end
            
            [oft_p,oft_n,oft_ext]=fileparts(OFT_Image);
            
            if(strcmp(oft_ext,'.dpx'))
                [oft_dpx_pixels, oft_dpx_details]=readdpx(OFT_Image);
                oft_cvMax=oft_dpx_details.ImageDetails.ImageElementDetailsParsed.ReferenceHighDataCodeValue;
                OFT_Out_Image0=uint16((((2^16)-1)/oft_cvMax))*oft_dpx_pixels;
                
                if(exist('oft_default','var')==0)
                    figure
                        imshow(OFT_Out_Image0);
                end
                
                %oft_dpx_pixels_lin=sim_alexa(double(oft_dpx_pixels)./double(oft_cvMax),'LogC2SceneLinear',400);

                if(exist('oft_default','var')==0)
                    figure
                        imshow(oft_dpx_pixels_lin.^2.4);
                end

                %OFT_Out_Image0=uint16(((2^16)-1)*oft_dpx_pixels_lin);
                
                if(exist('oft_default','var')==0)
                    figure
                        imshow(OFT_Out_Image0);
                end
            
            OFT_Out_Image=OFT_Out_Image0;
                
            else        
                oft_imageData=imread(OFT_Image);
                
                ifInfo=imfinfo(OFT_Image);
                
                if(strcmp(ifInfo.Format,'tif') && ifInfo.SamplesPerPixel==4)
                    
                    OFT_Out_Image=oft_imageData(:,:,1:3);
                    
                    if(isa(oft_imageData,'single'))
                        
                        maxINorm=1/max(OFT_Out_Image(:));
                        
                        OFT_Out_Image=maxINorm*OFT_Out_Image;
                        
                        OFT_Out_Image=im2uint16(OFT_Out_Image);
                        
                    end
                    
                elseif(strcmp(ifInfo.Format,'tif') && ifInfo.SamplesPerPixel==3)
                    
                    if(isa(oft_imageData,'single'))
                        
                        maxINorm=1/max(oft_imageData(:));
                        
                        OFT_Out_Image=oft_imageData;
                        
                        %//!!!OFT_Out_Image=im2uint16(OFT_Out_Image);
                    else
                        
                        OFT_Out_Image=oft_imageData;
                        
                    end
                    
                else
                    
                    OFT_Out_Image=oft_imageData;
                
                end
                
                %oft_dpx_pixels_lin=sim_alexa((1/((2^16)-1))*double(oft_imageData),'LogC2SceneLinear',400);

                %OFT_Out_Image=uint16(((2^16)-1)*oft_dpx_pixels_lin);
            end
                                       
%                     OFT_cameraImageOfTestChart = double(OFT_Out_Image);
%                     [OFT_cameraImageOfTestChart_PatchLocations,OFT_cameraImageOfTestChart_PatchColours] = CCFind(OFT_cameraImageOfTestChart);
%                     visualizecc(OFT_cameraImageOfTestChart,OFT_cameraImageOfTestChart_PatchLocations);
            
            %if(OFT_Linearization)
            
            
        end
    end
end