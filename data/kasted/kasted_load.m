% kasted_load: load Kasted data
% TI
if ~exist('dx');dx=50;end
TI=read_eas_matrix(sprintf('kasted_ti_dx%d.dat',dx));
x_ti=[1:1:size(TI,2)].*dx;
y_ti=[1:1:size(TI,1)].*dx;

% soft well data
d_well=read_eas('kasted_soft_well.dat');

% Hard well data
d_well_hard=read_eas('kasted_hard_well.dat');

% elevation data
d_ele=read_eas('kasted_soft_ele.dat');

% resistivity data
d_res=read_eas('kasted_soft_res.dat');

figure(1);
subplot(3,1,1)
imagesc(x_ti,y_ti,TI(:,:,1));colorbar
axis image;
set(gca,'ydir','normal');
title('Kasted TI - 0: clay/no channel, 1: sand/channel')
set(gca,'ydir','normal')

subplot(3,2,3)
S=sum(abs(d_well(:,4:5)-0.5)')';S=S./(max(S));
scatter(d_well(:,1),d_well(:,2),1+S*15,d_well(:,5),'filled')
caxis([0 1])
axis image
set(gca,'ydir','normal')
colorbar
title('P(Channel | well), kasted_soft_well.dat','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(3,2,4)
scatter(d_well_hard(:,1),d_well_hard(:,2),15,d_well_hard(:,4),'filled')
axis image
set(gca,'ydir','normal')
colorbar
title('P(Channel | well), kasted_hard_well.dat','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on;box on

subplot(3,2,5)
scatter(d_ele(:,1),d_ele(:,2),5,d_ele(:,5),'filled')
axis image
set(gca,'ydir','normal')
caxis([0 1])
colorbar
title('P(channel | I_ele) - kasted_soft_ele.dat','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(3,2,6)
scatter(d_res(:,1),d_res(:,2),5,d_res(:,5),'filled')
axis image
set(gca,'ydir','normal')
colorbar
caxis([0 1])
title('P(channel | I_res ), kasted_soft_res.dat','Interpreter','None')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

print -dpng kasted_data.png
