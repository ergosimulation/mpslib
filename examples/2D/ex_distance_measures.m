clear all;close all

%% TI
TId=read_eas_matrix('channels.ti');

%% Simulation grid
[ny,nx]=size(TId);
%nx=100;ny=50;
x=1:1:nx;
y=1:1:ny;
SIM=ones(ny,nx).*NaN;


%% MPS parameters
O.n_real=1;            
O.n_max_cpdf_count=1;
O.n_max_ite=1e+9;
O.debug=2;
O.n_cond=49;
O.template_size=[20 20 1];
O.method='mps_genesim'; 
O.shuffle_simulation_grid=1;
O.debug=0;

%% Test effect of distance measure
O.distance_measure=1;
distance_min=[0, 0.05, 0.1, 0.2, 0.5];
distance_pow=[0, 0.25,.5, 1, 2];
clear reals
subfigure(1,1,1)
k=0;
for i=1:length(distance_min)
for j=1:length(distance_pow)
    k=k+1;
    O.distance_min=distance_min(i);
    O.distance_pow=distance_pow(j);
    
    [reals{i,j},Oo{i,j}]=mps_cpp(TId,SIM,O);
    mps_cpp_clean(Oo{i,j})
    
    subplot(length(distance_min),length(distance_pow),k);cla;drawnow;
    imagesc(reals{i,j});axis image;caxis([0 1])
    title(sprintf('dis=[%g,%g,%g] t=%3.2fs',O.distance_measure,O.distance_min,O.distance_pow,Oo{i,j}.time))
    colormap(gray)
    drawnow    
end
end
print_mul(sprintf('distance measure %d',O.distance_measure))

