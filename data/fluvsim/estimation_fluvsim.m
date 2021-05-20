close all
%% load data
clear all
TI = read_eas_matrix('ti_fluvsim_big_channels3D.SGEMS');
ncat=length(unique(TI(:)));

cax=[0-.5 ncat-.5];
cmap =parula(ncat);

ny = 130;
nx = 100;
x=1:1:nx;
y=1:1:ny;
z=0;
SIM = ones(ny,nx).*NaN;

N_obs = 20;rng(2)
N_obs = 10;rng(4)
N_obs = 6;rng(1)
N_obs = 6;rng(3)
N_obs = 4;rng(3)
ix_obs = randi(nx,N_obs,1);
iy_obs = randi(ny,N_obs,1);
iref=11;
for i=1:N_obs
    d(i)=TI(iy_obs(i),ix_obs(i),iref);
end

d_obs=[ix_obs(:) iy_obs(:) iy_obs(:).*0 d(:)];

%x=100:1:200;nx=length(x);
%y=100:1:170;ny=length(y);
%z=0;


 
figure(1);
subplot(1,2,1);
imagesc(TI(:,:,iref)');axis image
xlabel('x');ylabel('y');
colormap(gca,cmap)
caxis(cax)
colorbar
title('One 2D slice of the 3D training image')

subplot(1,2,2);
scatter(d_obs(:,2),d_obs(:,1),50,d_obs(:,4),'filled');
xlabel('x');ylabel('y');
caxis(cax)
colormap(gca,cmap)
axis image;
axis([1 ny 1 nx])
box on
set(gca,'ydir','revers')
colorbar
drawnow;
title('Conditional data')

print('-dpng','fluvsim_ti_data')

% 

%% Setup mpslib

% Simulation
n_real = 60;
SIM=ones(ny,nx).*NaN;

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
[reals,Osim]=mps_cpp_thread(TI,SIM,Osim);

% compute probability of facies
clear Psim
for ic=1:ncat
    Psim(:,:,ic)=sum(reals==(ic-1),3)/Osim.n_real;
end

figure(2);
for i=1:min([size(reals,3),9])
    subplot(3,3,i);
    imagesc(y,x,reals(:,:,i)');
    caxis(cax)
    colormap(gca,cmap)
    axis image
end
print('-dpng','fluvsim_simulation_reals')

figure(3);
for i=1:ncat;
    subplot(1,ncat,i);
    imagesc(y,x,Psim(:,:,i)');
    axis image
    caxis([0 1])
    try
        colormap(gca,cmap_geosoft)
    catch
        colormap(gca,flipud(gray))
    end        
    title(sprintf('P(m_i=%d)',i-1))
    colorbar
end
print('-dpng','fluvsim_simulation_prob')
drawnow;




%% estimation
n_cond_est = 400;
Oest=O;
Oest.n_cond = n_cond_est ;
%Oest.doEstimation = 1;
Oest.n_real = 1;
Oest.debug=-2;
Oest.n_max_cpdf_count=400;
Oest.n_max_ite=1000000;
clear N
i=0;
n_cond = n_cond_est;
distance_min  =O.distance_min;
%for n_cond = [5,4,3,2,1]
%for distance_min = linspace(O.distance_min,1,21)
distance_min_arr = [O.distance_min:0.02:1];
distance_min_arr = [0.1];

for distance_min=distance_min_arr;
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


%
Pest=est_mul{end};
figure(5);
for i=1:5;
    subplot(1,5,i);
    imagesc(y,x,Pest(:,:,i)');
    axis image
    caxis([0 1])
    try
        colormap(gca,cmap_geosoft)
    catch
        colormap(gca,flipud(gray))
    end        
    title(sprintf('P(m_i=%d)',i-1))
    colorbar
end
drawnow;
print('-dpng','fluvsim_estimation_prob')

%% Entropy maps
figure(9);clf;
subplot(1,2,1);
imagesc(y,x,entropy_2d(Psim)');
axis image
caxis([0 1])
colormap(flipud(gray));colorbar;
xlabel('x');ylabel('y')
title('from sequential simulation')

subplot(1,2,2);
imagesc(y,x,entropy_2d(Pest)');
axis image
caxis([0 1])
colormap(flipud(gray));colorbar;
xlabel('x');ylabel('y')
title('from estimation')

sgtitle('Marginal entropy, H(m_i)')

print('-dpng','fluvsim_entropy')

