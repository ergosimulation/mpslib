% mps_cpp_estimation: Perform sequential estimation
%
% Will split sequentuial estimation on multiple threads
%
% Select number of threads by running
% parpool(nthreads) before running this function.
%
function [est,O]=mps_cpp_estimation(TI,SIM,O,use_parfor)
doPlot=1;

O.n_real=1;
if nargin<4, use_parfor=1;end

if (license('test','Distrib_Computing_Toolbox')==0);
    disp(sprintf('%s: parallel toolbox not available - using single thread',mfilename))
    use_parfor=0;
end

if use_parfor==1;

    %% try use parpool
    try
        %poolobj = gcp('nocreate');
        poolobj = gcp;
        n_threads=poolobj.NumWorkers;
    catch
        disp(sprintf('%s: No parallel toolbox - using 1 thread/worker',mfilename))
        n_threads=1;
    end
    t_init=now;
    
    [ny,nx,nz]=size(SIM);
    nxyz=prod(size(SIM));
    nsub=ceil(nxyz/n_threads);
    
    % setup masks
    ii_r=shuffle(1:nxyz); % shuffle nodes
    %ii_r=1:1:nxyz;
    
    i0=0;
    for i=1:n_threads
        i1=i0+1;
        if i<n_threads
            i2=i0+nsub;
        else
            i2=nxyz;
        end
        ii{i}=ii_r(i1:1:i2);
        i0=i2;
        
        mask{i}=zeros(size(SIM));
        for j=1:length(ii{i})
            [ix1,iy1,iz1]=ind2sub([nx ny nz],ii{i}(j));
            mask{i}(iy1,ix1,iz1)=1;
        end
        if isfield(O,'d_mask')
            mask{i}=mask{i}.*O.d_mask;
        end
        
        if doPlot==1;
            nsp=ceil(sqrt(n_threads));
            subplot(nsp,nsp,i);
            imagesc(mask{i});
            colormap(gca,1-gray);
            axis image;drawnow;
            title(sprintf('subset %d/%d',i,n_threads))
        end
    end
    
    %% setup multiple runs
    for i=1:n_threads
        Othread{i}=O;
        Othread{i}.d_mask=mask{i};
        
        % make outdir
        outdir{i}=sprintf('mps_%02d',i);
        if ~exist(outdir{i},'dir')
            % create an emprt directory
            [status,message]=mkdir(outdir{i});
            if status==0;
                disp(sprintf('%s: %s',mfilename,message));
            end
        end
        
        % copy hard and soft data
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
    
    %% Perform the estimation
    cwd=pwd;
    parfor i=1:n_threads;
        cd(cwd);
        cd(outdir{i});
        
        disp(sprintf('%s: running thread #%d in %s',mfilename,i,outdir{i}));
        [r{i},Othread{i}]=mps_cpp(TI,SIM,Othread{i});
    end
    cd(cwd);
    %% COLLECT THE DATA FROM THE THREADS
    est=Othread{1}.cg.*nan;
    for i=1:n_threads;
        for ix=1:nx
        for iy=1:ny
        for iz=1:nz
            if Othread{i}.d_mask(iy,ix,iz)==1;
                if nz==1
                    est(iy,ix,:)=Othread{i}.cg(iy,ix,:);
                else
                    est(iy,ix,iz,:)=Othread{i}.cg(iy,ix,iz,:);
                end                    
            end
        end
        end
        end
    end
    O=Othread{1};
    O.cg=est;
    O.time = (now-t_init)*3600*24;
    
else
    [reals,O]=mps_cpp(TI,SIM,O);
    est = O.cg;
end

