function [TI, ti_fname] = mps_ti(ti_fname)
% mps_ti: load local and remote training images
%
% Call: 
%    [TI, ti_fname] = mps_ti(ti_fname)
% Examples
% List local TIs:
%    mps_ti('list')
%
% Load local TIs:
%    TI=mps_ti; % loads default ti_strebelle_250_250_1.dat
%    TI=mps_ti('ti_strebelle_250_250_1.dat')
%    TI=mps_ti('ti_fluvsim_250_250_100.dat')
%
% Load remote TI
%    [TI, ti_fname] = mps_ti('https://trainingimages.org/uploads/3/4/7/0/34703305/ti_strebelle.sgems')
%
% See for example https://trainingimages.org/training-images-library.html
% for a collection of training images
%
% See also mps_cpp
%


[mat_folder,~,~] = fileparts(which('mps_cpp.m'));
ti_folder = sprintf('%s%s%s%s%s%s%s',mat_folder,filesep,'..',filesep,'data',filesep,'ti');


if nargin == 0
    ti_fname = 'ti_strebelle_250_250_1.dat';
    %ti_name = 'https://trainingimages.org/uploads/3/4/7/0/34703305/ti_strebelle.sgems';
end
if strcmp(lower(ti_fname),'list')==1
    disp(sprintf('%s: local training images:',mfilename))
    dir(sprintf('%s%s*dat',ti_folder,filesep));
    TI=[];
    return
end


% Check for url 
if strcmp(ti_fname(1:4),'http')==1
    f_remote = ti_fname;
    [url_f, url_file, url_ext]=fileparts(f_remote);
    url_file = [url_file, url_ext];
    if exist([pwd,filesep,url_file])==0;
        disp(sprintf('Trying to download ''%s'' to %s',f_remote,url_file))
        urlwrite(f_remote,url_file);
    end
    ti_fname = url_file;
end


if exist([pwd,filesep,ti_fname])==2
    disp(sprintf('%s: Trying to load %s',mfilename, ti_fname))
    TI = read_eas_matrix([pwd,filesep,ti_fname]);
elseif exist([ti_folder,filesep,ti_fname])==2
    disp(sprintf('%s: Trying to load %s',mfilename, ti_fname))
    TI = read_eas_matrix([ti_folder,filesep,ti_fname]);
else
    disp(sprintf('%s: Could not locate ''%s''',mfilename,ti_fname))
end





