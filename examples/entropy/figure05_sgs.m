clear all;

use_ok=0;

nsim=1000;
dx=1;
m0=0;
r=25;
v=1;
Va=sprintf('0.0001 Nug(0) + %g Gau(%g)',v,r);
%Va=sprintf('0.001 Nug(0) + %g Gau(%g)',v,r);
%Va=sprintf('0.01 Nug(0) + %g Gau(%g)',v,r);
%Va=sprintf('%g Sph(%g)',v,r);
%Va=sprintf('%g Exp(%g)',v,r);



%TMH 
%nsim=100;
%TMH


%nx=200;
nsim=1000;
%for nx=[50,100,200,400]
for nx=[400]
    close all
    clear mul*
    x=[1:1:nx].*dx;
    
    Cm=precal_cov(x(:),x(:),Va);
    
    H_analytic = entropy_gaussian(Cm);
    
    %% Compute entropy directly
    
    pf=floor(log(nx)/log(2))
    nc2=2.^([4:1:pf]);
    nc3=nx;
    nc=fliplr([0:1:10,nc2,nc3]);
    %nc=fliplr([1,2,4,8]);
    for k=1:length(nc);
        progress_txt(k,length(nc))
        
        for j=1:nsim
            rng(j+1)
            sim=NaN.*ones(1,nx);
            cE=sim;
            cSI=sim;
            if use_ok==1
                sim(10)=1;
                sim(20)=1;
                sim(30)=-.5;
            end
            i_path=1:nx;
            i_path=shuffle(1:nx);
            t0=now;
            for i=1:nx
                
                i_cur=i_path(i);
                
                i_c=find(~isnan(sim));
                n_c=length(i_c);
                if nc(k)==0
                    n_c=0;
                end
                
                if n_c==0;
                    d_est = m0;
                    d_var  =v;
                else
                    pos_known = x(i_c);
                    val_known = sim(i_c);
                    pos_est=x(i_cur);
                    
                    if use_ok==1
                    %    sim(10)=1;
                    %    sim(30)=-.5;
                    else
                        options.mean=m0;
                    end
                    options.max=nc(k);
                    [d_est,d_var]=krig(pos_known(:),val_known(:),pos_est(:),Va,options);
                    % krig
                end
                d_real = randn(1)*sqrt(d_var)+d_est;
                % conditional self-information.
                if d_var==0;
                    cSI(i_cur)=0;
                    cE(i_cur)=0;
                else
                    cSI(i_cur)=-log(normpdf(d_real,d_est,sqrt(d_var)));
                    cE(i_cur)=entropy_gaussian(d_var);
                end
                %%
                doTestSI=0;
                if (doTestSI==1)&&(j==2);
                    n_test=1000000;                   
                    d_real_test = randn(1,n_test)*sqrt(d_var)+d_est;
                    mSI=-log(normpdf(d_real_test,d_est,sqrt(d_var)));
                    disp(sprintf('H_full=%5.4g, H_sim=%5.4g',cE(i_cur),mean(mSI)))
                    %keyboard
                end
                %%
                sim(i_cur)=d_real;
                
            end   
            
            n_gamma=21;
            h=linspace(0,max(x)/2,n_gamma);
            h=linspace(0,r*2,21);
            [gamma,gamma_d]=semivar_exp(x(:),sim(:),h);
            
            
            E=sum(cE);
            SI=sum(cSI);
            
            mulG(j,k,:)=gamma;
            mulT(j,k)=(now-t0)*3600*24;
            mulE(j,k)=E;
            mulSI(j,k)=SI;
            mulSIM(j,k,:)=sim;
        end
        
        mulSEMIVAR(k,:)=mean(squeeze(mulG(:,k,:)));
        
    end
    %%
    
    E_full = entropy_gaussian(Cm);
    E_ind = nx*entropy_gaussian(v);
    
    E_est = mean(mulE);
    %E_est = mean(mulSI);
    
    E_perc = ((E_est-E_full)./(E_ind-E_full));
    
    txt=sprintf('Mnx%04d_%s',nx,space2char(Va));
    txt=space2char(txt,'_','\.')
    if use_ok==1
        txt=[txt,'_ok'];
    end
    save(txt)
    
   
    
    %%
    FS=10;
    figure(1);clf;
    plot([1 nsim],[1 1].*E_full,'k--','LineWidth',2)
    hold on
    plot([1 nsim],[1 1].*E_ind,'k-.','LineWidth',2)
    p=plot(1:nsim,mulE,'*');
    hold off
    legend(p,num2str(nc'),'Location','NorthEastOutside')
    xlabel('Realization number')
    ylabel('Self-Entropy')
    ppp(10,6,FS,2,2)
    grid on
    print_mul(sprintf('%s_entropy_per_sim',txt))
    
    %%
    figure(2);clf;
    for k=1:length(nc);
        p2(k)=plot(x,(k-1)+squeeze(mulSIM(1,k,:))','k-','LineWidth',1+k/10);
        hold on
    end
    hold off
    %legend(p2,num2str(nc'),'Location','NorthEastOutside')
    xlabel('x')
    ylabel('Simulated value')
    ppp(10,6,FS,2,2)
    grid on
    print_mul(sprintf('%s_entropy_sim',txt))
    
    %% 3D plot
    figure(12);clf;
    for k=1:1:length(nc);
        %p2(k)=plot(x,(k-1)+squeeze(mulSIM(1,k,:))','k-','LineWidth',1+k/10);
        p2(k)=plot3(x,x.*0+k,squeeze(mulSIM(1,k,:))','k-','LineWidth',1);
        %p2(k)=plot3(x,x.*0+k,squeeze(mulSIM(1,k,:))','k-','LineWidth',1+k/10);
        hold on
    end
    hold off
    %legend(p2,num2str(nc'),'Location','NorthEastOutside')
    xlabel('x')
    ylabel('n_c')
    
    iic=1:2:length(nc);
    set(gca,'Ytick',iic)
    set(gca,'YtickLabel',num2str(nc(iic)'))
    zlabel('Simulated value')
    
    set(gca,'YMinorTick','On')
    ax=gca;
    ax.YAxis.MinorTickValues=[1:1:length(nc)];
    set(gca,'ydir','reverse')
    
    ppp(10,6,FS-1,2,2)
    grid on
    view([-7,66])
    print_mul(sprintf('%s_entropy_sim_3d',txt))
    
    %%
    figure(3);
    plot(nc,mean(mulE),'k-*')
    set(gca,'Xscale','log')
    hold on
    plot(xlim,[1 1].*E_full,'k--','LineWidth',2)
    plot(xlim,[1 1].*E_ind,'k-.','LineWidth',2)
    hold off
    xlabel('x')
    ylabel('Entropy')
    ppp(10,6,FS,2,2)
    grid on
    print_mul(sprintf('%s_entropy',txt))
   
    %% SEMIVAR
    Recomp=0;
    if Recomp==1;
        clear mulG mulSEMIVAR
        n_gamma=21;
        h=linspace(0,max(x),n_gamma);
        h=linspace(0,r*2,11);
        for k=1:length(nc)
            for j=1:nsim
                sim=mulSIM(j,k,:);
                [gamma,gamma_d]=semivar_exp(x(:),sim(:),h);
                %[gamma,gamma_d]=semivar_exp_gstat(x(:),sim(:),0,180,2,100);
                
                mulG(j,k,:)=gamma;
            end
            mulSEMIVAR(k,:)=mean(squeeze(mulG(:,k,:)));
        end
    end
    
    clear p;
    figure(14);clf;%set_paper('landscape','a4',1);
    set(gca,'FontSize',FS-7);
    gamma_synth_dist=linspace(0,max(gamma_d),501);
    gamma_synth=semivar_synth(Va,gamma_synth_dist);
    
    plot(gamma_synth_dist,gamma_synth,'k:','LineWidth',3)
    hold on
    for k=1:length(nc);
        col=[0 0 0]+k/40;
        w=max([8-k/2,1]);
        p(k)=plot(gamma_d,mulSEMIVAR(k,:),'k-','LineWidth',w,'color',col);
        L{k}=sprintf('n_c=%d, H_p=%3.1f',nc(k),1-E_perc(k));
    end
    p(k+1)=plot(gamma_synth_dist,gamma_synth,'k:','LineWidth',3)
    L{k+1}=sprintf('%s','Reference');
    hold off
    grid on
    xlabel('d, distance')
    ylabel('\gamma(d), semivariance')
    legend(p,L,'Location','NorthEastOutside')
    %ppp(9,7,FS,2,2)
    print_mul(sprintf('%s_semivar',txt),6,600)
    
    %%
    figure(4)
    plot(nc,100*E_perc,'k-*','LineWidth',2);
    set(gca,'Xscale','log')
    xlabel('n_c')
    ylabel('I_{loss}, Loss of information (%)')
    ylim([0,105])
    grid on
    %ylim([0.6,1.05]);xlim([1,nx]);grid on
    ylim([-.05,60]);xlim([1,nx]);grid on
    ppp(10,6,FS,2,2)
    print_mul(sprintf('%s_nc',txt),6,600)
    
    
    p_lev=0.995;
    %p_lev=0.99;
    try
    nc_lev=interp1(1-E_perc,nc,p_lev);
    xl=xlim;
    yl=ylim;
    hold on
    plot([xl(1) nc_lev],100.*[ 1 1].*(1-p_lev),'k--','LineWidth',2)
    %plot([xl(1) nc_lev],[1 1].*p_lev,'k--','LineWidth',2)
    plot([1 1].*nc_lev,100.*[yl(1) yl(2)],'k--','LineWidth',2)
    hold off
    text(nc_lev*1.1,100*0.2,sprintf('{n_c}_{(%g%%)} = %3.0f',100*(1-p_lev),nc_lev))
    print_mul(sprintf('%s_nc2',txt))
    end
    
    %%
    figure(5);clf
    %semilogy(100*E_perc,mean(mulT),'k-*');
    plot(100*E_perc,mean(mulT),'k-*');
    xlabel('Information loss (%)'); ylabel('Computaton time')
    
    
    m_mulT=mean(mulT);
    for i=[1,2,3,length(nc)-2,length(nc)-1,length(nc)]
        t=text(100*E_perc(i)+1,m_mulT(i)+0.01,sprintf('n_c=%d',nc(i)),'rotation',30,'FontSize',FS-2)
    end
    grid on
    ppp(10,6,FS,2,2)
    xlim([-2 102])
    %ylim([-.01 1.01])
    print_mul(sprintf('%s_time_loss',txt))
    
    %%
    for i=1:length(nc)
        mulMeanSI(:,i)=cumsum(mulSI(:,i))'./[1:nsim];
        mulMeanE(:,i)=cumsum(mulE(:,i))'./[1:nsim];
    end
    
    figure(6);clf
    plot([1 nsim],[1 1].*E_full,'k--','LineWidth',2)
    hold on
    plot([1 nsim],[1 1].*E_ind,'r:','LineWidth',2)
    p=plot(1:nsim,mulE,'.','MarkerSize',3);
    p2=plot(1:nsim,mulSI,'--','MarkerSize',2);
    p3=plot(1:nsim,mulMeanSI,'-','MarkerSize',2);
    for ip=1:length(p);
        set(p2(ip),'color',get(p(ip),'color'))
        set(p3(ip),'color',get(p(ip),'color'))
    end
    hold off
    legend(p,num2str(nc'),'Location','NorthEastOutside')
    xlabel('Realization number')
    ylabel('Self-Entropy')
    ppp(10,6,FS,2,2)
    grid on
    print_mul(sprintf('%s_entropy_per_sim2',txt))
    
    
    
    %%
    figure(7);clf;
    clear L
    i=11;
    plot(mulSI(:,i),'k.');
    hold on; 
    plot(mulMeanSI(:,i),'k-','LineWidth',3);
    plot(mulMeanE(:,i),'r-','LineWidth',1.5);
    hold off
    grid on
    L{1}=sprintf('SI(m^* | n_c=%d)',nc(i));
    L{2}='Eq. 12';
    L{3}='Eq. 14';
    legend(L,'Location','NorthEastOutside')
    xlabel('Realization number')
    ylabel('Self-information / Entropy (nats)')
    ppp(10,6,FS,1.8,2)
    grid on
    print_mul(sprintf('%s_entropy_cum_nc%d',txt,nc(i)))
    mean(mulMeanE(:,i))
    disp(sprintf('H_%d=%5.1f',i,mean(mulMeanE(:,i))))
    
    %%
    mean(mulMeanE(:,1))
    disp(sprintf('H_max=%5.1f',mean(mulMeanE(:,end))))
    disp(sprintf('H_min=%5.1f',mean(mulMeanE(:,1))))
    
    
    
    
end













