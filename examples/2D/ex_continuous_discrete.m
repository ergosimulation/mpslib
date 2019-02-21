clear all;close all

%% TI
filename_d = 'channels.dat';
filename_c = 'channels_continuous.dat';
doSmall=1;
if doSmall
    di=4;
    TI_c=read_eas_matrix(filename_c);TI_c=TI_c(di:di:end,di:di:end);
    TI_d=read_eas_matrix(filename_d);TI_d=TI_d(di:di:end,di:di:end);
    filename_d = 'channels_small.dat';
    filename_c = 'channels_small_continuous.dat';
    write_eas_matrix(filename_d, TI_d);
    write_eas_matrix(filename_c, TI_c);
end

figure(1);
subplot(1,2,1);imagesc(TI_c);axis image;title('continuous');colorbar
subplot(1,2,2);imagesc(TI_d);axis image;title('discrete');colorbar
colormap(gray)

%% Simulation grid
[ny,nx]=size(TI_d);
%nx=100;ny=50;
%nx=30;ny=30;
x=1:1:nx;
y=1:1:ny;
SIM=ones(ny,nx).*NaN;


%% MPS parameters
O.n_real=1;            
O.n_max_cpdf_count=1;
O.n_max_ite=1e+9;

O.n_cond=49;
O.template_size=[20 20 1];
O.method='mps_genesim'; 
O.shuffle_simulation_grid=1;
O.debug=0;
O.WriteTI=0;
%O.distance_measure = 0;

%% Test effect of distance measure
% Both a discrete and continuous TI is considered. Change the distance
% measure to analyze it effect.

%O.distance_measure=1; % intended for discrete TIs
O.distance_measure=2; % intended for continuous TIs

distance_min=[0, 0.05, 0.1, 0.2, 0.5];
distance_pow=[0, 0.25,.5, 1, 2];

clear reals* O_*
%subfigure(1,1,1)
k=0;
for i=1:length(distance_min)
for j=1:length(distance_pow)
    k=k+1;
    O.distance_min=distance_min(i);
    O.distance_pow=distance_pow(j);
    O.debug=2;
    O.rseed=2;
    
    O.parameter_filename='mps_genesim_dis.txt';
    O.ti_filename=filename_d;
    [reals_d{i,j},O_d{i,j}]=mps_cpp(TI_d,SIM,O);
    mps_cpp_clean(O_d{i,j})
    
    O.parameter_filename='mps_genesim_con.txt';
    O.ti_filename=filename_c;
    [reals_c{i,j},O_c{i,j}]=mps_cpp(TI_c,SIM,O);
    mps_cpp_clean(O_c{i,j})

    figure(2);subfigure(2,2,1);
    subplot(length(distance_min),length(distance_pow),k);cla;drawnow;
    imagesc(reals_d{i,j});axis image;caxis([0 1])
    title(sprintf('dis=[%g,%g,%g] t=%3.2fs',O.distance_measure,O.distance_min,O.distance_pow,O_d{i,j}.time))
    colormap(gray)
    drawnow    

    figure(3);subfigure(2,2,2);
    subplot(length(distance_min),length(distance_pow),k);cla;drawnow;
    imagesc(reals_c{i,j});axis image;caxis([0 1])
    title(sprintf('dis=[%g,%g,%g] t=%3.2fs',O.distance_measure,O.distance_min,O.distance_pow,O_c{i,j}.time))
    colormap(gray)
    drawnow    

end
end
figure(2);
print_mul(sprintf('distance measure %d - discrete',O.distance_measure))
figure(3);
print_mul(sprintf('distance measure %d - continious',O.distance_measure))

%%
i=2;
j=2;
%mps_cpp_plot(reals_d{i,j},O_d{i,j})
mps_cpp_plot(reals_c{i,j},O_c{i,j})
