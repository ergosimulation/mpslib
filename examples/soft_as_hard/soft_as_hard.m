clear all;%close all
TI=read_eas_matrix('ti.dat');
SIM=zeros(30,30).*NaN;
O=mps_snesim_read_par('mps_snesim.txt');

O.template_size=[9 9 1];
O.n_real=1000;
O.n_cond=25;
O.debug=0;
       
O.exe_root='E:\Users\tmh\RESEARCH\PROGRAMMING\GITHUB\MPSLIB\msvc2017\x64\Release';

for id=[1];
%for id=[0:6];
    O.filename_parameter=sprintf('mps_snesim_%d.txt',id);
    clear t em;
    
    O.hard_data_filename='duuumy.dat';
    if id==0; 
        O.soft_data_fnam='duuumy.dat';
    elseif id==1; 
        O.soft_data_fnam='soft_case1.dat';
        O.txt='Soft data d_1';
    elseif id==2; 
        O.soft_data_fnam='soft_case2.dat';
        O.txt='Soft data d_2';
    elseif id==3; 
        O.soft_data_fnam='soft_case3.dat';
        O.txt='Soft data d_3';
    elseif id==4; 
        O.txt='Soft data d_3 (as hard soft data)';
        O.soft_data_fnam='soft_as_hard.dat';
        O.hard_data_filename='duuumy.dat';
    elseif id==5; 
        O.soft_data_fnam='duuumy.dat';
        O.hard_data_filename='hard_as_hard.dat';
        O.txt='d_3 (as hard data)';               
    elseif id==6; 
        O.txt='Soft data d_3 (as hard soft data)';
        O.soft_data_fnam='soft_as_softhard.dat';
        O.hard_data_filename='duuumy.dat';
        O.txt='d_3 (as hard data) (P(m_i==1)=0.999)';               
    end
    %
    i=0;
    
    ishuf_arr=[0 1 2];
    nmg_arr=[0,1,2,3,4];
    
    %ishuf_arr=[2];
    %nmg_arr=[0,1,2];
    
    
    figure(id+1);clf
    for ishuf=ishuf_arr;
        i=i+1;
        j=0;
        for nmg=nmg_arr;
            j=j+1;
            O.shuffle_simulation_grid=ishuf;
            O.n_multiple_grids=nmg;
            
            [r,Oo]=mps_cpp_thread(TI,SIM,O);
            disp(sprintf('Time Elapsed: %gs',Oo.time))
            
            em{i,j}=etype(r);
            t(i,j)=Oo.time./O.n_real;
            
            %% figure
            figure(id+1);
            subplot(length(ishuf_arr),length(nmg_arr),j+(i-1)*length(nmg_arr));
            imagesc(em{i,j});
            caxis([-1 1])
            %colormap(cmap_linear([1 0 0 ; 0 0 0 ; 1 1 1]))
            %colormap(cmap_linear([1 0 0 ; 1 0 0; 1 0 0 ; 1 1 1 ; 0 0 1 ; 0 1 0  ; 0 0 0]))
            colormap(cmap_linear([1 0 0 ; 1 0 0; 1 0 0 ; 0 0 1; 1 1 1 ;  0 0 0 ; 0 1 0 ]))
            set(gca,'FontSize',4);
            title(sprintf('t=%3.2fs',t(i,j)),'FontSize',8)
            %xlabel(sprintf('ip_%d mg_%d',ishuf_arr(i),nmg_arr(j)))
            axis image
            
            %if j==1;
                %t=text(-.4,1.1,sprintf('ipath=%d',O.shuffle_simulation_grid),'units','normalized')
                ylabel(sprintf('ipath=%d',O.shuffle_simulation_grid),'FontSize',6)
                xlabel(sprintf('nmg=%d',O.n_multiple_grids),'FontSize',5)
            %end
            
            %caxis([0 1])
            drawnow
            
        end
    end
    figure(id+1)
    try; suptitle(O.txt);end
    txt=sprintf('snes_id%d_n%d',id,Oo.n_real);
    print_mul(txt)
    save(txt)

end