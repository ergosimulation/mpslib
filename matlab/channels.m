% channels : 2D [250x250] training image
% from Strebelle (2000)
function d=channels(di,keepall);
if nargin<1;di=1;end
if nargin<2;keepall=0;end

%%
d=load('channels.mat');
d=d.channels;
[ny,nx]=size(d);
if di<1;
    % rescale
    x=1:nx;
    y=1:ny;
    [xx,yy]=meshgrid(x,y);
    
    
    x2=1:di:nx;
    y2=1:di:ny;
    [xx2,yy2]=meshgrid(x2,y2);
    
    
    d = griddata(xx(:),yy(:),d(:),xx2,yy2,'nearest');
elseif di>1
    d_org = d;
    nx_new=length([di:di:nx]);
    ny_new=length([di:di:ny]);
    
    if keepall==1;
        nz_new=di*di;
        d=zeros(ny_new,nx_new,nz_new);
        iz=0;
        for ix=1:di
            for iy=1:di
                iz=iz+1;
                d(:,:,iz)=d_org(iy+[di:di:ny]-di,ix+[di:di:nx]-di);
            end
        end
    else
        d=d_org([di:di:ny],[di:di:nx]);
    end
    
    
    
end