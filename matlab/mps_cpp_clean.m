% mps_cpp_options: Clean up after mps_cpp
%
% Call:
%   mps_cpp_clean(options);
%
% See also: mps_cpp
%

function mps_cpp_clean(options)

if nargin==1
    fn=[options.output_folder,filesep,options.ti_filename];
else
    fn='*';
end
try
    cmd=[fn,'_sg*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);

    cmd=[fn,'_path*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);

    cmd=[fn,'_tg*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);
    
    cmd=[fn,'_cg*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);

    cmd=[fn,'_ent*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);

    cmd=[fn,'_selfInf*'];
    %%disp(sprintf('%s: trying to delete ''%s''',mfilename,cmd));
    delete(cmd);
    
end
