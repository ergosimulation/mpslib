% mps_example_2d
%
% the mGstat toolbox is needed to run the examples below
%
clear all;close all

% load ti
f_ti{1}='ti_cb_6x6_120_120_1.dat';
f_ti{2}='ti_strebelle_125_125_1.dat';
i_ti=2;
TI=read_eas_matrix(['..',filesep,'..',filesep,'ti',filesep,f_ti{i_ti}]);


% setup simulation grid
x=1:1:80;nx=length(x);
y=1:1:40;ny=length(y);

SIM=ones(ny,nx).*NaN;

% setup some simulation options 
O_gen.n_real=25;            
O_gen.debug=0;
O_gen.n_cond=49;
O_gen.shuffle_simulation_grid=2; % Preferential path

%% UNCONDITIONAL
io=0;

% MPS_SNESIM_TREE
io=io+1;
O{io}=O_gen;
O{io}.name='SNESIM (tree)';
O{io}.parameter_filename='mps_snesim_2d.txt';
O{io}.method='mps_snesim_tree'; 


% % MPS_SNESIM_LIST
% io=io+1;
% O{io}=O_gen;
% O{io}.name='SNESIM (list)';
% O{io}.parameter_filename='mps_snesim_2d.txt';
% O{io}.method='mps_snesim_list'; 

% % MPS_GENESIM --> ENESIM style
% io=io+1;
% O{io}=O_gen;
% O{io}.name='ENESIM';
% O{io}.n_max_ite=1e+9;
% O{io}.n_max_cpdf_count=1e+9;
% O{io}.parameter_filename='mps_genesim_2d_enesim.txt';
% O{io}.method='mps_genesim'; 

% MPS_GENESIM --> GENERALIZED ENESIM style
io=io+1;
O{io}=O_gen;
O{io}.name='GENESIM';
O{io}.n_max_ite=1e+9;
O{io}.n_max_cpdf_count=10;
O{io}.parameter_filename='mps_genesim_2d.txt';
O{io}.method='mps_genesim'; 

% MPS_GENESIM --> Direct Sampling Style
io=io+1;
O{io}=O_gen;
O{io}.name='GENESIM/DSAMP';
O{io}.n_max_ite=1e+9;
O{io}.n_max_cpdf_count=1;
O{io}.parameter_filename='mps_genesim_2d_dsam.txt';
O{io}.method='mps_genesim'; 


% run 
nO=length(O);
for io=1:length(O);
    [reals_unc{io},O{io}]=mps_cpp(TI,SIM,O{io});
end

%%
figure(1);clf;
set(gcf,'name','Unconditional Etype')
for io=1:nO,
    [em,ev]=etype(reals_unc{io});
    
    subplot(nO,2,(io-1)*2+1);
    imagesc(O{io}.x, O{io}.y, em);
    axis image
    caxis([0 1])
    title([O{io}.name,' - Etype Mean'])
    
    subplot(nO,2,(io-1)*2+2);
    imagesc(O{io}.x, O{io}.y, ev);
    axis image
    title('Etype var')
end

figure(2);clf;
set(gcf,'name','Unconditional reals')
nr=5;
for io=1:nO,
    for ir=1:nr
        subplot(nO,nr,(io-1)*nr+ir)
        imagesc(x,y,reals_unc{io}(:,:,ir));caxis([0 1])
        if ir==1;
            title(O{io}.name)
        else
            title(sprintf('r_%d',ir))
        end
        axis image
    end
end

%%
%% MAKE HARD AND SOFT DATA
% hard data
z=O{1}.z;
m_ref=TI(1:ny,1:nx);
[xx,yy]=meshgrid(x,y);
nxy=prod(size(xx));
n_hard=12;
rng('seed')=1;
i_hard=randomsample(nxy,n_hard);
pos_hard(:,1)=xx(i_hard);
pos_hard(:,2)=yy(i_hard);
pos_hard(:,3)=z(1);
val_hard(:,1)=m_ref(i_hard);
f_hard='mps_2d_hard_data.dat';
write_eas(f_hard,[pos_hard val_hard]);

% soft data
ind=unique(m_ref(:));
clear p_soft;
[h,hx]=hist(m_ref(:),ind);
marg_1d=h./sum(h);
p_soft=ones(size(m_ref)).*NaN;
nx=length(x);
for ix=1:nx;
    if ix<60
        w_soft=ix/(60);
    else
        w_soft=1;
    end
    d=m_ref(:,ix);
    p=0.*d;
    i0=find(d==0);
    i1=find(d==1);
    
    p= d.*(1-w_soft) + marg_1d(1)*(w_soft);
    p_soft(:,ix)=p;
    
end
p_soft=[p_soft(:) 1-p_soft(:)];
f_soft='mps_2d_soft_data.dat';
write_eas(f_soft,[xx(:) yy(:) yy(:).*0+z(1) p_soft(:,1) p_soft(:,2)]);

% scattered soft
rng('seed')=1;
n_soft=277;
i_soft=randomsample(nxy,n_soft);
clear pos_soft val_soft;
pos_soft(:,1)=xx(i_soft);
pos_soft(:,2)=yy(i_soft);
pos_soft(:,3)=z(1);
w_soft = rand(1,n_soft);
val_soft(:,1)= m_ref(i_soft).*(1-w_soft) + marg_1d(1).*(w_soft);;
f_soft_scatter='mps_2d_soft_data_scatter.dat';
write_eas(f_soft_scatter,[pos_soft val_soft 1-val_soft]);

f_soft='mps_2d_soft_data_scatter.dat';


%% plot hard and soft data
figure(11);clf;
imagesc(x,y,m_ref);
xlabel('X')
ylabel('Y')
title('Reference model')
axis image;
ax=axis;
colorbar
set(gca,'ydir','reverse');
print('-dpng',sprintf('mps_2d_examples_reference_ti%02d.png',i_ti))

figure(12);
dh=read_eas(f_hard);
scatter(dh(:,1),dh(:,2),40,dh(:,4),'filled');
xlabel('X')
ylabel('Y')
title('Hard data')
axis image
axis(ax);
box on
colorbar;
set(gca,'ydir','reverse');
print('-dpng',sprintf('mps_2d_examples_hard_ti%02d.png',i_ti))

figure(13);
ds=read_eas(f_soft);
for i=1:length(ind);
    subplot(1,2,i);
    if i==1;
        scatter(ds(:,1),ds(:,2),40,ds(:,4),'filled');
    else
        scatter(ds(:,1),ds(:,2),40,ds(:,5),'filled');
    end
    caxis([0 1])
    xlabel('X')
    ylabel('Y')
    title(['soft data, ind=',num2str(ind(i))])
    axis image
    axis(ax);
    box on
    colorbar;
    set(gca,'ydir','reverse');
end
print('-dpng',sprintf('mps_2d_examples_hard_soft_ti%02d.png',i_ti))


%% HARD CONDITIONAL
for io=1:nO
    Oh{io}=O{io};
    [~,a,b]=fileparts(O{io}.parameter_filename);
    Oh{io}.parameter_filename=sprintf('%s_hard%s',a,b);
    Oh{io}.hard_data_filename=f_hard;
    [reals_hard{io},Oh{io}]=mps_cpp(TI,SIM,Oh{io});
end

%%
figure(3);clf;
set(gcf,'name','Hard conditional Etype')
for io=1:nO,
    [em,ev]=etype(reals_hard{io});
    
    subplot(nO,2,(io-1)*2+1);
    imagesc(O{io}.x, O{io}.y, em);
    axis image
    caxis([0 1])
    title([O{io}.name,' - Etype Mean'])
    
    subplot(nO,2,(io-1)*2+2);
    imagesc(O{io}.x, O{io}.y, ev);
    axis image
    title('Etype var')
end

figure(4);clf;
set(gcf,'name','Hard conditional reals')
nr=5;
for io=1:nO,
    for ir=1:nr
        subplot(nO,nr,(io-1)*nr+ir)
        imagesc(x,y,reals_hard{io}(:,:,ir));caxis([0 1])
        if ir==1;
            title(O{io}.name)
        else
            title(sprintf('r_%d',ir))
        end
        axis image
    end
end

    
%% SOFT CONDITIONAL
for io=1:nO
    Os{io}=O{io};
    [~,a,b]=fileparts(O{io}.parameter_filename);
    Os{io}.parameter_filename=sprintf('%s_soft%s',a,b);
    Os{io}.soft_data_filename=f_soft;
    [reals_soft{io},Os{io}]=mps_cpp(TI,SIM,Os{io});
end

%% plot SOFT CONDITIONAL
figure(5);clf;
set(gcf,'name','Soft conditional Etype')
for io=1:nO,
    [em,ev]=etype(reals_soft{io});
    
    subplot(nO,2,(io-1)*2+1);
    imagesc(O{io}.x, O{io}.y, em);
    axis image
    caxis([0 1])
    title([O{io}.name,' - Etype Mean'])
    
    subplot(nO,2,(io-1)*2+2);
    imagesc(O{io}.x, O{io}.y, ev);
    axis image
    title('Etype var')
end

figure(6);clf;
set(gcf,'name','Soft conditional reals')
nr=5;
for io=1:nO,
    for ir=1:nr
        subplot(nO,nr,(io-1)*nr+ir)
        imagesc(x,y,reals_soft{io}(:,:,ir));caxis([0 1])
        if ir==1;
            title(O{io}.name)
        else
            title(sprintf('r_%d',ir))
        end
        axis image
    end
end



%% HARD AND SOFT CONDITIONAL
for io=1:nO
    Ohs{io}=O{io};
    [~,a,b]=fileparts(O{io}.parameter_filename);
    %try, Ohs{io}=rmfield(Ohs{io},'soft_data_fnam');end
    Ohs{io}.parameter_filename=sprintf('%s_hard_soft%s',a,b);
    Ohs{io}.hard_data_filename=f_hard;
    Ohs{io}.soft_data_filename=f_soft;
    [reals_hardsoft{io},Ohs{io}]=mps_cpp(TI,SIM,Ohs{io});
end

%% plot HARD SOFT CONDITIONAL
figure(7);clf;
set(gcf,'name','Hard and Soft conditional Etype')
for io=1:nO,
    [em,ev]=etype(reals_hardsoft{io});
    
    subplot(nO,2,(io-1)*2+1);
    imagesc(O{io}.x, O{io}.y, em);
    axis image
    caxis([0 1])
    title([O{io}.name,' - Etype Mean'])
    
    subplot(nO,2,(io-1)*2+2);
    imagesc(O{io}.x, O{io}.y, ev);
    axis image
    title('Etype var')
end

figure(8);clf;
set(gcf,'name','Hard and Soft conditional reals')
nr=5;
for io=1:nO,
    for ir=1:nr
        subplot(nO,nr,(io-1)*nr+ir)
        imagesc(x,y,reals_hardsoft{io}(:,:,ir));caxis([0 1])
        if ir==1;
            title(O{io}.name)
        else
            title(sprintf('r_%d',ir))
        end
        axis image
    end
end

    
%% Hard copys
for i=1:8;
    fn=get(figure(i),'name');
    print_mul(fn);
end

