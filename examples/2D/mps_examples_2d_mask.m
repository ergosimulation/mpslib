% mps_example_2d_mask

%% Example 1. Three masks
clear all;close all
x=1:1:250;nx=length(x);
y=1:1:200;ny=length(y);
% mpslib options
O.parameter_filename='mps_snesim_2d_mask_a.txt';
O.n_real=1;            
O.debug=-1;
O.n_cond=16;
O.template_size=[20 20 1];
O.method='mps_snesim_tree'; 
%O.method='mps_snesim_list'; 
%O.method='mps_genesim'; 
O.plot=1; % Plot progress when calling mps_cpp_mask


% load TI
TI1=read_eas_matrix('TI1.dat');
TI2=read_eas_matrix('TI2.dat');
TI3=read_eas_matrix('TI3.dat');
TI4=read_eas_matrix('TI4.dat');

% The mask 3 regions, 3 TIs
SIM=ones(ny,nx).*NaN;
MASK=zeros(ny,nx)+1;
MASK(:,51:120)=2;
MASK(:,121:end)=3;
TI{1}=TI2;
TI{2}=TI3;
TI{3}=TI4;
O.mask_conditional = [1 1 1]; % For each mask 'mask_conditional' indicates wheter simulation should be conditional to previsouly simnulated data)

tic
[reals,O1,Omul]=mps_cpp_mask(TI,SIM,MASK,O);
print('-dpng',sprintf('%s_ex1',mfilename))
toc
figure(2);
imagesc(x,y,reals);axis image
print('-dpng',sprintf('%s_ex1_single',mfilename))

%% Example 2. Two regsions, with mask from simulation
Os=O;
Os.parameter_filename='mps_snesim_2d_mask_b.txt';
[MASK]=mps_cpp(TI1,SIM,Os);
MASK=MASK+1;
%%
clear TI
TI{1}=TI4;
TI{2}=TI4';
O.mask_conditional = [1 1];
O.mask_order = [2 1];
[reals2,O,Omul]=mps_cpp_mask(TI,SIM,MASK,O);
print('-dpng',sprintf('%s_ex2',mfilename))
figure(3);
imagesc(x,y,reals2);axis image
print('-dpng',sprintf('%s_ex2_single',mfilename))

