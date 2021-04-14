%kasted_mps_estimation
clear all;close all;
doPlot=1;
n_max_ite=100000;1000000;
n_max_cpdf_count= 10000000; 1000;2000;
n_real = n_max_cpdf_count;1000;

n_conds = [1,2,4,9,25,36, 49];
min_dists = [0 0.1 0.15, 0.2, 0.25, 0.35 0.5 1];

n_conds = [1,2,4,9,25];
min_dists = [0.15, 0.2, 0.25, 0.35];

n_conds = [4];
min_dists = [0.1];

if ~exist('n_conds','var')
    n_conds = [4];
end

if ~exist('min_dists','var')
    min_dists = [0 0.15, 0.2, 0.25, 0.35];
end

% load kasted adta
dx=200;
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



%% check for consistency

i=1;
j=1;

Oc=O;
Oc.distance_min = min_dists(j);

n_cond_hard = n_conds(i);
n_cond_soft = 0; % non-colocate soft data - only for GENESIM

Oc.n_cond=[n_cond_hard, n_cond_soft];

Oc.doEstimation=1;
Oc.n_real=1;
Oc.n_max_cpdf_count=n_max_cpdf_count;;

d_hard = d_well_hard;

i_not = [   108    62    60    79    89];
i_ok = setxor(1:size(d_hard,1),i_not)
d_hard = d_hard(i_ok,:)

i_not = [35];
i_ok = setxor(1:size(d_hard,1),i_not)
d_hard = d_hard(i_ok,:)

%write_eas('kasted_hard_well_conistent.dat',d_hard)

n_use = size(d_hard,1);
%rng(1);
%d_hard = d_hard(randomsample(1:size(d_hard,1),n_use),:);


n_hard = size(d_hard,1);

P_est = zeros(n_hard,2);
P_local = zeros(n_hard,2);

%profile on
for i_use = 1:n_hard;
    progress_txt(i_use,n_hard)
    i_cond = setxor(1:n_hard,i_use);
    
    Oc.d_hard = d_hard(i_cond,:);
    
    mask = zeros(size(SIM));
    
    ix=1+ceil((d_hard(i_use,1)-O.x(1))/dx);
    iy=1+ceil((d_hard(i_use,2)-O.y(1))/dx);
    
    mask(iy,ix)=1;
    Oc.d_mask = mask;
    
    [reals_est,Oest]=mps_cpp(TI,SIM,Oc);
    P_est(i_use,:) = squeeze(Oest.cg(iy,ix,:)); 
    P_local(i_use,:) = [1-d_hard(i_use,4) d_hard(i_use,4)];
    
    KL_dis(i_use) = kl(P_local(i_use,:),P_est(i_use,:));
end
%profile report


KL_dis(find(isinf(KL_dis)))=max(KL_dis);

DD =sortrows([[1:n_hard]',KL_dis(:)],2,'des');
n_show = 5;
disp(sprintf('The 5 most inconsistent data are: '))
disp(DD(1:n_show,1)')




%%
figure(1);
subplot(2,2,1);
scatter(d_hard(:,1),d_hard(:,2),50,P_local(:,2),'filled');
colormap(gca,cmap)
axis image
set(gca,'ydir','normal')
colorbar

subplot(2,2,2);
scatter(d_hard(:,1),d_hard(:,2),50,P_local(:,2),'filled');
hold on
scatter(d_hard(:,1),d_hard(:,2),20,P_est(:,2),'filled');
hold off
colormap(gca,cmap)
axis image
set(gca,'ydir','normal')
colorbar

subplot(2,2,3);
plot(d_hard(:,1),d_hard(:,2),'k.','MarkerSIze',30);
hold on
scatter(d_hard(:,1),d_hard(:,2),0.1+KL_dis*10,d_hard(:,4),'filled');
hold off
axis image
colormap(gca,parula)
colorbar

subplot(2,2,4);
scatter(d_hard(:,1),d_hard(:,2),50,KL_dis,'filled');
hold on
for i=1:n_hard
    text(d_hard(i,1),d_hard(i,2),sprintf('%d',i),'HOrizontalAlignment','center')
end
hold off
axis image
colormap(gca,cmap_geosoft)
%colormap(gca,flipud(copper))
colorbar
            
