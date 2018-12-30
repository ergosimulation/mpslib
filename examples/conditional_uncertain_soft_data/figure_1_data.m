% figure_1_data
m_ref = read_eas_matrix('m_ref.dat');

figure(1);clf,
subplot(1,2,1);imagesc(TI);title('Training Image');axis image;ax=axis;
subplot(1,2,2);imagesc(m_ref);title('Reference model');;axis image;axis(ax);
print('-dpng','figure_1_data')
