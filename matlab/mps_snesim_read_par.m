
function [O]=mps_snesim_read_par(filename);
if nargin==0
    filename='mps_snesim_tree.txt';
end


O.filename_parameter=filename;

fid=fopen(O.filename_parameter,'r');

% number of realizations
l=line_strip_char(fgetl(fid),'#');
O.n_real=str2num(l);

% random seed
l=line_strip_char(fgetl(fid),'#');
O.rseed=str2num(l);

% # multiple grids
l=line_strip_char(fgetl(fid),'#');
O.n_multiple_grids=str2num(l);

% TEMPLATE SIZE
l=line_strip_char(fgetl(fid),'#');
O.n_min_node_count=str2num(l);
l=line_strip_char(fgetl(fid),'#');
O.n_cond=str2num(l);


for i=1:3
  l=line_strip_char(fgetl(fid),'#');
  O.template_size(i,:)=str2num(l);
end

% SIMULATION GRID SIZE
for i=1:3;
  l=line_strip_char(fgetl(fid),'#');
  O.simulation_grid_size(i)=str2num(l);
end

% WORLD/ORIGIN SIZE
for i=1:3;
  l=line_strip_char(fgetl(fid),'#');
  O.origin(i)=str2num(l);
end

% GRID CELL SIZE
for i=1:3;
  l=line_strip_char(fgetl(fid),'#');
  O.grid_cell_size(i)=str2num(l);
end

l=line_strip_char(fgetl(fid),'#');
O.ti_filename=strip_space(l);

l=line_strip_char(fgetl(fid),'#');
O.output_folder=strip_space(l);

% shuffle simulation grid - random path
l=line_strip_char(fgetl(fid),'#');
dum=str2num(l);
O.shuffle_simulation_grid=dum(1);
if length(dum)>1
    O.entropyfactor_simulation_grid=dum(2);
else
    O.entropyfactor_simulation_grid=4;
end

% shuffle TI grid -
l=line_strip_char(fgetl(fid),'#');
O.shuffle_ti_grid=str2num(l);

% HARD DATA
l=line_strip_char(fgetl(fid),'#');
O.hard_data_filename=strip_space(l);

l=line_strip_char(fgetl(fid),'#');
O.hard_data_search_radius=str2num(l);

% SOFT DATA

l=line_strip_char(fgetl(fid),'#');
O.soft_data_categories=strip_space(l);

l=line_strip_char(fgetl(fid),'#');
O.soft_data_fnam=strip_space(l);


l=line_strip_char(fgetl(fid),'#');
O.n_threads=str2num(l);

l=line_strip_char(fgetl(fid),'#');
O.debug=str2num(l);

try
    l=line_strip_char(fgetl(fid),'#');
    O.mask_filename=strip_space(l);
end

try
    l=line_strip_char(fgetl(fid),'#');
    O.doEntropy=str2num(l);
end

try
    l=line_strip_char(fgetl(fid),'#');
    O.doEstimation=str2num(l);
end

%%
% set x,y, and z parameters
O.x=[0:(O.simulation_grid_size(1)-1)].*O.grid_cell_size(1)+O.origin(1);
O.y=[0:(O.simulation_grid_size(2)-1)].*O.grid_cell_size(2)+O.origin(2);
O.z=[0:(O.simulation_grid_size(3)-1)].*O.grid_cell_size(3)+O.origin(3);


fclose(fid);



function l=line_strip_char(l,char)
i=strfind(l,char);
l=l(i+1:end);


