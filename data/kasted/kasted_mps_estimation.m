%kasted_mps_estimation
clear all;close all;
n_max_ite=100000;1000000;
n_max_cpdf_count= 2000;
n_real = 250;

n_conds = [9];
min_dists = [0.2 0.5];


if ~exist('n_conds','var')
    n_conds = [4];
end

if ~exist('min_dists','var')
    min_dists = [0.15, 0.2, 0.25, 0.35];
end


% load kasted adta
dx=100;
kasted_load;
% SET SIZE OF SIMULATION GRID
x1 = 562000-200;
x2 = 576300+200;
y1 = 6225200-200;
y2 = 6235400+200;

ax=[x1 x2 y1 y2];

O.x = x1:dx:x2;
O.y = y1:dx:y2;
nx=length(O.x);
ny=length(O.y);
SIM=zeros(ny,nx).*NaN;

% Simulation
O.method = 'mps_genesim';
O.n_real = n_real;
O.doEntropy = 0; % compute entropy and self-information
O.shuffle_simulation_grid=2; % preferential path
O.d_hard = d_well_hard;
O.n_max_ite=n_max_ite;
O.n_max_cpdf_count=1; % DS
O.rseed=1;

% Conditional data
Oc.d_hard = d_well_hard;
%Oc.d_soft = d_res;
%Oc.d_soft = d_ele;
%i_use_soft_well = find(d_well(:,4)-0.5);
%Oc.d_soft = d_well(i_use_soft_well,:);

pmarg1d(2)=sum(TI(:))/prod(size(TI));
pmarg1d(1)=1-pmarg1d(2);
col0=[1 0 0];col1=[0 0 0];
cmap=cmap_linear([col0;1 1 1;col1],[0 pmarg1d(2) 1]);
            

k=0;
for i=1:length(n_conds);
    for j=1:length(min_dists);
        k=k+1;
        Oc=O;
        Oc.distance_min = min_dists(j);
        
        n_cond_hard = n_conds(i);
        n_cond_soft = 0; % non-colocate soft data - only for GENESIM
        
        Oc.n_cond=[n_cond_hard, n_cond_soft];
        
        % SIM
        Oc.n_max_cpdf_count=1; % DS
        [reals_cond,Osim]=mps_cpp_thread(TI,SIM,Oc);
        [em, ev]=etype(reals_cond);
        P_SIM{i,j}=em;
        disp('SIM DONE')
        
        % EST
        Oc.doEstimation=1;
        Oc.n_real=1;
        Oc.n_max_cpdf_count=1000;
        Oc.n_max_cpdf_count=n_max_cpdf_count;;
        [reals_est,Oest]=mps_cpp(TI,SIM,Oc);
        P_EST{i,j}=Oest.cg(:,:,2);
        disp('EST DONE')
        
        OmulEST{i,j}=Oest;
        OmulSIM{i,j}=Osim;
        
        %% Plot ETYPE
        figure(200+k);clf;
        subplot(1,2,1);imagesc(Osim.x,Osim.y,P_SIM{i,j});
        axis image;axis(ax);colormap(cmap);
        set(gca,'ydir','normal')
        hold on;
        plot(Oc.d_hard(:,1),Oc.d_hard(:,2),'w.','MarkerSize',14);
        scatter(Oc.d_hard(:,1),Oc.d_hard(:,2),10,Oc.d_hard(:,4),'filled')
        hold off
        caxis([0 1])
        title(sprintf('Simulation - d_{min}=%3.1f n_c=%d',Oc.distance_min, Oc.n_cond(1)))
        subplot(1,2,2);imagesc(Oest.x,Oest.y,P_EST{i,j});
        axis image;axis(ax);colormap(cmap);
        set(gca,'ydir','normal')
        hold on;
        plot(Oc.d_hard(:,1),Oc.d_hard(:,2),'w.','MarkerSize',14);
        scatter(Oc.d_hard(:,1),Oc.d_hard(:,2),10,Oc.d_hard(:,4),'filled')
        hold off
        caxis([0 1])
        title(sprintf('Estimation - d_{min}=%3.1f n_c=%d',Oc.distance_min, Oc.n_cond(1)))
        print_mul(sprintf('kasted_mul_dx%d_est%d_%d_c%d_nr%d',dx,100*min_dists(j),n_conds(i),n_max_cpdf_count, n_real))
        
        %PLOT reals
        figure(100+k);clf;
        for l=1:9;
            subplot(3,3,l);
            imagesc(Osim.x,Osim.y,reals_cond(:,:,l));
            axis image;axis(ax);
            set(gca,'ydir','normal')
            set(gca,'ydir','normal');
            axis image
        end
        print_mul(sprintf('kasted_mul_dx%d_sim%d_%d_c%d_nr%d',dx,100*min_dists(j),n_conds(i),n_max_cpdf_count, n_real))
        
        drawnow;pause(.1);
        
    end
end
save(sprintf('kasted_dx%d_mul_%d_%d_c%d_nr%d',dx,length(min_dists),length(n_conds),n_max_cpdf_count, n_real))

return


return
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

% MPS Estimation
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
