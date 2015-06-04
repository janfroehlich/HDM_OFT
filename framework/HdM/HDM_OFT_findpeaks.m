function [peakamps,peaklocs,peakwidths,resid] = ...
  HDM_OFT_findpeaks(data,npeaks,minwidth,maxwidth,minpeak,debug);
%FINDPEAKS Find up to npeaks interpolated peaks in data.
%
%  [peakamps,peaklocs,peakwidths,resid] =
%     findpeaks(data,npeaks,minwidth,maxwidth,minpeak,debug);
%
%       finds up to npeaks interpolated peaks in real data.
%       A peak is rejected if its width is
%         less than minwidth samples wide(default=1), or
%         less than minpeak in magnitude (default=min(data)).
%       Quadratic interpolation is used for peak interpolation.
%       Left-over data with peaks removed is returned in resid.
%       Peaks are returned in order of decreasing amplitude.
%         They can be sorted in order of location as follows:
%           [peaklocs,sorter] = sort(peaklocs);
%           amps = zeros(size(peakamps));
%           npeaks = length(peaklocs);
%           for col=1:npeaks,
%             amps(:,col) = peakamps(:,sorter(col));
%           end;
%         They can be sorted in order of width as follows:
%           [peakwidths,sorter] = sort(peakwidths);
%           peakamps = peakamps(sorter);
%           peaklocs = peaklocs(sorter);

len = length(data);

if nargin<6,
  debug = 0;
end;

if nargin<5,
 minpeak = min(data);
end;

if nargin<4,
 maxwidth = 0;
end;

if nargin<3,
 minwidth = 1;
end;

if nargin<2,
 npeaks = len;
end;

peakamps = zeros(1,npeaks);
peaklocs = zeros(1,npeaks);
peakwidths = zeros(1,npeaks);
if debug, peaksarr = 1.1*max(data)*ones(size(data)); end;
if debug, orgdata = data; end;
if debug, npeaks, end

nrej = 0;
pdebug=debug;
ipeak=0;
while ipeak<npeaks
 [ploc, pamp, pcurv] = maxr(data);
 if (pamp==minpeak), warning('findpeaks:min amp reached');
        break;
 end
 plocq = round(ploc);
 ulim = min(len,plocq+1);
 camp = pamp;
 %
 % Follow peak down to determine its width
 %
 drange = max(data) - minpeak; % data dynamic range
 tol = drange * 0.01;
 dmin = camp;
 while ((ulim<len) & (data(ulim)<=dmin+tol)),
   camp = data(ulim);
   ulim = ulim + 1;
   if (camp<dmin), dmin=camp; end
 end;
 ulim = ulim - 1;
 lamp = camp;

 llim = max(1,plocq-1);
 camp = pamp;
 dmin = camp;
 while ((llim>1) & (data(llim)<=dmin+tol)),
   camp = data(llim);
   llim = llim - 1;
   if (camp<dmin), dmin=camp; end
 end;
 llim = llim + 1;
 uamp = camp;
 %
 % Remove the peak
 %
 data(llim:ulim) = min(lamp,uamp) * ones(1,ulim-llim+1);
 %
 % Reject peaks which are too narrow (indicated by zero loc and amp)
 %
 pwid = ulim - llim + 1;
 if ~(pwid < minwidth),
   ipeak = ipeak + 1;
   peaklocs(ipeak) = ploc;
   peakamps(ipeak) = pamp;
   peakwidths(ipeak) = - 1/pcurv; % Formerly pwid 6/13/00/jos
   nrej = 0;
   if pdebug>1
      peaksarr(plocq) = pamp;
      maxloc = min(len,2*round(max(peaklocs)));
      ttl = sprintf(...
        'Peak %d = %0.2f at %0.2f, width %d',ipeak,pamp,ploc,pwid);
      if x == -1
        pdebug = 0;
      end
   end
 else
   nrej = nrej + 1;
   if (nrej >= 10),
     warning('*** findpeaks: giving up (10 rejected peaks in a row)');
     break;
   end;
 end;
end;
if (ipeak<npeaks),
 warning(sprintf(...
   '*** peaks.m: only %d peaks found instead of %d',ipeak,npeaks));
 peakamps = peakamps(1:ipeak);
 peaklocs = peaklocs(1:ipeak);
 peakwidths = peakwidths(1:ipeak);
end;
resid = data;


function [xi,yi,hc] = maxr(a)
%MAXR   Find interpolated maximizer(s) and max value(s)
%       for (each column of) a.
%
%               [xi,yi,hc] = maxr(a)
%
%  Calls max() followed by qint() for quadratic interpolation.
%
   [m,n] = size(a);
   if m==1, a=a'; t=m; m=n; n=t; end;
   [y,x] = max(a);
   xi=x;    % vector of maximizer locations, one per col of a
   yi=y;    % vector of maximum values, one per column of a
   if nargout>2, hc = zeros(1,n); end
   for j=1:n,   % loop over columns
     if x(j)>1, % only support interior maxima
       if x(j)<m,
         [xdelta,yij,cj] = qint(a(x(j)-1,j),y(j),a(x(j)+1,j));
         xi(j) = x(j) + xdelta;
         if nargout>2, hc(j) = cj; end
         if (nargout>1), yi(j) = yij; end
       end;
     end;
   end;

function [p,y,a] = qint(ym1,y0,yp1)
%QINT   Quadratic interpolation of 3 uniformly spaced samples
%
%               [p,y,a] = qint(ym1,y0,yp1)
%
%       returns extremum-location p, height y, and half-curvature a
%       of a parabolic fit through three points.
%       The parabola is given by y(x) = a*(x-p)^2+b,
%       where y(-1)=ym1, y(0)=y0, y(1)=yp1.

    p = (yp1 - ym1)/(2*(2*y0 - yp1 - ym1));
    if nargout>1
     y = y0 - 0.25*(ym1-yp1)*p;
    end;
    if nargout>2
     a = 0.5*(ym1 - 2*y0 + yp1);
    end;