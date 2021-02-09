% mps_cpp_example_readthedocs: 
% The example used for https://mpslib.readthedocs.io/en/latest/matlab-interface.html
clear all

%% DEFAULT

TI=mps_ti;             %  training image
SIM=zeros(80,60).*NaN; %  simulation grid
O.template_size= [5 5 1]';
[reals,O]=mps_cpp(TI,SIM,O);

O

%% GENESIM
clear all;
TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulationgrid
O.method='mps_genesim';
[reals,O]=mps_cpp(TI,SIM,O);

O

%% Sequential estimation
clear all;
TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulationgrid
SIM(10:12,20)=0;
SIM(40:40:43)=1;
O.method='mps_genesim';
O.doEstimation=1;

[reals,O]=mps_cpp(TI,SIM,O);
est = O.cg;


%estimation using parallel threads
O.n_max_cpdf_count=100000;
[est]=mps_cpp_estimation(TI,SIM,O);

%% Sequential estimation
clear all;
TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulation grid
O.method='mps_snesim_tree';
O.doEntropy=1;
O.doEstimation=0;
O.n_real = 10;
[reals,O]=mps_cpp(TI,SIM,O);

O.SI 

H_est = mean(O.SI)


