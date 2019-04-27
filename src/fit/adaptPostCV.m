%%
addpath(genpath('../../../matlab-linsys/'))
addpath(genpath('../../../robustCov/'))
addpath(genpath('../../'))
%%
clear all
%% Load real data:
sqrtFlag=false;
subjIdx=[2:6,8,10:15]; %Excluding C01 (outlier), C07, C09 (less than 600 strides of Post), C16 (missed first trial of Adapt)
[Y,Yasym,Ycom,U,Ubreaks]=groupDataToMatrixForm(subjIdx,sqrtFlag);
Uf=[U;ones(size(U))];
datSet=dset(Uf,Yasym');
%% Get folded data for adapt/post
datSetAP=datSet.split([826]); %First half is 1-825, last part 826-1650
%%
opts.Nreps=10;
opts.fastFlag=100;
opts.indB=1;
opts.indD=[];
opts.stableA=true;
[fitMdlAP,outlogAP]=linsys.id([datSetAP],0:5,opts);

%% Save (to avoid recomputing in the future)
nw=datestr(now,'yyyymmddTHHMMSS');
save(['../../res/AP_CV_' nw '.mat'],'fitMdlAP', 'outlogAP', 'datSetAP', 'opts');
%% Visualize CV log
f1=vizDataLikelihood(fitMdlAP(2:end,1),datSetAP);
ph=findobj(gcf,'Type','Axes');
f2=vizDataLikelihood(fitMdlAP(2:end,2),datSetAP);
ph1=findobj(gcf,'Type','Axes');

fh=figure;
ah=copyobj(ph([1]),fh);
ah(1).Title.String={'Adapt-model';'Cross-validation'};
ah(1).YAxis.Label.String={'Post-data'; 'log-L'};
ah(1).XTickLabel={'1','2','3','4','5','6'};
ah1=copyobj(ph1([2]),fh);
ah1(1).XAxis.Label.String={'Model Order'};
ah1(1).XTickLabel={'1','2','3','4','5','6'};
ah1(1).Title.String={'Post-model';'log-L'};
set(gcf,'Name','Adapt/Post cross-validation');
%% Visualize self-measured BIC
%for %Each of the four fit sets
%    f(i)= %Generate fig
%end
fittedLinsys.compare(fitMdlAP(2:end,1))
fittedLinsys.compare(fitMdlAP(2:end,2))

%Copy all panels onto single fig:
%fh=figure;