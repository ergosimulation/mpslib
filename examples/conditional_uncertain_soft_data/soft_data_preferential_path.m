% test
clear all;

O.method='mps_snesim_tree';
O.method='mps_genesim';
O.n_max_cpdf_count= 1;
O.n_cond= 25;
O.n_max_ite= 4000;
O.nreal=1;

TI=read_eas_matrix('ti.dat');
SIM=ones(30,30)*NaN;

d=read_eas('soft_case1.dat');
i_use=randomsample(900,60);
write_eas('soft.dat',d(i_use,:));
O.soft_data_fnam='soft.dat';


%O.soft_data_fnam='soft_case1.dat';
O.soft_data_fnam='soft_case2.dat';
%O.soft_data_fnam='soft_case3.dat';


O.entropyfactor_simulation_grid=4;

d=read_eas(O.soft_data_fnam);
%%
N=5
for i=1:N;
    progress_txt(i,N)
    O.rseed=i;
    O.shuffle_simulation_grid=2;
    O.debug=2;
    O.n_real=1;
    [reals,O]=mps_cpp(TI,SIM,O);
    r(:,:,i)=reals;
    ipath(:,:,i)=O.I_PATH;

    %%
    figure_focus(1);
    subplot(1,2,1);
    imagesc(O.x,O.y,etype(r));axis image
    caxis([0 1])
    subplot(1,2,2);
    imagesc(O.x,O.y,etype(ipath));axis image
    hold on
    scatter(d(:,1),d(:,2),abs(d(:,4)-.5)*220+.1,'k')
    hold off
    caxis([0 12]);
    %caxis([4.5 6.5]);
    colorbar
    drawnow
    
end
colormap hot

%%
ep=etype(ipath)
see=sort(ep(:));
see(1:12)
