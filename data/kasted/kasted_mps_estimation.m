%kasted_mps_estimati%on
clear all;close all;

% basic settings
useRef=0;
doPlot=1; 
doPlot=2; % more figures
useSubSet = 0;
dx=50;
%dx=100; 
%dx=200; % choose for faster simulation on coarser grid

%


%useRef=1;doPlot=1;

p=gcp;
n_workers = p.NumWorkers;

n_max_ite=100000;1000000;
n_max_cpdf_count= n_workers*50;2000;
n_real = n_max_cpdf_count;1000;

n_max_cpdf_count= 2000;
n_real = 1000;


n_conds = [1,2,4,9,25,36,49];
min_dists = [0:0.025:1];

n_conds = [1,2,4,9, 16, 25, 36,49, 64, 81];
min_dists = [0:0.1:1];


n_conds = [1,2,4,9,16,25,36];
n_conds = [1,2,4,9,16,25];
n_conds = [1,2,4,9,18];
min_dists = [0.15 0.2 0.25 0.35];
min_dists = [0:0.05:1];


n_real = 32*10;
n_conds = [4,9,16];
min_dists = [0.2:0.05:0.35];


if ~exist('n_conds','var')
    n_conds = [4];
end

if ~exist('min_dists','var')
    min_dists = [0 0.15, 0.2, 0.25, 0.35];
end

% load kasted adta
kasted_load;
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
O.debug=-1;
O.method = 'mps_genesim';
O.n_real = n_real;
O.doEntropy = 0; % compute entropy and self-information
O.shuffle_simulation_grid=2; % preferential path
O.d_hard = d_well_hard;
O.n_max_ite=n_max_ite;
O.n_max_cpdf_count=1; % DS
O.rseed=1;
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
txt=sprintf('kasted_dx%d_mul_%d_%d_c%d_nr%d_nh%d_R%d',dx,length(min_dists),length(n_conds),n_max_cpdf_count, n_real, n_hard,useRef);




%title(sprin
%% ESTIMATION
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
        Oc.n_max_cpdf_count=1; % DS
        [reals_cond,Osim]=mps_cpp_thread(TI,SIM,Oc);
        [em, ev]=etype(reals_cond);
        P_SIM{i,j}=em;
        disp(sprintf('SIM DONE, t=%5.1fs',Osim.time))
        
        % EST
        Oc.doEstimation=1;
        Oc.n_real=1;
        Oc.n_max_cpdf_count=n_max_cpdf_count;;
        %[reals_est,Oest]=mps_cpp(TI,SIM,Oc);
        [reals_est,Oest]=mps_cpp_estimation(TI,SIM,Oc,1);
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
set(gca,'yTick',[1:1:length(n_conds)].*ny-nx/2)
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
set(gca,'yTick',[1:1:length(n_conds)].*ny-nx/2)
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


