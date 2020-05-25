clear all
TI1=channels;
TI2=TI1';
SIM=zeros(180,160).*NaN; %  simulation grid
O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
%O.method='mps_snesim_list'; %
%O.method='mps_genesim'; %
%O.distance_min=0.01;
%O.distance_pow=1;

MASK1=zeros(size(SIM));
MASK1(70:130,40:100)=1;

MASK2=1-MASK1;

O.n_real=1;   %  optional number of realization
O.d_mask=MASK1;
[reals,O]=mps_cpp(TI1,SIM,O);



% rotate TI and simulate rest
[xx,yy]=meshgrid(O.x,O.y);
i_hard=find(~isnan(reals));
d_hard=[xx(i_hard), yy(i_hard), i_hard.*0+O.z(1), reals(i_hard)];
O.d_hard=d_hard;
O.d_mask=MASK2;
[reals2,O]=mps_cpp(TI2,SIM,O);


subplot(2,3,1);
imagesc(O.x, O.y,MASK1);caxis([-1 1]);axis image
subplot(2,3,2);
imagesc(O.x, O.y, TI1);caxis([-1 1]);axis image
subplot(2,3,3);
imagesc(O.x, O.y, reals);caxis([-1 1]);axis image


subplot(2,3,4);
imagesc(O.x, O.y,MASK2);caxis([-1 1]);axis image
subplot(2,3,5);
imagesc(O.x, O.y, TI2);caxis([-1 1]);axis image
subplot(2,3,6);
imagesc(O.x, O.y, reals2);caxis([-1 1]);axis image
