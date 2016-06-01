classdef HDM_OFT_SpectrumExportImport
    methods(Static)
        function o_spectrum=ImportSpectrum(i_spectrumFile)

            %% defaults
            l_Env=HDM_OFT_InitEnvironment(); 

            HDM_OFT_Utils.OFT_DispTitle('import spectrum');
            
            try
                
            l_fid = fopen(i_spectrumFile);
            l_out = textscan(l_fid,'%s%s','delimiter','\t');
            fclose(l_fid);

            l_s = size(l_out);
            
            if(l_s(1) == 1 && l_s(2) == 2)
                            
                l_c1 = l_out(1, 1);
                l_c1 = l_c1{1, 1};
                l_c2 = l_out(1, 2);
                l_c2 = l_c2{1, 1};
                
                l_w = [];
                l_i = [];
                
                for cur = 1 : size(l_c1, 1)
                    
                    l_str = l_c1 {cur, 1};
                    
                    if(findstr(l_str,'nm'))
                        
                        l_w = [l_w, str2num(strrep(l_str, 'nm', ''))];
                        l_i = [l_i, str2double(l_c2(cur))];
                        
                    end
                    
                end  
                
                o_spectrum = [l_w; l_i];
                
                l_nmBase=360:1:830;
                o_spectrum = [l_nmBase; interp1(o_spectrum(1,:), o_spectrum(2,:),l_nmBase,'pchip',0)];
                
                return;
                            
            end
            
            catch
            
            ;
                
            end
                      
                      
            [l_p,l_n,l_ext]=fileparts(i_spectrumFile);
            
            if(strcmp(l_ext,'.xls') || strcmp(l_ext,'.xlsx'))
                
                [ndata, text, alldata] =xlsread(i_spectrumFile);
                
                if isempty(text)
                    
                    o_spectrum=ndata(1:2,:);
                    
                else
                    
                    waveLength=strrep(text(1,:), 'nm', '');
                    wvSize=size(waveLength);
                    waveLength2=str2double(waveLength(2:wvSize(2)));
                    o_spectrum = [waveLength2;ndata];
                    
                end
                
                l_nmBase=360:1:830;
                o_spectrum = [l_nmBase; interp1(o_spectrum(1,:), o_spectrum(2,:),l_nmBase,'pchip',0)];
                
            else        
                
                l_csvData = csvread(i_spectrumFile);
                
                
                
                
            end
            
            
        end
    end
end