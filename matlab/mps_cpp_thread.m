% mps_cpp_threads: run MPS algorirthms using multiple threads
%
% Call:
%   [reals,O]=mps_cpp_threads(TI,SIM,O);
%
% example:
%   TI=channels;           %  training image
%   SIM=zeros(80,60).*NaN; %  simulation grid
%   O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
%   %O.method='mps_snesim_list'; % MPS algorithm to run 
%   %O.method='mps_genesim'; % MPS algorithm to run
%   O.n_real=8;             %  optional number of realization
%   [reals,O]=mps_cpp_thread(TI,SIM,O);
%
% See also: mps_cpp, mps_snesim_read_par, mps_snesim_write_par,
%           mps_genesim_read_par, mps_genesim_write_par
%
%
function [reals,O,Othread]=mps_cpp_thread(TI,SIM,O,verbose);
reals=[];

if ~isfield(O,'n_real');
    O.n_real=1;
end
if ~isfield(O,'rseed');O.rseed=1;end
if ~isfield(O,'debug');O.debug=0;end

%% try to use parpool
try
    %poolobj = gcp('nocreate');
    poolobj = gcp;
    n_threads=poolobj.NumWorkers;
catch
    disp(sprintf('%s: No parallel toolbox - using 1 thread/worker',mfilename))
    n_threads=1;
end

n_reals_per_thread=ceil(O.n_real/n_threads);
actual_threads=ceil(O.n_real/n_reals_per_thread);


if actual_threads==1;
    disp(sprintf('%s: No parallelization, using 1 thread/worker',mfilename))
    [reals,O]=mps_cpp(TI,SIM,O);
    return
else
    if O.debug>-1
        disp(sprintf('%s: Using %d threads/workers',mfilename,actual_threads))
    end
end


%%
for i=1:actual_threads;
    outdir{i}=sprintf('mps_%02d',i);
    if ~exist(outdir{i},'dir')
        % create an emprt directory
        [status,message]=mkdir(outdir{i});
        if status==0;
            disp(sprintf('%s: %s',mfilename,message));
        end
    end
    Othread{i}=O;
    %Othread{i}.output_folder=[outdir{i},filesep,'.'];
    if i==actual_threads
        reals_left=O.n_real-(i-1)*n_reals_per_thread;
        Othread{i}.n_real=reals_left;
    else
        Othread{i}.n_real=n_reals_per_thread;
    end
    Othread{i}.rseed=O.rseed+i;
    
    try
        if exist([pwd,filesep,O.hard_data_filename],'file');
            copyfile([pwd,filesep,O.hard_data_filename],[outdir{i}]);
        end
    catch
        try 
            disp(sprintf('%s: Could not copy %s to %s',mfilename,O.soft_data_fnam,outdir{i}));
        catch
            % disp(sprintf('%s: No soft data',mfilename));
        end
    end
    try
        if exist([pwd,filesep,O.soft_data_fnam]','file');
            copyfile([pwd,filesep,O.soft_data_fnam],[outdir{i}]);
        end
    end
    
end
%%

cwd=pwd;
t_init=now;
parfor i=1:actual_threads;
    cd(cwd);
    cd(outdir{i});
    if ~isfield(Othread{i},'debug');Othread{i}.debug=0;end
    if Othread{i}.debug>0;
        disp(sprintf('%s: running thread #%d in %s',mfilename,i,outdir{i}));
    end
    [r{i},Othread{i}]=mps_cpp(TI,SIM,Othread{i});
end
t_total = (now-t_init)*3600*24;

for i=1:actual_threads;
    t_thread(i) = Othread{i}.time;
end
%%
cd(cwd);
if (Othread{1}.simulation_grid_size(3)==1)&&(Othread{1}.simulation_grid_size(2)==1)
    ndim=1;
elseif (Othread{1}.simulation_grid_size(3)==1)
    ndim=2;
else
    ndim=3;
end

for i=1:actual_threads;
    if i==1;
        reals=r{i};
    else
        reals=cat(ndim+1,reals,r{i});
    end
end

%%
if nargout>1
    fn=fieldnames(Othread{1});
    t_sum=0;
    for i=1:length(fn)
        if ~isfield(O,fn{i})
            O.(fn{i})=Othread{1}.(fn{i});
        end
    end
    O.time = t_total;
    O.time_thread = t_thread;
end
%% Extract entropy 
if (O.doEntropy>0)
    i0=0;
    O.SI=zeros(1,O.n_real);
    for i=1:actual_threads
        %update SI
        O.SI(i0+[1:Othread{i}.n_real])=Othread{i}.SI;
        
        % Update E
        for j=1:Othread{i}.n_real
            
            if (O.simulation_grid_size(2)==1)&(O.simulation_grid_size(3)==1)
                % 1D
                O.E(i0+j,:)=Othread{i}.E(j,:);
            elseif (O.simulation_grid_size(3)==1)
                % 2D
                O.E(:,:,i0+j)=Othread{i}.E(:,:,j);
            else
                % 3D
                O.E(:,:,:,i0+j)=Othread{i}.E(:,:,:,j);
            end
        end
        i0=i0+Othread{i}.n_real;
    end
    O.H=mean(O.SI);
end







