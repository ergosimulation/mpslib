% write_eas_matrix : writes an 3D arrays as one one column data in GEO EAS
% format
%
% Call;
%    write_eas_matrix(filename,data,header,nanValue);
%    write_eas_matrix(filename,data);
%
% ! Assumes: [nx ny nz]=size(data);
%
% filename [string]
% data [ndata,natts] 
% header [structure{natts}] : SHOU
% nanValue [float] : NaN value
%
% TMH (thomas.mejer.hansen@gmail.com)
%
% See also write_eas, read_eas_matrix
%
% Note: works only for one column, and up to 2D
%
function write_eas_matrix(filename,data,header,nanValue);
  
  if nargin<1,
    help write_eas_matrix;
    return;
  end
  
  if nargin==1,
    data=filename;
    filename='dummy.eas';;
    mgstat_verbose(sprintf('%s : Filename not set, using ''%s''.',mfilename,filename),0)
  end

  %[ny,nx,nz,natts]=size(data);
  [nx,ny,nz,natts]=size(data);
  top_line=sprintf('%d %d %d',ny,nx,nz);
  
  if natts>1, 
     disp(sprintf('%s: only 1 attriubute is supported ATM',mfilename));
     return
  end
  if nargin<3,
    for i=1:natts;
      header{i}=sprintf('col%d, unknown',i);
    end
  end
  if (ischar(header));
      header_tmp=header;
      clear header;
      header{1}=header_tmp;
  end
  
  if nargin<4,
      nanValue=NaN;
  end

  
  
  % replace NAN values
  inan=find(isnan(data));
  if ~isempty(inan)
      data(inan)=nanValue;
  end
  
  fid=fopen_retry(filename,'wt');
  
  fprintf(fid,'%s\n',top_line);
  fprintf(fid,'%d\n',natts);
  for ih=1:natts,
    fprintf(fid,'%s\n',header{ih});
  end
  
  if (nz==1)&(ny==1);
    % 1D;
    d=data;
    fprintf(fid,'%18.12g\n',d(:));      
  elseif nz==1
    % 2D;
    d=data';
    fprintf(fid,'%18.12g\n',d(:));      
  else
    % 3D;
    n=prod(size(data));
    d=zeros(1,n);
    i=0;
    for iz=1:nz
    for ix=1:nx
    for iy=1:ny
        i=i+1;
        d(i)=data(ix,iy,iz);
    end
    end
    end
   
    fprintf(fid,'%18.12g\n',d(:));            
  end
  
  fclose(fid);
  
  
  
  return
  
   
   