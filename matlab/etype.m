% etype: return etype mean, std, and mode from a set of 2 realizations.
%
%    [E,Evar,Emode]=etype(D)
function [E,Evar,Emode]=etype(D)
[ny,nx,nsim]=size(D);
E=zeros(ny,nx);
for i=1:nsim
    E=E+D(:,:,i);
end
E=E./nsim;


if nargout>1,
    Evar=zeros(ny,nx);
    for iy=1:ny
        for ix=1:nx
            Evar(iy,ix)=var(squeeze(D(iy,ix,:)));
        end
    end
end

if nargout>2,
    Emode=zeros(ny,nx);
    for iy=1:ny
        for ix=1:nx
            d=(squeeze((D(iy,ix,:))));
            unique_d=unique(d);
            if length(unique_d)==1
                unique_d=[unique_d-1 unique_d];
            end
            [h,hx]=hist(d,unique_d);
            ih=find(h==max(h));ih=ih(1);
            Emode(iy,ix)=hx(ih);
        end
    end
end


