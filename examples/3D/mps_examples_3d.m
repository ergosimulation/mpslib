% mps_example_softwarex
%
% Figure for SoftwareX manuscript 
clear all;close all

n_real=4;

x=1:1:80;nx=length(x);
y=1:1:40;ny=length(y);
z=1:1:30;nz=length(z);



f_ti{1}='ti_cb_6x6_40_40_40.dat';
i_ti=1;


% load TI
TI=read_eas_matrix(['..',filesep,'..',filesep,'ti',filesep,f_ti{i_ti}]);

% setup simulation grid
SIM=zeros(ny,nx,nz);

O.n_real=n_real;            
O.debug=1;
O.n_cond=25;

%% UNCONDITIONAL
% MPS_SNESIM_TREE
O.parameter_filename='mps_snesim_3d_unconditional.txt';
O.method='mps_snesim_tree'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);


%% MPS_GENESIM_TREE / ENESIM1e+9 / DSIM
% % ENESIM TYPE SIMULATION IS TOO SLOW IN 3D
% O.n_max_ite=1e+9;
% O.n_max_cpdf_count=1e+9;
% O.parameter_filename='mps_genesim_3d_enesim_unconditional.txt';
% O.method='mps_genesim'; 
% O.n_real=n_real;            
% [reals,O]=mps_cpp(TI,SIM,O);

O.n_max_ite=1000;
O.n_max_cpdf_count=10;
O.parameter_filename='mps_genesim_3d_unconditional.txt';
O.method='mps_genesim'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);

O.n_max_ite=1000;
O.n_max_cpdf_count=1;
O.parameter_filename='mps_genesim_3d_dsam_unconditional.txt';
O.method='mps_genesim'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);


%% MAKE HARD DATA
m_ref=[reals(:,:,:,1)];
try;m_ref=TI(1:ny,1:nx,1:nz);;end
try
    clear pos_hard val_hard;
end

[xx,yy,zz]=meshgrid(O.x,O.y,O.z);
%xx=permute(xx,[2 1 3]);
%yy=permute(yy,[2 1 3]);
%zz=permute(zz,[2 1 3]);

nxyz=prod(size(xx));
n_hard=12;
i_hard=randomsample(nxyz,12);
pos_hard(:,1)=xx(i_hard);
pos_hard(:,2)=yy(i_hard);
pos_hard(:,3)=zz(i_hard);
val_hard(:,1)=m_ref(i_hard);
write_eas('mps_3d_hard_data.dat',[pos_hard val_hard]);

%% soft data
ind=unique(m_ref(:));
clear p_soft;
[h,hx]=hist(m_ref(:),ind);
marg_1d=h./sum(h);
for i=1:length(ind);
    p_soft(:,i)=zeros(nxyz,1);
    ii=find(m_ref==ind(i));
    p_soft(ii,i)=1;    
end
p_soft=p_soft+.7;
sum_p_soft=sum(p_soft')';
NM=repmat(sum_p_soft,[1,length(ind)]);
p_soft=p_soft./NM;

write_eas('mps_3d_soft_data.dat',[xx(:) yy(:) zz(:) p_soft]);


%%
% figures
figure(1);clf;
s=slice(xx,yy,zz,m_ref,O.x(end),[O.y(1) O.y(end)],O.y(1));
shading flat
xlabel('X')
ylabel('Y')
zlabel('Z')
title('Reference model')
axis image;
ax=axis;
colorbar
set(gca,'ydir','reverse');
print('-dpng',sprintf('mps_3d_examples_reference_ti%02d.png',i_ti))


title('Reference model - Hard Data')
hold on
scatter3(pos_hard(:,1),pos_hard(:,2),pos_hard(:,3),40,val_hard,'filled');
hold off
for is=1:length(s);alpha(s(is),.5);end
print('-dpng',sprintf('mps_3d_examples_hard_ti%02d.png',i_ti))

figure(3);
for i=1:length(ind);
    subplot(2,2,i);
    scatter3(xx(:),yy(:),zz(:),40,p_soft(:,i),'filled');
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
print('-dpng',sprintf('mps_3d_examples_hard_soft_ti%02d.png',i_ti))

%% CONDITIONAL
O.hard_data_filename = 'mps_3d_hard_data.dat';

% MPS_SNESIM_TREE
O.parameter_filename='mps_snesim_3d_hard.txt';
O.method='mps_snesim_tree'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);

% MPS_GENESIM_TREE / ENESIM1e+9 / DSIM
% % Traditional ENESIM not feasible in 3D
% O.n_max_ite=1e+9;
% O.n_max_cpdf_count=1e+9;
% O.parameter_filename='mps_genesim_3d_enesim_hard.txt';
% O.method='mps_genesim'; 
% O.n_real=n_real;            
% [reals,O]=mps_cpp(TI,SIM,O);

O.n_max_ite=1000;
O.n_max_cpdf_count=10;
O.parameter_filename='mps_genesim_3d_hard.txt';
O.method='mps_genesim'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);

O.n_max_ite=1000;
O.n_max_cpdf_count=1;
O.parameter_filename='mps_genesim_3d_dsam_hard.txt';
O.method='mps_genesim'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);



%% CONDIIONAL SOFT DATA
O.hard_data_filename = 'mps_3d_hard_data.dat';
O.soft_data_fnam = 'mps_3d_soft_data.dat';
O.soft_data_categories='0;1;2;3';

% MPS_SNESIM_TREE
O.parameter_filename='mps_snesim_3d_hard_soft.txt';
O.method='mps_snesim_tree'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);


% % MPS_GENESIM_TREE / ENESIM1e+9 / DSIM
% O.n_max_ite=1e+9;
% O.n_max_cpdf_count=1e+9;
% O.parameter_filename='mps_genesim_3d_enesim_hard_soft.txt';
% O.method='mps_genesim'; 
% O.n_real=n_real;            
% [reals,O]=mps_cpp(TI,SIM,O);

O.n_max_ite=1000;
O.n_max_cpdf_count=10;
O.parameter_filename='mps_genesim_3d_hard_soft.txt';
O.method='mps_genesim'; 
O.n_real=n_real;            
[reals,O]=mps_cpp(TI,SIM,O);


