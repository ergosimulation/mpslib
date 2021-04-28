function H=entropy_2d(P);

[ny,nx,nc]=size(P);

for ix=1:nx;
for iy=1:ny;
    H(iy,ix)=entropy(P(iy,ix,:),nc);
end
end

    