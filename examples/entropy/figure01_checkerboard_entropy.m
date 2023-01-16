close all;clear all;
rseed=1;
rng(rseed);
profile off;

Nr=1000;    
%Nr=500;
    
%% options
options.null='';
options.plot=1;
options.plot_interval=100;
options.n_cond=45;40;10;16*4+10;
options.n_max_ite=1800;
options.precalc_dist_full=0;
options.shuffle_simulation_grid=0;

options.verbose=1;
options.plot=2;
%options.plot_interval=1;

%% SIM GRID SIZE
nx=10;ny=10;
%nx=40;ny=40;

SIM.D=zeros(ny,nx)+NaN;
N_SIM=prod(size(SIM.D));

nmul_arr=[1:8];
nmul_arr=[1,2,4,6];
nmul_arr=[1,2,3,4,5,6];
nmul_arr=[1,2,4,8];
%nmul_arr=[1:8];
nk=length(nmul_arr);
for k=1:nk
    nmul=nmul_arr(k)
    
    %% TI: CHECKERBOARD
    w=nmul_arr(k);
    TI.D=ti_checkerboard_2d(w,81);
    
    %% SIMULATION    
    %profile on;
    tic;
    
    O.method='mps_genesim';
    O.n_max_cpdf_count=1e+9;
    O.n_max_ite=1e+9;
    %O.shuffle_simulation_grid=0;
    %O.shuffle_simulation_grid=1;
    O.n_reals=1;
    O.n_cond=8*8+1;
    O.doEntropy=1;
    
    for i=1:Nr
        O.rseed=10000+i;
        [reals,O]=mps_cpp(TI.D,SIM.D,O);
    
        %[sim,opt]=mps_enesim(TI.D,SIM.D,options);
        cb{k}.sim(:,:,i)=reals;
        cb{k}.cSI(:,:,i)=O.E;
        cb{k}.SI(i)=O.SI;
        cb{k}.ti=TI.D;
        %t(k)=toc;
        
        if mod(i,10)==0
            progress_txt([k,i],[length(nmul_arr),Nr],sprintf('H=%3.2f',mean(cb{k}.SI(1:i))))
        end
    
    end    
    cb{k}.No=2*w^2;
    cb{k}.H_ex=log2(cb{k}.No);
    cb{k}.H=mean(cb{k}.SI(i));
    2.^cb{k}.H
    
    doMul=0;
    if doMul==1;
        n_cond_arr=[0,1,2,3,4,5,6,7,8,12,16,20,24,38,32];
        for l=1:length(n_cond_arr);
            O.n_cond=n_cond_arr(l);
            [reals,O]=mps_cpp(TI.D,SIM.D,O);
            cb_mul{k,l}.sim=reals;
            cb_mul{k,l}.E=O.E;
            cb_mul{k,l}.options=O;
        end
    end
    
    %profile report;
    
    
end
save(sprintf('mps_cpp_entropy_checkerboard_rand%d_nr%d_seed%d',options.shuffle_simulation_grid,Nr,rseed));


%%
cmap=1-gray;
col=[0 0 0;1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; .1 .1 .1; .2 .2 .2; .3 .3 .3; .4 .4 .4];
ncb=length(cb);
figure_focus(8);clf;
for k=1:nk;
    w=nmul_arr(k);
    plot(1:Nr,cb{k}.SI,'.','MarkerSize',max([13-2*k,4]),'color',col(k,:)),
    hold on
    plot(1:Nr,ones(1,Nr).*cb{k}.H_ex,':','MarkerSize',22,'color',col(k,:),'LineWidth',2),
    %plot(1:Nr,cb{k}.H.*ones(1,Nr),'-','color',col(k,:))
    hand(k)=plot(1:Nr,cumsum(cb{k}.SI)./[1:Nr],'-','color',col(k,:),'LineWidth',2);
    H(k)=mean(cb{k}.SI);
    text(Nr+Nr*.01,H(k),sprintf('H(f_{%d}(m))=%3.1f b',w,H(k)),'color',col(k,:))
%    text(Nr+Nr*.01,H(k),sprintf('H_{%d}=%3.1f/%3.1f b',w,H(k),cb{k}.H_ex),'color',col(k,:))
end
hold off
xlabel('Realization number')
ylabel('Self Information / Entropy (bits)')

grid on
ppp(10,6,10,2,2)
print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d',O.shuffle_simulation_grid,nk,Nr))
%set(gca, 'XScale', 'log')
%print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_log',O.shuffle_simulation_grid,nk,Nr))

%%
FS=8;
nshow=5;
figure_focus(9);clf;
for k=1:nk;
    w=nmul_arr(k);
    for i=1:nshow
        subplot(nk,nshow,(k-1)*nshow+i);
        if i==1;
            imagesc_grid(cb{k}.ti(1:10,1:10),[1 1 1].*.7);
            title(sprintf('Sample model w=%d',w),'FontSize',FS)
        else
            imagesc_grid(cb{k}.sim(:,:,end-i),[1 1 1].*.7);
            title(sprintf('SI(m^*)=%3.1f b',cb{k}.SI(i)),'FontSize',FS)
        end
        axis image
        colormap(cmap)
        set(gca,'FontSize',FS-4);
        if (i==1);text(-3,-1,sprintf('%s)',char(96+k)),'FontSize',FS);end
    end
end
print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_real',O.shuffle_simulation_grid,nk,Nr))



%% in one figure
FS=10;
nshow=4;
g=3;
figure('Renderer', 'painters', 'Position', [10 10 g*210 g*297 ])
%[ha, pos] = tight_subplot(nk,nshow,[0.01 0],[.1 .1],[.1 .1]);
ns=0;
for k=1:nk;
    w=nmul_arr(k);
    for i=1:nshow
        ns=ns+1;
        subplot(nk+2,nshow,(k-1)*nshow+i);
        %axes(ha(ns));
        if i==1;
            imagesc_grid(cb{k}.ti(1:10,1:10),[1 1 1].*.7);
            title(sprintf('Sample model w=%d',w),'FontSize',FS)
        else
            imagesc_grid(cb{k}.sim(:,:,end-i),[1 1 1].*.7);
            title(sprintf('SI(m^*)=%3.1f b',cb{k}.SI(i)),'FontSize',FS)
        end
        axis image
        colormap(cmap)
        set(gca,'FontSize',FS-4);
        if (i==1);text(-3,-1,sprintf('%s)',char(96+k)),'FontSize',FS);end
    end
end

%
subplot(nk+2,nshow,[((nk*nshow)+1):nshow*(nk+2)])
cmap=1-gray;
col=[0 0 0;1 0 0; 0 1 0; 0 0 1; 1 1 0; 0 1 1; 1 0 1; .1 .1 .1; .2 .2 .2; .3 .3 .3; .4 .4 .4];
col_p=col;
col_p=1-((1-col_p)*.4);
ncb=length(cb);
%figure_focus(8);clf;
for k=1:nk;
    w=nmul_arr(k);
    plot(1:Nr,cb{k}.SI,'.','MarkerSize',max([13-2*k,4]),'color',col_p(k,:)),
    hold on
    plot(1:Nr,ones(1,Nr).*cb{k}.H_ex,':','MarkerSize',22,'color',col(k,:),'LineWidth',3),
    %plot(1:Nr,cb{k}.H.*ones(1,Nr),'-','color',col(k,:))
    hand(k)=plot(1:Nr,cumsum(cb{k}.SI)./[1:Nr],'-','color',col(k,:),'LineWidth',2);
    H(k)=mean(cb{k}.SI);
    text(Nr+Nr*.01,H(k),sprintf('H(f_{%d}(m))=%3.1f b',w,H(k)),'color',col(k,:))
    %text(Nr+Nr*.01,H(k),sprintf('H_{%d}=%3.1f/%3.1f b',w,H(k),cb{k}.H_ex),'color',col(k,:))
end
ax=gca;
dw=0.08;
pos=get(ax,'position');set(ax,'position',[pos(1)+dw pos(2) pos(3)-2*dw pos(4)])

hold off
xlabel('Realization number')
ylabel('Self Information / Entropy (bits)')
text(-.15,0.9,sprintf('%s)',char(96+k+1)),'FontSize',FS,'units','normalized');

grid on
print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_onefig',O.shuffle_simulation_grid,nk,Nr))
set(gca, 'XScale', 'log')

axis([1 Nr*1 0 12])

print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_log_onefig',O.shuffle_simulation_grid,nk,Nr))
%print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_log',O.shuffle_simulation_grid,nk,Nr))
%print_mul(sprintf('cb_checkerboard_rp%d_nw%d_Nr%d_real',O.shuffle_simulation_grid,nk,Nr))


%% histogram
col=[1 0 0; 0 1 0 ; 0 0 1; 1 1 0];
dx=.25;bins=[0:dx:10]-dx/2;
figure(21);clf
clear h
for i=1:length(cb);
    %subplot(2,2,i)
    h(i)=histogram(cb{i}.SI,bins,'FaceColor',col(i,:))    
    hold on    
    Hest=mean(cb{i}.SI);
    plot([1 1].*Hest,ylim,'k--')    
    L{i}=sprintf('SI_{f_%d}(m^*)',nmul_arr(i));
end
hold off
legend(h,L)
xlabel('Self-information, S(m^*)')
ylabel('Number of outcomes (of 1000)')
print_mul(sprintf('cb_checkerboard_SI_rp%d_nw%d_Nr%d_log_onefig',O.shuffle_simulation_grid,nk,Nr))



