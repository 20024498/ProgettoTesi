clear 

h_states = {'ModCtrlLogic', 'WrongLogicExec', 'ICSServ', 'ICSMasq', 'SpoofComMsg', 'localMITM', 'ManContr', 'SpoofRepMsg', 'ModRepMsg', 'NotCoherStatus (OR)', 'CorrReact', 'UnstablePS (OR)'};
obs = {'MsgFreq', 'SuspArgICS', 'QuickExecSuspCom', 'DataCoherenceDev', 'ServLaunchCmd', 'SuspRunLoc', 'RunExecHash', 'ServBinMod', 'DataCoherenceHist', 'DataCoherenceMeasure', 'UpdateMonitor'};
names=[h_states, obs];

n=length(names);

intrac = {'ModCtrlLogic', 'WrongLogicExec';
'ModCtrlLogic', 'UpdateMonitor';
'WrongLogicExec', 'UnstablePS (OR)';
'ICSServ', 'ICSMasq';
'ICSServ', 'QuickExecSuspCom';
'ICSServ', 'ServLaunchCmd';
'ICSServ', 'ServBinMod';
'ICSMasq', 'SpoofComMsg';
'ICSMasq', 'SuspArgICS';
'ICSMasq', 'SuspRunLoc';
'ICSMasq', 'RunExecHash';
'SpoofComMsg', 'UnstablePS (OR)';
'SpoofComMsg', 'DataCoherenceDev';
'SpoofComMsg', 'DataCoherenceHist';
'SpoofComMsg', 'DataCoherenceMeasure';
'localMITM', 'QuickExecSuspCom';
'localMITM', 'ServBinMod';
'ManContr', 'UnstablePS (OR)';
'ManContr', 'DataCoherenceDev';
'ManContr', 'DataCoherenceHist';
'ManContr', 'DataCoherenceMeasure';
'SpoofRepMsg', 'NotCoherStatus (OR)';
'SpoofRepMsg', 'MsgFreq';
'SpoofRepMsg', 'DataCoherenceDev';
'ModRepMsg', 'NotCoherStatus (OR)';
'ModRepMsg', 'DataCoherenceDev';
'NotCoherStatus (OR)', 'CorrReact';
'CorrReact', 'UnstablePS (OR)'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc = {'ModCtrlLogic', 'ModCtrlLogic';
'ModCtrlLogic', 'WrongLogicExec';
'WrongLogicExec', 'WrongLogicExec';
'ICSServ', 'ICSServ';
'ICSMasq', 'ICSMasq';
'SpoofComMsg', 'SpoofComMsg';
'localMITM', 'localMITM';
'localMITM', 'ManContr';
'localMITM', 'SpoofRepMsg';
'localMITM', 'ModRepMsg';
'ManContr', 'ManContr';
'SpoofRepMsg', 'SpoofRepMsg';
'ModRepMsg', 'ModRepMsg';
'NotCoherStatus (OR)', 'CorrReact';
'CorrReact', 'CorrReact'};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node ModCtrlLogic slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModCtrlLogic')}=tabular_CPD(bnet,bnet.names('ModCtrlLogic'),'CPT',cpt);
clear cpt;

%node WrongLogicExec slice 1 
%parent order:{ModConLog}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('WrongLogicExec')}=tabular_CPD(bnet,bnet.names('WrongLogicExec'),'CPT',cpt);
clear cpt;

%node ICSServ slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSServ')}=tabular_CPD(bnet,bnet.names('ICSServ'),'CPT',cpt);
clear cpt;

%node ICSMasq slice 1 
%parent order:{ICSServ}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSMasq')}=tabular_CPD(bnet,bnet.names('ICSMasq'),'CPT',cpt);
clear cpt;

%node SpoofComMsg slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofComMsg')}=tabular_CPD(bnet,bnet.names('SpoofComMsg'),'CPT',cpt);
clear cpt;

%node localMITM slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('localMITM')}=tabular_CPD(bnet,bnet.names('localMITM'),'CPT',cpt);
clear cpt;

%node ManContr slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ManContr')}=tabular_CPD(bnet,bnet.names('ManContr'),'CPT',cpt);
clear cpt;

%node SpoofRepMsg slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofRepMsg')}=tabular_CPD(bnet,bnet.names('SpoofRepMsg'),'CPT',cpt);
clear cpt;

%node ModRepMsg slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModRepMsg')}=tabular_CPD(bnet,bnet.names('ModRepMsg'),'CPT',cpt);
clear cpt;

%node NotCoherStatus (OR) slice 1 
%parent order:{ModRepMes, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.0, 1.0];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
bnet.CPD{bnet.names('NotCoherStatus (OR)')}=tabular_CPD(bnet,bnet.names('NotCoherStatus (OR)'),'CPT',cpt);
clear cpt;

%node CorrReact slice 1 
%parent order:{NotCoherStatus}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('CorrReact')}=tabular_CPD(bnet,bnet.names('CorrReact'),'CPT',cpt);
clear cpt;

%node UnstablePS (OR) slice 1 
%parent order:{WrongReact, SpoofComMes, ModComMes, CorrReact}
cpt(1,1,1,1,:)=[1.0, 0.0];
cpt(1,1,1,2,:)=[0.0, 1.0];
cpt(1,1,2,1,:)=[0.0, 1.0];
cpt(1,1,2,2,:)=[0.0, 1.0];
cpt(1,2,1,1,:)=[0.0, 1.0];
cpt(1,2,1,2,:)=[0.0, 1.0];
cpt(1,2,2,1,:)=[0.0, 1.0];
cpt(1,2,2,2,:)=[0.0, 1.0];
cpt(2,1,1,1,:)=[0.0, 1.0];
cpt(2,1,1,2,:)=[0.0, 1.0];
cpt(2,1,2,1,:)=[0.0, 1.0];
cpt(2,1,2,2,:)=[0.0, 1.0];
cpt(2,2,1,1,:)=[0.0, 1.0];
cpt(2,2,1,2,:)=[0.0, 1.0];
cpt(2,2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,2,:)=[0.0, 1.0];
bnet.CPD{bnet.names('UnstablePS (OR)')}=tabular_CPD(bnet,bnet.names('UnstablePS (OR)'),'CPT',cpt);
clear cpt;

%node MsgFreq slice 1 
%parent order:{SpoofRepMes}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('MsgFreq')}=tabular_CPD(bnet,bnet.names('MsgFreq'),'CPT',cpt);
clear cpt;

%node SuspArgICS slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 1.0E-4];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspArgICS')}=tabular_CPD(bnet,bnet.names('SuspArgICS'),'CPT',cpt);
clear cpt;

%node QuickExecSuspCom slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('QuickExecSuspCom')}=tabular_CPD(bnet,bnet.names('QuickExecSuspCom'),'CPT',cpt);
clear cpt;

%node DataCoherenceDev slice 1 
%parent order:{ModComMes, SpoofRepMes, ModRepMes, SpoofComMes}
cpt(1,1,1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,1,1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(1,1,2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(1,1,2,2,:)=[1.0E-4, 0.9999];
cpt(1,2,1,1,:)=[1.0E-4, 0.9999];
cpt(1,2,1,2,:)=[1.0E-4, 0.9999];
cpt(1,2,2,1,:)=[1.0E-4, 0.9999];
cpt(1,2,2,2,:)=[1.0E-4, 0.9999];
cpt(2,1,1,1,:)=[1.0E-4, 0.9999];
cpt(2,1,1,2,:)=[1.0E-4, 0.9999];
cpt(2,1,2,1,:)=[1.0E-4, 0.9999];
cpt(2,1,2,2,:)=[1.0E-4, 0.9999];
cpt(2,2,1,1,:)=[1.0E-4, 0.9999];
cpt(2,2,1,2,:)=[1.0E-4, 0.9999];
cpt(2,2,2,1,:)=[1.0E-4, 0.9999];
cpt(2,2,2,2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('DataCoherenceDev')}=tabular_CPD(bnet,bnet.names('DataCoherenceDev'),'CPT',cpt);
clear cpt;

%node ServLaunchCmd slice 1 
%parent order:{ICSServ}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('ServLaunchCmd')}=tabular_CPD(bnet,bnet.names('ServLaunchCmd'),'CPT',cpt);
clear cpt;

%node SuspRunLoc slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspRunLoc')}=tabular_CPD(bnet,bnet.names('SuspRunLoc'),'CPT',cpt);
clear cpt;

%node RunExecHash slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('RunExecHash')}=tabular_CPD(bnet,bnet.names('RunExecHash'),'CPT',cpt);
clear cpt;

%node ServBinMod slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('ServBinMod')}=tabular_CPD(bnet,bnet.names('ServBinMod'),'CPT',cpt);
clear cpt;

%node DataCoherenceHist slice 1 
%parent order:{ModComMes, SpoofComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('DataCoherenceHist')}=tabular_CPD(bnet,bnet.names('DataCoherenceHist'),'CPT',cpt);
clear cpt;

%node DataCoherenceMeasure slice 1 
%parent order:{SpoofComMes, ModComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('DataCoherenceMeasure')}=tabular_CPD(bnet,bnet.names('DataCoherenceMeasure'),'CPT',cpt);
clear cpt;

%node UpdateMonitor slice 1 
%parent order:{ModConLog}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('UpdateMonitor')}=tabular_CPD(bnet,bnet.names('UpdateMonitor'),'CPT',cpt);
clear cpt;



%%%%%%%%% ------- slice 2

%node ModCtrlLogic slice 2 
%parent order:{ModConLog}
cpt(1,:)=[0.986871, 0.013129];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ModCtrlLogic'))}=tabular_CPD(bnet,n+bnet.names('ModCtrlLogic'),'CPT',cpt);
clear cpt; 

%node WrongLogicExec slice 2 
%parent order:{ModConLog, WrongReact, ModConLog}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.2, 0.8];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'WrongReact', 'ModConLog', 'ModConLog', 'WrongReact'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('WrongLogicExec'))}=tabular_CPD(bnet,n+bnet.names('WrongLogicExec'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ICSServ slice 2 
%parent order:{ICSServ}
cpt(1,:)=[0.995165, 0.004835];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ICSServ'))}=tabular_CPD(bnet,n+bnet.names('ICSServ'),'CPT',cpt);
clear cpt; 

%node ICSMasq slice 2 
%parent order:{ICSMasq, ICSServ}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.994351, 0.005649];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ICSMasq', 'ICSServ', 'ICSMasq'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ICSMasq'))}=tabular_CPD(bnet,n+bnet.names('ICSMasq'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofComMsg slice 2 
%parent order:{SpoofComMes, ICSMasq}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.98331628, 0.01668372];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofComMes', 'ICSMasq', 'SpoofComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofComMsg'))}=tabular_CPD(bnet,n+bnet.names('SpoofComMsg'),'CPT',cpt1);
clear cpt; clear cpt1;

%node localMITM slice 2 
%parent order:{MITM}
cpt(1,:)=[0.985993, 0.014007];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('localMITM'))}=tabular_CPD(bnet,n+bnet.names('localMITM'),'CPT',cpt);
clear cpt; 

%node ManContr slice 2 
%parent order:{MITM, ModComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985763, 0.014237];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModComMes', 'MITM', 'ModComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ManContr'))}=tabular_CPD(bnet,n+bnet.names('ManContr'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofRepMsg slice 2 
%parent order:{MITM, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.9828439999999999, 0.017156];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofRepMes', 'MITM', 'SpoofRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofRepMsg'))}=tabular_CPD(bnet,n+bnet.names('SpoofRepMsg'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModRepMsg slice 2 
%parent order:{MITM, ModRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985695, 0.014305];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModRepMes', 'MITM', 'ModRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModRepMsg'))}=tabular_CPD(bnet,n+bnet.names('ModRepMsg'),'CPT',cpt1);
clear cpt; clear cpt1;

%node CorrReact slice 2 
%parent order:{NotCoherStatus, CorrReact, NotCoherStatus}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.3, 0.7];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'CorrReact', 'NotCoherStatus', 'NotCoherStatus', 'CorrReact'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('CorrReact'))}=tabular_CPD(bnet,n+bnet.names('CorrReact'),'CPT',cpt1);
clear cpt; clear cpt1;

% choose the inference engine
ec='JT';

% ff=0 --> no fully factorized  OR ff=1 --> fully factorized
ff=1;

% list of clusters
if (ec=='JT')
	engine=bk_inf_engine(bnet, 'clusters', 'exact'); %exact inference
else
	if (ff==1)
		engine=bk_inf_engine(bnet, 'clusters', 'ff'); % fully factorized
	else
		clusters={[]};
		engine=bk_inf_engine(bnet, 'clusters', clusters);
	end
end

% IMPORTANT: DrawNet start slices from 0,
T=11; %max time span (from XML file campo Time Slice) thus from 0 to T-1
tStep=1; %from  XML file campo Time Step
evidence=cell(n,T); % create the evidence cell array

% Evidence
% first cells of evidence are for time 0
% Campo Algoritmo di Inferenza  (filtering / smoothing)
filtering=1;
% filtering=0 --> smoothing (is the default - enter_evidence(engine,evidence))
% filtering=1 --> filtering
if ~filtering
	fprintf('\n*****  SMOOTHING *****\n\n');
else
	fprintf('\n*****  FILTERING *****\n\n');
end

[engine, loglik] = enter_evidence(engine, evidence, 'filter', filtering);

% analysis time is t for anterior nodes and t+1 for ulterior nodes
for t=1:tStep:T-1
%t = analysis time

% create the vector of marginals
% marg(i).T is the posterior distribution of node T
% with marg(i).T(false) and marg(i).T(true)

% NB. if filtering then ulterior nodes cannot be marginalized at time t=1

if ~filtering
	for i=1:(n*2)
		marg(i)=marginal_nodes(engine, i , t);
	end
else
	if t==1
		for i=1:n
			marg(i)=marginal_nodes(engine, i, t);
		end
	else
		for i=1:(n*2)
			marg(i)=marginal_nodes(engine, i, t);
		end
	end
end

% Printing results
% IMPORTANT: To be consistent with DrawNet we start counting/printing time slices from 0


% Anterior nodes are printed from t=1 to T-1
fprintf('\n\n**** Time %i *****\n****\n\n',t-1);
%fprintf('*** Anterior nodes \n');
for i=1:n
	if isempty(evidence{i,t})
		for k=1:ns(i)
			fprintf('Posterior of node %i:%s value %i : %d\n',i, names{i}, k, marg(i).T(k));
		end
			fprintf('**\n');
		else
			fprintf('Node %i:%s observed at value: %i\n**\n',i,names{i}, evidence{i,t});
		end
	end
end

% Ulterior nodes are printed at last time slice
fprintf('\n\n**** Time %i *****\n****\n\n',T-1);
%fprintf('*** Ulterior nodes \n');
for i=(n+1):(n*2)
	if isempty(evidence{i-n,T})
		for k=1:ns(i-n)
			fprintf('Posterior of node %i:%s value %i : %d\n',i, names{i-n}, k, marg(i).T(k));
		end
		fprintf('**\n');
	else
		fprintf('Node %i:%s observed at value: %i\n**\n',i,names{i-n}, evidence{i-n,T});
	end
end