function H=entropy_2d(P);

[ny,nx,nc]=size(P);

for ix=1:nx;
    for iy=1:ny;
        p = squeeze(P(iy,ix,:));
        i=find(p>0);
        
        %I=-log(p(i));
        I=- log(p(i))./log(nc);
        
        Palt=p(i);
        
        Halt = sum( Palt.*I );
        
        H(iy,ix)=Halt;
    end
end


