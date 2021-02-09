% mps_cpp_example_estimation
% Example of applying sequential estimation, and comparing to results
% obtained using sequential simulation.
clear all;

TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulation grid
SIM(10:12,20)=0; % some conditional data
SIM(40:40:43)=1; % some mode conditional data
O.method='mps_genesim';
O.n_cond=15;


% A: compute the marginal conditional probability using
% sequential SIMULATION
O.n_real=50;
t0=now;
[reals,OA]=mps_cpp(TI,SIM,O);
t1A=(now-t0)*3600*24;
[P1_marg_sim]=etype(reals);

%%% B: compute the marginal conditional probability using 
% sequential ESTIMATION
O.doEstimation=1;
O.n_cond=6;
O.n_max_cpdf_count=10000;
t0=now;
[reals,OB]=mps_cpp(TI,SIM,O);
t1B=(now-t0)*3600*24;
P1_marg_est = OB.cg(:,:,2);

%%% C: compute the marginal conditional probability using 
% sequential ESTIMATION, using multiple threads 
O.doEstimation=1;
t0=now;
[est,OC]=mps_cpp_estimation(TI,SIM,O);
t1C=(now-t0)*3600*24;
P1_marg_est_par = est(:,:,2);

figure(1);
subplot(1,3,1);
imagesc(OA.x, OA.y, P1_marg_sim);
axis image;caxis([0 1]);colorbar
title(sprintf('P(m_i=1), SeqSim, nReal=%d, t=%3.1fs, n_c=%d',OA.n_real,t1A, OA.n_cond))

subplot(1,3,2);
imagesc(OA.x, OA.y, P1_marg_est);
axis image;caxis([0 1]);colorbar
title(sprintf('P(m_i=1), SeqEst, t=%3.1fs,  n_c=%d',t1B, OB.n_cond))

subplot(1,3,3);
imagesc(OA.x, OA.y, P1_marg_est_par);
axis image;caxis([0 1]);colorbar
title(sprintf('P(m_i=1), SeqEstPat, t=%3.1fs, n_c=%d',t1C, OC.n_cond))





