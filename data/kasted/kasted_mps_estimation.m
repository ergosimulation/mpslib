%kasted_mps_estimation
clear all;close all;

if ~exist('mps_cpp.m','file')
    addpath(sprintf('..%s..%smatlab%s',filesep,filesep,filesep));
end

%% basic settings
n_max_ite=5000;
distance_pow = 1;
use_parfor = 1;
useRef=0;
doPlot=1; 
doPlot=2; % more figures
useSubSet = 0;
%dx=200;
%dx=100; 
%dx=200; % choose for faster simulation on coarser grid

% Detailed run 
%min_dists = [0:0.05:1];
%n_conds = [1:1:6].^2;

% manuscript run
min_dists = [0.05,0.15, 0.2, 0.25, 0.35, 0.5];
n_conds = [2,6,10,18];

% small test
%dx=100;min_dists = [0.2];n_conds = [6 9];n_real = 501;

if ~exist('n_real','var')
    n_real = 1000;
end

if ~exist('n_max_cpdf_count','var')
    n_max_cpdf_count= n_real;
    %n_max_cpdf_count= 1000;
end


if ~exist('n_conds','var')
    n_conds = [4, 10, 18];
end

if ~exist('min_dists','var')
    min_dists = [0 0.15, 0.2, 0.25, 0.35];
end

if use_parfor == 1;
    p=gcp;
    n_workers = p.NumWorkers;
end

%% load kasted adta
doPlot=0;
kasted_load;
doPlot=1;
% SET SIZE OF SIMULATION GRID
x1 = 562000-200;
x2 = 576400+200;
y1 = 6225200-200;
y2 = 6235400+200;

ax=[x1 x2 y1 y2];

O.x = x1:dx:x2;
O.y = y1:dx:y2;
nx=length(O.x);
ny=length(O.y);
SIM=zeros(ny,nx).*NaN;

%d_well_hard  = read_eas('kasted_hard_well_conistent.dat');

% Simulation
O.debug=2;
O.method = 'mps_genesim';
O.n_real = n_real;
O.doEntropy = 0; % compute entropy and self-information
O.shuffle_simulation_grid=2; % preferential path
O.d_hard = d_well_hard;
O.n_max_ite=n_max_ite;
O.n_max_cpdf_count=1; % DS
O.rseed=1;
O.distance_pow=distance_pow;
O.hard_data_search_radius=10000000;
% Conditional data
O.d_hard = d_well_hard;

%Oc.d_soft = d_res;
%Oc.d_soft = d_ele;
%i_use_soft_well = find(d_well(:,4)-0.5);
%Oc.d_soft = d_well(i_use_soft_well,:);


pmarg1d(2)=sum(TI(:))/prod(size(TI));
pmarg1d(1)=1-pmarg1d(2);
col0=[1 0 0];col1=[0 0 0];
try;
    cmap=cmap_linear([col0;1 1 1;col1],[0 pmarg1d(2) 1]);
catch
    cmap=hot;
end

%% MAKE REF DATA? FROM TI
if useRef==1;
    d_hard = d_well_hard;
    for i=1:size(d_hard,1);
        ix1=8000/dx+ceil((d_hard(i,1)-O.x(1))/dx);
        iy1=2000/dx+ceil((d_hard(i,2)-O.y(1))/dx);
        
        d_hard(i,4)=TI(iy1,ix1,1);
        
    end
    O.d_hard = d_hard;
    figure;
    scatter(d_hard(:,1),d_hard(:,2),10,d_hard(:,4),'filled');
    axis image
    axis(ax);
   
end

%% SUBSET
if useSubSet == 1;
    n_use_hard = 24;
    rng(1);
    %i_hard_use = randomsample(size(O.d_hard,1),n_use_hard);
    i_hard_use = randsample(size(O.d_hard,1),n_use_hard)';
    O.d_hard = O.d_hard(i_hard_use,:);
end

n_hard = size(O.d_hard,1);
txt=sprintf('kasted_dx%d_mul_%d_%d_c%d_nr%d_nh%d_R%d_p%d_pf%d',dx,length(min_dists),length(n_conds),n_max_cpdf_count, n_real, n_hard,useRef,O.distance_pow,use_parfor);


%% ESTIMATION AND SIMULATION
k=0;
for i=1:length(n_conds);
    for j=1:length(min_dists);
        close all;
        disp(sprintf('nc=%d, min_dist=%3.2f',n_conds(i), min_dists(j)))
        k=k+1;
        Oc=O;
        Oc.distance_min = min_dists(j);
        
        n_cond_hard = n_conds(i);
        n_cond_soft = 0; % non-colocate soft data - only for GENESIM
        
        Oc.n_cond=[n_cond_hard, n_cond_soft];
                
        % SIM
        Oc.parameter_filename=[Oc.method,'_sim.txt'];
        Oc.n_max_cpdf_count=1; % DS
        if use_parfor == 1;
            [reals_cond,Osim]=mps_cpp_thread(TI,SIM,Oc);
        else
            [reals_cond,Osim]=mps_cpp(TI,SIM,Oc);
        end
        [em, ev]=etype(reals_cond);
        P_SIM{i,j}=em;
        disp(sprintf('SIM DONE, t=%5.1fs',Osim.time))
        
        % EST
        Oc.parameter_filename=[Oc.method,'_est.txt'];
        Oc.doEstimation=1;
        Oc.n_real=1;
        Oc.n_max_cpdf_count=n_max_cpdf_count;;
        %[reals_est,Oest]=mps_cpp(TI,SIM,Oc);
        [reals_est,Oest]=mps_cpp_estimation(TI,SIM,Oc,use_parfor);
        P_EST{i,j}=Oest.cg(:,:,2);
        disp(sprintf('EST DONE, t=%5.1fs',Oest.time))
        
        try
            P(:,:,1)=P_SIM{i,j,1};P(:,:,2)=1-P_SIM{i,j};
            H_SIM_2d{i,j}=entropy_2d(P);
            H_SIM(i,j)=sum(sum(H_SIM_2d{i,j}));
            P(:,:,1)=P_EST{i,j};P(:,:,2)=1-P_EST{i,j};H_EST_2d{i,j}=entropy_2d(P);
            H_EST(i,j)=sum(sum(H_EST_2d{i,j}));
        end
        T_SIM(i,j)=Osim.time;
        T_EST(i,j)=Oest.time;
        
        OmulSIM{i,j}=Osim;
        OmulEST{i,j}=Oest;
        
        %% Plot ETYPE
        if doPlot>1
            figure(200+k);clf;
            %subplot(1,2,1);imagesc(Osim.x,Osim.y,P_SIM{i,j});
            subplot(1,2,1);pcolor(Osim.x,Osim.y,P_SIM{i,j});shading flat
            axis image;axis(ax);colormap(cmap);
            set(gca,'ydir','normal')
            hold on;
            plot(Oc.d_hard(:,1),Oc.d_hard(:,2),'w.','MarkerSize',14);
            scatter(Oc.d_hard(:,1),Oc.d_hard(:,2),10,Oc.d_hard(:,4),'filled')
            hold off
            caxis([0 1])
            title(sprintf('Simulation - d_{min}=%3.2f n_c=%d',Oc.distance_min, Oc.n_cond(1)))
            %subplot(1,2,2);imagesc(Oest.x,Oest.y,P_EST{i,j});
            subplot(1,2,2);pcolor(Oest.x,Oest.y,P_EST{i,j});shading flat
            axis image;axis(ax);colormap(cmap);
            set(gca,'ydir','normal')
            hold on;
            plot(Oc.d_hard(:,1),Oc.d_hard(:,2),'w.','MarkerSize',14);
            scatter(Oc.d_hard(:,1),Oc.d_hard(:,2),10,Oc.d_hard(:,4),'filled')
            hold off
            caxis([0 1])
            title(sprintf('Estimation - d_{min}=%3.2f n_c=%d',Oc.distance_min, Oc.n_cond(1)))
            try;print_mul(sprintf('%s_nc%d_mind%d_est',txt,n_conds(i),100*min_dists(j)));end
        end
        %PLOT reals
        if doPlot>1
            figure(100+k);clf;
            for l=1:9;
                subplot(3,3,l);
                imagesc(Osim.x,Osim.y,reals_cond(:,:,l));
                axis image;axis(ax);
                set(gca,'ydir','normal')
                axis image
            end
            try;print_mul(sprintf('%s_nc%d_mind%d_sim',txt,n_conds(i),100*min_dists(j)));end
        end
        
        drawnow;pause(.1);
        
    end
end
clear reals_cond
save(txt)

%% OPTIONALLY LOAD ALLREADY ESTIMATED/SIMULATED DATA
%clear all;load kasted_dx50_mul_4_4_c1000_nr100_nh112_R0.mat
%clear all;load kasted_dx50_mul_4_2_c1000_nr1000_nh112_R0.mat
%% PLOT ALL
n1=length(n_conds);
n2=length(min_dists);
nx=Oest.simulation_grid_size(1);
ny=Oest.simulation_grid_size(2);
bEST = zeros(n1*ny,n2*nx);
bSIM = zeros(n1*ny,n2*nx);
for i=1:n1
    for j=1:n2
        x0=(j-1)*nx;
        y0=(i-1)*ny;
        ix=[1:nx]+x0;
        iy=[1:ny]+y0;
        bEST(iy,ix)=P_EST{i,j};
        bSIM(iy,ix)=P_SIM{i,j};
    end
end

figure(10);
imagesc(bEST);
axis image;colormap(cmap);colorbar
hold on
for i=1:(length(min_dists)-1);plot(0.5+[1 1].*(i*nx),ylim,'k-','LineWidth',1);end
for i=1:(length(n_conds)-1);plot(xlim,0.5+[1 1].*(i*ny),'k-','LineWidth',1);end
hold off
set(gca,'xTick',[1:1:length(min_dists)].*nx-nx/2)
set(gca,'xTickLabel',num2str(min_dists'))
xlabel('d_{max}')
set(gca,'yTick',[1:1:length(n_conds)].*ny-ny/2)
set(gca,'yTickLabel',num2str(n_conds'))
ylabel('n_c')
set(gca,'ydir','normal')
try;print_mul([txt,'_EST']);end

figure(11);
imagesc(bSIM);
axis image;colormap(cmap);colorbar
hold on
for i=1:(length(min_dists)-1);plot(0.5+[1 1].*(i*nx),ylim,'k-','LineWidth',1);end
for i=1:(length(n_conds)-1);plot(xlim,0.5+[1 1].*(i*ny),'k-','LineWidth',1);end
hold off
set(gca,'xTick',[1:1:length(min_dists)].*nx-nx/2)
set(gca,'xTickLabel',num2str(min_dists'))
xlabel('d_{max}')
set(gca,'yTick',[1:1:length(n_conds)].*ny-ny/2)
set(gca,'yTickLabel',num2str(n_conds'))
ylabel('n_c')
set(gca,'ydir','normal')
try;print_mul([txt,'_SIM']);end


%%
figure(12);clf;
h1=loglog(n_conds,T_EST,'-*');legend(num2str(min_dists'));
hold on
h2=loglog(n_conds,T_SIM,'--*');legend(num2str(min_dists'));
ylabel('Time (s)')
xlabel('N_c')
hold off
for ih=1:length(h1);set(h2(ih),'color',get(h1(ih),'color'));end
title('Simulation time, SIM(--) EST(-)')
grid on
try;print_mul([txt,'_T']);end

figure(13);clf;
h1=semilogy(min_dists,T_EST','-*');legend(num2str(n_conds'));
hold on
h2=semilogy(min_dists,T_SIM','--*');legend(num2str(n_conds'));
xlabel('d_{max}')
ylabel('Time (s)')
hold off
for ih=1:length(h1);set(h2(ih),'color',get(h1(ih),'color'));end
title('Simulation time, SIM(--) EST(-)')
grid on
try;print_mul([txt,'_T2']);end



figure(14);clf;
h1=semilogx(n_conds,H_EST,'-*');legend(num2str(min_dists'));
hold on
h2=semilogx(n_conds,H_SIM,'--*');legend(num2str(min_dists'));
hold off
for ih=1:length(h1);set(h2(ih),'color',get(h1(ih),'color'));end
xlabel('N_c')
ylabel('Entropy')
title('Entropy, SIM(--) EST(-)')
grid on
try;print_mul([txt,'_H']);end


figure(15);clf;
h1=plot(min_dists,H_EST','-*');legend(num2str(n_conds'));
hold on
h2=plot(min_dists,H_SIM','--*');legend(num2str(n_conds'));
hold off
for ih=1:length(h1);set(h2(ih),'color',get(h1(ih),'color'));end
xlabel('N_c')
ylabel('Entropy')
xlabel('d_{max}')
ylabel('Entropy')
title('Entropy, SIM(--) EST(-)')
grid on
try;print_mul([txt,'_H2']);end


