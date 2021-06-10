% cmap_linear : computes a linear cmap arrary between at certain intervals
%
% cmap=cmap_linear(colors,levels,n)
%
%   colors [ncolors,3] -- def:[1 0 0;1 1 1;0 0 1]; % red-white-blue
%   levels [1,ncolors] -- def:[]
%   n [1] -- number of rows in the colormap, def:[64]
% Example
%    % red-white-blue 
%    cmap = cmap_linear; % red-white-blue
%           cmap_linear([1 0 0;1 1 1;0 0 1])
%
%    % red-80%purewhite-blue
%    cmap = cmap_linear([1 0 0;1 1 1;1 1 1;0 0 1],[0 .1 .9 1]);
%
%    % Yellow,Black,Turqoise
%    cmap= colormap(cmap_linear([1 1 0; 0 0 0; 0 1 1])); % Yellow,Black,Turqoise
%
% TMH/2011
%
function [cmap,levels]=cmap_linear(colors,levels,n)

if nargin<3, n=2*64+1;end
if nargin<1, colors=[1 0 0;1 1 1;0 0 1];end


nc=size(colors,1);
if nargin<2,levels=[];end
if isempty(levels);
    levels=linspace(1/n,1,nc);
end


if (levels(1)<1/n); levels(1)=1/n; end

cmap=zeros(n,3);
icol=ceil(levels*n);
for i=1:(nc-1);
    i1=icol(i);
    i2=icol(i+1);
    c=zeros(i2-i1+1,3);
    for j=1:3;
        c(:,j)=linspace(colors(i,j),colors(i+1,j),i2-i1+1);
    end  
    cmap(i1:i2,:)=c;
end
    
    





