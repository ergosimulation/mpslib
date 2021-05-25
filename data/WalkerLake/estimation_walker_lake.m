% estimation_walker_lake: Estimation example using data from Walker Lake
%
% Training data are from
% http://trainingimages.org/training-images-library.html
%
% TI (C_WLTICAT.sgems) : http://trainingimages.org/uploads/3/4/7/0/34703305/c_wlticat.zip
% d_obs (B_WLCATsamples.sgems): http://trainingimages.org/uploads/3/4/7/0/34703305/b_wlcatsamples.zip
% d_obs_exhaustive (A_WLreferenceCAT.sgems):
% http://trainingimages.org/uploads/3/4/7/0/34703305/a_wlreferencecat.zip,
%
%

clear all;close all

ncores=feature('numcores');
delete(gcp('nocreate'))
parpool(ncores)

%% load data
TI = read_eas_matrix('C_WLTICAT.sgems');
d_obs = read_eas('B_WLCATsamples.sgems');
d_ref = read_eas_matrix('A_WLreferenceCAT.sgems');
TI=d_ref

n_use = 100;
if n_use~=100
    nd = size(d_obs,1);
    i_use=randsample(nd,nd_use);
    d_obs=d_obs(i_use,:);
end


[ny,nx,nz]=size(d_ref);
dx=1;
x=1:dx:nx;
y=1:dx:ny;
z=0;

%x=100:1:200;nx=length(x);
%y=100:1:170;ny=length(y);
%z=0;



figure(1);
subplot(1,3,1);
imagesc(TI);axis image
title('Walke Lake - TI')
colorbar

subplot(1,3,2);
imagesc(d_ref);axis image;
hold on
plot(d_obs(:,1),d_obs(:,2),'w.','MarkerSize',12)
scatter(d_obs(:,1),d_obs(:,2),10,d_obs(:,4),'filled');
hold off
colorbar
title('Walke Lake - Reference')
ax=axis;

subplot(1,3,3);
scatter(d_obs(:,1),d_obs(:,2),20,d_obs(:,4),'filled');
box on
set(gca,'ydir','revers')
axis image;axis(ax)
colorbar
drawnow;
title('Walke Lake - d_{obs}')


%% Setup mpslib

% Simulation
SIM=ones(ny,nx).*NaN;

n_real = 500;
n_cond_sim = 36;
n_cond_est = 9;
distance_min=0.1;
n_max_ite=10000;

n_cond_sim = 9;
n_cond_est = 9;
%distance_min=0.3;


clear O
O.x=x;
O.y=y;
O.debug=-1;
O.n_real = n_real;


O.method = 'mps_genesim';
O.n_max_ite=n_max_ite;
O.n_max_cpdf_count=1; % DS
O.distance_min = distance_min;
O.max_search_radius=[100,100];

%O.method = 'mps_snesim_tree';


O.doEntropy = 0; % compute entropy and self-information
O.d_hard = d_obs;
O.rseed=2;


%% simulation
Osim=O;
Osim.n_cond = n_cond_sim ;
Osim.n_max_cpdf_count=1; % DS
Osim.n_real = n_real;
[reals,Osim]=mps_cpp_thread(TI,SIM,Osim);

% compute probability of facies
clear Psim
Psim(:,:,1)=sum(reals==0,3)/O.n_real;
Psim(:,:,2)=sum(reals==1,3)/O.n_real;
Psim(:,:,3)=sum(reals==2,3)/O.n_real;

figure(2);
for i=1:min([size(reals,3),9])
    subplot(3,3,i);
    imagesc(x,y,reals(:,:,i));
    axis image
end

figure(3);
for i=1:3;
    subplot(1,3,i);
    imagesc(x,y,Psim(:,:,i));
    axis image
    caxis([0 1])
    colormap(gca,flipud(gray))
    title(sprintf('P(m_i=%d)',i-1))
    colorbar
end
drawnow;

%% estimation
n_cond_est = 9;
Oest=O;
Oest.n_cond = n_cond_est ;
%Oest.doEstimation = 1;
%Oest.n_real = 1;
%Oest.distance_min=0.2;
%Oest.n_cond = 9 ;
Oest.debug=-2;
Oest.n_max_cpdf_count=400;
Oest.n_max_ite=1000000;
ncat = length(unique(TI(:)));
clear N
i=0;
n_cond = n_cond_est;
O.distance_min = 0.4;
distance_min  =O.distance_min;
%for n_cond = [5,4,3,2,1]
%for distance_min = linspace(O.distance_min,1,21)
for distance_min = [O.distance_min:0.02:1];
    disp(sprintf('Using n_cond = %d, distance_min=%3.1f',n_cond,distance_min))
    i=i+1;
    Oest.n_cond = n_cond;
    Oest.distance_min = distance_min;
    
    % set mask
    if i==1;
        est=ones(ny,nx,ncat).*NaN;
    end
    mask = isnan(est(:,:,1));
    ii_mask=find(mask);
    ii_done=find(1-mask);
    %N(i)=length(ii_mask)
    if length(ii_mask)>100;
        
        Oest.d_mask = mask;
        [est_mul{i},Oest_mul{i}]=mps_cpp_estimation(TI,SIM,Oest);
        
        t(i)=Oest_mul{i}.time;
        min_count = 200;
        ok_grid = Oest_mul{i}.TG2>min_count;
        ii_ok=find(ok_grid);
        ii_not_ok=find(1-ok_grid);
        
        for icat = 1:ncat;
            est_mul_tmp = est_mul{i}(:,:,icat);
            est_tmp = est(:,:,icat);
            est_tmp(ii_ok)=est_mul_tmp(ii_ok);
            est(:,:,icat)=est_tmp;
        end
        
        Mest{i}=est;
        
        
        figure(11);
        nnt=4;
        nr=8;
        ip=i;
        if ip>nr, ip=nr;end
        nn0=(ip-1)*nnt;
        subplot(nr,nnt,nn0+1);imagesc(mask);axis image;caxis([0 1]);colorbar;title('mask')
        subplot(nr,nnt,nn0+2);imagesc(Oest_mul{i}.TG2);axis image;colorbar;title('TG2')
        subplot(nr,nnt,nn0+3);imagesc(est_mul{i}(:,:,1));axis image;caxis([-1 1]);title('est_mul')
        subplot(nr,nnt,nn0+4);imagesc(est(:,:,1));axis image;caxis([-1 1]);title('est')
        drawnow
    end
end

%Oest.n_cond = 4;
%[est,Oest_2]=mps_cpp_estimation(TI,SIM,Oest);


%%
Pest= est;


figure(5);
for i=1:3;
    subplot(1,3,i);
    imagesc(x,y,Pest(:,:,i));
    axis image
    caxis([0 1])
    colormap(gca,flipud(gray))
    title(sprintf('P(m_i=%d)',i-1))
    colorbar
end
drawnow;






