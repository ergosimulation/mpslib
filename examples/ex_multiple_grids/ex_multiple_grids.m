% ex_multiple_grid: Demonstrate using multiple grids  mps_snesim_tree
clear all;close all

% load training image
TI=read_eas_matrix('ti.dat');

% setup simulation grid
x=1:1:90;nx=length(x);
y=1:1:95;ny=length(y);
SIM=ones(ny,nx).*NaN;;

%% Uncodtional simulation using mps_snesim_tree with different 
%  number of multiple grids and conditioning data-
O.method='mps_snesim_tree'; 
%O.method='mps_genesim'; 
O.n_real=1;
O.rseed=1;
O.debug=1;

O.shuffle_simulation_grid=0; % sequential/unilateral
%O.shuffle_simulation_grid=1; % random

nmg=[0,1,2,3];ni=length(nmg);
nc =[3^2, 4^2, 5^2, 6^2, 8^2, 9^2];nj=length(nc);

for i=1:length(nmg);
for j=1:length(nc);
    temp_size=sqrt(nc(j));
    O.template_size=[temp_size temp_size 1]; 
    O.n_cond = nc(j);
    O.n_multiple_grids=nmg(i);
    O.parameter_filename=sprintf('mps_snesim_nmg%02d_ts%02d.txt',O.n_multiple_grids,O.template_size(1));
    [reals,O]=mps_cpp(TI,SIM,O);
    
    subplot(ni,nj,j+(i-1)*nj);
    imagesc(x,y,reals(:,:,1)');
    set(gca,'FontSize',5)
    axis image
    title(sprintf('NMG=%d, TS=%d, t=%3.1fs',O.n_multiple_grids,O.template_size(1),O.time),'FontSize',6)
    drawnow;
end
end
print('-dpng',sprintf('ex_multiple_grids_shuffle%d',O.shuffle_simulation_grid))