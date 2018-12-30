% figure_9_10_ds_nonco
clear all;
x=1:1:30;nx=length(x);
y=1:1:30;ny=length(y);

%%
cmap=load('cmap_em.dat');

%% LOAD SOFT DATA
f_soft{1}='soft_case1.dat';
f_soft{2}='soft_case2.dat';
f_soft{3}='soft_case3.dat';

d_soft{1}=read_eas(f_soft{1});
d_soft{2}=read_eas(f_soft{2});
d_soft{3}=read_eas(f_soft{3});


% SETUP SIMULATION
TI = read_eas_matrix('ti.dat');
SIM = ones(ny,nx).*NaN;

n_cond=5^2;n_max_ite=4000; % OLD RUN
O.method='mps_genesim'; % MPS algorithm to run (def='mps_snesim_tree')
O.origin=[1 1 0];
O.n_cond = n_cond; % number of conditional points
O.n_max_cpdf_count=1; % DIRECT SAMPLING!
O.n_cond=[n_cond];
O.n_max_ite=n_max_ite;

O.n_real=600;   %  number of realizations

n_cond_soft = [1 3 25];
max_search_radius_soft=1000;

for rpath = [1,2];
    O.shuffle_simulation_grid = rpath;
    O.max_search_radius=[1000 max_search_radius_soft]; % SEARCH SOFT DATA AWAY FROM COLOCATED LOCATION
    
    i_soft_arr=[1,2,3];
    
    i_soft_arr=[1,2,3];
    figure(8+rpath);clf,
    for i=1:length(n_cond_soft)
        for j=1:length(i_soft_arr)
            try;progress_txt([i,j],[length(n_cond_sodr),length(i_soft_arr)]);end
            O.parameter_filename = sprintf('ds_d%d_ncond_soft%d_rpath%d.par',i_soft_arr(j),n_cond_soft(i),rpath);
            O.soft_data_fnam = f_soft{i_soft_arr(j)};
            O.n_cond=[n_cond n_cond_soft(i)];
            
            [reals,O]=mps_cpp_thread(TI,SIM,O);
            
            subplot(length(n_cond_soft),length(i_soft_arr),j+(i-1)*3)
            imagesc(etype(reals));caxis([0 1]);
            title(sprintf('DS, d%d, N_{soft}%d, rp=%d',i_soft_arr(j),n_cond_soft(i),rpath))
            cb=colorbar;
            ylabel(cb, 'P(channel)')
            axis image
            colormap(cmap);
            drawnow
        end
    end
    print('-dpng',sprintf('figure_%d_rpath%d_ds_nonco',8+rpath,rpath))
end
