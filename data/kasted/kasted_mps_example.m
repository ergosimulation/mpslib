% kasted_mps_example
clear all;close all;

%% load kasted adta
dx=400;
kasted_load;
%% SET SIZE OF SIMULATION GRID
x1 = 562000;
x2 = 576300;
y1 = 6225200;
y2 = 6235400;

O.x = x1:dx:x2;
O.y = y1:dx:y2;
nx=length(O.x);
ny=length(O.y);
SIM=zeros(ny,nx).*NaN;


%% Unconditional simulation
O.method = 'mps_snesim_tree';
O.template_size=[8 8 1];
O.n_multiple_grids = 3;
O.n_cond = 18;
O.n_real = 9;
O.doEntropy = 1; % compute entropy and self-information
[reals_uncond,Ou]=mps_cpp_thread(TI,SIM,O);
%[reals_uncond,Ou]=mps_cpp(TI,SIM,O);

if O.doEntropy==1
    disp(sprintf('Estimated entropy = %4.1f',mean(Ou.SI)))
end

figure(2);clf;
for i=1:9;
    subplot(3,3,i);
    imagesc(Ou.x,Ou.y,reals_uncond(:,:,i));
    set(gca,'ydir','normal');
    axis image
end
drawnow;pause(1);
%% Conditional simulation
clear Oc;
Oc=O;

% select which hard 
%Oc.d_hard = d_well_hard;
% Select soft data
Oc.d_soft = d_res;
%Oc.d_soft = d_ele;
%i_use_soft_well = find(d_well(:,4)-0.5);
%Oc.d_soft = d_well(i_use_soft_well,:);

Oc.shuffle_simulation_grid=2; % preferential path

n_cond_hard = 16;
n_cond_soft = 1; % non-colocate soft data - only for GENESIM 

% Use SNESIM?
Oc.method = 'mps_snesim_tree';
Oc.template_size=[8 8 1];
Oc.n_multiple_grids = 3;
Oc.n_cond=[n_cond_hard];
Oc.n_min_node_count=10;

% Use GENESIM/DS
%Oc.method = 'mps_genesim';
Oc.n_cond=[n_cond_hard, n_cond_soft];

Oc.n_real = 100;

[reals_cond,Oc]=mps_cpp_thread(TI,SIM,Oc);

if Oc.doEntropy==1
    disp(sprintf('Estimated entropy = %4.1f',mean(Oc.SI)))
end


figure(3);clf;
for i=1:9;
    subplot(3,3,i);
    imagesc(Ou.x,Ou.y,reals_cond(:,:,i));
    set(gca,'ydir','normal');
    axis image
end

figure(4);
[etype_mean, etype_var]=etype(reals_cond);
subplot(1,2,1);
imagesc(Oc.x, Oc.y, etype_mean);
axis image
hold on
plot(d_well_hard(:,1),d_well_hard(:,2),'w.','MarkerSize',22);
scatter(d_well_hard(:,1),d_well_hard(:,2),10,d_well_hard(:,4),'filled')
set(gca,'ydir','normal');
hold off
axis image
colorbar;
title('Etype Mean')

subplot(1,2,2);
imagesc(Oc.x, Oc.y, etype_var);
set(gca,'ydir','normal');
axis image;
colorbar
title('Etype Variance')
drawnow;pause(1);

%% MPS Estimation
Oest = Oc; 
Oest.method = 'mps_genesim';
Oest.n_max_cpdf_count=100
Oest.n_real=1;
Oest.doEstimation = 1;
Oest.n_cond=[16,1];
[~,Oest]=mps_cpp(TI,SIM,Oest);
Pcond = Oest.cg;

figure(5);
subplot(1,2,1);
imagesc(Oest.x, Oest.y, Pcond(:,:,2));
axis image
hold on
plot(d_well_hard(:,1),d_well_hard(:,2),'w.','MarkerSize',22);
scatter(d_well_hard(:,1),d_well_hard(:,2),10,d_well_hard(:,4),'filled')
set(gca,'ydir','normal');
hold off
axis image
colorbar;
title('Etype Mean')
