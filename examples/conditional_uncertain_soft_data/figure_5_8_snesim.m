% figure_5_snesim
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
n_cond = 25;
nt=floor(sqrt(n_cond));
TI = read_eas_matrix('ti.dat');
SIM = ones(ny,nx).*NaN;

O.method='mps_snesim_tree'; % MPS algorithm to run 
O.origin=[1 1 0];

O.n_max_cpdf_count=1; % ENESIM style simulation
O.template_size=[nt nt 1];
O.n_cond = n_cond;
O.hard_data_search_radius=130;
O.n_multiple_grids=1;

O.n_real=600;   %  optional number of realization

i_path_arr=[0,1,2];
i_soft_arr=[1,2,3];

figure(5);clf;
for i=1:length(i_path_arr)
    for j=1:length(i_soft_arr)
        try;progress_txt([i,j],[length(i_path_arr),length(i_soft_arr)]);end
        O.parameter_filename = sprintf('snesim_d%d_rpath%d.par',i_soft_arr(j),i_path_arr(i));
        O.soft_data_fnam = f_soft{i_soft_arr(j)};
        O.shuffle_simulation_grid = i_path_arr(i);
        [reals,O]=mps_cpp_thread(TI,SIM,O);
        subplot(length(i_path_arr),length(i_soft_arr),j+(i-1)*3)
        imagesc(etype(reals));caxis([0 1]);
        title(sprintf('SNESIM, d%d, rp%d',i_soft_arr(j),i_path_arr(i)))
        cb=colorbar;
        ylabel(cb, 'P(channel)')
        axis image
        colormap(cmap);
        drawnow
    end
end
print('-dpng','figure_5_8_snesim')