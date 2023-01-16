%clear all;nx=26;ny=25;n_cond=25;saveMov=1;Cmethod=1;entropy_cb_cond_sim;
%return
%
% Run next line once to create data.
if ~exist('strebelle_12_12_nc144_rs02_CM1.mat','file')
    figure04_entropy_randpath_data
end


clear all;close all
Clabel{1}='P_{uni}';
Clabel{2}='P_{rand}';
Clabel{3}='P_{minH}';
Clabel{4}='P_{maxH}';


lstyle{1}='-';
lstyle{2}='-';
lstyle{3}='-';
lstyle{4}='-';

lw{1}=1;
lw{2}=1.5;
lw{3}=2;
lw{4}=2.5;

col{1}=[1 0 0];
col{2}=[0 1 0];
col{3}=[0 0 1];
col{4}=[0 0 0];

nx=12;ny=12;n_cond=144;
%n_cond=25
%nx=5;ny=5;n_cond=25;
useTI='strebelle';

txt_base=sprintf('%s_%d_%d_nc%d',useTI,nx,ny,n_cond);

clear SI M txt
Cmethod_arr=[1,2,3,4];[1,2,3,4];
rseed_arr=1:100;;
for im=1:length(Cmethod_arr);
    for j=1:length(rseed_arr);
        txt{im}=sprintf('%s_rs%02d_CM%d',txt_base,rseed_arr(j),Cmethod_arr(im));
        disp(txt{im});
        M{im}=load([txt{im},'.mat']);
        SI{im}(j,:)=cumsum(M{im}.H);
        SI_1{im}(j,:)=cumsum(M{im}.SI);
    end
    H(im)=mean(SI{im}(:,end));
    SI2(im)=mean(SI_1{im}(:,end));
end
fprintf('Average H = H = ')
fprintf('%3.1f   ',H)
fprintf('\n')
fprintf('Average SI = ')
fprintf('%3.1f   ',SI2)
fprintf('\n')
%%
clear h
figure(2);clf;set_paper;
for im=1:length(M)
    %plot(SI{i}','Style',lstyle{im})
    h_single=plot(SI_1{im}','LineWidth',lw{im},'LineStyle',lstyle{im},'color',col{im});
    %h_single2=plot(SI{im}','LineWidth',lw{im},'LineStyle',lstyle{im},'color',col{im});
    h(im)=h_single(1);
    hold on
    
end
hold off
xlabel('Iteration number, i')
ylabel('Sum(SI(m_i^*))','Interpreter','tex')
legend(h,Clabel,'Location','NorthWest')
%legend(h,Clabel,'Location','NorthWest')
grid on
ppp(10,7,12,2,2)
print_mul([txt_base,'_SI_mul'],1,0,0,300)

%%
figure(5);clf;set_paper;
for im=1:length(M);
    plot(cumsum(M{im}.H),'LineWidth',2,'color',col{im})
    hold on
end
hold off
xlabel('Iteration number, i')
ylabel('Sum(SI(m_i^*))','Interpreter','tex')
%legend(Clabel,'Location','NorthWest')
legend(Clabel,'Location','NorthEastOutside')
grid on
ppp(9,6,12,2,2)
print_mul([txt_base,'_SI'],1,0,0,300)
%return
%%
col0=[1 1 1];
col1=[0 0 0];
colnan=[.8 .8 0];

cmap=cmap_linear([colnan; col0; col0; col1])

for im=4:length(M)
    
    figure(5+im);clf;set_paper('portrait')
    subfigure(1,3,1);
    ns_y=8;
    ir=[1,2,4,8,16, 32, 64, nx*ny]
    ir=ir(find(ir<=(nx*ny)));
    %ir=2;ns_y=1
    FS=7;
    for i=1:length(ir);
        subplot(ns_y,3,(i-1)*3+1);
        if ir(i)==(nx*ny);
            imagesc(M{im}.SIM_all(:,:,ir(i)+1))
        else
            imagesc(M{im}.SIM_all(:,:,ir(i)))
        end
        caxis([-1 1])
        colormap(gca,cmap)
        axis image;set(gca,'FontSize',FS);
        if i==1, title('m^*','FontSize',FS+2);end
        ylabel(sprintf('Iteration = %d',ir(i)))
        colorbar_shift;
        
        subplot(ns_y,3,(i-1)*3+2);
        imagesc(M{im}.E_all(:,:,ir(i)))
        caxis([0 1])
        colormap(gca,cmap_linear([1 1 1;0 0 0]))
        axis image;set(gca,'FontSize',FS);
        if i==1, title('H(m_i|m_c)','FontSize',FS+2);end
        colorbar_shift;
        
        subplot(ns_y,3,(i-1)*3+3);
        imagesc(M{im}.CG_all(:,:,ir(i)))
        caxis([0 1])
        colormap(gca,cmap_linear([col0;col1]))
        axis image;set(gca,'FontSize',FS);
        if i==1, title('P(m_i=1)','FontSize',FS+2);end
        colorbar_shift;
        
    end
    print_mul(sprintf('%s_onefig',txt{im}),4,0,0,300)
end
return

%%
for im=1:length(M)
    figure(im*10+1);clf;
    for i=1:length(ir);
        subplot(3,4,i);
        if ir(i)==(nx*ny);
            imagesc(M{im}.O.x,M{1}.O.y,M{im}.SIM_all(:,:,ir(i)+1));
        else
            imagesc(M{im}.O.x,M{1}.O.y,M{im}.SIM_all(:,:,ir(i)));
        end
        caxis([-1 1])
        colormap(gca,cmap)
        axis image;set(gca,'FontSize',FS);
        if ir(i)==(nx*ny);
            title(sprintf('m^*'),'FontSize',FS+2);
        else
            title(sprintf('m^*, i=%d',ir(i)),'FontSize',FS+2);
        end
    end
    figure(im*10+2);clf;
    for i=1:length(ir);
        subplot(3,4,i);
        imagesc(M{im}.O.x,M{1}.O.y,M{im}.E_all(:,:,ir(i)))
        caxis([0 1])
        colormap(gca,cmap_linear([1 1 1;0 0 0]))
        axis image;set(gca,'FontSize',FS);
        title(sprintf('H(m_i|m_c), i=%d',ir(i)),'FontSize',FS+2);
        %    if i==1, title('H(m_i|m_c)','FontSize',FS+2);end
    end
    figure(im*10+3);clf;
    for j=1:length(ir);
        subplot(3,4,j);
        imagesc(M{im}.O.x,M{1}.O.y,M{im}.CG_all(:,:,ir(j)))
        caxis([0 1])
        colormap(gca,cmap_linear([col0;colnan;col1]))
        axis image;set(gca,'FontSize',FS);
        title(sprintf('P(m_i=1), i=%d',ir(j)),'FontSize',FS+2);
        %    if i==1, title('H(m_i|m_c)','FontSize',FS+2);end
    end
    print_mul(sprintf('%s_CG',txt{im}))
end
