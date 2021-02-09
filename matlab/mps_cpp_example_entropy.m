% mps_cpp_example_entropy
% Example of computing self-information and entropy as part of sequential
% simulation
clear all;close all

TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulation grid

%SIM=zeros(20,12).*NaN; %  simulation grid
%SIM(10:12,20)=0; % some conditional data
%SIM(40:40:43)=1; % some mode conditional data

O.method='mps_snesim_tree';
%O.method='mps_genesim';O.n_max_cpdf_count=10;
O.n_real=50;
O.doEntropy=1;
O.rseed=1;
nc_arr = [1:7].^2;
%nc_arr = [1:2:30];

for i=1:length(nc_arr);
    O.n_cond = nc_arr(i);
    [reals,Oout] = mps_cpp(TI,SIM,O);
    
    SI(i,:)=Oout.SI;
    H(i)=mean(Oout.SI);
    real{i}=reals(:,:,1);
    t(i)=Oout.time;
    
    plot(1:O.n_real,SI(1:i,:),'-')
    legend(num2str(nc_arr(1:i)'))
    xlabel('Realization #')
    ylabel('Self-information')
    drawnow
    
    
end
%%
figure(1);
plot(1:O.n_real,SI,'-')
legend(num2str(nc_arr(1:i)'))
hold off
xlabel('Realization #')
ylabel('Self-information')
drawnow
print -dpng mps_cpp_example_entropy_1


%%
figure(2);
subplot(1,2,1)
bar(nc_arr,H)
xlabel('N_{cond}')
ylabel('Entropy')
%set(gca,'Xscale','log')
subplot(1,2,2)
plot(t,H,'-*');
hold on
for i=1:length(t)
    text(t(i)+.2,H(i),sprintf('Nc=%d',nc_arr(i)))
end
hold off
xlabel('simulation time (s)')
ylabel('Entropy')
print -dpng mps_cpp_example_entropy_2

figure(3);
for i=1:length(nc_arr);
    subplot(4,4,i);
    imagesc(Oout.x, Oout.y, real{i});
    axis image;
    title(sprintf('N_c=%d, SI=%4.1f',nc_arr(i),SI(i)))
end
print -dpng mps_cpp_example_entropy_3

