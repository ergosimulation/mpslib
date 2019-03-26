clear all;
SIM=ones(30,30).*NaN;
TI=read_eas_matrix('ti.dat');%
cmap=cmap_linear([1 1 1; 1 0 0; 0 0 0]);

O.parameter_filename='mps_genesim_test.txt';
O.method='mps_genesim';
O.soft_data_fnam='soft_as_softhard.dat';
O.n_max_ite=100000;
O.n_max_cpdf_count=1;
O.max_search_radius=[10000 10000];

O.debug=1;
O.n_real=50;
O.clean = 1;
%O.exe_root = 'E:\Users\tmh\RESEARCH\PROGRAMMING\GITHUB\MPSLIB\msvc2017\x64\Release';


nc_soft=[0 1 3];
j=0;
for ic=1:length(nc_soft);
    for k=1:2;
        disp(sprintf('ic=%d, k=%d ', ic,k))
        j=j+1;
        %O.n_cond = [25 nc_soft(ic)];O.shuffle_simulation_grid=k;
        O.n_cond = [9 nc_soft(ic)];O.shuffle_simulation_grid=k;
        %[r{j},Oo{j}]=mps_cpp_thread(TI,SIM,O);
        [r{j},Oo{j}]=mps_cpp(TI,SIM,O);
    end
end

%%
figure(1);clf;
for i=1:length(Oo)
    subplot(3,2,i);
    imagesc(etype(r{i}));
    axis image;
    caxis([0 1]);
    title(sprintf('t=%3.1fs i_p=%d, nc_{soft}=%d',Oo{i}.time,Oo{i}.shuffle_simulation_grid,Oo{i}.n_cond(2)))
    %title(sprintf('t=%3.1fs i_p=%d, nc_{hard}=%d, nc_{soft}=%d ',Oo{i}.time,Oo{i}.shuffle_simulation_grid,Oo{i}.n_cond(1),Oo{i}.n_cond(2)))
end
%print_mul(sprintf('%s_nMaxCpdf%03d_C','ex_hard_as_soft',O.n_max_cpdf_count))






return
%%
O.filename_parameter='mps_snesim_mul.txt';
O.debug=0;
O.n_real=100;
O.n_multiple_grids=2;
O.template_size=[5 5 1];
[r,Oo]=mps_cpp_thread(TI,SIM,O);
close all;
mps_cpp_plot(r,Oo,1);
figure(2);
print('-dpng',sprintf('%s_nmg%d_TS%02d',Oo.method,Oo.n_multiple_grids,Oo.template_size(1)))
