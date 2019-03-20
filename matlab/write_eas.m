% write_eas : writes a GEO EAS formatted file into Matlab.
%
% Call write_eas(filename,data,header,title,nanValue);
%
% filename [string]
% data [ndata,natts] 
% header [structure{natts}] : header values for data columns
% title [string] : optional title for EAS file
% nanValue [float] : NaN value
%
% TMH (tmh@gfy.ku.dk)
%
function write_eas(filename,data,header,line1,nanValue);
  
  if nargin<1,
    help write_eas;
    return;
  end
  
  if nargin==1,
    data=filename;
    filename='dummy.eas';;
    mgstat_verbose(sprintf('%s : Filename not set, using ''%s''.',mfilename,filename),0)
  end

  if nargin<3,
    for i=1:size(data,2);
      header{i}=sprintf('col%d, unknown',i);
    end
  end
  if (ischar(header));
      header_tmp=header;
      clear header;
      header{1}=header_tmp;
  end
  
  if nargin<4,
    line1=sprintf('Data written by mGstat %s',date);
  end
  
  if nargin<5,
      nanValue=NaN;
  end

  
  
  nd=size(data,2);

  % replace NAN values
  data(find(isnan(data)))=nanValue;
  
  fid=fopen_retry(filename,'wt');
  
  fprintf(fid,'%s\n',line1);
  fprintf(fid,'%d\n',nd);
  for ih=1:nd,
    fprintf(fid,'%s\n',header{ih});
  end
  
  if size(data,2)==1
      fprintf(fid,'%18.12g\n',data(:));
  elseif size(data,2)==2
      d=data';
      fprintf(fid,'%18.12g   %18.12g\n',d(:));
  elseif size(data,2)==3
      d=data';
      fprintf(fid,'%18.12g   %18.12g   %18.12g\n',d(:));
  elseif size(data,2)==4
      d=data';
      fprintf(fid,'%18.12g   %18.12g   %18.12g   %18.12g\n',d(:));
  elseif size(data,2)==5
      d=data';
      fprintf(fid,'%18.12g   %18.12g   %18.12g   %18.12g   %18.12g\n',d(:));
  else
      
      for id=1:size(data,1),
          %fprintf(fid,'%7.4g   %7.4g   %7.4g ',data(id,:));
          fprintf(fid,'%18.12g   %18.12g   %18.12g ',data(id,:));
          fprintf(fid,'\n');
      end
  end
  fclose(fid);
  
  
  
  return
  
   
   