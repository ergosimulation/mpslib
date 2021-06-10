% kasted_load: load Kasted data
% TI
if ~exist('dx');dx=50;end
if ~exist('doPlot');doPlot=1;end
if ~exist('createCoarse');createCoarse=0;end

%% Create training TI at subpixel resolution?
if createCoarse == 1;
    TI=read_eas_matrix('kasted_shrunk_ti.dat'); % The TI from Figure 7a, in Johannsson and Hansen (2021)
    for dx_use = [50,100,150,200,300,400];
        dx_org = 50;
        ds = dx_use/dx_org;
        TI_sub=ti_subsample_2d(TI,ds);
        
        fname = sprintf('kasted_ti_dx%d.dat',dx_use);
        disp(fname)
        write_eas_matrix(fname,TI_sub);
    
    end
end

%% Load the data
TI=read_eas_matrix(sprintf('kasted_ti_dx%d.dat',dx));
x_ti=[1:1:size(TI,2)].*dx;
y_ti=[1:1:size(TI,1)].*dx;

% soft well data
d_well_soft=read_eas('kasted_soft_well.dat');

% Hard well data
d_well_hard=read_eas('kasted_hard_well.dat');

% elevation data
d_ele=read_eas('kasted_soft_ele.dat');

% resistivity data
d_res=read_eas('kasted_soft_res.dat');

ax=[0.5620    0.5764    6.2254    6.2354].*1e+6;

if doPlot==0 
    return
end
figure(1);clf;try;set_paper('portrait');end
subplot(4,1,1)
imagesc(x_ti,y_ti,TI(:,:,1));colorbar
axis image;
set(gca,'ydir','normal');
title('a) Kasted TI - 0: clay/no channel, 1: sand/channel')
set(gca,'ydir','normal')

subplot(4,2,3)
S=sum(abs(d_well_soft(:,4:5)-0.5)')';S=S./(max(S));
scatter(d_well_soft(:,1),d_well_soft(:,2),1+S*15,d_well_soft(:,5),'filled')
caxis([0 1])
axis image;axis(ax)
set(gca,'ydir','normal')
colorbar
title('b) P(Channel | I_{well-soft})','Interpreter','tex')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(4,2,4)
scatter(d_well_hard(:,1),d_well_hard(:,2),15,d_well_hard(:,4),'filled')
axis image;axis(ax)
set(gca,'ydir','normal')
colorbar
title('c) P(Channel | I_{well-hard})','Interpreter','tex')
xlabel('UTM X');ylabel('UTM Y');grid on;box on

subplot(4,2,5)
scatter(d_ele(:,1),d_ele(:,2),5,d_ele(:,5),'filled')
axis image;axis(ax)
set(gca,'ydir','normal')
caxis([0 1])
colorbar
title('d) P(channel | I_{ele})','Interpreter','tex')
xlabel('UTM X');ylabel('UTM Y');grid on; box on

subplot(4,2,6)
scatter(d_res(:,1),d_res(:,2),5,d_res(:,5),'filled')
axis image;axis(ax)
set(gca,'ydir','normal')
colorbar
caxis([0 1])
title('e) P(channel | I_{res} )','Interpreter','tex')
xlabel('UTM X');ylabel('UTM Y');grid on; box on
print -dpng kasted_data.png
