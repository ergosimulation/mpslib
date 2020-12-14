
clear all;close all;
di=1;
dx=0.075*di;
TI=channels(di,1);           %  training image
x_ti=dx*[1:1:size(TI,2)];
y_ti=dx*[1:1:size(TI,1)];

x=0:dx:7;nx=length(x);
y=0:dx:12;ny=length(y);

SIM=zeros(ny,nx).*NaN; %  simulation grid
%O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
%O.method='mps_snesim_list'; %
O.method='mps_genesim'; %

O.n_cond=49;             %  optional number of realization
O.n_cond=16,
O.distance_pow=2;
O.distance_min=0.01;
O.distnace_measure=1;
O.template_size=[9 9 1];
O.x=x;
O.y=y;
n_real=64*10;
d_hard=[1 6 0 1;6 6 0 1];


%% unCONDitional simulation
Ou=O;
Ou.n_real=n_real;
[reals_u,Ou]=mps_cpp_thread(TI,SIM,Ou);

% CONDitional simulation
Oc=O;
Oc.n_real=n_real;
Oc.d_hard=d_hard;

[reals_c,Oc]=mps_cpp_thread(TI,SIM,Oc);

%% CONDitional estimation
Oest=O;
Oest.d_hard=d_hard;
%d_hard_single=[3.5 6 0 1];Oest.d_hard=d_hard_single;
Oest.doEstimation=1;

%Oest.max_search_radius=[100 30];

Oest.n_max_cpdf_count=1e+9;
Oest.n_max_ite=1e+9;
%Oest.n_max_cpdf_count=100;
%Oest.n_max_ite=1000;
Oest.n_cond=2;
Oest.n_real=1;
[reals_est,Oest]=mps_cpp(TI,SIM,Oest);

Pchannel=Oest.cg(:,:,2);
%iy=find(y==6)
ay=abs(y-6);
iy=find(ay==min(ay));
iy=iy(1);

save ex_estimation_channels.mat


%%
mps_cpp_plot(reals_c,Oc)

%%
figure(4);
imagesc(Oest.x,Oest.y,Oest.cg(:,:,2));
caxis([0 1])
colormap(jet)
axis image
colorbar
print -dpng P_channel.png

figure(5);
plot(x,Pchannel(iy,:),'k-')
hold on
plot(xlim,[1 1].*mean(TI(:)),'k:')
hold off
print -dpng P_channel_profile.png



%%


figure(1);clf;
imagesc(x_ti,y_ti,TI(:,:,1));
colormap(1-gray)
axis image


figure(2);clf;
imagesc(O.x,O.y,reals_c(:,:,1));
colorbar
colormap(1-gray)
axis image

%%
close all
FrameRate = 25;
Quality = 95;

for j=1:2;
    
    if j==1
        vname='cond';
    else
        vname='uncond';
    end
    
    writerObj = VideoWriter(vname);
    writerObj.FrameRate=FrameRate;
    writerObj.Quality=Quality;
    open(writerObj);
    
    figure(1),clf;
    for ir=1:min([100,n_real]);
        
        if j==1;
            imagesc(O.x,O.y,reals_c(:,:,ir));
        else
            imagesc(O.x,O.y,reals_u(:,:,ir));
        end
        colorbar
        colormap(1-gray)
        axis image
        frame = getframe(gcf);
        try
            writeVideo(writerObj,frame);
        catch
            disp(sprintf('%s: problems writing %s',mfilename,fname));
        end
    end
    close(writerObj);
    
end


