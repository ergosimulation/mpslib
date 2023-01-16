clear all;close all;
load ti_2D_1

%% options

% TI REF
ti_ref=ti;
%ti_ref=imresize(ti,[100 100],'nearest');
%ti_ref=imresize(ti_ref,[1000 1000],'nearest');

% SIM FIELD

nsim=100;
nx_arr=[100:100:1000];
nx_arr=[100:50:500];

i_n=0;
for n_cond=[0,1,2,4,8,16,32];
    i_n=i_n+1;
    figure_focus(2);clf;
    figure_focus(3);clf;
    figure_focus(4);clf;
    try
        clear e mul
    end
    for i=1:length(nx_arr);
        
      
        nx_ti=nx_arr(i);
        ti=imresize(ti_ref,[1 1].*nx_ti,'nearest');
        
        figure_focus(2);
        subplot(4,3,i);
        imagesc(ti);axis image
        drawnow
        
        nx_sim=2*(nx_ti/10);
        SIM.D=ones(nx_sim,nx_sim).*NaN;
        
        % simulate
        Oorg.method='mps_genesim';
        Oorg.n_max_cpdf_count=1e+9;
        Oorg.n_max_ite=1e+9;
        %Oorg.n_max_cpdf_count=200;
        %Oorg.n_max_ite=20000;
        
        
        Oorg.method='mps_snesim_tree';
        Oorg.template_size=[9 9 1];
        Oorg.n_multiple_grids=3;
        
        
        Oorg.shuffle_simulation_grid=0;
        Oorg.shuffle_simulation_grid=1;
        Oorg.n_reals=1;
        Oorg.n_cond=n_cond;
        Oorg.doEntropy=1;
        
        for isim=1:nsim
            tic;
            rng(isim);
            
            clear O;
            Oorg.rseed=10000+isim;
            [sim,O]=mps_cpp(ti,SIM.D,Oorg);
            %        [sim,opt]=mps_enesim(ti,SIM.D,options);
            mul{i}{isim}.sim=sim;
            mul{i}{isim}.options=O;
            e(i,isim)=sum(O.SI);
            n(i,isim)=prod(size(SIM.D));
            t(i,isim)=toc;
        end
        mean(e')
        figure_focus(3);
        subplot(4,3,i);
        imagesc(sim);axis image
        drawnow
        
        figure_focus(4);
        subplot(4,3,i);
        imagesc(O.E);axis image
        title(sprintf('H=%g N=%d',e(i),nx_sim^2))
        drawnow
        
        save(sprintf('mps_cpp_entropy_data_n_cond_%d_nx%d_nsim%d_%s_downscale',n_cond,length(nx_arr),nsim,O.method));
        
    end
    
    
    %%
    figure_focus(20+i_n);clf
    h1=loglog(n,n,'k:','LineWidth',2);
    hold on
    h2=loglog(n,e,'k.','LineWidth',.1,'MarkerSize',12);
    %loglog(n,e./n,'g-','LineWidth',.2);
    h3=loglog(n,mean(e'),'k-','LineWidth',3);
    %loglog(n,mean(e'./n'),'g-','LineWidth',2);
    hold off
    legend([h1(1),h2(1),h3(1)],'N_M','SI(m^*)','H(m)','Location','NorthEastOutside')
    xlabel('Number of model parameters','FontSize',16)
    ylabel('Entropy Self-information (bits)','FontSize',16)
    set(gca,'FontSize',14)
    grid on
    axis image
    set(gca,'xlim',[.9*min(n(:,1)) 1.1*max(n(:,1))])
    print_mul(sprintf('entropy_cpp_ti_loglog_downscale_nc%d_nsim%d_%s',n_cond,nsim,O.method))
    
end
%% plot
%load mps_entropy_data_n_cond_10;

for i=1:4;
    figure_focus(4);
    subplot(4,3,i);
    imagesc(mul{i}{1}.options.E);axis image
    title(sprintf('H=%g N=%d',e(i),n(i)))
    drawnow
    
    colormap(1-cmap_cmr)
    
end
