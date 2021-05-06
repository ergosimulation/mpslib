% estimation_walker_lake: Estimation example using data from Walker Lake
%
% Training data is from 
% http://trainingimages.org/training-images-library.html
% 
% TI (C_WLTICAT.sgems) : http://trainingimages.org/uploads/3/4/7/0/34703305/c_wlticat.zip
% d_obs (B_WLCATsamples.sgems): http://trainingimages.org/uploads/3/4/7/0/34703305/b_wlcatsamples.zip
% d_obs_exhaustive (A_WLreferenceCAT.sgems):
% http://trainingimages.org/uploads/3/4/7/0/34703305/a_wlreferencecat.zip, 
%

clear all

% load data
TI = read_eas_matrix('C_WLTICAT.sgems');
d_obs = read_eas('B_WLCATsamples.sgems');
d_ref = read_eas_matrix('A_WLreferenceCAT.sgems');


[ny,nx,nz]=size(d_ref);
dx=1;
x=1:dx:nx;
y=1:dx:ny;
z=0;


figure(1);
subplot(1,2,1);
imagesc(TI);axis image
subplot(1,2,2);
imagesc(x,y,d_ref);axis image;
hold on
plot(d_obs(:,1),d_obs(:,2),'w.','MarkerSize',12)
scatter(d_obs(:,1),d_obs(:,2),10,d_obs(:,4),'filled');
hold off
drawnow;



%% Setup mpslib

% Simulation
SIM=ones(ny,nx).*NaN;

n_real = 100;
n_cond_sim = 36;
n_cond_est = 5;
distance_min=0.3;
n_max_ite=10000;

clear O
O.x=x;
O.y=y;
O.debug=-1;
O.n_real = n_real;


O.method = 'mps_genesim';
O.n_max_ite=n_max_ite;
O.n_max_cpdf_count=1; % DS
O.distance_min = distance_min;

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
Oest=O;
Oest.n_cond = n_cond_est ;
%Oest.doEstimation = 1;
%Oest.n_real = 1;
Oest.distance_min=0.4;
Oest.n_cond = 9 ;
[ests,Oest]=mps_cpp_estimation(TI,SIM,Oest);
Pest= Oest.cg;


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






