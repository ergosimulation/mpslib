clear all;close all
id=0;

if ~exist('mps_cpp_entropy_data_n_cond_1_nx9_nsim100_mps_snesim_tree_downscale.mat','file')
    mps_cpp_entropy_ti_downscale
end


%id=id+1;d{id}=load('mps_entropy_data_n_cond_0_nx9_downscale');
%id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_0_nx9_nsim10_mps_genesim_downscale');
id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_0_nx9_nsim100_mps_snesim_tree_downscale.mat');

use_upscale=1;
%use_upscale=1;
if use_upscale==1;
    
    %id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_0_nx9_nsim10_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_1_nx9_nsim100_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_2_nx9_nsim100_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_4_nx9_nsim100_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_8_nx9_nsim100_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_16_nx9_nsim100_mps_snesim_tree_downscale.mat');
    id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_32_nx9_nsim100_mps_snesim_tree_downscale.mat');
    
%     %id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_0_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_1_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_2_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_4_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_8_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_16_nx9_nsim10_mps_genesim_downscale.mat');
%     id=id+1;d{id}=load('mps_cpp_entropy_data_n_cond_32_nx9_nsim10_mps_genesim_downscale.mat');
    
    
    txt='upscale';
    
    
else
    id=id+1;d{id}=load('mps_entropy_data_n_cond_1_nx9_downscale.mat');
    id=id+1;d{id}=load('mps_entropy_data_n_cond_5_nx9_downscale.mat');
    id=id+1;d{id}=load('mps_entropy_data_n_cond_10_nx9_downscale.mat');
    id=id+1;d{id}=load('mps_entropy_data_n_cond_15_nx9_downscale.mat');
    txt='downscale'
end

n0=length(find(d{1}.sim==0));n=prod(size(d{1}.sim)); p=[n0 n-n0]./n;
e0=entropy(p);

%%
figure(10);clf
clear h;
h(1)=loglog(1:100000,1:100000,'k--','LineWidth',1);
hold on
col(1,:)=[0 0 0];
col(2,:)=1-[1 1 1].*.9;
col(3,:)=1-[1 1 1].*.8;
col(4,:)=1-[1 1 1].*.7;
col(5,:)=1-[1 1 1].*.6;
col(6,:)=1-[1 1 1].*.5;
col(7,:)=1-[1 1 1].*.4;
col(8,:)=[0 1 0];
col(9,:)=[0 0 1];
for id=1:length(d);
    m0=(mean(d{id}.e'));
    E=2*(std(d{id}.e'));
    %loglog(d{id}.n,d{id}.e./e0,'.','LineWidth',.05,'color',col(id,:),'MarkerSize',5)
    errorbar(d{id}.n(:,1),m0,E,'-','LineWidth',.1,'color',col(id,:),'MarkerSize',5)
    %loglog(n,e./n,'g-','LineWidth',.2);

    n=d{id}.n(:,1);
    h(1+id)=loglog(d{id}.n(:,1),m0,'*-','LineWidth',1+.5*id,'color',col(id,:));

    pow(id)=mean((log(m0./e0)./log(n')));
    
    try;
        H{id}=sprintf('N_c = %d',d{id}.O.n_cond);
    catch
        H{id}=sprintf('i_d=%d',id);
    end

end
hold off
grid on;
Hl = [ {'N_M'}, H ];
legend(h,Hl,'Location','NorthEastOutside');
%legend(h,'H=N','N_c=0','N_c=1','N_c=5','N_c=10','N_c=15','Location','NorthEastOutside');
axis([400/1.2 10000*1.2 30 20000])
xlabel('Number of model parameters, N')
ylabel('Entropy (bits)')
set(gca,'Xtick',[500,1000,2000,5000,10000]);
set(gca,'ytick',[50,100,500,1000,5000,10000]);
text(-.15,1.0,'a)','Units','Normalized','FontSize',18)
%ylabel('Entropy / Number of free parameters, N_F = H/H(m_i)')
print_mul(sprintf('mps_cpp_entropy_ti_%s_%s_E',txt,d{end}.O.method))

%%
figure(11);clf
clear h;
for id=1:length(d);
    %loglog(d{id}.n,d{id}.e,'-','LineWidth',.05,'color',col(id,:))
    %loglog(d{id}.n,d{id}.e./d{id}.n,'-','LineWidth',.1,'color',col(id,:));
    %hold on
    %h(1+id)=loglog(d{id}.n(:,1),mean(d{id}.e')','b','LineWidth',3,'color',col(id,:));
    h(id)=loglog((d{id}.n(:,1)),mean(d{id}.e'./d{id}.n')./e0,'*-','LineWidth',1+.5*id,'color',col(id,:));
    hold on
end

hold off
legend(h,H,'Location','NorthEastOutside');
%legend(h,'N_c=0','N_c=1','N_c=5','N_c=10','N_c=15','Location','NorthEastOutside');
xlabel('Number of model parameters')
ylabel('N_{free}/N')
set(gca,'Xtick',[500,1000,2000,5000,10000]);
yl=[0.02 .05 .1 .5  1];
set(gca,'Ytick',yl);
for i=1:length(yl);
    L{i}=sprintf('%2d%%',100*yl(i));
end
%L{1}='5%';
%L{2}='10%';
%L{3}='50%';
%L{4}='100%';
set(gca,'YtickLabel',L);
grid on
axis([400/1.2 10000*1.2 yl(1) 1.20])
text(-.15,1.0,'b)','Units','Normalized','FontSize',18)
print_mul(sprintf('mps_cpp_entropy_ti_%s_%s_NF_N',txt,d{end}.O.method))

%%
figure(12);clf
id=length(d);
i_arr=[1,3,5,7,9];ni=length(i_arr);
i_arr=[1,3,4,9];ni=length(i_arr);
i_arr=[1,3,5,7,9];ni=length(i_arr);
j=0;
FS=5;
for i=i_arr;
    j=j+1;
    if use_upscale==1;
        nx_sim=sqrt(d{id}.n(i,1));
        nx_ti=nx_sim*5;
        ti_ref=imresize(d{1}.ti,[100 100],'nearest');
        ti=imresize(ti_ref,[1 1].*nx_ti,'nearest');

    else
        nx_sim=sqrt(d{id}.n(i,1));
        nx_ti=nx_sim*5;
        ti=imresize(d{1}.ti_ref,[1 1].*nx_ti,'nearest');
    end
    dx=100/nx_ti;
    
    subplot(4,ni,j);
    imagesc(ti);axis image
    title(sprintf('%s) pixel witdth=%3.2f',char(96+j),100/nx_ti))
    set(gca,'FontSize',FS);
    xlabel('pixels')
    ylabel('pixels')
    
    isim=2;
    subplot(4,ni,ni+j);
    imagesc(dx:dx:20,dx:dx:20,d{id}.mul{i}{isim}.sim);axis image
    %title(sprintf('%s) m^*',char(96+j),d{1}.n(i,1)))
    title(sprintf('%s) m^*',char(96+j+ni)))
    set(gca,'FontSize',FS);
    xlabel('X');ylabel('Y')
    
    subplot(4,ni,2*ni+j);
    %imagesc(d{id}.O.x*dx,d{id}.O.y*dx,d{id}.mul{i}{isim}.options.E);axis image
    imagesc(dx:dx:20,dx:dx:20,d{id}.mul{i}{isim}.options.E);axis image
    xlabel('X');ylabel('Y')
    caxis([0 1])
    title(sprintf('%s) SI(f(m_i^*|m_c))',char(96+j+2*ni)))
    set(gca,'FontSize',FS);
    
end
colormap(1-cmap_cmr);
[cb]=colorbar_shift;
print_mul(sprintf('mps_cpp_entropy_ti_%s_%s_sim',txt,d{end}.O.method))

