function  entropy_cb_cond_sim_fct(Cmethod,nx,ny,rseed,n_cond,subsample,useTI,di,doPlot, saveMAT)

if ~exist('Cmethod');Cmethod=4;end
if ~exist('ny');ny=29;end
if ~exist('nx');nx=19;end
if ~exist('rseed');rseed=2;end
if ~exist('n_cond');n_cond=25;end
if ~exist('subsample');subsample=1;end
if ~exist('useTI');useTI='strebelle';end
if ~exist('di');di=2;end
if ~exist('doPlot');doPlot=-1;end
if ~exist('saveMAT');saveMAT=1;end

txt=sprintf('%s_%d_%d_nc%d_rs%02d_CM%d',useTI,nx,ny,n_cond,rseed,Cmethod);

fprintf('Starting: %s',txt);

try
    delete('d_soft.dat')
    delete('d_hard.dat')
end
rng(rseed)



%% TI

if strcmp(useTI,'cb4')
    TI=ti_checkerboard_2d(4);
elseif strcmp(useTI,'cb8')
    TI=ti_checkerboard_2d(10);
else
    TI=channels;           %  training image
    TI_org=TI;
    %di=2;
    %di=4;
    if subsample==1;
        j=0;
        for ix1=1:di;
            for iy1=1:di;
                j=j+1;
                TI2(:,:,j)=TI(iy1:di:(end-di+iy1),ix1:di:(end-di+ix1));;
            end
        end
        TI=TI2;
    else
        TI=TI(1:di:end,1:di:end);
    end
end
[ti_ny,ti_nx,nz]=size(TI);
val=unique(TI(:));


if doPlot>-1;
    figure(1001);
    imagesc(TI(:,:,1));axis image;colorbar
    colormap(1-gray)
    drawnow;
    print_mul(sprintf('ti_%s',useTI))
end
%%
%O=mps_genesim_read_par('mps_genesim.txt');
O.method='mps_genesim';
O.parameter_filename='mps_genesim_test.txt';
O.n_real=1;             %  optional number of realization
O.n_max_ite=1000000000;
O.n_cond=[n_cond 2];
O.n_max_cpdf_count=1e+9;
O.shuffle_simulation_grid=Cmethod-1;
O.doEstimation=1;
O.doEntropy=1;
O.debug=-1;
O.distance_min=0;
%O.distance_min=0.2;
disp('SIMULATION')

%%
SIM=zeros(ny,nx).*NaN; %  simulation grid
%figure(1002);clf;
%imagesc(SIM*NaN);axis image;colormap(1-gray)
%print_mul(sprintf(sprintf('mps_cond_simgrid_%s_%d_%d',useTI,ny,nx)))

Oin=O;

%%
if doPlot>-1;
    figure(11);clf,
    subfigure(3,1,1);clf;
    set(gcf,'color','w');
    ax=gcf;
end

if doPlot>0;
    FrameRate = 10;
    Quality = 95;
    vname=sprintf(sprintf('mps_cond_%s_%d_%d_M%d_nc%d_ss%d',useTI,ny,nx,Cmethod,n_cond,subsample));
    writerObj = VideoWriter(vname);
    %writerObj = VideoWriter(vname,'MPEG-4'); % Awful quality ?
    writerObj.FrameRate=FrameRate;
    writerObj.Quality=Quality;
    open(writerObj);
end


ni=prod(size(SIM));
for i=1:ni
    disp(sprintf('i=%4d/%4d',i,ni))
    %    SIM(1,i+2)=val(1);
    
    try
        if exist('d_soft.dat','file');delete('d_soft.dat');end
        if exist('d_hard.dat','file');delete('d_hard.dat');end
        O=rmfield(O,'d_soft');
        O=rmfield(O,'d_hard');
    end
    
    [reals,O]=mps_cpp(TI,SIM,Oin);
    
    sumCondH(i)=nansum(O.E(:));
    
    
    %% compute conditional
    m_cond_1=SIM;
    %imagesc(O.cg(:,:,2));caxis([-.01 1])
    for iiy=1:ny;
        for iix=1:nx;
            if isnan(m_cond_1(iiy,iix))
                m_cond_1(iiy,iix)=O.cg(iiy,iix,2);
            end
        end
    end
    %% compute mode
    m_mode=SIM;
    for iiy=1:ny;
        for iix=1:nx;
            
            P=squeeze(O.cg(iiy,iix,:));
            if ~isnan(P(1))
                imode=find(max(P)==P);
                if length(imode)>1
                    m_mode(iiy,iix)=val(randomsample(imode,1));
                else
                    m_mode(iiy,iix)=val(imode(1));
                end
            end
            
        end
    end
    
    %% update conditional
    inan=find(isnan(SIM));
    if Cmethod==1;
        % unilateral
        i_sim=i;
    elseif Cmethod==2;
        % random
        i_sim=randomsample(find(isnan(SIM)),1);
    elseif Cmethod==3;
        % min ent
        Emin=min(O.E(inan));
        i_test= find(O.E(inan)==Emin);
        if length(i_test)>1
            i_rand=randomsample(i_test,1);
        else
            i_rand=i_test;
        end
        i_sim = inan(i_rand);
    else
        % max ant
        i_test= find(O.E(inan)==max(O.E(:)));
        if length(i_test)>1
            i_rand=randomsample(i_test,1);
        else
            i_rand=i_test;
        end
        i_sim = inan(i_rand);
    end
    
    SIM_old=SIM;
    [iy_sim,ix_sim]=ind2sub([ny nx],i_sim);
    %[ix_sim,iy_sim]=ind2sub([nx ny],i_sim);
    P=squeeze(O.cg(iy_sim,ix_sim,:));
    
    H(i)=O.E(iy_sim,ix_sim);
    
    
    E_all(:,:,i)=O.E(:,:,1);
    SIM_all(:,:,i)=SIM;
    CG_all(:,:,i)=O.cg(:,:,2);
    
    [ind]=sample_from_1d(P);
    SIM(iy_sim,ix_sim)=val(ind);
    SI(i)=-log2(P(ind));    
    
    %% PLOT
    if (doPlot>-1)&&((i<(2*n_cond)) | (mod(i,10)==0))
        
        col_nan=[1 1 1];
        col_min=[0 1 0];
        col_max=[0 0 0];
        
        figure_focus(11);clf;
        
        subplot(1,4,1);
        imagesc(SIM_old);
        title('\bf{m}^*')
        caxis([-.01 1])
        colormap(gca,[col_nan;cmap_linear([col_min; col_max])])
        colorbar;
        axis image;
        
        
        subplot(1,4,2);
        imagesc(m_cond_1);
        title('f(m_i==1 | \bf{m}^*)')
        %colormap(gca,[col_nan;cmap_linear([col_min; col_max])])
        caxis([0 1])
        colormap(gca,cmap_linear([0 1 0; 1 1 1; 0 0 0]))
        colorbar;axis image;
        
        
        subplot(1,4,3);
        imagesc(O.E(:,:,1));caxis([0 1])
        %title('Cond. Ent H(f(m_i))')
        %title('1D Conditional Entropy \newline H(f(m_i))')
        title('1D Conditional Entropy, H(f(m_i))')
        colormap(gca,cmap_linear([1 1 1; 0 1 0; 0 0 0]))
        colormap(gca,cmap_linear([1 1 1; 1 0 0; 0 0 0]))
        colormap(gca,cmap_linear([1 1 1; 1 0 0; 1 0 0; 1 0 0; 0 0 0]))
        colormap(gca,flipud(cmap_cmr))
        
        colorbar;axis image;
        hold on
        plot(ix_sim,iy_sim,'go')
        hold off
        
        %         subplot(2,3,5);
        %         imagesc(m_mode);
        %         title('Mode')
        %         caxis([-.01 1])
        %         colormap(gca,[col_nan;cmap_linear([col_min; col_max])])
        %         %colormap(gca,cmap_linear([col_min; col_max]))
        %         axis image;colorbar;
        
        subplot(1,4,4);
        p= plot(1:i,sumCondH(1:i),'k-*','MarkerSize',18,'Marker','.');
        hold on
        plot(1:i,cumsum(H(1:i)),'r-');
        axis image
        ylim([0 prod(size(SIM))])
        xlim([0 prod(size(SIM))])
        xlabel('Iteration Number')
        ylabel('Sum(H(m_i))')
        grid on
        ylim([0 max(sumCondH)])
        legend('sum(H(m_i)))','sum(SI(m_i^*))')
        %t=text(0.5,0.9,sprintf('Iteration #%3d',i),'Units','Normalized','HorizontalAlignment','center');
        title(sprintf('i=#%3d, sum(H_i)=%4.1f',i,sumCondH(i)),'Units','Normalized','HorizontalAlignment','center');
        
        
        drawnow
        
        if doPlot>0;
            
            frame = getframe(ax);
            writeVideo(writerObj,frame);
            if doPlot>1
                print_mul(sprintf('%s_%04d',vname,i))
            end
        end
        
    end
    
end
SIM_all(:,:,i+1)=SIM;
    
%%
if doPlot>0;
    for j=1:20;
        writeVideo(writerObj,frame);
    end
    close(writerObj);
end

%%
doCompH=0;
if doCompH==1;
    try
        delete('d_soft.dat')
        delete('d_hard.dat')
    end
    rng(rseed)
    % TRY COMPUTING ENT
    O1=Oin;
    O1.doEntropy=1;
    O1.doEstimation=0;
    O1.n_real=100;
    SIM=SIM.*NaN;
    [reals,O1]=mps_cpp(TI,SIM,O1);
    disp(sprintf('H=%g',mean(O1.selfE)))
end
%%
if saveMAT==1
    clear ax;
    disp(sprintf('Saving workspace to %s', txt))
    save(txt)
end