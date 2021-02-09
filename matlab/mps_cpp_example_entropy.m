% mps_cpp_example_entropy
% Example of computing self-information and entropy as part of sequential
% simulation
clear all;

TI=mps_ti;           %  training image
SIM=zeros(80,60).*NaN; %  simulation grid
%SIM=zeros(20,12).*NaN; %  simulation grid
%SIM(10:12,20)=0; % some conditional data
%SIM(40:40:43)=1; % some mode conditional data

O.method='mps_snesim_tree';
O.n_cond=9;
O.n_real=40;
O.doEntropy=1;


nc_arr = [1:1:25];

for i=1:length(nc_arr);
    O.n_cond = nc_arr(i);
    [reals,Oout] = mps_cpp(TI,SIM,O);
    
    SI(i,:)=Oout.SI;
    H(i)=mean(Oout.SI);
    real{i}=reals(:,:,1);
    
    
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

figure(2);
bar(nc_arr,H)
xlabel('N_{cond}')
ylabel('Entropy')


