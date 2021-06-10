% plot Kasted hard data: Figure 6 in Johannson and Hansen (2021)
dx=50;
kasted_load;
d_well_hard(:,1:3)=d_well_hard(:,1:3)/1000;
close(1)
%%
xlim =  [0 50*0.05]+[565.4];
ylim = [0 -50*0.05]+[6232.3];
xlim =  [0 50*0.05]+[568.0];
ylim = [0 50*0.05]+[6229];


xl=[xlim(1) xlim(1) xlim(2) xlim(2) xlim(1)] ;
yl=[ylim(1) ylim(2) ylim(2) ylim(1) ylim(1)]; 


col0=[1 0 0];col1=[0 0 0]
cmap_discrete=[col0;col1];
p_channel_marg=0.58;
cmap_prob=cmap_linear([cmap_discrete(1,:);1 1 1;cmap_discrete(2,:)],[0 p_channel_marg 1.0]);

figure(1);set_paper('landscape');clf
subplot(1,2,1);
set(gca,'FontSize',5)
plot(d_well_hard(:,1),d_well_hard(:,2),'k.','MarkerSize',16);
hold on
scatter(d_well_hard(:,1),d_well_hard(:,2),10,d_well_hard(:,4),'filled');
%plot([ax(1) ax(1) ax(2) ax(2) ax(1)],[ax(3), ax(4) ax(4) ax(3) ax(3)],'k--');
% TRAINING IMAGE
%plot(xti+x(3),yti+y(3),'r--') %
hold off
axis image
box on
grid on
xlabel('UTMX (km)')
ylabel('UTMY (km)')
colormap(cmap_discrete)
cb=colorbar;
set(cb,'Ytick',[0.25 0.75]);set(cb,'YtickLabel',{'None','Channel'})
set(gca,'FontSize',7)

try;print_mul(sprintf('kasted_hard_obs'));end

hold on
    plot(xl,yl,'k--')
hold off

try,print_mul(sprintf('kasted_hard_obs_mask'));end

