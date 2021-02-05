% mps_example_softwarex
%
% Figure for SoftwareX manuscript 
%
rng(1);
clear all;close all

nx=80;ny=50;

TI=mps_ti('ti_strebelle_250_250_1.dat');
TI=TI(2:2:end,2:2:end);

SIM=zeros(ny,nx).*NaN; %  simulation grid

% options for all
nhard=7;
nc=7;

%nhard=7;6;20;15;5;1;6;30;
%nc=7; % TEMPLATE SIZE
%nc=10; % TEMPLATE SIZE
%nc=2;
%nc=7;

Oorg.n_multiple_grids=3; % --> !!
Oorg.rseed=1;             %  optional number of realization
Oorg.template_size=[nc nc 1]; % SNESIM TYPE COND
Oorg.n_cond=nc^2; % ENESIM TYPE COND
Oorg.n_real=600;             %  optional number of realization
Oorg.shuffle_simulation_grid=1;

%%

x=0:1:(nx-1);
y=0:1:(ny-1);

%% different methods
io=0;

io=io+1;
O{io}=Oorg;
O{io}.method='mps_snesim_tree';
O{io}.n_min_node_count=2;
%O{io}.n_cond_max=10;

io=io+1;
O{io}=Oorg;
O{io}.method='mps_snesim_list';
O{io}.n_min_node_count=2;

io=io+1;
O{io}=Oorg;
O{io}.method='mps_genesim';
O{io}.n_max_cpdf_count=100000;
O{io}.n_max_ite=100000;
 
io=io+1;
O{io}=Oorg;
O{io}.method='mps_genesim';
O{io}.n_max_cpdf_count=10;
O{io}.n_max_ite=100000;

io=io+1;
O{io}=Oorg;
O{io}.method='mps_genesim';
O{io}.n_max_cpdf_count=1;
O{io}.n_max_ite=100000;


%% CONDITIONAL DATA
% hard data
clear d_c
n_shift=10; % dx,dy from origin

d_x=ceil(rand(1,nhard).*(nx-1));
d_y=ceil(rand(1,nhard).*(ny-1));
d_z=d_y.*0;
for i=1:nhard
    d_c(i)=TI(d_y(i)+n_shift,d_x(i)+n_shift);
    %d_c(i)=1;
end
f_cond='f_hard.dat';
d_cond=[d_x(:) d_y(:) d_z(:) d_c(:)];
write_eas(f_cond,d_cond);

% soft
try;clear d_soft;end
[xx,yy]=meshgrid(x,y);
m_ref=TI(1:ny,1:nx);
n_s=5;
m_soft_conv=conv2(TI-.5,ones(n_s,n_s),'same')./n_s^2;
m_soft_conv=m_soft_conv([1:ny]+n_shift,[1:nx]+n_shift);

m_soft=0.*m_soft_conv;
c_frac=linspace(0,1,size(m_soft,2));
for ix=1:size(m_soft,2);
    m_soft(:,ix)=0.5 + c_frac(ix)*m_soft_conv(:,ix);
end

p_0 = 1-m_soft(:);
p_1 = m_soft(:);

sp=(p_0+p_1);
p_0=p_0./sp;
p_1=p_1./sp;

d_soft=[xx(:) yy(:) yy(:).*0 p_0 p_1];
f_soft='f_soft.dat';
write_eas(f_soft,d_soft);

%% plot data
try;close(1);end
figure(1);set_paper;
cmap_ref=1-gray;

subplot(3,2,[1 3]);
imagesc(TI);axis image;
xlabel('X [pixel #]')
ylabel('Y [pixel #]')
title('a) Training image')
%print_mul('mps_softwareX_ti')
caxis([-1 1])
D=SIM.*0-1;
for i=1:nhard
    D(d_y(i),d_x(i))=d_c(i);;
end

%subplot(3,2,2);
%imagesc(D);axis image;
%caxis([-1 1])
%xlabel('X')
%label('Y')
%hold on
%scatter(d_cond(:,1),d_cond(:,2),50,1-d_cond(:,4),'filled')
%scatter(d_cond(:,1),d_cond(:,2),40,d_cond(:,4),'filled')
%hold off
%title('b) Simulation grid with hard data')
colormap(cmap_linear([1 1 1; cmap_ref(1,:) ; cmap_ref(end,:)]))

subplot(3,2,[2 4]);
imagesc(reshape(d_soft(:,5),ny,nx));axis image;
xlabel('X')
ylabel('Y')
caxis([0 1])
colormap(gca,flipud(hot))
colorbar
hold on
scatter(d_cond(:,1),d_cond(:,2),50,1-d_cond(:,4),'filled')
scatter(d_cond(:,1),d_cond(:,2),40,d_cond(:,4),'filled')
hold off
title('b) Simulation grid\newline hard and soft data, P(m_i)=1')

print_mul(sprintf('mps_softwareX_ti_sim_NH%d',nhard))

%% UNCONDITIONAL SIMULATION
for io=1:length(O);
    O{io}.n_real=3;
    tic
    [reals{io},O{io},Othread{io}]=mps_cpp_thread(TI,SIM,O{io});
    %[reals{io},O{io}]=mps_cpp(TI,SIM,O{io});
    t1(io)=toc;
end


%% CONDITIONAL SIMULATION / HARD
Oc=O;
for io=1:length(Oc);    
    Oc{io}.d_hard=d_cond;
    Oc{io}.n_real=Oorg.n_real;
    Oc{io}.hard_data_filename=f_cond;
    Oc{io}.hard_data_search_radius=1;
    Oc{io}.soft_data_fnam='no_soft.dat';
    tic
    [reals_cond{io},Oc{io}]=mps_cpp_thread(TI,SIM,Oc{io});
    %[reals_cond{io},Oc{io}]=mps_cpp(TI,SIM,Oc{io});
    t2(io)=toc
end

%% CONDITIONAL SIMULATION / HARD AND SOFT
use_soft_data=1;
Oc_s=Oc;
for io=1:length(Oc_s);
    if use_soft_data==1;
        Oc_s{io}.d_soft=d_soft;
        Oc_s{io}.soft_data_fnam=f_soft;
    end
    tic
    
    [reals_cond_s{io},Oc_s{io}]=mps_cpp_thread(TI,SIM,Oc_s{io});
    t3(io)=toc
end



%% plot uncond
figure(3);clf;set_paper;('portrait');
nr=Oorg.n_real;
nr=3;
nr_use=5;
nO=length(reals);
for io=1:nO;
    j=(io-1)*nr_use;
    for ir=1:nr;
        subplot(nO,nr_use,j+ir);
        imagesc(x,y,reals{io}(:,:,ir));
        set(gca,'FontSize',8)
        axis image;
        if ir==1;
            txt=sprintf('%s) %s',char(96+io),O{io}.method);
            try
                txt=sprintf('%s) %s (Nmax=%d)',char(96+io),O{io}.method,O{io}.n_max_cpdf_count);
            end
            h_t=title(txt,'interp','none','FontSize',16);
            set(h_t,'HorizontalAlignment','Left')
            pos=get(h_t,'Position');
            pos(1)=-50;
            set(h_t,'Position',pos);fname=sprintf('mps_softwareX_NMG%d_NC%d_TS%d_SH%d_NH%d',Oc{1}.n_multiple_grids,Oc{1}.n_cond,Oc{1}.template_size(1),Oc{1}.shuffle_simulation_grid,nhard);
            s=suptitle(fname);
            set(s,'interpreter','none')
            
        end
    end
    [em,ev]=etype(reals{io});
    subplot(nO,nr_use,j+ir+1);
    imagesc(x,y,em);caxis([0 1]);axis image
    subplot(nO,nr_use,j+ir+2);
    imagesc(x,y,ev);caxis([0 .2]);axis image
  
    
end
print_mul('mps_softwareX_reals')


%% plot cond  hard
figure(4);clf;set_paper('portrait');
nO=length(reals);
for io=1:(nO);
    j=(io-1)*nr_use;
    for ir=1:nr;
        ax1=subplot(nO+3,nr_use,j+ir);
        imagesc(x,y,reals_cond{io}(:,:,ir));
        colormap(ax1,1-gray);
        set(gca,'FontSize',8)
        axis image;
        if ir==1;
            txt=sprintf('%s) %s',char(96+io),O{io}.method);
            try
                txt=sprintf('%s) %s (Nmax=%d)',char(96+io),O{io}.method,O{io}.n_max_cpdf_count);
            end
            h_t=title(txt,'interp','none','FontSize',16);
            set(h_t,'HorizontalAlignment','Left')
            pos=get(h_t,'Position');
            pos(1)=-50;
            set(h_t,'Position',pos);
           
        end
    end
    [em,ev]=etype(reals_cond{io});
    d=reals_cond{1}(:);P0=(sum(d==0))/length(d);

    ax2=subplot(nO+3,nr_use,j+ir+1);
    imagesc(x,y,em);caxis([0 1]);axis image
    %colormap(ax2,1-gray);
    colormap(ax2,flipud(hot));
    set(gca,'FontSize',8)
        
    hold on
    %plot(d_cond(:,1),d_cond(:,2),'w.','MarkerSize',30)
    scatter(d_cond(:,1),d_cond(:,2),40,1-d_cond(:,4),'filled')
    scatter(d_cond(:,1),d_cond(:,2),30,d_cond(:,4),'filled')
    hold off
    if io==1; title('Etype mean');   end
    
    ax3=subplot(nO+3,nr_use,j+ir+2);
    imagesc(x,y,sqrt(ev));caxis([.2 .7]);axis image
    colormap(ax3,1-gray);
    colormap(ax3,flipud(hot));
    set(gca,'FontSize',8)
    hold on
    plot(d_cond(:,1),d_cond(:,2),'ko','MarkerSize',5)
    hold off
    if io==1; title('Etype std');   end
    
    %title(sprintf('P_{1Dmarg}=[%3.2f %3.2f]',P0,1-P0))
    
end
fname=sprintf('mps_softwareX_NMG%d_NC%d_TS%d_SH%d_NH%d',Oc{1}.n_multiple_grids,Oc{1}.n_cond,Oc{1}.template_size(1),Oc{1}.shuffle_simulation_grid,nhard);
print_mul(fname)
s=suptitle(fname);
set(s,'interpreter','none')
print_mul([fname,'_title'])

%%%%%%%%%

%% plot cond  hard and SOFT
figure(5);clf;set_paper('portrait');
nO=length(reals);
for io=1:(nO);
    j=(io-1)*nr_use;
    for ir=1:nr;
        ax1=subplot(nO+3,nr_use,j+ir);
        imagesc(x,y,reals_cond_s{io}(:,:,ir));
        colormap(ax1,1-gray);
        set(gca,'FontSize',8)
        axis image;
        if ir==1;
            txt=sprintf('%s) %s',char(96+io),O{io}.method);
            try
                txt=sprintf('%s) %s (Nmax=%d)',char(96+io),O{io}.method,O{io}.n_max_cpdf_count);
            end
            h_t=title(txt,'interp','none','FontSize',16);
            set(h_t,'HorizontalAlignment','Left')
            pos=get(h_t,'Position');
            pos(1)=-50;
            set(h_t,'Position',pos);
           
        end
    end
    [em,ev]=etype(reals_cond_s{io});
    d=reals_cond{1}(:);P0=(sum(d==0))/length(d);

    ax2=subplot(nO+3,nr_use,j+ir+1);
    imagesc(x,y,em);caxis([0 1]);axis image
    colormap(ax2,1-gray);
    colormap(ax2,flipud(hot));
    set(gca,'FontSize',8)
        
    hold on
    %plot(d_cond(:,1),d_cond(:,2),'w.','MarkerSize',30)
    scatter(d_cond(:,1),d_cond(:,2),40,1-d_cond(:,4),'filled')
    scatter(d_cond(:,1),d_cond(:,2),30,d_cond(:,4),'filled')
    hold off
    if io==1; title('Etype mean');   end
    
    
    ax3=subplot(nO+3,nr_use,j+ir+2);
    imagesc(x,y,sqrt(ev));caxis([0.2 .7]);axis image
    colormap(ax3,1-gray);
    colormap(ax3,flipud(hot));
    set(gca,'FontSize',8)
    hold on
    plot(d_cond(:,1),d_cond(:,2),'ko','MarkerSize',5)
    hold off
    if io==1; title('Etype std');   end
    
    
    %title(sprintf('P_{1Dmarg}=[%3.2f %3.2f]',P0,1-P0))
    
end
fname=sprintf('mps_softwareX_NMG%d_NC%d_TS%d_SH%d_NH%d_soft',Oc{1}.n_multiple_grids,Oc{1}.n_cond,Oc{1}.template_size(1),Oc{1}.shuffle_simulation_grid,nhard);
print_mul(fname)
s=suptitle(fname);
set(s,'interpreter','none')
print_mul([fname,'_title'])

save(fname)

return

%%
%% SNESIM FORTRAN
x=[0:1:(O{1}.simulation_grid_size(1)-1)].*O{1}.grid_cell_size(1)+O{1}.origin(1);
y=[0:1:(O{1}.simulation_grid_size(2)-1)].*O{1}.grid_cell_size(2)+O{2}.origin(2);

S = snesim_init(TI,x,y);
S.fconddata.fname=Oc{1}.hard_data_filename;
S.nsim=Oorg.n_real;
S.nsim=max([4 ceil(Oorg.n_real/10)]);
S.max_cond=Oorg.n_cond;
S.nmulgrids=Oorg.n_multiple_grids+1;
tic;
S=snesim(S);
%S=snesim(S,x,y);
t2(io+1)=toc


% PLOT SNESIM RESULTS
for i=1:3;
    ax1=subplot(nO+3,nr_use,nr_use*(nO)+i)
    imagesc(S.D(:,:,i));
    colormap(ax1,1-gray);
    axis image;
    set(gca,'FontSize',8)

    if i==1;
        txt=sprintf('%s) SNESIM (STANFORD)',char(96+io));
        h_t=title(txt,'interp','none','FontSize',16);
        set(h_t,'HorizontalAlignment','Left')
        pos=get(h_t,'Position');
        pos(1)=-50;
        set(h_t,'Position',pos);
    end
end
ax2=subplot(nO+3,nr_use,nr_use*(nO)+4)
imagesc(S.x,S.y,S.etype.mean);
colormap(ax2,1-gray);
caxis([0 1])
axis image;
set(gca,'FontSize',8)
hold on
plot(d_cond(:,1),d_cond(:,2),'w.','MarkerSize',30)
scatter(d_cond(:,1),d_cond(:,2),30,d_cond(:,4),'filled')
hold off

ax3=subplot(nO+3,nr_use,nr_use*(nO)+5)
imagesc(S.x,S.y,sqrt(S.etype.var));
colormap(ax3,1-gray);
hold on
plot(d_cond(:,1),d_cond(:,2),'ko','MarkerSize',5)
hold off
axis image;
caxis([0.2 .7])
set(gca,'FontSize',8)

fname=sprintf('mps_softwareX_NMG%d_NC%d_TS%d_SH%d_NH%d_SNESIM',Oc{1}.n_multiple_grids,Oc{1}.n_cond,Oc{1}.template_size(1),Oc{1}.shuffle_simulation_grid,nhard);
s=suptitle(fname);
set(s,'interpreter','none')
print_mul(fname)

%%
  save(fname)
