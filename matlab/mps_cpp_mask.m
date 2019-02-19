% mps_cpp_mask: run MPSlib using masked grids
%
% Call:
%   [reals,O]=mps_cpp_mask(TI,SIM,MASK,O)
%
%     TI: Cell aray of training images (TI{1}, TI{2}, ..)
%     SIM: simulation grid (NON nan values are hard data)
%     MASK: as SIM, bit with integer values for each TI
%     O: MPSlib options
%
%  See also mps_cpp
%
function [reals,O,Omul]=mps_cpp_mask(TI,SIM,MASK,O)

if ~isfield(O,'plot')
    O.plot=1;
end

if ~iscell(TI);
    disp(sprintf('%s: TI needs to a cell (multiple TIs)',mfilename))
end

cax=[-1 max(TI{1}(:))];

nti=length(TI);

if ~isfield(O,'mask_order')
    O.mask_order = 1:nti;
end

if ~isfield(O,'mask_conditional')
    O.mask_conditional = ones(1,nti);
end

SIM_ORG = SIM;
SIM_CUR = SIM;

for iti = O.mask_order
    disp(sprintf('%s: submask %d',mfilename,iti))
    
    % SIMULATE GRID 0
    MASK_CUR =(MASK==iti);
    
    Omul{iti}=O;
    Omul{iti}.parameter_filename=sprintf('%02d_%s',iti,O.parameter_filename);
    Omul{iti}.mask_filename=sprintf('mask%02d.dat',iti);
    write_eas_matrix(Omul{iti}.mask_filename,MASK_CUR);
    
    if (O.mask_conditional(iti)==1)
        SIM=SIM_CUR;
    else
        disp('non_cond!')
        SIM=SIM_ORG;
    end
    
    [reals,Omul{iti}]=mps_cpp(TI{iti},SIM,Omul{iti});
    
    if (O.mask_conditional(iti)==1)
        SIM_CUR = reals;
    else
        iuse=find(~isnan(reals));
        SIM_CUR(iuse)=reals(iuse);
    end
   
    if O.plot>0
        figure(1)
        subplot(3,nti,iti);imagesc(TI{iti});axis image;title(sprintf('TI{%d}',iti));caxis(cax)
        subplot(3,nti,nti+iti);imagesc(MASK_CUR);axis image;title('MASK')
        subplot(3,nti,2*nti+iti);imagesc(SIM_CUR);axis image;title('SIM\_CUR');caxis(cax)
        colormap(1-gray)
        drawnow;
    end
end

    










