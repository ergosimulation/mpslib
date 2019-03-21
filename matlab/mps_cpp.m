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
if ~isfield(O,'rseed');O.rseed=1;end
if ~isfield(O,'output_folder');O.output_folder='.';end

%% write ti
%if exist([pwd,filesep,O.ti_filename],'file')
%    O.WriteTI=0;
%else
%    O.WriteTI=1;
%end
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
end

%% write simulation grid
doSetSIM=1;
if doSetSIM==1;
    if ~isfield(O,'simulation_grid_size');
        [ny,nx,nz]=size(SIM);
        O.simulation_grid_size=[nx ny nz];
    end
    if ~isfield(O,'origin');
        O.origin=[0 0 0];
    end
    if ~isfield(O,'grid_cell_size');
        O.grid_cell_size=[1 1 1];
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
    if ~isfield(O,'d_soft');
        O.soft_data_fnam='d_soft.dat';
    end
    write_eas(O.soft_data_fnam,O.d_soft);
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

cmd=sprintf('%s %s',O.exe_filename,O.parameter_filename);
if (O.debug>-1), disp(sprintf('%s: running ''%s''',mfilename,cmd)); end

% run the algorithm
tic;
[status,cmdout]=system(cmd);
O.time=toc;

if (O.debug>0), 
    disp(sprintf('%s: output:',mfilename)); 
    disp(cmdout);
end

%%

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
    reals=D;
  elseif (O.simulation_grid_size(3)==1)
    % 2D
    %reals(:,:,i)=reshape(D,O.simulation_grid_size(1),O.simulation_grid_size(2))';
    reals(:,:,i)=D;
  else
    % 3D
    reals(:,:,:,i)=D;
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
    
    
    fname=sprintf('%s%s%s%s_path_%d.gslib',O.output_folder,filesep,f,e,i-1);
    if exist(fname,'file')
        O.(sprintf('I_PATH'))=read_eas_matrix(fname);
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
if (O.debug>1)
    for i=1:O.n_real
        fname_path=sprintf('%s%s%s%s_path_%d.gslib',O.output_folder,filesep,f,e,i-1);
        
        
        
        try
            PP=read_eas(fname_path);
        catch
            disp(sprintf('%s: problems reading output file (%s) - waiting a bit an retrying',mfilename,fname));
            pause(5);
            PP=read_eas(fname_path);
        end
        O.path(:,i)=PP(:);
        
        if (O.simulation_grid_size(2)==1)&(O.simulation_grid_size(3)==1)
            % 1D
        elseif (O.simulation_grid_size(3)==1)
            % 2D
            try
                O.P=read_eas_matrix(fname_path);
            end
            [ix,iy]=ind2sub([O.simulation_grid_size(2),O.simulation_grid_size(1)],PP(:)+1);
            for j=1:length(ix);
                O.I_PATH(iy(j),ix(j),i)=j;
            end
        else
            % 3D
        end
        
        
    end
end


O.x=[0:1:(O.simulation_grid_size(1)-1)].*O.grid_cell_size(1)+O.origin(1);
O.y=[0:1:(O.simulation_grid_size(2)-1)].*O.grid_cell_size(2)+O.origin(2);
O.z=[0:1:(O.simulation_grid_size(3)-1)].*O.grid_cell_size(3)+O.origin(3);

%%
if ~isfield(O,'clean'), O.clean=1; end
if (O.clean)
    mps_cpp_clean(O);
end




