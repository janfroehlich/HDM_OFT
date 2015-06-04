function ImgOut = sim_alexa( ImgIn , Mode , EI )
%Simulation der ARRI Alexa
%   Img : Image to convert. 
%         Range of Image 0-1
%         Range of Scene: 0.18 = 18%Grey - 1.0 = Perfect white diffuser
%   Mode:
%   EI  :

%% Debug:
% EI = 800;
%
%%

SL2LogC.EI = [160 200 250 320 400 500 640 800 1000 1280 1600];
SL2LogC.cut = [0.005561 0.006208 0.006871 0.007622 0.008318 0.009031 0.009840 0.010591 0.011361 0.012235 0.013047];
SL2LogC.a = [5.555556 5.555556 5.555556 5.555556 5.555556 5.555556 5.555556 5.555556 5.555556 5.555556 5.555556];
SL2LogC.b = [0.080216 0.076621 0.072941 0.068768 0.064901 0.060939 0.056443 0.052272 0.047996 0.043137 0.038625];
SL2LogC.c = [0.269036 0.266007 0.262978 0.259627 0.256598 0.253569 0.250219 0.247190 0.244161 0.240810 0.237781];
SL2LogC.d = [0.381991 0.382478 0.382966 0.383508 0.383999 0.384493 0.385040 0.385537 0.386036 0.386590 0.387093];
SL2LogC.e = [5.842037 5.776265 5.710494 5.637732 5.571960 5.506188 5.433426 5.367655 5.301883 5.229121 5.163350];
SL2LogC.f = [0.092778 0.092782 0.092786 0.092791 0.092795 0.092800 0.092805 0.092809 0.092814 0.092819 0.092824];
SL2LogC.UpperClip = [832 854 875 898 918 937 958 976 994 1013 1023 1023 1023 1023];
SL2LogC.UpperClip = SL2LogC.UpperClip/1023;

Sen2LogC.EI = [160 200 250 320 400 500 640 800 1000 1280 1600];
Sen2LogC.cut = [0.004680 0.004597 0.004518 0.004436 0.004369 0.004309 0.004249 0.004201 0.004160 0.004120 0.004088];
Sen2LogC.a = [ 40.0 50.0 62.5 80.0 100.0 125.0 160.0 200.0 250.0 320.0 400.0];
Sen2LogC.b = [-0.076072 -0.118740 -0.171260 -0.243808 -0.325820 -0.427461 -0.568709 -0.729169 -0.928805 -1.207168 -1.524256];
Sen2LogC.c = [0.269036 0.266007 0.262978 0.259627 0.256598 0.253569 0.250219 0.247190 0.244161 0.240810 0.237781];
Sen2LogC.d = [0.381991 0.382478 0.382966 0.383508 0.383999 0.384493 0.385040 0.385537 0.386036 0.386590 0.387093];
Sen2LogC.e = [42.062665 51.986387 64.243053 81.183335 100.295280 123.889239 156.482680 193.235573 238.584745 301.197380 371.761171];
Sen2LogC.f = [-0.071569 -0.110339 -0.158224 -0.224409 -0.299079 -0.391261 -0.518605 -0.662201 -0.839385 -1.084020 -1.359723];

EINr = find(SL2LogC.EI == EI);
if isempty(EINr), error(['Please use one of the following Exposure Indices EI:',num2str(SL2LogC.EI)]); end
if not(SL2LogC.EI == Sen2LogC.EI), error('Sim_ALEXA internal EI Paramter wrong'); end

%%
ImgOut = zeros(size(ImgIn));        
        
switch Mode
    case 'SceneLinear2LogC'
        Index = ImgIn > SL2LogC.cut(EINr);      
        ImgOut(Index) = (SL2LogC.c(EINr) * log10((SL2LogC.a(EINr) * ImgIn(Index)) + SL2LogC.b(EINr))) + SL2LogC.d(EINr);
        ImgOut(not(Index)) = SL2LogC.e(EINr) * ImgIn(not(Index)) + SL2LogC.f(EINr);
        
        ImgOut(ImgOut > SL2LogC.UpperClip(EINr)) = SL2LogC.UpperClip(EINr);
        
    case 'LogC2SceneLinear'
        ImgIn(ImgIn > SL2LogC.UpperClip(EINr)) = SL2LogC.UpperClip(EINr);
        
        Index = ImgIn > (SL2LogC.e(EINr) * SL2LogC.cut(EINr) + SL2LogC.f(EINr));
        ImgOut(Index) = (10.^((ImgIn(Index) - SL2LogC.d(EINr)) / SL2LogC.c(EINr)) - SL2LogC.b(EINr)) / SL2LogC.a(EINr);
        ImgOut(not(Index)) = (ImgIn(not(Index)) - SL2LogC.f(EINr)) / SL2LogC.e(EINr);
        
    case 'LogC2SensorRAW'
        %ImgIn(ImgIn > SL2LogC.UpperClip(EINr)) = SL2LogC.UpperClip(EINr);
        %ImgIn(ImgIn > Sen2LogC.UpperClip(EINr)) = Sen2LogC.UpperClip(EINr);
        
        Index = ImgIn > Sen2LogC.e(EINr) * Sen2LogC.cut(EINr) + Sen2LogC.f(EINr);   
        ImgOut(Index) = (10.^((ImgIn(Index) - Sen2LogC.d(EINr)) / Sen2LogC.c(EINr)) - Sen2LogC.b(EINr)) / Sen2LogC.a(EINr);
        ImgOut(not(Index)) = (ImgIn(not(Index)) - Sen2LogC.f(EINr)) / Sen2LogC.e(EINr);

    case 'SensorRAW2LogC'
        Index = ImgIn > Sen2LogC.cut(EINr);
        ImgOut(Index) = Sen2LogC.c(EINr) * log10(Sen2LogC.a(EINr) * ImgIn(Index) + Sen2LogC.b(EINr)) + Sen2LogC.d(EINr);
        ImgOut(not(Index)) = Sen2LogC.e(EINr) * ImgIn(not(Index)) + Sen2LogC.f(EINr);   
                
        %ImgOut(ImgOut > Sen2LogC.UpperClip(EINr)) = Sen2LogC.UpperClip(EINr);
    otherwise
        error('Mode not supported');
end

end

