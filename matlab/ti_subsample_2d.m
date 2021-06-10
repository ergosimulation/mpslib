% ti_subsample_2d: Subsamples a 2D image into a coarser image.
%
% Call
%   ti_subsample_2d(TI_in,ds);
%
function TI_out=ti_subsample_2d(TI_in,ds);

if nargin == 1; 
    ds = 2;
end

[ny,nx,nz] = size(TI_in);

if nz>1;
    % 3D TI is treated as a set of 2D images
    for iz=1:nz;
        TI_out_single=ti_subsample_2d(TI_in(:,:,iz),ds);
        if iz==1;
            TI_out=TI_out_single;
        else
            n = size(TI_out,3);
            TI_out(:,:,n+[1:size(TI_out_single,3)]) = TI_out_single;
        end
          
    end
    
    return
end

%%
ix_arr=0:ds:(nx-ds);nx_out = length(ix_arr);
iy_arr=0:ds:(ny-ds);ny_out = length(iy_arr);

nz_out = ds^2;
TI_out = ones(ny_out,nx_out,nz_out);

j=0;
for ix=1:ds
for iy=1:ds
    j=j+1;
    TI_out(:,:,j) = TI_in(iy_arr+iy,ix_arr+ix);
end
end





