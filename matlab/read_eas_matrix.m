% read_eas : reads an 3D array stored as a 1D array in EAS format
%
% Call [D,header,title]=read_eas_matrix(filename);
%
% TMH (thomas.mejer.hansen@gmail.com)
%
% See also write_eas_matrix, write_eas
%
% Note: works only for one column, and up to 2D
%
function [D,header,txt_title,dim,txtdata,txtheader]=read_eas_matrix(filename,nx,ny,nz);

   nanVal=-997799;

   %% GET COLUMN DATA
   [d,header,txt_title,txtheader]=read_eas(filename);
   ncols=length(header);
   if nargin == 1
       % GET NX,NY,NZ
       % SGeMS header info
       dim=[];
       try
           id1=strfind(txt_title,'(');
           id2=strfind(txt_title,')');
           dims=txt_title( (id1+1):(id2-1) );
           
           j=findstr(dims,'x');
           dim.nx=str2num(dims(1:(j(1)-1)));
           dim.ny=str2num(dims((j(1)+1):(j(2)-1)));
           dim.nz=str2num(dims((j(2)+1):length(dims)));
       end
       % MPS header info 'nx ny nz'
       try
           d_header=str2num(txt_title);
           dim.nx=d_header(1);
           dim.ny=d_header(2);
           dim.nz=d_header(3);
       end
       if isempty(dim)
           disp(sprintf('%s: Could not find dimension info %s. Please specify as input parameters',filename));
           return;
       end
   else
       dim.nx=1;
       dim.ny=1;
       dim.nz=1;
       
       try;dim.nx=nx;end
       try;dim.ny=ny;end
       try;dim.nz=nz;end
   end
   
   
   d(find(d==nanVal))=NaN;
   
   %% RESHAPE TO MATRIX 3D ARRAY
   D=reshape(d,dim.nx,dim.ny,dim.nz,ncols);
   %if dim.nz==1;
   %    D=D';
   %else
       D=permute(D,[2 1 3 4]);
   %end