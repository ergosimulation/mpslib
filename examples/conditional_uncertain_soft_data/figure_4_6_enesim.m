% figure_4_6_enesim
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
O.method='mps_genesim'; % MPS algorithm to run
O.origin=[1 1 0];
O.n_cond = n_cond; % number of conditional points
O.n_max_cpdf_count=30; % Set below \inf to improve CPU
O.n_cond=[n_cond];
O.n_max_ite=n_max_ite;

O.n_real=600;   %  optional number of realization

i_path_arr=[0,1,2];
i_soft_arr=[1,2,3];
figure(4);clf;
for i=1:length(i_path_arr)
    for j=1:length(i_soft_arr)
        try;progress_txt([i,j],[length(i_path_arr),length(i_soft_arr)]);end
        O.parameter_filename = sprintf('enesim_d%d_rpath%d.par',i_soft_arr(j),i_path_arr(i));
        O.soft_data_fnam = f_soft{i_soft_arr(j)};
        O.shuffle_simulation_grid = i_path_arr(i);
        [reals,O]=mps_cpp_thread(TI,SIM,O);
      
        subplot(length(i_path_arr),length(i_soft_arr),j+(i-1)*3)
        imagesc(etype(reals));caxis([0 1]);
        title(sprintf('ENESIM, d%d, rp%d',i_soft_arr(j),i_path_arr(i)))
        cb=colorbar;
        ylabel(cb, 'P(channel)')
        axis image
        colormap(cmap);
        drawnow
    end
end
print('-dpng','figure_4_6_enesim')