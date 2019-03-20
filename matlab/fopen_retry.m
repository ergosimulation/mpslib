% fopen_retry: Retry opening file for writing until sucecssfull
%              a replacement for fopen
%
% Call:
%    fid=fopen_retry(filename,options,t_pause,N_max);
%   
%    filename: file to open
%    options: e.g. 'w','r',....
%    t_pause(1): pause in second after failure to open handle
%    N_max(10): Number of tries....
%
% See also fopen
%
function fid=fopen_retry(filename,options,t_pause,N_max);
if nargin<2, options='w';end
if nargin<3, t_pause=1;end
if nargin<4, N_max_try=10;end


fid=-1;
i=0;
while fid<0
    i=i+1;    
    fid=fopen(filename,options);
    
    
    if i==N_max_try
        disp(sprintf('Tried to open %s %d times with no luck :/',filename,i))
        break;
    end
    
    if fid<0    
        disp(sprintf('failed to open handle for ''%s'' (%d time) trying again',filename,i));
        t_pause=4*exp(i-N_max_try);
        pause(t_pause);
    end
    
    
end





