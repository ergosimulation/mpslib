function O=mps_genesim_write_par(O,parameter_filename);

if nargin==0, 
    help(mfilename);
    O='';
    return
end

if nargin==1
    if isfield(O,'parameter_filename');
        parameter_filename=O.parameter_filename;
    else
        parameter_filename='mps_enesim.txt';
    end
end

O.parameter_filename=parameter_filename;

%% SOME DEFAULTS
if ~isfield(O,'n_real'); O.n_real=1; end
if ~isfield(O,'rseed'); O.rseed=0; end
if ~isfield(O,'n_cond'); O.n_cond=[25 1]; end
if ~isfield(O,'n_max_ite'); 
    O.n_max_ite=1000000; 
else
    O.n_max_ite = ceil(O.n_max_ite(1));
end
if ~isfield(O,'n_max_cpdf_count'); O.n_max_cpdf_count=1; end
%if ~isfield(O,'template_size'); O.template_size=[5 5 1]; end
if ~isfield(O,'simulation_grid_size'); O.simulation_grid_size=[50 50 1]; end
if ~isfield(O,'origin'); O.origin=[0 0 0]; end
if ~isfield(O,'grid_cell_size'); O.grid_cell_size=[1 1 1]; end
if ~isfield(O,'ti_filename');O.ti_filename='TI/ti_strebelle_250_250_1.sgems';end 
if ~isfield(O,'mask_filename');O.mask_filename='mask.dat';end 
if ~isfield(O,'output_folder');O.output_folder='.';end 
if ~isfield(O,'shuffle_simulation_grid');O.shuffle_simulation_grid=2;end
if ~isfield(O,'entropyfactor_simulation_grid');O.entropyfactor_simulation_grid=4;end
if ~isfield(O,'shuffle_ti_grid');O.shuffle_ti_grid=1;end
if ~isfield(O,'hard_data_filename');O.hard_data_filename='conditional.dat';end
if ~isfield(O,'hard_data_search_radius');O.hard_data_search_radius=100000;end
%if ~isfield(O,'soft_data_search_radius');O.soft_data_search_radius=O.hard_data_search_radius;end
if ~isfield(O,'soft_data_categories');O.soft_data_categories='0;1';end
if ~isfield(O,'soft_data_filename');O.soft_data_filename='soft.dat';end
if ~isfield(O,'n_threads');O.n_threads=1;end
if ~isfield(O,'debug');O.debug=-1;end
 
if ~isfield(O,'distance_measure');O.distance_measure=1;end
if ~isfield(O,'distance_min');O.distance_min=0;end
if ~isfield(O,'distance_pow');O.distance_pow=0;end

if ~isfield(O,'colocated_dimension');O.colocated_dimension=0;end

if ~isfield(O,'max_search_radius');O.max_search_radius=[1 1].*1e+6;end

if ~isfield(O,'doEstimation');O.doEstimation=0;end
if ~isfield(O,'doEntropy');O.doEntropy=0;end

if (O.doEstimation==1)&&(O.n_real>1)
    O.n_real=1;
    disp(sprintf('%s: Setting n_real=%d in estimation mode.',mfilename,O.n_real))
end

if (O.doEstimation==1)&&(O.n_max_cpdf_count==1)    
    disp(sprintf('%s: O.n_max_cpdf_count=1 (DS mode) is not usefull in estimation mode',mfilename))
    O.n_max_cpdf_count=1000;
    disp(sprintf('%s: Setting O.n_max_cpdf_count=%d in estimation mode.',mfilename,O.n_max_cpdf_count))
end

% multiple grids are not used by enesim
%if (O.n_multiple_grids~=0);
    %disp(sprintf('%s: Setting nmulgrids to ZERO to avoid relocation',mfilename));
    %O.n_multiple_grids=0;
%end
   

%% WRITE STRUCTURE TO PARAMETER FILE
fid=fopen_retry(O.parameter_filename,'w');

fprintf(fid,'Number of realizations # %d\n',O.n_real);
fprintf(fid,'Random Seed (0 `random` seed) # %d\n',O.rseed);
fprintf(fid,'Maximum number of counts for conditional pdf # %d\n',O.n_max_cpdf_count);
% LIMIT NEIGHBORHOOD
if (length(O.n_cond)==1)
    fprintf(fid,'Max number of conditional point (Nhard) # %d\n',O.n_cond(1));
else
    fprintf(fid,'Max number of conditional point (Nhard,Nsoft) # %d %d\n',O.n_cond(1),O.n_cond(2));
end
fprintf(fid,'Max number of iterations # %d\n',O.n_max_ite);
%
%Distance measure [1:disc, 2:cont], minimum distance # 1 0
fprintf(fid,'Distance measure [1:disc, 2:cont], minimum distance, distance power # %d %f %f\n',O.distance_measure,O.distance_min,O.distance_pow);

% Colocated Dimension
fprintf(fid,'Colocated Dimension [0: no colocattion; >0: Colocated] # %d \n',O.colocated_dimension);


% maximum search radius
if (length(O.max_search_radius)==1)
    fprintf(fid,'Maximum search radius # %f\n',O.max_search_radius(1));
else
    fprintf(fid,'Maximum search radius # %f %f\n',O.max_search_radius(1),O.max_search_radius(2));
end

% SIMULATION GRID SIZE
for i=1:3;
  fprintf(fid,'Simulation grid size %s # %d\n',char(87+i),O.simulation_grid_size(i));
end
% WORLD/ORIGIN
for i=1:3;
  fprintf(fid,'Simulation grid world/origin %s # %d\n',char(87+i),O.origin(i));
end
% GRID CELL SIZE
for i=1:3;
  fprintf(fid,'Simulation grid grid cell size %s # %d\n',char(87+i),O.grid_cell_size(i));
end

fprintf(fid,'Training image file (spaces not allowed) # %s\n',O.ti_filename);
fprintf(fid,'Output folder (spaces in name not allowed) # %s\n',O.output_folder);
fprintf(fid,'Shuffle Simulation Grid path (2: preferential, 1: random, 0: sequential, EF) # %d %g\n',O.shuffle_simulation_grid,O.entropyfactor_simulation_grid);
fprintf(fid,'Shuffle Training Image path (1: random, 0: sequential) # %d\n',O.shuffle_ti_grid);
% HARD DATA
fprintf(fid,'HardData filename  (same size as the simulation grid)# %s\n',O.hard_data_filename);
fprintf(fid,'HardData seach radius (world units) # %g\n',O.hard_data_search_radius);
% SOFT DATA
fprintf(fid,'Softdata categories (separated by ;) # %s\n',O.soft_data_categories);
fprintf(fid,'Soft datafilenames (separated by ; only need (number_categories - 1) grids) # %s\n',O.soft_data_filename);

fprintf(fid,'Number of threads (minimum 1, maximum 8 - depend on your CPU) # %d\n',O.n_threads);
fprintf(fid,'Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # %d\n',O.debug);
% MASK GRID
fprintf(fid,'Mask grid # %s\n',O.mask_filename);
% doEntropy?
fprintf(fid,'doEntropy # %d\n',O.doEntropy);
% doESTIMATION?
fprintf(fid,'doEstimation # %d\n',O.doEstimation);

fclose(fid);
