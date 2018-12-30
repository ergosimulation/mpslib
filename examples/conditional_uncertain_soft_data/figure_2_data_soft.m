% figure_2_data_soft

m_ref = read_eas_matrix('m_ref.dat');
d1=read_eas('soft_case1.dat');
d2=read_eas('soft_case2.dat');
d3=read_eas('soft_case3.dat');


figure(2);clf,
s(1)=subplot(2,2,1);
imagesc(m_ref);
title('m_{ref}');

s(2)=subplot(2,2,2);
scatter(d1(:,1),d1(:,2),10,d1(:,5),'filled');
title('I_{d1}');

s(3)=subplot(2,2,3);
scatter(d2(:,1),d2(:,2),10,d2(:,5),'filled');
title('I_{d2}');

s(4)=subplot(2,2,4);
scatter(d3(:,1),d3(:,2),10,d3(:,5),'filled');
title('I_{d3}');


for i=1:length(s);
    axes(s(i));
    set(gca,'ydir','revers')
    axis image;
    axis([0 31 0 31]);
    caxis([0 1])
    cb=colorbar;
    if i>1
        ylabel(cb, 'P(channel)')
    end
    box on
    
end

print('-dpng','figure_2_data_soft')
