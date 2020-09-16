% kasted_load: load Kasted data
clear all;close all;
% TI
TI=read_eas_matrix('kasted_ti.dat');
dx=50;
x_ti=[1:1:size(TI,2)].*dx;
y_ti=[1:1:size(TI,1)].*dx;

% soft well data
d_soft=read_eas('kasted_welllog.dat');

% Hard well data
d_hard=read_eas('kasted_welllog_hard.dat');

% elevation data
d_ele=read_eas('kasted_elevation.dat');

% resistivity data
d_res=read_eas('kasted_resistivity_0_5.dat');



figure(1);
subplot(3,1,1)
imagesc(x_ti,y_ti,TI);colorbar
axis image;
title('Kasted TI - 0: clay/no channel, 1: sand/channel')
set(gca,'ydir','reverse')

subplot(3,2,3)
scatter(d_soft(:,1),d_soft(:,2),5,d_soft(:,4),'filled')
caxis([0 1])
axis image
set(gca,'ydir','reverse')
colorbar
title('kasted_welllog.dat - P(Channel)','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(3,2,4)
scatter(d_hard(:,1),d_hard(:,2),15,d_hard(:,4),'filled')
axis image
set(gca,'ydir','reverse')
colorbar
title('kasted_welllog_hard.dat - P(Channel)','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on;box on

subplot(3,2,5)
scatter(d_ele(:,1),d_ele(:,2),5,d_ele(:,4),'filled')
axis image
set(gca,'ydir','reverse')
caxis([0 1])
colorbar
title('kasted_elevation.dat - P(Channel)','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(3,2,6)
scatter(d_res(:,1),d_res(:,2),5,log10(d_res(:,3)),'filled')
axis image
set(gca,'ydir','reverse')
colorbar
title('kasted_resistivity_0_5.dat','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

print -dpng kasted_data.png

%% Setup MPS


x1=floor(min(d_soft(:,1))/dx)*dx;
x2=ceil(max(d_soft(:,1))/dx)*dx;
y1=floor(min(d_soft(:,2))/dx)*dx;
y2=ceil(max(d_soft(:,2))/dx)*dx;
x=x1:dx:x2;nx=length(x);
y=y1:dx:y2;ny=length(y);

SIM=zeros(ny,nx).*NaN; %  simulation grid
O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
O.n_real=100;             %  optional number of realization
O.x=x;
O.y=y;

%O.d_hard=d_hard;
O.d_soft=d_soft;

[reals,O]=mps_cpp_thread(TI,SIM,O);
  
mps_cpp_plot(reals,O)

