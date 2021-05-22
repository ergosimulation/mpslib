% kasted_mps_genesim_subset
clear all;close all
if ~exist('mps_cpp.m','file')
    addpath(sprintf('..%s..%smatlab%s',filesep,filesep,filesep));
end

dx=100;
dx=50;
n_conds = [2,6,10,14,18,36] ;
min_dists = [0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.35, 0.5, 0.7, 1];
n_real=500;

use_parfor = 0;

%n_conds = [2,6,10] ;
%min_dists = [0.05 0.25 0.8];
%n_real=100;dx=50;
%n_real=1000;dx=200

debug_level=-1;
debug_level=2;
doSIM=1;
use_mask=3;

%%
if ~exist('plots');plots=0;end %1 for running once, plots = 2 for running mulitple times
if ~exist('rseed');rseed=2;end
if ~exist('dx');dx=50;end
if ~exist('max_cpdf_count'); max_cpdf_count=n_real;end
if ~exist('doSIM'); doSIM=0;;end
if ~exist('debug_level');debug_level=-1;end

%% Load data
doPlot=0;
kasted_load;

% set hard data
O.d_hard = d_well_hard;

% SET SIZE OF SIMULATION GRID
x1 = ax(1)-200;
x2 = ax(2)+200;
y1 = ax(3)-200;
y2 = ax(4)+200;

ax=[x1 x2 y1 y2];

O.x = x1:dx:x2;
O.y = y1:dx:y2;
nx=length(O.x);
ny=length(O.y);
SIM=zeros(ny,nx).*NaN;

% make MASK
xlim =  [0 50*0.05]+[565.4];xlim=xlim*1000;
ylim = [-50*0.05 0]+[6232.3];ylim=ylim*1000;
if use_mask ==2;
    ylim = [-50*0.05 0]+[6234.8];ylim=ylim*1000;
elseif use_mask == 3
    xlim =  [0 50*0.05]+[568.4];xlim=xlim*1000;
    ylim = [0 50*0.05 ]+[6229];ylim=ylim*1000;
end
xl=[xlim(1) xlim(1) xlim(2) xlim(2) xlim(1)] ;
yl=[ylim(1) ylim(2) ylim(2) ylim(1) ylim(1)]; 

[xx,yy]=meshgrid(O.x, O.y);
MASK = ((xx>=xlim(1)) & (xx<=xlim(2)) & (yy>=ylim(1)) & (yy<=ylim(2)) );

ix1=find(O.x>=xlim(1));ix1=ix1(1);
ix2=find(O.x<=xlim(2));ix2=ix2(end)
iy1=find(O.y>=ylim(1));iy1=iy1(1);
iy2=find(O.y<=ylim(2));iy2=iy2(end);

mask_x_bounds = [ix1 ix2];
mask_y_bounds = [iy1 iy2];

%% plot data
pmarg1d(2)=sum(TI(:))/prod(size(TI));
pmarg1d(1)=1-pmarg1d(2);
col0=[1 0 0];col1=[0 0 0]
cmap_discrete=[col0;col1];
p_channel_marg=0.58;
cmap_prob=cmap_linear([cmap_discrete(1,:);1 1 1;cmap_discrete(2,:)],[0 p_channel_marg 1.0]);


figure(1);set_paper('landscape');clf
subplot(1,2,1);
set(gca,'FontSize',5)
plot(d_well_hard(:,1),d_well_hard(:,2),'k.','MarkerSize',16);
hold on
scatter(d_well_hard(:,1),d_well_hard(:,2),10,d_well_hard(:,4),'filled');
hold off
axis image
box on
grid on
xlabel('UTMX (km)')
ylabel('UTMY (km)')
colormap(cmap_discrete)
cb=colorbar;
set(cb,'Ytick',[0.25 0.75]);set(cb,'YtickLabel',{'None','Channel'})
set(gca,'FontSize',7)

print_mul(sprintf('kasted_hard_obs'))
hold on
plot(xl,yl,'k--')
hold off
print_mul(sprintf('kasted_hard_obs_mask%d',use_mask))

%% Run estimations and plot
[ti_ny,ti_nx]=size(TI);
val=unique(TI(:));
nval=length(val);

%%

matfile=sprintf('est_%d_%d_%d_m%d_dx%d',length(n_conds),length(min_dists),max_cpdf_count,use_mask,dx);
if exist([matfile,'.mat'],'file');
    disp(sprintf('Loading %s',matfile))
    load(matfile)
else
    % Simulation Grid Size
    
    myOest= cell(length(n_conds),length(min_dists));
    
    for i = 1:length(n_conds)
        n_cond = n_conds(i);
        for j = 1:length(min_dists)
            
            ind = (i-1)*length(min_dists)+j;
            distance_min = min_dists(j);
            
            disp(sprintf('Testing N_c=%d, d=%2.1f',n_cond,distance_min))
            %%kasted_enesim_est.m;
            
            tic;
            rng(rseed)
            
            %% Setup MPSLIB
            %clear O*
            useGenesim=1;
            if useGenesim==1
                O.method='mps_genesim';
                O.parameter_filename='mps_genesim_test.txt';
                O.n_max_ite=5000;
                O.n_cond=[n_cond 0];
                O.n_max_cpdf_count=max_cpdf_count;
                O.distance_min=distance_min;
                O.distance_pow=3;
            else
                O.method='mps_snesim_tree';
                O.parameter_filename='mps_snesim_test.txt';
                O.te_size=[5,5,1];
                O.n_multiple_grids=3;
            end
            O.n_real=1;             %  optional number of realization
            O.rseed=rseed;
            O.shuffle_simulation_grid=1;
            O.doEstimation=1;
            O.doEntropy=0;
            O.debug=debug_level;
            O.distance_measure=1;
            O.distance_pow=1;
            O.output_folder='output';%sprintf('output%i',ind);
            O.output_folder='.';%sprintf('output%i',ind);
            r=10000;
            O.hard_data_search_radius=0;
            O.max_search_radius=[r r];
            %% MASK
            if use_mask > 0
                O.d_mask=MASK;
            elseif exist('mask.dat','file')
                delete('mask.dat')
            end
            
            %%
            try
                if exist('d_soft.dat','file');delete('d_soft.dat');end
                if exist('d_hard.dat','file');delete('d_hard.dat');end
                O=rmfield(O,'d_soft');
                O=rmfield(O,'d_hard');
            end
            
            %% Estimation
            disp('ESTIMATION')
            Oest=O;
            Oest.n_max_cpdf_count=max_cpdf_count;
            
            if use_parfor>1
                % next line does estimation in parallel
                [reals,Oest]=mps_cpp_estimation(TI,SIM,Oest);
            else
                [reals,Oest]=mps_cpp(TI,SIM,Oest);
            end
            myOest{i,j} = Oest;
            fprintf('Done, t_est=%3.1fs\n',Oest.time);
            
            %% Simulation
            if doSIM==1;
                Osim=O;
                Osim.doEstimation=0;
                Osim.n_max_cpdf_count=1;
                Osim.n_real=n_real;
                Osim.debug=-1;
                disp('SIMULATION')
                if use_parfor>0
                    [reals_sim,Osim]=mps_cpp_thread(TI,SIM,Osim);
                    Osim.time_org=Osim.time;
                    o=gcp('nocreate');
                    Osim.time=Osim.time.*o.NumWorkers;
                else
                    [reals_sim,Osim]=mps_cpp(TI,SIM,Osim);
                end
                myOsim{i,j} = Osim;
                [myOsim{i,j}.em_sim,myOsim{i,j}.ev_sim]=etype(reals_sim);
                fprintf('Done, t_sim=%3.1fs\n',Osim.time);
                
            end
            
            %% Plots
            if plots == 1
                figure_focus(11);
                subplot(length(n_conds),length(min_dists),ind)
                imagesc(Oest.x,Oest.y,Oest.cg(:,:,2));
                axis image;
                title(sprintf('n_cond = %i, min_distance: %6.2f',Oest.n_cond(1),Oest.distance_min))
                drawnow;
                if j==length(min_dists)
                    print_mul('Oest')
                end
            end
        end
        %save(sprintf('est_%d_%d_%d',length(n_conds),length(min_dists),O.n_max_cpdf_count))
    end
    save(matfile)
end


%% Composite plot - estimation
composite_x = mask_x_bounds(2)-mask_x_bounds(1)+1;
composite_y = mask_y_bounds(2)-mask_y_bounds(1)+1;
composite_x_tot = length(n_conds)*composite_x;
composite_y_tot = length(min_dists)*composite_y;
composite_grid = NaN(composite_x_tot,composite_y_tot);
times_grid = NaN(length(n_conds),length(min_dists));

for i = 1:length(n_conds)
    for j = 1:length(min_dists)
        O = myOest{i,j};
        try
            m_est = flipud(O.cg(mask_y_bounds(1):mask_y_bounds(2),mask_x_bounds(1):mask_x_bounds(2),2));
            composite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y) = m_est;
            %oOcomposite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y) = O.cg(mask_x_bounds(1):mask_x_bounds(2),mask_y_bounds(1):mask_y_bounds(2),2);
            times_grid(i,j) = O.time;
        end
    end
end

figure(5);imagesc(composite_grid);
axis image
% grid and custom tickers
yticks([1:length(n_conds)]*composite_y-composite_y/2)
yticklabels(n_conds)
ylabel('n_c, number of conditionals')

xticks([1:length(min_dists)]*composite_x-composite_x/2)
xticklabels(min_dists)
xlabel('d_{max}')

hold on;
for i = 1:length(n_conds)-1
    plot(0.5+[0,size(composite_grid,2)],0.5+[(i)*composite_x,(i)*composite_x],'-k');
end
for j = 1:length(min_dists)
    plot(0.5+[(j)*composite_y,(j)*composite_y],0.5+[0,size(composite_grid,1)],'-k');
end
hold off;

plTime=0;
if plTime==1;
for i = 1:length(n_conds)
    for j = 1:length(min_dists)
        t = text( 5+(j-1)*composite_x,(i)*composite_y-40, sprintf('time = %0.2f sec', times_grid(i,j) ) );
        t.Color = [1 1 1];
        t.FontWeight = 'bold';
        t.FontSize = 5;
    end
end
end
t_grid{1}=times_grid;
c{1}=composite_grid;


cmap_parula=parula;
col0=cmap_parula(1,:);
col1=cmap_parula(end,:);
% next line: Black-white-Red
col0=[1 0 0];col1=[0 0 0];
cmap=cmap_linear([col0;1 1 1;col1],[0 pmarg1d(2) 1]);
colormap(cmap)
colorbar



%title(sprintf('Sensitivity analysis, max_cpdf = %i', max_cpdf_count))
print_mul(sprintf('est_%d_%d_%d_%d',length(n_conds),length(min_dists),O.n_max_cpdf_count,n_real))



%% Composite plot - estoi
if isfield(myOest{1,1},'TG2');
    composite_x = mask_x_bounds(2)-mask_x_bounds(1)+1;
    composite_y = mask_y_bounds(2)-mask_y_bounds(1)+1;
    composite_x_tot = length(n_conds)*composite_x;
    composite_y_tot = length(min_dists)*composite_y;
    composite_grid = NaN(composite_x_tot,composite_y_tot);
    times_grid = NaN(length(n_conds),length(min_dists));
    
    for i = 1:length(n_conds)
        for j = 1:length(min_dists)
            O = myOest{i,j};
            s = flipud(O.TG2(mask_y_bounds(1):mask_y_bounds(2), mask_x_bounds(1):mask_x_bounds(2)));
            composite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y)= s;
            %composite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y)= O.TG2(mask_x_bounds(1):mask_x_bounds(2), mask_y_bounds(1):mask_y_bounds(2));
            
            times_grid(i,j) = O.time;
        end
    end
    
    figure(7);imagesc(composite_grid);
    axis image
    % grid and custom tickers
    yticks([1:length(n_conds)]*composite_y-composite_y/2)
    yticklabels(n_conds)
    ylabel('n_c, number of conditionals')
    
    xticks([1:length(min_dists)]*composite_x-composite_x/2)
    xticklabels(min_dists)
    xlabel('d_{max}')
    
    hold on;
    for i = 1:length(n_conds)-1
        plot(0.5+[0,size(composite_grid,2)],0.5+[(i)*composite_x,(i)*composite_x],'-k');
    end
    for j = 1:length(min_dists)
        plot(0.5+[(j)*composite_y,(j)*composite_y],0.5+[0,size(composite_grid,1)],'-k');
    end
    hold off;
    
    colormap(cmap_geosoft)
    %colormap(gray)
    colormap(cmap_linear([0 0 0; 1 0 0; 0 1 0; 1 1 1]))
    caxis([0 n_real])
    cb=colorbar;
    set(get(cb,'Ylabel'),'String','Counts in conditional pd')
    %title(sprintf('Sensitivity analysis, max_cpdf = %i', max_cpdf_count))
    print_mul(sprintf('est_counts_%d_%d_%d_%d',length(n_conds),length(min_dists),O.n_max_cpdf_count,n_real))
end




%% Composite plot - simulation
if doSIM==1;
    composite_x = mask_x_bounds(2)-mask_x_bounds(1)+1;
    composite_y = mask_y_bounds(2)-mask_y_bounds(1)+1;
    composite_x_tot = length(n_conds)*composite_x;
    composite_y_tot = length(min_dists)*composite_y;
    composite_grid = NaN(composite_x_tot,composite_y_tot);
    times_grid = NaN(length(n_conds),length(min_dists));
    
    for i = 1:length(n_conds)
        for j = 1:length(min_dists)
            O = myOsim{i,j};
            se = flipud(O.em_sim(mask_y_bounds(1):mask_y_bounds(2), mask_x_bounds(1):mask_x_bounds(2)));
            composite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y) = se;
            %composite_grid(1+(i-1)*composite_x:(i)*composite_x,1+(j-1)*composite_y:(j)*composite_y) = O.em_sim(mask_x_bounds(1):mask_x_bounds(2), mask_y_bounds(1):mask_y_bounds(2));
            times_grid(i,j) = O.time;
        end
    end
    
    figure(6);imagesc(composite_grid);
    axis image
    % grid and custom tickers
    yticks([1:length(n_conds)]*composite_y-composite_y/2)
    yticklabels(n_conds)
    ylabel('n_c, number of conditionals')
    
    xticks([1:length(min_dists)]*composite_x-composite_x/2)
    xticklabels(min_dists)
    xlabel('d_{max}')
    
    hold on;
    for i = 1:length(n_conds)-1
        plot(0.5+[0,size(composite_grid,2)],0.5+[(i)*composite_x,(i)*composite_x],'-k');
    end
    for j = 1:length(min_dists)
        plot(0.5+[(j)*composite_y,(j)*composite_y],0.5+[0,size(composite_grid,1)],'-k');
    end
    hold off;
    
    if plTime==1;
    for i = 1:length(n_conds)
        for j = 1:length(min_dists)
            t = text( 5+(j-1)*composite_x,(i)*composite_y-40, sprintf('time = %0.2f sec', times_grid(i,j) ) );
            t.Color = [1 1 1];
            t.FontWeight = 'bold';
            t.FontSize = 5;
        end
    end
    end
    
    t_grid{2}=times_grid;
    c{2}=composite_grid;
    
    cmap_parula=parula;
    col0=cmap_parula(1,:);
    col1=cmap_parula(end,:);
    % next line: Black-white-Red
    col0=[1 0 0];col1=[0 0 0];
    cmap=cmap_linear([col0;1 1 1;col1],[0 pmarg1d(2) 1]);
    colormap(cmap)
    colorbar
    
    
    %title(sprintf('Sensitivity analysis, max_cpdf = %i', max_cpdf_count))
    print_mul(sprintf('simest_%d_%d_%d_%d',length(n_conds),length(min_dists),O.n_max_cpdf_count,n_real))
    
end




%%
figure
p1=semilogy(min_dists,[t_grid{1}],'-')
hold on
p2=plot(min_dists,[t_grid{2}],'--')
hold off
for ip=1:length(p1);
    set(p2(ip),'color',get(p1(ip),'Color'))
end
legend(p1,num2str(n_conds(:)))
grid on
ylabel('CPU time (s)')
xlabel('distance')
print_mul(sprintf('time_%d_%d_%d_%d',length(n_conds),length(min_dists),O.n_max_cpdf_count,n_real))

%%
figure;clf
imagesc([t_grid{1};t_grid{2}])

figure;clf
imagesc([c{1};c{2}])
