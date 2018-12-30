TI=channels;           %  training image
SIM=zeros(80,60).*NaN; %  simulation grid
O.method='mps_snesim_tree'; 
O.n_real=80;

% simulation on one CPU
t0=now;
[reals]=mps_cpp(TI,SIM,O);
disp(sprintf('Elapsed time (sequential): %g s',(now-t0)*(3600*24)))

% simulation on multiple CPUs (require the Matlab Parallel toolbox)
t0=now;
[reals]=mps_cpp_thread(TI,SIM,O);
disp(sprintf('Elapsed time (parallel): %g s',(now-t0)*(3600*24)))