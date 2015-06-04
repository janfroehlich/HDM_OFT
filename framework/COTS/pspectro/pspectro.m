%% pspectro: Process Irradiance Data
% This function processes absolute radiometric data (irradiance) with
% dimension $[\mu \mathrm{W} \cdot \mathrm{cm}^{-2}]$ and calculates: 
% 
% * The illuminance (lux) with dimension $[\mathrm{lm}\cdot\mathrm{m}^{-2}]$.
% * The tristimulus values X,Y, and Z (CIE 1931 standard 2deg observer).
% * The correlated color temperature $(T_{c})$ in kelvin.
% * The color rendering indicies $R_{i}$ and the general color rendering index $R_{\mathrm{a}}$ of the test source.
% 
% contact: Matt Aldrich, <http://media.mit.edu/resenv/lighting/>


%%
function [XYZ2deg,ispd,lux,xyz2deg,cct,duv,Ra,R] = pspectro(mspd,~)
%% Usage
%
% *input*
%%
% * The input vector |mspd| is of dimension (m,2) where the first column
% contains the x-axis (nanometers) and the second column contains the
% irradiance data $[\mu \mathrm{W} \cdot
% \mathrm{cm}^{-2}]$ to be processed.
%%
% *output*
%%
% * |output: [XYZ2deg,ispd,lux,xyz2deg,cct,duv,Ra,R]|
% * |XYZ2deg: Tristimulus vector of dimension [1,3] of the form [X Y Z].|
% * |ispd: 1nm interpolated version of the input of form [nm,data].|
% * |lux: the irradiance data weighted by the photopic efficiency function.|
% * |xyz2deg: the x, y, and z projection onto CIE 1931 chromaticity space of form [x y z].|
% * |cct: the correlated color temperature of the input source.|
% * |duv: the distance from the blackbody curve for the color temperature.|
% * |Ra: the CRI of the source of size [15,1].|
% * |R: the individual scores of the index.|
%%
% A example of |mspd| could be:
%%
%   380.0000    0.0344
%   430.0000    0.8370
%   480.0000    0.5570
%   530.0000    2.7031
%   580.0000    1.5260
%   630.0000    3.8860
%   680.0000    0.3056
%   730.0000    0.0600
%   780.0000    0.0139

%% Function Description
% pspectro calls multiple functions to calculate these parameters.
%%
% The value of |range| should not be changed, it specifies the range over which the data
% is integrated (visible range). The value |unitconversion| can be modified
% to accomodate a different a different scaling of |mspd|.  
range = 380:1:780;
unitconversion = (1e-6/.0001); %convert [uW / cm ^ 2] -> [W / m ^ 2]

%% |ispd|
% The function |interpolatespd| linearly interpolates the input. It is then
% available as an output.
ispd = interpolatespd(mspd,range);

%% |getlux|
% The function |getlux| integrates the irradiance with the luminous
% efficiency function $V(\lambda)$ to calculate illuminance. The
% $V(\lambda)$ used here is the CIE 2-deg photopic luminosity curve (1924)
% available at <http://cvision.ucsd.edu/>. The relative spectral power of
% the color matching variable $\overline{y}$ can also be used to calculate
% the total lux (see function |getristimulus2deg|).
%
% The lux calculation uses the irradiance $(E_{e,\lambda})$ and performs a
% scalar multiplication with $V(\lambda)$ such that:
%
% $$E_{v} = k\sum_{380}^{780}E_{e,\lambda} V(\lambda)\Delta\lambda,$$
%
% where $k = 683 \,\mathrm{lm} \cdot W^{-1}$.
%
% The constant k represents the peak photopic sensitivity of the eye. The
% luminosity function is graphed below.
%% 
% <<cie1924luminouseff.png>>
%%
lux = getlux(interpolatespd([mspd(:,1) mspd(:,2).*unitconversion],range),range);
%% |getristimulus2deg|
% The function |gettristimulus2deg| integrates the irradiance with the
% color matching functions of the CIE 1931 standard 2 degree observer and
% weights them such that the output Y of |XYZ2deg| is in the lux. These
% color matching functions can be obtained freely from the CIE website:
% <http://www.cie.co.at/>. Alternatively, consult this webpage for additional
% observers and updated data <http://cvision.ucsd.edu/>.
%
% The tristimulus values are calculated using the measured irradiance 
% according to the following equations:
%
% $$X = k\sum_{380}^{780}E_{e,\lambda}\overline{x}(\lambda)\Delta\lambda,$$
%
% $$Y = k\sum_{380}^{780}E_{e,\lambda}\overline{y}(\lambda)\Delta\lambda,$$
%
% $$Z = k\sum_{380}^{780}E_{e,\lambda}\overline{z}(\lambda)\Delta\lambda.$$
%
% where $k = 683 \,\mathrm{lm} \cdot W^{-1}$. Alternatively, the
% constant could be specified such that the values were normalized to Y. In
% this case,
%
% $$k = 100 /
% \sum_{380}^{780}P{(\lambda})\overline{y}(\lambda)\Delta\lambda$$
%
% To edit the file, directly open and modify the |gettristimulus2deg|
% function.
%%
% <<cie1931std2deg.png>>
%%
XYZ2deg = gettristimulus2deg(interpolatespd([mspd(:,1) mspd(:,2).*unitconversion],range),range);

%% |getxyz|
% The function |getxyz| projects the [X,Y,Z] trimstimlus values onto
% two-dimensional chromaticity space (CIE 1931).
%
% These coordinates are calculated as:
%
% $$x = \frac{X}{X+Y+Z},$$
%
% $$y = \frac{Y}{X+Y+Z}.$$
%
xyz2deg = getxyz(XYZ2deg);
%% |xytouv|
% The function |xytouv| converts the (x,y) coordinate in (u,v) in the CIE
% 1960 Uniform Color Space.
%
% These coordinates are calculated as:
%
% $$u = \frac{4x}{-2x+12y+3},$$
%
% $$v = \frac{6y}{-2+12y+3}.$$
%
uv2deg = xytouv(xyz2deg);
%% |getuvbbCCT|
% The function |getuvbbCCT| uses a table of (u,v) that correspond to a
% correlated color temperature using a resolution of 1 kelvin. The table
% was generated using a Plankian Radiator and projecting the resulting data
% onto CIE 1964 space (e.g, the blackbody curve was generated for all
% possible CCT at 1 kelvin resolution).  
[cct duv] = getuvbbCCT(uv2deg(end,[1 2]));
%% |getbbradiator|
% To calculate the CRI of the source, an ideal test source must be created.
% If the CCT of the source is below 5000 K, then |getbbradiator| is called and an ideal blackbody
% radiator is used as a reference. 
%
% To generate the reference spectrum, Planck's law is applied.  The
% following equation is used to calculate the spectrum:
%
% $$I(v,T) = \frac{c_{1}}{\lambda^{5}} [\mathrm{exp}(c_{2}/(\lambda T))-1]^{-1},$$
%
% where $c_{1} = 3.7418 \times 10^{-16} \, [\mathrm{W} \cdot \mathrm{m}^{-2}]$ and $c_{2} = 1.4388 \times 10^{-2} \,[\mathrm{mK}].$ The desired color
% temperature $T$ and the range $\lambda$ are set according to the
% correlated color temperature $T_{c}$ and range (typically 380nm -
% 780nm).
%
% The reference source is normalized to 560 nm in the final step. An
% example of the function's output is given below for a blackbody radiator
% with $T = 2800\,\mathrm{K}$.
%%
% <<planckianradiator.png>>
%% |getdilluminantspd|
% If the test source has a CCT greater
% than 5000 K then a daylight simulator is used as a reference (function
% |getdilluminantspd|). 
%
% 
%
% The spectral output of daylight can be obtained by the following equation
%
% $$S_{D}(\lambda) = S_{0}(\lambda) + M_{1}S_{1}(\lambda) +
% M_{2}S_{2}(\lambda)$$
%
% The eigenvectors $S_{0}(\lambda)$, $S_{1}(\lambda)$, and $S_{2}(\lambda)$
% can be obtained freely at the CIE website <http://www.cie.co.at/>.
%
% Obtaining $S_{D}(\lambda)$ requires two steps. In the first step
% $x_{D}$ and $y_{D}$ are calculated. In the second step, $x_{D}$ and
% $y_{D}$ are used to calculate $M_{1}$ and $M_{2}$.  First, calculate 
% $x_{D}$ and $y_{D}$   
%
% When $4000\,K \leq T_{c} \leq 7000\,K$ 
%
% $$x_{D} = -4.6070 \times 10^{9}/T_{c}^{3} + 2.9678 \times
% 10^{6}/T_{c}^{2} + 0.09911 \times 10^{3} / T_{c} + 0.244063$$
%
% When $7000\,K \leq T_{c} \leq 25000\,K$ 
%
% $$x_{D} = -2.0064 \times 10^{9}/T_{c}^{3} + 1.9081 \times
% 10^{6}/T_{c}^{2} + 0.24748 \times 10^{3} / T_{c} + 0.237040$$
%
% The other coordinate, $y_{D}$ is expressed by
%
% $$y_{D} = -3.000 x_{D}^{2} + 2.870_x{D} - 0.275$$
%
% In the second step, calculate $M_{1}$ and $M_{2}$ such that:
%
% $$M_{1}=(-1.3515 - 1.7703x_{D} + 5.9114y_{D}) / (0.0241 + 0.2562x_{D} -0.7341y_{D})$$ 
% 
% $$M_{2}=(0.0300 - 31.442x_{D} + 30.0717y_{D}) / (0.0241 + 0.2562x_{D}
% -0.7341y_{D})$$ 
%
% Using $M_{1}$ and $M_{2}$, we can apply the following equation using
% $S_{0}(\lambda)$, $S_{1}(\lambda)$ and, $S_{2}(\lambda)$.
%
% $$S_{D}(\lambda) = S_{0}(\lambda) + M_{1}S_{1}(\lambda) +
% M_{2}S_{2}(\lambda)$$ 
%
% An example $S_{D}(\lambda)$ for $T_{c} = 6500\,$ normalized at 560nm is given below:
%%
% <<daylightsimulator.png>>
%%
if cct <= 5000
    nrefspd = getrelativespd(getbbradiator(cct,range),range,560);
elseif cct > 5000
    nrefspd = getrelativespd(getdilluminantspd(cct,range),range,560);
end
%% |getcri1995|
% The function |getcri1995| computes $R_{i}$ where i is the index of the 15
% samples used to compute the average $R_{a}$ of the test source. The
% reflectance of the fifteen color samples is graphed below:
%%
% <<ciereflectance.png>>
%
% The calculation begins by first finding the normalized tristimulus values
% of the reflecting color samples designated by subscript i for $i = 1,2,\,{}_{\cdots}\,15$ under the reference spectra $(P_{\lambda})$  and test spectra $(E_{\lambda})$. 
% Thus, the tristimulus values of the reference source are:
%
% $$X_{\mathrm{r},i} = k_{r} \sum_{380}^{780}P_{\lambda}R_{\lambda,i}\overline{x}(\lambda)\Delta\lambda,$$
%
% $$Y_{\mathrm{r},i} = k_{r} \sum_{380}^{780}P_{\lambda}R_{\lambda,i}\overline{y}(\lambda)\Delta\lambda,$$
%
% $$Z_{\mathrm{r},i} = k_{r} \sum_{380}^{780}P_{\lambda}R_{\lambda,i}\overline{z}(\lambda)\Delta\lambda.$$
%
% The tristimulus values for the test source are:
%
% $$X_{\mathrm{t},i} = k_{t}\sum_{380}^{780}E_{\lambda}R_{\lambda,i}\overline{x}(\lambda)\Delta\lambda,$$
%
% $$Y_{\mathrm{t},i} = k_{t}\sum_{380}^{780}E_{\lambda}R_{\lambda,i}\overline{y}(\lambda)\Delta\lambda,$$
%
% $$Z_{\mathrm{t},i} = k_{t}\sum_{380}^{780}E_{\lambda}R_{\lambda,i}\overline{z}(\lambda)\Delta\lambda.$$
%
% where $P_{\lambda}$ is the relative power for the reference source, $E_{\lambda}$ is the measured irradiance of the test source, $R_{\lambda}$ is the 
% tabulated reflectance of the current color sample, and $\overline{x}$, $\overline{y}$, and
% $\overline{z}$
% are the color matching functions of a the standard observer.  For both
% the reference and test spectra (the function inputs), k
% is calculated for a perfect diffuse reflector (e.g., the $R_{\lambda}$ 
% term is one).  
%
% For both sources, k is found according to the following equations:
%
% $$k_{r} = 100 /
% \sum_{380}^{780}P_{\lambda}\overline{y}(\lambda)\Delta\lambda$$
%
% $$k_{t} = 100 /
% \sum_{380}^{780}E_{\lambda}\overline{y}(\lambda)\Delta\lambda
% $$
%
% Where the subscripts $\mathrm{r}$ and $\mathrm{t}$ denote the reference and test source
% respectively.
%
% In the second step, the previously calculated tristiumlus values of the fifteen color samples
% illuminanted under both the reference and test sources are mapped to
% CIE 1960 uv space. (see function |getxyz| and |xytouv|.) Once these
% equations are applied we obtain $(u_{r},v_{r})$ and $(u_{t},v_{t})$, the uv coordinates of the
% reference source and test source in CIE 1964 UCS, respectively.
%
% Next, the sample is chromatically adapted according to the Von Kries
% equations.  
%
% Here the reference source uv coordinates, the test source uv coordinates,
% and the uv coordinates of the color samples illuminated by the test
% source are converted to coefficicents c and d according to
%
% $$c = (4 - u - 10v)/v$$
%
% and
%
% $$d = (1.708v + 0.404 - 1.481u) / v$$
%
% We designate $c_{\mathrm{r}}$ and $d_\mathrm{r}$ to refer to the cd calculation for the
% reference source.  Similarly, $c_\mathrm{t}$ and $d_\mathrm{t}$ refer to the test
% source.  Finally, we reserve $c_{\mathrm{t},i}$ and $d_{\mathrm{t},i}$ to
% designate the converted uv coordinates of the test samples as illuminated
% by the test source.  The subscript $i$ refers to the 15 samples
% calculated.
%
% To indicate that a uv coordinate has been chromatically adapted we
% indicate it using a prime (i.e., ${u_{\mathrm{t}}}'$ and ${v_{\mathrm{t}}}'$). To take into
% account the adaptive color shift we apply the following equations:
%
% $${u_{\mathrm{t}}}' = u_{\mathrm{r}}$$
%
% $${v_{\mathrm{t}}}' = v_{\mathrm{r}}$$
%
% $${u_{\mathrm{t},i}}' = (10.872 + 0.404
% c_{\mathrm{r}}c_{\mathrm{t},i}/c_{\mathrm{t}} -
% 4d_{\mathrm{r}}d_{\mathrm{t},i}/d_{\mathrm{t}}) /
% (16.518 + 1.481c_{\mathrm{r}}c_{\mathrm{t},i}/c_{\mathrm{t}} - d_{\mathrm{r}}d_{\mathrm{t},i}/d_{\mathrm{t}})$$
%
% $${v_{\mathrm{t},i}}' = 5.520 / (16.518 + 1.481 c_{\mathrm{r}}
% c_{\mathrm{t},i} / c_{t} -
% d_{\mathrm{r}}d_{\mathrm{t},i}/d_{\mathrm{t}})$$
%
% To clarify the terms $u_{\mathrm{r}}$ and $v_{\mathrm{r}}$ refer to the
% $(u_{r},v_{r})$ coordinate calculated earlier.  
%
% Once the samples and test source have been adapted, the color difference
% between the samples is calculated according to CIE 1964 UVW space
% (*CIEUVW*) such that:
%
% $${W_{\mathrm{r},i}}^{*} = 25(Y_{\mathrm{r},i})^{1/3}-17$$
%
% $${U_{\mathrm{r},i}}^{*} = 13 {W_{\mathrm{r},i}}^{*} (u_{\mathrm{r},i} - u_{r})$$
%
% $${V_{\mathrm{r},i}}^{*} = 13 {W_{\mathrm{r},i}}^{*} (v_{\mathrm{r},i} -
% v_{r})$$
%
% $${W_{\mathrm{t},i}}^{*} = 25(Y_{\mathrm{t},i})^{1/3}-17$$
%
% $${U_{\mathrm{t},i}}^{*} = 13 {W_{\mathrm{t},i}}^{*} ({u_{\mathrm{t},i}}' - u_{t})$$
%
% $${V_{\mathrm{t},i}}^{*} = 13 {W_{\mathrm{t},i}}^{*} ({v_{\mathrm{t},i}}' -
% v_{t})$$
%
% for $i = 1,2,\,{}_{\cdots}\,15.$  
%
% Again, for reference, the chromatically
% adapted samples illuminated using the test source are designated 
% ${u_{\mathrm{t},i}}'$ and ${v_{\mathrm{t},i}}'$.  The terms
% $u_{\mathrm{r},i}$ and $v_{\mathrm{r},i}$ are the uv coordinates of the
% samples illuminated under the reference source.
%
% The color difference is then calculated according to
%
% $$\Delta E_{i} = ({U_{\mathrm{r},i}}^{*} - {U_{\mathrm{t},i}}^{*})^{2} +
% ({V_{\mathrm{r},i}}^{*} - {V_{\mathrm{t},i}}^{*})^{2} +
% ({W_{\mathrm{r},i}}^{*} - {W_{\mathrm{t},i}}^{*})^{2}$$ 
%
% The color rendering indices R_{i} for each of the color samples are
% obtained using
%
% $$R_{i} = 100 - 4.6 \Delta E_{i}$$ 
%
% and the general color rendering index $R_{\mathrm{a}}$ is given as the
% average of the first eight samples:
%
% $$R_{\mathrm{a}} =  (\sum_{i=1}^{8} R_{i})/8$$
%
[Ra R] = getcri1995(ispd,nrefspd,range);

%% Sample Usage
% A demo of this function can be performed by loading |demo.mat| and typing 
%
% |>> [XYZ2deg,ispd,lux,xyz2deg,cct,duv,Ra,R] = pspectro(result)|
%
% Suppose a source is measured with the following irradiance:
%%
% <<tsirradiance.png>>
%%
% and the vector |result| contains the measured data of form
% [nm,irradiance].  We call
%
% |>> [XYZ2deg,ispd,lux,xyz2deg,cct,duv,Ra,R] = pspectro(result)|
% 
% |XYZ2deg =|
% 
%   1.0e+003 *
% 
%     1.4886    1.5000    1.1371
% 
% 
% |ispd = [omitted here]|
% 
%
% |lux =|
% 
%   1.5000e+003
% 
% 
% |xyz2deg =|
% 
%     0.3608    0.3636    0.2756
% 
% 
% |cct =|
% 
%         4500
% 
% 
% |duv =|
% 
%   1.7554e-016
% 
% 
% |Ra =|
% 
%    64.4896
% 
% 
% |R =|
% 
%    58.6969
%    85.1930
%    86.3655
%    45.1539
%    58.3774
%    74.2449
%    73.4934
%    34.3917
%   -50.1813
%    55.8588
%    24.7698
%    68.5544
%    64.8323
%    91.0630
%    56.3256
%% About
% Author: Matt Aldrich 
%
% www: <http://media.mit.edu/resenv/lighting>
%% References
%
% Wyszecki, G. & Stiles, W. S. Color Science : Concepts and Methods,
% Quantitative Data and Formulae. Wiley New York, 1982
%
% Ohta, N. & Robertson, A. Colorimetry: fundamentals and applications. Wiley New York, 2005
