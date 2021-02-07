% mps_cpp_demo: Examples of running MPS from within MATLAB
%
% Runs MPS algorithms for different set of parameters
% 
% See also: mps_cpp_demo_example_unconditional
%

if ~exist('TI','var');
    [TI,TI_fname]=mps_ti;           %  training image
    %[TI,TI_fname]=mps_ti('ti_cb_6x6_40_40_1.dat');   
    %[TI,TI_fname]=mps_ti('ti_fluvsim_250_250_100.dat');       
end
figure(1);
imagesc(TI(:,:,1));axis image
try
    title(sprintf('TI: %s',TI_fname))
catch
    title('TI')
end
drawnow;

if ~exist('SIM','var');
    SIM=zeros(280,280).*NaN; %  simulation grid
end

O.n_real=1;  % Number of realizations
O.rseed=1;  % Random Seed


if ~isfield(O,'method')
    O.method='mps_enesim_general'; % MPS algorithm to run
    O.method='mps_snesim_tree'; % MPS algorithm to run (def='mps_snesim_tree')
    %O.method='mps_snesim_list'; % MPS algorithm to run (def='mps_snesim_tree')
end
if ~isfield(O,'n_max_cpdf_count')
    O.n_max_cpdf_count=1; % Maximum number of conditional data points
end

if ~exist('par_1','var'); par_1='n_cond';end
if ~exist('arr_1','var'); arr_1=[1,2,3,4,5,6,7].^2; end

if ~exist('par_2','var'); par_2='rseed';end
if ~exist('arr_2','var'); arr_2=[1,2,3];end

n_1=length(arr_1);
n_2=length(arr_2);

figure(2);
clf;
for i=1:n_1
for j=1:n_2
    O.(par_1)=arr_1(i);
    O.(par_2)=arr_2(j);

    if strcmp(par_1,'template_size');
        O.template_size=[sqrt(arr_1(i)) sqrt(arr_1(i)) 1];
    end
    
    tic;
    [reals,O]=mps_cpp(TI,SIM,O);
    t(i,j)=toc;
    if n_2==1;
        nn=ceil(sqrt(n_1));        
        subplot(nn,nn,(j-1)*n_1+i)
    else
        subplot(n_2,n_1,(j-1)*n_1+i)
    end
    
    d=reals(:);
    prob_real=sum(d==0)./length(d);
    d_ti=TI(:);
    prob_ti=sum(d_ti==0)./length(d_ti);
    disp(sprintf('P(TI==0)=%4.2f, P(real==0)==%4.2f',prob_ti,prob_real))
    
    imagesc(reals);axis image
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    set(gca,'FontSize',6);
    xlabel(sprintf('%s=%d',par_1,arr_1(i)),'Interpreter','none','FontSize',6);
    ylabel(sprintf('%s=%d',par_2,arr_2(j)),'Interpreter','none','FontSize',6);
    %xlabel(sprintf('t= %4.2f s',t(i,j)),'FontSize',6)
    h_title=title(sprintf('t=%6.2f',t(i,j)));
    %set(h_title,'FontSize',4,'Interpreter','None');
    drawnow;
end
end
tit=sprintf('%s_%s__%s',O.method,par_1,par_2);
ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
set(get(ax,'Title'),'Visible','on')
set(get(ax,'Title'),'interpreter','none')
set(get(ax,'Title'),'String',tit)
print('-dpng','-r600',tit)


