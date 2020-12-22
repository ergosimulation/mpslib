% mps_snesim_write_par
%
% See also: mps_cpp, mps_snesim_read_par
function O=mps_snesim_write_par(O,parameter_filename);


if nargin==0, 
    help(mfilename);
    O='';
    return
end

if nargin==1
    if isfield(O,'parameter_filename');
        parameter_filename=O.parameter_filename;
    else
        parameter_filename='mps_snesim_test.txt';
    end
end

O.parameter_filename=parameter_filename;

%% SOME DEFAULTS
if ~isfield(O,'n_real'); O.n_real=1; end
if ~isfield(O,'rseed'); O.rseed=0; end
if ~isfield(O,'n_multiple_grids'); O.n_multiple_grids=3; end
if ~isfield(O,'n_min_node_count');O.n_min_node_count=0; end
if ~isfield(O,'n_cond');O.n_cond=39; end
if ~isfield(O,'template_size'); O.template_size=[5 5 1]; end
if ~isfield(O,'simulation_grid_size'); O.simulation_grid_size=[50 50 1]; end
if ~isfield(O,'origin'); O.origin=[0 0 0]; end
if ~isfield(O,'grid_cell_size'); O.grid_cell_size=[1 1 1]; end
%if ~isfield(O,'ti_filename');O.ti_filename='snesim.ti';end 
if ~isfield(O,'ti_filename');O.ti_filename='TI/ti_strebelle_250_250_1.sgems';end 
if ~isfield(O,'mask_filename');O.mask_filename='mask.dat';end 
if ~isfield(O,'output_folder');O.output_folder='.';end 
if ~isfield(O,'shuffle_simulation_grid');O.shuffle_simulation_grid=2;end
if ~isfield(O,'entropyfactor_simulation_grid');O.entropyfactor_simulation_grid=4;end
if ~isfield(O,'shuffle_simulation_grid');O.shuffle_simulation_grid=2;end
%if ~isfield(O,'n_max_cpdf_count');O.n_max_cpdf_count=0;end
if ~isfield(O,'shuffle_ti_grid');O.shuffle_ti_grid=1;end
if ~isfield(O,'hard_data_filename');O.hard_data_filename='conditional.dat';end
if ~isfield(O,'hard_data_search_radius');O.hard_data_search_radius=1;end
if ~isfield(O,'soft_data_categories');O.soft_data_categories='0;1';end
if ~isfield(O,'soft_data_filename');O.soft_data_filename='soft.dat';end
if isfield(O,'soft_data_fnam');O.soft_data_filename=O.soft_data_fnam,end
if ~isfield(O,'n_threads');O.n_threads=1;end
if ~isfield(O,'debug');O.debug=-1;end
if ~isfield(O,'doEstimation');O.doEstimation=0;end
if ~isfield(O,'doEntropy');O.doEntropy=0;end

if (O.doEstimation==1)&&(O.n_real>1)
    O.n_real=1;
    disp(sprintf('%s: Setting n_real=%d in estimation mode.',mfilename,O.n_real))
end
%% WRITE STRUCTURE TO PARAMETER FILE
fid=fopen(O.parameter_filename,'w');

fprintf(fid,'Number of realizations # %d\n',O.n_real);
fprintf(fid,'Random Seed (0 `random` seed) # %d\n',O.rseed);
fprintf(fid,'Number of mulitple grids (start from 0) # %d\n',O.n_multiple_grids);

% TEMPLATE SIZE
fprintf(fid,'Min Node count (0 if not set any limit)# %d\n',O.n_min_node_count);
fprintf(fid,'Maximum number condtitional data (0: all) # %d\n',O.n_cond(1));
for i=1:3;
    if prod(size(O.template_size))==6;
        % VARYING TEMPLATE
        fprintf(fid,'Search template size %s # %d %d\n',char(87+i),O.template_size(i,:));
    else
        % CONSTANT TEMPLATE
        fprintf(fid,'Search template size %s # %d\n',char(87+i),O.template_size(i));
    end
    end
% SIMULATION GRID SUZE
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
% fprintf(fid,'Preferential Entropy Factor  (0: No random) # %d\n',O.entropyfactor_simulation_grid);
fprintf(fid,'Shuffle Training Image path (1 : random, 0 : sequential) # %d\n',O.shuffle_ti_grid);
% HARD DATA
fprintf(fid,'HardData filename  (same size as the simulation grid)# %s\n',O.hard_data_filename);
fprintf(fid,'HardData seach radius (world units) # %g\n',O.hard_data_search_radius);
% SOFT DATA
fprintf(fid,'Softdata categories (separated by ;) # %s\n',O.soft_data_categories);
fprintf(fid,'Soft datafilenames (separated by ; only need (number_categories - 1) grids) # %s\n',O.soft_data_filename);

fprintf(fid,'Number of threads (minimum 1, maximum 8 - depend on your CPU) # %d\n',O.n_threads);
fprintf(fid,'Debug mode(2: write to file, 1: show preview, 0: show counters, -1: no ) # %d\n',O.debug);
% mask
fprintf(fid,'Mask grid # %s\n',O.mask_filename);
% doEntropy
fprintf(fid,'doEntropy # %d\n',O.doEntropy);
% doESTIMATION?
fprintf(fid,'doEstimation # %d\n',O.doEstimation);

fclose(fid);
