% mps_cpp_ex_thread: Example of using multicores with mps_cpp
clear all;close all;
TI=mps_ti;           %  training image
figure;
imagesc(TI);
axis image;

SIM=zeros(80,60).*NaN; %  simulation grid
SIM(50,52)=0;
SIM([1:25:80],20)=1;
O.method='mps_snesim_tree'; 
O.n_real=148;
O.template_size=[15 15 1; 5 5 1]';

% simulation on one CPU
t0=now;
[reals, Osingle]=mps_cpp(TI,SIM,O);
t_single=(now-t0)*(3600*24);
disp(sprintf('Elapsed time (sequential): %g s',t_single))
mps_cpp_plot(reals,Osingle);

% simulation on multiple CPUs (requires the Matlab Parallel toolbox)
t0=now;
[reals, Othread]=mps_cpp_thread(TI,SIM,O);
t_thread=(now-t0)*(3600*24);
disp(sprintf('Elapsed time (parallel): %g s',t_thread))
mps_cpp_plot(reals,Othread);

disp(sprintf('Speedup = %3.1f (parallel/single): %g s',t_single/t_thread))

