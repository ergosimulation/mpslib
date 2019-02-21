% mps_cpp_plot: plot result of MPS simulation
%
% Call:
%   [reals,O]=mps_cpp_plot(reals,O);
%
% example:
%   TI=channels;           %  training image
%   SIM=zeros(80,60).*NaN; %  simulation grid
%   O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
%   %O.method='mps_snesim_list'; %
%   %O.method='mps_genesim'; %
%   O.n_real=1;             %  optional number of realization
%   [reals,O]=mps_cpp(TI,SIM,O);
%   mps_cpp_plot(reals,O);
%
% See also: mps_snesim_read_par, mps_snesim_write_par, mps_genesim_read_par,
% mps_genesim_write_par
%

function mps_cpp_plot(reals,O,hardcopy);
if nargin<3, hardcopy=0;end


if (length(O.z)==1)&&(length(O.y)==1);
    % 1D
    return
end

if strcmp(O.method,'mps_genesim')
    strTG{1}='Accepted Distance';
    strTG{2}='#Counts in conditional pd';
    strTG{3}='Index in TI';
    strTG{4}='#Ite in TI';
    strTG{5}='#sed conditional points';
else
    strTG{1}='#Conditional points';
    strTG{2}='maxLevel';
    strTG{3}='sumCounters';
  
end

try
if exist(O.hard_data_filename)
    d_hard=read_eas(O.hard_data_filename);
end
if exist(O.soft_data_fnam)
    d_soft=read_eas(O.soft_data_fnam);
end
end        

if (length(O.z)==1);
    % 2D
    
    % REALS
    figure;
    np=min([O.n_real, 25]);
    nsp=ceil(sqrt(np));
    for i=1:np;
        subplot(nsp,nsp,i);
        imagesc(O.x,O.y,reals(:,:,i));
        xlabel('X');ylabel('Y');title(sprintf('Real #%d',i))
        axis image;
    end
    if hardcopy==1; 
        print('-dpng',sprintf('%s_reals.png',O.ti_filename));
    end
    
    %% ETYPE'
    try
        [em,ev,emode]=etype(reals);
    catch
        [em,ev]=etype(reals);
    end
    figure;
    subplot(1,3,1);
    imagesc(O.x,O.y,em);axis image;title('Mean');colorbar
    subplot(1,3,2);
    imagesc(O.x,O.y,ev);axis image;title('Variance');colorbar
    try
        subplot(1,3,3);
        imagesc(O.x,O.y,emode);axis image;title('Mode');colorbar
    end
    if hardcopy==1; 
        print('-dpng',sprintf('%s_etype.png',O.ti_filename));
    end
    
    
    
    if O.debug>1
        figure;clf;
        
        nTG=length(strTG);
        
        if nTG<=3
            nsp_x = 1; 
            nsp_y = nTG;
        else
            nsp_x = 2; 
            nsp_y = ceil(nTG/2);
        end
            
        
        for i=1:nTG;
            subplot(nsp_y,nsp_x,i);
            imagesc(O.x,O.y,O.(sprintf('TG%d',i)));
            xlabel('X');ylabel('Y');
            title(strTG{i})
            axis image;
            colorbar
        end
        if hardcopy==1; 
            print('-dpng',sprintf('%s_debug_1.png',O.ti_filename));
        end
        
        if strcmp(O.method,'mps_genesim')
            
            % plot poisition in TI
            figure;clf;
            TI=read_eas_matrix(O.ti_filename);
            [ny,nx]=size(TI);
            j=0;
            for i=1:prod(size(reals(:,:,end)));
                [ix,iy]=ind2sub([nx,ny],O.TG3(i));
                if ~isnan(ix);
                    j=j+1;
                    ix_all(j)=ix;
                    iy_all(j)=iy;
                    d(j)=TI(iy,ix);
                end
                %plot(ix,iy,'ro','MarkerSize',1+12*(i/prod(O.simulation_grid_size)))
            end
            imagesc(TI);title('Training image');
            axis image;
            cax=caxis;
            colormap(gray)
            hold on
            cmap=hsv;
            
            %cmap=cmap_geosoft;
            nc=size(cmap,1);
            i_col=1+ceil((nc-1)*(d-cax(1))./(1+cax(2)-cax(1)));
            for i=1:length(d);
                cmap_scatter(i,:)=cmap(i_col(i),:);
            end
            s=scatter(ix_all,iy_all,10,cmap_scatter,'filled');
            colorbar
            if hardcopy==1; 
                print('-dpng',sprintf('%s_debug_2.png',O.ti_filename));
            end     
        end
        
        figure;clf;
        imagesc(O.x,O.y,O.I_PATH);
        axis image
        caxis([0 8])
        title('Path')
        
        if hardcopy==1; 
            print('-dpng',sprintf('%s_path.png',O.ti_filename));
        end
        
    end
    
    %% RELOCATION GRIDS
    if O.debug>2
        cmap=cmap_linear([1 1 1; 1 0 0; 0 0 0]);
        cax=[-1 max(max(reals(:)))];
        figure;clf
        NG=4;
        NM=O.n_multiple_grids+1;
        for i=1:NM
            subplot(NG,NM,i);imagesc(O.x,O.y,O.D_A_before{i});axis image;caxis(cax);colormap(cmap)
            title(sprintf('A - IGRID=%d',O.n_multiple_grids-i+1));
            
            subplot(NG,NM,NM+i);imagesc(O.x,O.y,O.D_B_after_relocate{i});axis image;caxis(cax);colormap(cmap)
            try
                hold on;plot(d_hard(:,1),d_hard(:,2),'ro');hold off
            end
            try;hold on;scatter(d_soft(:,1),d_soft(:,2),20*abs(5-d_soft(:,4)),'ko');hold off;end
            title('B - After Relo')
   
            
            subplot(NG,NM,2*NM+i);imagesc(O.x,O.y,O.D_C_after_sim{i});axis image;caxis(cax);colormap(cmap)
            try
                hold on;plot(d_hard(:,1),d_hard(:,2),'ro');hold off
            end
            try;hold on;scatter(d_soft(:,1),d_soft(:,2),20*abs(5-d_soft(:,4)),'ko');hold off;end
            title('C - After Sim')
            
            subplot(NG,NM,3*NM+i);imagesc(O.x,O.y,O.D_D_after_sim{i});axis image;caxis(cax);colormap(cmap)
            try
                hold on;plot(d_hard(:,1),d_hard(:,2),'ro');hold off
            end
            try;hold on;scatter(d_soft(:,1),d_soft(:,2),20*abs(5-d_soft(:,4)),'ko');hold off;end
            title('D - Rem relocated - done')
        end
        if hardcopy==1;
            print('-dpng',sprintf('%s_relocation.png',O.ti_filename));
        end

    end
    
    if isfield(O,'nmg_path');
        figure
        N=length(O.nmg_path);
        for i=1:N
            subplot(1,N,i);
            %scatter(O.nmg_path{i}.ix,O.nmg_path{i}.iy,20,1:1:length(O.nmg_path{i}.ix),'filled');caxis([1 5])
            scatter(O.x(O.nmg_path{i}.ix),O.y(O.nmg_path{i}.iy),10,1:1:length(O.nmg_path{i}.ix),'filled');caxis([1 5])
            axis image
            set(gca,'ydir','reverse');
            box on
            try;hold on;scatter(d_soft(:,1),d_soft(:,2),20*abs(5-d_soft(:,4)),'ko');hold off;end
            try
                hold on
                plot(d_hard(:,1),d_hard(:,2),'ro')
                hold off
            end
            title(sprintf('MG=%d',O.n_multiple_grids-i+1))
            colormap(gca,hot)
            colormap(gca,cmap_linear([1 0 0; 0 1 0; 0 0 1;0 0 0]))
        end
        try
            suptitle('Random path at each grid')
        end
        if hardcopy==1;
            print('-dpng',sprintf('%s_nmg_grid.png',O.ti_filename));
        end
    end
    
    %% 
    if isfield(O,'SOFT_before')
        figure
        N=length(O.nmg_path);
        for i=1:N
           subplot(2,N,i);
           imagesc(O.x,O.y,O.SOFT_before{i}(:,:,1,1))
           caxis([-1 1])
           axis image
           title(sprintf('before MG=%d',O.n_multiple_grids-i+1))
          
           subplot(2,N,i+N);
           imagesc(O.x,O.y,O.SOFT_after{i}(:,:,1,1))
           caxis([-1 1])
           axis image
           title(sprintf('after MG=%d',O.n_multiple_grids-i+1))
          
           
        end
        try;suptitle('SOft Data');end
        if hardcopy==1;
            print('-dpng',sprintf('%s_soft_data_grid.png',O.ti_filename));
        end
    end
    
    
end




