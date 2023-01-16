
clear all;close all
%%
subsample=1;
%di=5;nx=5;ny=5;
di=4;nx=12;ny=12;
%di=3;nx=18;ny=18;
%di=2;nx=24;ny=24;

useTI='strebelle';
doPlot=-1;
saveMAT=1;

for rseed=0:1:100;
    for Cmethod=[1:4]
        n_cond=nx*ny;
        entropy_cb_cond_sim_fct(Cmethod,nx,ny,rseed,n_cond,subsample,useTI,di,doPlot,saveMAT)
        n_cond=25;
        entropy_cb_cond_sim_fct(Cmethod,nx,ny,rseed,n_cond,subsample,useTI,di,doPlot,saveMAT)
    end
end
return


%%
%clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=1;entropy_cb_cond_sim;
%return
%
clear all;Cmethod=1;nx=20;ny=20;subsample=1;n_cond=116;entropy_cb_cond_sim
clear all;Cmethod=2;nx=20;ny=20;subsample=1;n_cond=116;entropy_cb_cond_sim
clear all;Cmethod=3;nx=20;ny=20;subsample=1;n_cond=116;entropy_cb_cond_sim
clear all;Cmethod=4;nx=20;ny=20;subsample=1;n_cond=116;entropy_cb_cond_sim


% LOOP OVER MANY ITERATIONS AND COMPUTE ENTROPY



%%
close all

clear all;di=5;Cmethod=1;nx=12;ny=12;subsample=1;n_cond=144;rseed=3;entropy_cb_cond_sim
clear all;di=5;Cmethod=2;nx=12;ny=12;subsample=1;n_cond=144;rseed=3;entropy_cb_cond_sim
clear all;di=5;Cmethod=3;nx=12;ny=12;subsample=1;n_cond=144;rseed=3;entropy_cb_cond_sim
clear all;di=5;Cmethod=4;nx=12;ny=12;subsample=1;n_cond=144;rseed=3;entropy_cb_cond_sim

%% n_cond=16
clear all;nx=26;ny=25;n_cond=16;saveMov=1;Cmethod=1;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=16;saveMov=1;Cmethod=2;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=16;saveMov=1;Cmethod=3;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=16;saveMov=1;Cmethod=4;entropy_cb_cond_sim;

%% n_cond=25
clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=1;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=2;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=3;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=4;entropy_cb_cond_sim;

%% n_cond=64
clear all;nx=26;ny=25;n_cond=64;saveMov=1;Cmethod=1;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=64;saveMov=1;Cmethod=2;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=64;saveMov=1;Cmethod=3;entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=64;saveMov=1;Cmethod=4;entropy_cb_cond_sim;

return
%%
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=1;useTI='cb4';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=2;useTI='cb4';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=3;useTI='cb4';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=4;useTI='cb4';entropy_cb_cond_sim;
%%
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=1;useTI='cb8';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=2;useTI='cb8';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=3;useTI='cb8';entropy_cb_cond_sim;
clear all;nx=26;ny=25;n_cond=8;saveMov=1;Cmethod=4;useTI='cb8';entropy_cb_cond_sim;
