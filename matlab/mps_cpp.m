% mps_cpp: run MPS algorirthms from Matlab
%
% Call:
%   [reals,O]=mps_cpp(TI,SIM,O);
%
%
% example:
%   TI=channels;           %  training image
%   SIM=zeros(80,60).*NaN; %  simulation grid
%   O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
%   %O.method='mps_snesim_list'; %
%   %O.method='mps_genesim'; %
%   O.n_real=1;             %  optional number of realization
%   [reals,O]=mps_cpp(TI,SIM,O);
% 
% % Hard data
%   % set as d_hard parameter:
%   O.d_hard [x y z d_hard]
%   % set as non_nan_numbers in SIM (only applies if O.d_hard is not set)
%
% % Soft data
%   % set as d_soft parameter:
%   O.d_soft [x y z prob_0 prob_1 ...]
%
% % MASK
%   % set MASK
%   MASK=zeros(size(SIM));;
%   MASK(1:5,1:5)=1; % only simulate these data
%   O.d_mask=MASK; [ny nx]
%
%
% % optional
%   O.exe_root: sets the path the folder containing the MPS binary files
%
%
% See also: mps_snesim_read_par, mps_snesim_write_par, mps_genesim_read_par,
% mps_genesim_write_par
%

function [reals,O]=mps_cpp(TI,SIM,O);

if nargin==0;
    TI=channels;           %  training image
    SIM=zeros(80,60).*NaN; %  simulation grid
    O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
    %O.method='mps_snesim_list'; % MPS algorithm to run (def='mps_snesim_tree')
    %O.method='mps_genesim'; % MPS algorithm to run (def='mps_snesim_tree')
    O.n_real=1;             %  optional number of realization
    [reals,O]=mps_cpp(TI,SIM,O);
    imagesc(reals);drawnow;
    return
end

if nargin<1; TI=channels;end
if nargin<2; SIM=zeros(100,100);end
if nargin<3, O.null='';end

if nargin==1;
    if isstruct(TI);
        O=TI;
        TI=read_eas_matrix(O.ti_filename);
        SIM=ones(length(O.y),length(O.x),length(O.z)).*NaN;
    end
end



D=[];
reals=[];



%% DEFAULT VALUES
if ~isfield(O,'debug');O.debug=-1;end
if ~isfield(O,'rseed');O.rseed=0;end
if ~isfield(O,'output_folder');O.output_folder='.';end

%% write ti
if isfield(O,'ti_filename') 
    if ~exist([pwd,filesep,O.ti_filename],'file')
        O.WriteTI=1;
    end
end
if ~isfield(O,'WriteTI')
    O.WriteTI=1;
end
if O.WriteTI==1;
    if ~isfield(O,'ti_filename')
        O.ti_filename='ti.dat';
    end
    if (O.debug>1) 
        disp(sprintf('%s: writing ti %s',mfilename,O.ti_filename))
    end
    write_eas_matrix(O.ti_filename,TI);
    O.WriteTI=1;
end

%% write simulation grid
doSetSIM=1;
if doSetSIM==1;
    if ~isfield(O,'simulation_grid_size');
        [ny,nx,nz]=size(SIM);
        O.simulation_grid_size=[nx ny nz];
    end
    if ~isfield(O,'origin');
        if isfield(O,'x'); o1=O.x(1);else o1=0;end
        if isfield(O,'y'); o2=O.y(1);else o2=0;end
        if isfield(O,'z'); o3=O.z(1);else o3=0;end
        O.origin=[o1 o2 o3];
    end
    if ~isfield(O,'grid_cell_size');
        if isfield(O,'x'); dx=O.x(2)-O.x(1);else dx=1;end
        if isfield(O,'y'); dy=O.y(2)-O.y(1);else dy=1;end
        if isfield(O,'z'); dz=O.z(2)-O.z(1);else dz=1;end
        O.grid_cell_size=[dx dy dz];
    end
end

%% Clean mask filename if it exist
if ~isfield(O,'mask_filename');
    O.mask_filename = 'mask.dat';
    if exist(O.mask_filename,'file')
        delete(O.mask_filename); % delete if not set
    end
end

%%
% WRITE HARD DATA IF SET AS VARIABLE
if ~isfield(O,'hard_data_filename')
    O.hard_data_filename='d_hard.dat';
    if exist(O.hard_data_filename,'file')
        delete(O.hard_data_filename); % delete if not set
    end
    
end

if isfield(O,'d_hard');
    write_eas(O.hard_data_filename,O.d_hard);
else
    % TEST FOR NON-NAN NUMBERS IN SIM-grid
    if  O.simulation_grid_size(3)==1;
        x=[0:1:O.simulation_grid_size(1)-1]*O.grid_cell_size(1)+O.origin(1);
        y=[0:1:O.simulation_grid_size(2)-1]*O.grid_cell_size(2)+O.origin(2);
        z=[0:1:O.simulation_grid_size(3)-1]*O.grid_cell_size(3)+O.origin(3);
        [xx,yy,zz]=meshgrid(x,y,z);
        i_hard=find(~isnan(SIM));
        if ~isempty(i_hard)            
            x_hard=xx(i_hard);
            y_hard=yy(i_hard);
            z_hard=zz(i_hard);
            sim_hard=SIM(i_hard);
            O.d_hard=[x_hard(:) y_hard(:) z_hard(:) sim_hard(:)];
            %O.d_hard=[xx(i_hard) yy(i_hard) zz(i_hard) SIM(i_hard)];
            write_eas(O.hard_data_filename,O.d_hard);
        end
        
    end
end


% WRITE SOFT DATA IF SET AS VARIABLE
if isfield(O,'d_soft');
    if ~isfield(O,'soft_data_filename');
        O.soft_data_filename='d_soft.dat';
    end
    write_eas(O.soft_data_filename,O.d_soft);
end

% WRITE MASK GRID IF SET AS VARIABLE
if isfield(O,'d_mask');
    if ~isfield(O,'mask_filename');
        O.soft_data_filename='mask.dat';
    end
    write_eas_matrix(O.mask_filename,O.d_mask);
end

%%
if ~isfield(O,'method');
    O.method='mps_snesim_tree';
    %O.method='mps_snesim_list';
    %O.method='mps_genesim';
end

%% WRITE PARAMETER FILE
if strfind(O.method,'snesim');
    if strcmp(O.method,'mps_snesim');
        O.method='mps_snesim_tree';
    end
    if ~isfield(O,'parameter_filename');O.parameter_filename='mps_snesim.txt';end
    O=mps_snesim_write_par(O);
elseif (strcmp(O.method,'mps_genesim'))||(strcmp(O.method,'mps_enesim_general'))
    O.method='mps_genesim';
    if ~isfield(O,'parameter_filename');O.parameter_filename='mps_genesim.txt';end
    O=mps_genesim_write_par(O);
elseif strcmp(O.method,'mps_dsam'|O.method,'mps_ds');
    O.method='mps_genesim';
    O.n_max_cpdf_count=1;
    if ~isfield(O,'parameter_filename');O.parameter_filename='ds.txt';end
    O=mps_genesim_write_par(O);
elseif strcmp(O.method,'mps_enesim');
    O.method='mps_genesim';
    O.n_max_cpdf_count=1e+20;
    if ~isfield(O,'parameter_filename');O.parameter_filename='enesim.txt';end
    O=mps_genesim_write_par(O);
else
    disp(sprintf('%s: no method for ''%s''',mfilename,O.method));
    return
end

%% RUN MPS CODE
% make output folder if it does not exist
if ~exist(O.output_folder,'dir')
    mkdir(O.output_folder);
end

%w_root='C:\Users\tmeha\RESEARCH\PROGRAMMING\MPS';

if isfield(O,'exe_root')
    w_root = O.exe_root;
else
    w_root=[fileparts(which('mps_cpp')),filesep,'..'];
end
O.exe_filename=[w_root,filesep,O.method];
if ~isunix
    O.exe_filename=[O.exe_filename,'.exe'];
end

% check that file exist
if ~exist(O.exe_filename,'file')
    disp(sprintf('%s: %s does not exist',mfilename,O.exe_filename));
    return;
end

cmd = sprintf('"%s" %s',O.exe_filename, O.parameter_filename);
%cmd=sprintf('%s %s',O.exe_filename,O.parameter_filename);
if (O.debug>-1), disp(sprintf('%s: running ''%s''',mfilename,cmd)); end


% run the algorithm
t_init=now;
[status,cmdout]=system(cmd);
O.time = (now-t_init)*3600*24;

if (O.debug>0), 
    disp(sprintf('%s: output:',mfilename)); 
    disp(cmdout);
end

%%
O.x=[0:1:(O.simulation_grid_size(1)-1)].*O.grid_cell_size(1)+O.origin(1);
O.y=[0:1:(O.simulation_grid_size(2)-1)].*O.grid_cell_size(2)+O.origin(2);
O.z=[0:1:(O.simulation_grid_size(3)-1)].*O.grid_cell_size(3)+O.origin(3);

%% READ DATA
[p,f,e]=fileparts(O.ti_filename);
clear D;
for i=1:O.n_real
  fname=sprintf('%s%s%s%s_sg_%d.gslib',O.output_folder,filesep,f,e,i-1);  
  try
      D=read_eas_matrix(fname);
  catch
      disp(sprintf('%s: COULD NOT READ %s',mfilename,fname))
  end
  
  if (O.simulation_grid_size(2)==1)&(O.simulation_grid_size(3)==1)
    % 1D
    reals(i,:)=D;
  elseif (O.simulation_grid_size(3)==1)
    % 2D
    %reals(:,:,i)=reshape(D,O.simulation_grid_size(1),O.simulation_grid_size(2))';
    reals(:,:,i)=D;
  else
    % 3D
    reals(:,:,:,i)=D;
  end
  
end

%% Read conditional estimated grid
if isfield(O,'doEstimation');
    if O.doEstimation==1;        
        nc=1;
        fname=sprintf('%s%s%s%s_cg_%d.gslib',O.output_folder,filesep,f,e,nc-1);            
        while (exist(fname,'file'))
            %disp(fname)
            try
                D=read_eas_matrix(fname);                
            catch
                disp(sprintf('%s: COULD NOT READ %s',mfilename,fname))
            end     
            try
            if (O.simulation_grid_size(2)==1)&(O.simulation_grid_size(3)==1)
                % 1D
                O.cg=D;
            elseif (O.simulation_grid_size(3)==1)
                % 2D
                O.cg(:,:,nc)=D;
            else
                % 3D
                O.cg(:,:,:,nc)=D;
            end
            catch
                disp(sprintf('%s: COULD NOT HANDLE %s',mfilename,fname))
            end
            nc=nc+1;
            fname=sprintf('%s%s%s%s_cg_%d.gslib',O.output_folder,filesep,f,e,nc-1);
            
        end
        
        % replace NaN with 0,1
        % only works in 2D
        handleNaN=1;
        if handleNaN==1;
        if isfield(O,'d_hard')&&(O.simulation_grid_size(3)==1);
            s=size(O.cg);nc=s(end);
            vals=[0:1:nc-1];
            try
            for i=1:size(O.d_hard,1);
                P=zeros(1,nc);
                P(O.d_hard(i,4)==vals)=1;
                ix1=ceil((O.d_hard(i,1)-O.origin(1))/O.grid_cell_size(1));
                iy1=ceil((O.d_hard(i,2)-O.origin(2))/O.grid_cell_size(2));
                for ic=1:nc
                    try
                        if (ix1>=1)&(iy1>=1)&(ix1<=O.simulation_grid_size(1))&(iy1<=O.simulation_grid_size(2))                        
                            O.cg(iy1,ix1,ic)=P(ic);
                        end
                    catch
                        keyboard
                    end
                end
            end
            catch
                disp('O.cg prob')
            end
        end
        end
    end
end

%% READ ENTROPY
if (O.doEntropy>0)
    
    try
        fname=sprintf('%s%s%s%s_selfInf.dat',O.output_folder,filesep,f,e);
        O.SI=load(fname);
    catch
        disp(sprintf('Could not load %s',fname));
    end       
    O.H=mean(O.SI);

    for i=1:O.n_real                 
         fname=sprintf('%s%s%s%s_ent_%d.gslib',O.output_folder,filesep,f,e,i-1);
         try
             D=read_eas_matrix(fname);
             %O.selfE(i)=nansum(D(:));
         catch
             disp(sprintf('%s: COULD NOT READ %s',mfilename,fname))
         end
         
         if (O.simulation_grid_size(2)==1)&(O.simulation_grid_size(3)==1)
             % 1D
             O.E(i,:)=D;
         elseif (O.simulation_grid_size(3)==1)
             % 2D
             O.E(:,:,i)=D;
         else
             % 3D
             O.E(:,:,:,i)=D;
         end
     end
end

%% READ TEMPORARY GRID VALUES
if (O.debug>1)
    for i=1:O.n_real
        for j=1:5;
            fname=sprintf('%s%s%s%s_tg%d_%d.gslib',O.output_folder,filesep,f,e,j,i-1);
            if exist(fname,'file')
                O.(sprintf('TG%d',j))=read_eas_matrix(fname);
            end
        end
    end
    
    % PATH
    fname=sprintf('%s%s%s%s_path_%d.gslib',O.output_folder,filesep,f,e,0);    
    if exist(fname,'file')
        
        O.I_PATH=ones([O.simulation_grid_size(2) O.simulation_grid_size(1) O.simulation_grid_size(3)]).*NaN;;
        O.i_path=read_eas(fname);
        nxyz=prod(O.simulation_grid_size);
        for i=1:length(O.i_path)
            if (O.i_path(i)>0) && (O.i_path(i)<nxyz)
                %iz=1;[ix,iy]=ind2sub([O.simulation_grid_size(1),O.simulation_grid_size(2)],O.i_path(i)+1);
                [ix,iy,iz]=ind2sub([O.simulation_grid_size(1),O.simulation_grid_size(2),O.simulation_grid_size(3)],O.i_path(i)+1);
                try
                    O.I_PATH(iy,ix)=i;
                catch
                    disp(sprintf('%s: could not update O.I_PATH(%d,%d)',mfilename,iy,ix))
                end
            else
                O.I_PATH(iy,ix)=NaN;
            end
        end
    end
end

%% relocation grids
if (O.debug>2)
    try
    j=0;
    for ilevel=O.n_multiple_grids:-1:0;
        j=j+1;
                                              
        O.D_A_before{j}=read_eas_matrix(sprintf('%s%s%s%s_sg_A_before_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        O.D_B_after_relocate{j}=read_eas_matrix(sprintf('%s%s%s%s_sg_B_after_hard_relocation_before_simulation_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        O.D_C_after_sim{j}=read_eas_matrix(sprintf('%s%s%s%s_sg_C_after_simulation_before_cleaning_relocation_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        O.D_D_after_sim{j}=read_eas_matrix(sprintf('%s%s%s%s_sg_D_after_hard_cleaning_relocation_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        
    end
    catch
        disp(sprintf('%s: Could not read relocation grids',mfilename))
    end
end


%% paths at grids
if (O.debug>2)
    try
    j=0;
    for ilevel=O.n_multiple_grids:-1:0;
        j=j+1;
        O.nmg_path{j}.index=read_eas(sprintf('%s%s%s%s_path_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        [O.nmg_path{j}.ix,O.nmg_path{j}.iy]=ind2sub([length(O.x) length(O.y)],O.nmg_path{j}.index+1);       
    end
    
    catch
    disp(sprintf('%s: Could not read nmg paths',mfilename))
    end
end

%% SOFT GRIDS
if (O.debug>2)
    try
    j=0;
    for ilevel=O.n_multiple_grids:-1:0;
        j=j+1;       
        O.SOFT_before{j}=read_eas_matrix(sprintf('%s%s%s%s_sdg_before_shuffling_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
        O.SOFT_after{j}=read_eas_matrix(sprintf('%s%s%s%s_sdg_after_shuffling_0_level_%d.gslib',O.output_folder,filesep,f,e,ilevel));   
    end
    
    catch
        disp(sprintf('%s: Could not read soft data',mfilename))        
    end
end


%%
if ~isfield(O,'clean'), O.clean=1; end
if (O.clean)  
    mps_cpp_clean(O);
end




