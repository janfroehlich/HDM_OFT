function OFT_Out_ImageCos4Corrected=HDM_OFT_Cos4Correction(OFT_In_Image,OFT_In_f,OFT_In_d)

OFT_Env=HDM_OFT_InitEnvironment();

if(exist('OFT_In_Image','var')==0)
    disp('using default linearization');
    OFT_Image='F:\usr\fuchs\OFTP\002Development\MatLab\testData\IndustryCameraMeasurements\20141208\ClientDataSample\0CC9E082-69AF-44ED-A057-1C6B09E4E404/light_2015-02-27-170428-0002.tif';
    OFT_Image=imread(OFT_Image);
    
    f=6;%mm
    d=6;%mm 7,4 micrometer
else
    OFT_Image=OFT_In_Image;
    f=OFT_In_f;
    d=OFT_In_d;
end

HDM_OFT_Utils.OFT_DispTitle('start cos4 correction');

% C0 = par(1);
% u0 = par(2);
% v0 = par(3);
% f = par(4);
% gamma = 1;

%[u,v] = meshgrid(1:size(OFT_Image,1),1:size(OFT_Image,2));
%flat_img = C0*cos( atan( ((u-u0).^2 + (v-v0).^2).^.5 / f) ).^gamma;

OFT_Out_ImageCos4Corrected=OFT_Image;

centerRow=size(OFT_Out_ImageCos4Corrected,1)/2;
centerColumn=size(OFT_Out_ImageCos4Corrected,2)/2;

halfDiaDP=sqrt((centerRow)^2+(centerColumn)^2);

for row=1:size(OFT_Out_ImageCos4Corrected,1)
    for column=1:size(OFT_Out_ImageCos4Corrected,2)
        
        curDP=sqrt((row-centerRow)^2+(column-centerColumn)^2);
        curD=(d/2)*curDP/halfDiaDP;
        alpha=atan(curD/f);        
        cos4cor=(cos(alpha))^4;
        
        cos4cor=1/cos4cor;        
        curI=cos4cor*OFT_Out_ImageCos4Corrected(row,column,:);
        OFT_Out_ImageCos4Corrected(row,column,1)=curI(1);
        OFT_Out_ImageCos4Corrected(row,column,2)=curI(2);
        OFT_Out_ImageCos4Corrected(row,column,3)=curI(3);
        
        
%         OFT_Out_ImageCos4Corrected(row,column,1)=cos4cor*((2^8)-1);
%         OFT_Out_ImageCos4Corrected(row,column,2)=cos4cor*((2^8)-1);
%         OFT_Out_ImageCos4Corrected(row,column,3)=cos4cor*((2^8)-1);
    end
end

if(exist('OFT_In_Image','var')==0)
    figure
    subplot(1,2,1),imshow(OFT_Image);
    subplot(1,2,2),imshow(OFT_Out_ImageCos4Corrected);
end

HDM_OFT_Utils.OFT_DispTitle('finish cos4 correction');

end
