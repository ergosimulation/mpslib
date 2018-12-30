% mps_snesim_2d_varying_template
%
% needs mGstat/SIPPI
%
O=mps_snesim_read_par('mps_snesim_2d_unconditional.txt');
O.parameter_filename='mps_snesim_2d_varying_template.txt';


%TI=read_eas_matrix('ti.dat');
TI=channels;
O.simulation_grid_size=[130 120 1];

SIM=zeros(size(O.simulation_grid_size)).*NaN; %  simulation grid
O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')

%O.n_multiple_grids=5;
O.n_multiple_grids=5;
O.n_cond=100;


    
maxt=9;
mint=3;
t=mint:1:maxt;
nt=length(t)

    
T_full=[maxt maxt 1; mint mint 1 ]';

k=0;
nr=3;
nSIM=((maxt-mint)/2)+1;
clf;drawnow;
for j=1:nSIM
    for i=1:(nr+nt);
        k=k+1;
        O.n_real=1;             %  optional number of realization
        if i<=nt;
            T=[[1 1].*t(nt-i+1) 1];
            O.rseed=k;        
        else
            T=[maxt maxt-2*(j-1) ; maxt maxt-2*(j-1) ; 1 1 ];
            O.rseed=i;        
        end               
        O.template_size=T;
        O.parameter_filename=sprintf('mps_snesim_template_%d_%d.txt',T(1),T(2));
        
        [reals,O]=mps_cpp(TI,SIM,O);
        if i==1;
            time0=O.time;
        end
            
        subplot(nSIM,nr+nt,k);
        imagesc(reals);axis image;
        try
            %title(sprintf('t=%3.2fs T(%d,%d<->%d,%d)',O.time,O.template_size(1,1),O.template_size(2,1),O.template_size(1,2),O.template_size(2,2)),'FontSize',6)
            title(sprintf('T(%d,%d<->%d,%d)',O.template_size(1,1),O.template_size(2,1),O.template_size(1,2),O.template_size(2,2)),'FontSize',8)
        catch
            %title(sprintf('t=%3.2fs T(%d,%d)',O.time,O.template_size(1),O.template_size(2)),'FontSize',8)
            title(sprintf('T(%d,%d)',O.template_size(1),O.template_size(2)),'FontSize',8)
        end
        hold on 
        plot([0 O.simulation_grid_size(1)*O.time/time0],[-1 -1],'r-','LineWidth',3)
        hold off
        
        axis off
        
        drawnow;
    end
    
    
    
end
set_paper('landscape','a3')
tit=sprintf('T0=%5.1fs NMulGrid=%d',time0,O.n_multiple_grids);
suptitle(tit)
print_mul([mfilename,'_',tit])


