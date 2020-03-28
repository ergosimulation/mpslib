%
% Compare ENESIM style simulation and estimation
% 
% 1. nreal VERY large (n_real should not be an issue)
%    ENESIM
%
% 2. ENESIM sim STATS as a function of N_REALS!!! How many to obtain
% credible stats?
%
%
clear all;close all
x=1:1:30;nx=length(x);
y=1:1:30;ny=length(y);

m_ref=read_eas_matrix('m_ref.dat');
%% LOAD SOFT DATA
f_soft{1}='soft_case1.dat';
f_soft{2}='soft_case2.dat';
f_soft{3}='soft_case3.dat';

d_soft{1}=read_eas(f_soft{1});
d_soft{2}=read_eas(f_soft{2});
d_soft{3}=read_eas(f_soft{3});

cmap=load('cmap_em.dat');
cmap = cmap_linear([1 0 0; 1 1 1; 0 0 0]);

%% SETUP SIMULATION
idata=3;
n_cond=5;
n_max_ite=70000; % OLD RUN

TI=channels(4,1);
SIM = ones(ny,nx).*NaN;


O.method='mps_snesim_tree'; % MPS algorithm to run
O.n_multiple_grids=1;
O.template_size=[10,10,1]';
O.origin=[1 1 0];
O.n_cond = n_cond; % number of conditional points
O.n_max_cpdf_count=10000; % Set below \inf to improve CPU
O.n_cond=[n_cond];
O.n_max_ite=n_max_ite;
O.n_real=1;   %  optional number of realization

O.doEstimation=1;
O.doEntropy=0;

clear d_hard
d_hard(:,1:3)=d_soft{idata}(:,1:3);
for i=1:size(d_hard,1);
    m=m_ref(d_hard(i,2),d_hard(i,1));
    d_hard(i,4)=m_ref(d_hard(i,2),d_hard(i,1));
end
O.d_hard=d_hard;

cond_arr=[0,1,2,4,8,16,32,64];
%cond_arr=[0,1,2,4];

for icond = 1:length(cond_arr);
    disp(sprintf('n_cond=%d',cond_arr(icond)))
    O.n_cond=cond_arr(icond);
    
    O.parameter_filename = sprintf('%s_nc%02d_est.par',O.method,O.n_cond);
    %O.shuffle_simulation_grid = i_path_arr(i);
    [reals,O_est{icond}]=mps_cpp(TI,SIM,O);

        
    O_est{icond}.H=zeros(size(reals));
    ncat=2;
    for iy=1:ny
    for ix=1:nx
        O_est{icond}.H(iy,ix)=entropy(squeeze(O_est{icond}.cg(iy,ix,:)),ncat);
    end
    end
    
    P_channel_est{icond} = O_est{icond}.cg(:,:,2);
    H_channel_est{icond} = O_est{icond}.H;
    
    %%
    figure(1);
    subplot(2,4,icond)
    imagesc(x,y,P_channel_est{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_est{icond}.n_cond));
    drawnow;
    print_mul(sprintf('Pchannel_est_id%d',idata))
    
    figure(2);
    subplot(2,4,icond)
    imagesc(x,y,H_channel_est{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_est{icond}.n_cond));
    drawnow;
    print_mul(sprintf('H_est_id%d',idata))
    
end

save(sprintf('EST_nreal%d_ncarr%d',O.n_real,length(cond_arr)))

%% SIM

O.doEstimation=0
O.n_real=100;
clear reals

for icond = 1:length(cond_arr);
    disp(sprintf('n_cond=%d',cond_arr(icond)))
    O.n_cond=cond_arr(icond);
    
    O.parameter_filename = sprintf('%s_nc_02%d_sim.par',O.method,O.n_cond);
    %O.shuffle_simulation_grid = i_path_arr(i);
    [reals{icond},O_sim{icond}]=mps_cpp_thread(TI,SIM,O);
    
    P_channel_sim{icond} = mean(reals{icond},3);
    %%
    H_channel_sim{icond}=zeros(ny,nx);
    ncat=2;
    for iy=1:ny
    for ix=1:nx
        hc=hist(squeeze(reals{icond}(iy,ix,:)),[0,1]);
        P=hc./sum(hc);
        H_channel_sim{icond}(iy,ix)=entropy(P,ncat);
    end
    end
    
    %%
    figure(3);
    subplot(2,4,icond)
    imagesc(x,y,P_channel_sim{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_sim{icond}.n_cond));
    drawnow;
    print_mul(sprintf('Pchannel_sim_id%d',idata))
    
    figure(4);
    subplot(2,4,icond)
    imagesc(x,y,H_channel_sim{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_sim{icond}.n_cond));
    drawnow;
    print_mul(sprintf('H_sim_id%d',idata))
    
    
end

save(sprintf('SIM_nreal%d_ncarr%d',O.n_real,length(cond_arr)))

save SIM

%% PLOT
if ~exist('H_channel_sim');
    load SIM_nreal200_ncarr4
end

for icond = 1:length(cond_arr)
    
    
    figure(1);
    subplot(2,4,icond)
    imagesc(x,y,P_channel_est{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_est{icond}.n_cond));
    drawnow;
    
    figure(2);
    subplot(2,4,icond)
    imagesc(x,y,H_channel_est{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_est{icond}.n_cond));
    drawnow;
 
    figure(3);
    subplot(2,4,icond)
    imagesc(x,y,P_channel_sim{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_sim{icond}.n_cond));
    drawnow;
    
    figure(4);
    subplot(2,4,icond)
    imagesc(x,y,H_channel_sim{icond});axis image
    caxis([0 1]);colormap(gca,hot)
    title(sprintf('N_c = %d',O_sim{icond}.n_cond));
    drawnow;
    


end

figure(1); print_mul(sprintf('Pchannel_est_id%d',idata))
figure(2); print_mul(sprintf('H_est_id%d',idata))
figure(3); print_mul(sprintf('Pchannel_sim_id%d',idata))
figure(4); print_mul(sprintf('H_sim_id%d',idata))
   
