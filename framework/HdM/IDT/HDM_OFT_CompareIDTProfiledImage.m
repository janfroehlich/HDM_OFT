function HDM_OFT_CompareIDTProfiledImage(OFT_In_ReferenceImage2View, OFT_In_TransformedImage2View)

OFT_Env=HDM_OFT_InitEnvironment();

HDM_OFT_Utils.OFT_DispTitle('compare transformed image');

outputVideo = VideoWriter(fullfile(OFT_Env.OFT_ProcessPath,'Eval2Reference.avi'));
outputVideo.FrameRate = 24;
open(outputVideo);

oft_pixNorm=1/(2^8-1);
if(isa(OFT_In_TransformedImage2View,'uint16'))%//!!!
    oft_pixNorm=1/(2^16-1);
end

OFT_ImageOriginalDouble1Base=oft_pixNorm*double(OFT_In_TransformedImage2View);
OFT_ImageOriginalOrgDouble1Base=oft_pixNorm*double(OFT_In_ReferenceImage2View);

for ii = 1:2
    for pulse=1.0:-0.1:0
        writeVideo(outputVideo,pulse*OFT_ImageOriginalOrgDouble1Base+(1-pulse)*OFT_ImageOriginalDouble1Base);
    end
    for pulse=0:0.1:1.0
        writeVideo(outputVideo,pulse*OFT_ImageOriginalOrgDouble1Base+(1-pulse)*OFT_ImageOriginalDouble1Base);
    end
end

close(outputVideo);

implay(fullfile(OFT_Env.OFT_ProcessPath,'Eval2Reference.avi'));

% shuttleAvi = VideoReader(fullfile(OFT_Env.OFT_ProcessPath,'Eval2Reference.avi'));
% mov(shuttleAvi.NumberOfFrames) = struct('cdata',[],'colormap',[]);
% for ii = 1:shuttleAvi.NumberOfFrames
%     mov(ii) = im2frame(read(shuttleAvi,ii));
% end
% 
% figure
% set(gcf,'position', [100 500 shuttleAvi.Width shuttleAvi.Height])
% set(gca,'units','pixels');
% set(gca,'position',[0 0 shuttleAvi.Width shuttleAvi.Height])
% image(mov(1).cdata,'Parent',gca);
% axis off;
% movie(mov,5,shuttleAvi.FrameRate);

HDM_OFT_Utils.OFT_DispTitle('compare transformed image succesfully finished');

end
