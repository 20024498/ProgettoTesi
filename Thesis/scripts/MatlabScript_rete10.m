clear 

h_states = {'ModConLog', 'WrongReact', 'ICSServ', 'ICSMasq', 'SpoofComMes', 'MITM', 'ModComMes', 'SpoofRepMes', 'ModRepMes', 'NotCoherStatus', 'CorrReact', 'ICSCompr'};
obs = {'Periodic', 'SuspArgICS', 'QuickExecSuspCom', 'CoherentDev', 'ServLaunchCmd', 'SuspRunLoc', 'RunExecHash', 'ServBinMod_2', 'CoherentHist', 'CoherentRep', 'UpdateMonitor'};
names=[h_states, obs];

n=length(names);

intrac = {'ModConLog', 'WrongReact';
'ModConLog', 'UpdateMonitor';
'WrongReact', 'ICSCompr';
'ICSServ', 'ICSMasq';
'ICSServ', 'QuickExecSuspCom';
'ICSServ', 'ServLaunchCmd';
'ICSServ', 'ServBinMod_2';
'ICSMasq', 'SpoofComMes';
'ICSMasq', 'SuspArgICS';
'ICSMasq', 'SuspRunLoc';
'ICSMasq', 'RunExecHash';
'SpoofComMes', 'ICSCompr';
'SpoofComMes', 'CoherentDev';
'SpoofComMes', 'CoherentHist';
'SpoofComMes', 'CoherentRep';
'MITM', 'QuickExecSuspCom';
'MITM', 'ServBinMod_2';
'ModComMes', 'ICSCompr';
'ModComMes', 'CoherentDev';
'ModComMes', 'CoherentHist';
'ModComMes', 'CoherentRep';
'SpoofRepMes', 'NotCoherStatus';
'SpoofRepMes', 'Periodic';
'SpoofRepMes', 'CoherentDev';
'ModRepMes', 'NotCoherStatus';
'ModRepMes', 'CoherentDev';
'NotCoherStatus', 'CorrReact';
'CorrReact', 'ICSCompr'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc = {'ModConLog', 'ModConLog';
'WrongReact', 'WrongReact';
'ModConLog', 'WrongReact';
'ICSServ', 'ICSServ';
'ICSMasq', 'ICSMasq';
'SpoofComMes', 'SpoofComMes';
'MITM', 'MITM';
'ModComMes', 'ModComMes';
'MITM', 'ModComMes';
'SpoofRepMes', 'SpoofRepMes';
'MITM', 'SpoofRepMes';
'ModRepMes', 'ModRepMes';
'MITM', 'ModRepMes';
'CorrReact', 'CorrReact';
'NotCoherStatus', 'CorrReact';
};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node ModCtrlLogic(id=ModConLog) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModConLog')}=tabular_CPD(bnet,bnet.names('ModConLog'),'CPT',cpt);
clear cpt;

%node WrongLogicExec(id=WrongReact) slice 1 
%parent order:{ModConLog}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('WrongReact')}=tabular_CPD(bnet,bnet.names('WrongReact'),'CPT',cpt);
clear cpt;

%node ICSServ(id=ICSServ) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSServ')}=tabular_CPD(bnet,bnet.names('ICSServ'),'CPT',cpt);
clear cpt;

%node ICSMasq(id=ICSMasq) slice 1 
%parent order:{ICSServ}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSMasq')}=tabular_CPD(bnet,bnet.names('ICSMasq'),'CPT',cpt);
clear cpt;

%node SpoofComMsg(id=SpoofComMes) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofComMes')}=tabular_CPD(bnet,bnet.names('SpoofComMes'),'CPT',cpt);
clear cpt;

%node localMITM(id=MITM) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('MITM')}=tabular_CPD(bnet,bnet.names('MITM'),'CPT',cpt);
clear cpt;

%node ManContr(id=ModComMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModComMes')}=tabular_CPD(bnet,bnet.names('ModComMes'),'CPT',cpt);
clear cpt;

%node SpoofRepMsg(id=SpoofRepMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofRepMes')}=tabular_CPD(bnet,bnet.names('SpoofRepMes'),'CPT',cpt);
clear cpt;

%node ModRepMsg(id=ModRepMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModRepMes')}=tabular_CPD(bnet,bnet.names('ModRepMes'),'CPT',cpt);
clear cpt;

%node NotCoherStatus (OR)(id=NotCoherStatus) slice 1 
%parent order:{ModRepMes, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.0, 1.0];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
bnet.CPD{bnet.names('NotCoherStatus')}=tabular_CPD(bnet,bnet.names('NotCoherStatus'),'CPT',cpt);
clear cpt;

%node CorrReact(id=CorrReact) slice 1 
%parent order:{NotCoherStatus}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('CorrReact')}=tabular_CPD(bnet,bnet.names('CorrReact'),'CPT',cpt);
clear cpt;

%node UnstablePS (OR)(id=ICSCompr) slice 1 
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
bnet.CPD{bnet.names('ICSCompr')}=tabular_CPD(bnet,bnet.names('ICSCompr'),'CPT',cpt);
clear cpt;

%node MsgFreq(id=Periodic) slice 1 
%parent order:{SpoofRepMes}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('Periodic')}=tabular_CPD(bnet,bnet.names('Periodic'),'CPT',cpt);
clear cpt;

%node SuspArgICS(id=SuspArgICS) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 1.0E-4];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspArgICS')}=tabular_CPD(bnet,bnet.names('SuspArgICS'),'CPT',cpt);
clear cpt;

%node QuickExecSuspCom(id=QuickExecSuspCom) slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('QuickExecSuspCom')}=tabular_CPD(bnet,bnet.names('QuickExecSuspCom'),'CPT',cpt);
clear cpt;

%node DataCoherenceDev(id=CoherentDev) slice 1 
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
bnet.CPD{bnet.names('CoherentDev')}=tabular_CPD(bnet,bnet.names('CoherentDev'),'CPT',cpt);
clear cpt;

%node ServLaunchCmd(id=ServLaunchCmd) slice 1 
%parent order:{ICSServ}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('ServLaunchCmd')}=tabular_CPD(bnet,bnet.names('ServLaunchCmd'),'CPT',cpt);
clear cpt;

%node SuspRunLoc(id=SuspRunLoc) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspRunLoc')}=tabular_CPD(bnet,bnet.names('SuspRunLoc'),'CPT',cpt);
clear cpt;

%node RunExecHash(id=RunExecHash) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('RunExecHash')}=tabular_CPD(bnet,bnet.names('RunExecHash'),'CPT',cpt);
clear cpt;

%node ServBinMod(id=ServBinMod_2) slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('ServBinMod_2')}=tabular_CPD(bnet,bnet.names('ServBinMod_2'),'CPT',cpt);
clear cpt;

%node DataCoherenceHist(id=CoherentHist) slice 1 
%parent order:{ModComMes, SpoofComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('CoherentHist')}=tabular_CPD(bnet,bnet.names('CoherentHist'),'CPT',cpt);
clear cpt;

%node DataCoherenceMeasure(id=CoherentRep) slice 1 
%parent order:{SpoofComMes, ModComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('CoherentRep')}=tabular_CPD(bnet,bnet.names('CoherentRep'),'CPT',cpt);
clear cpt;

%node UpdateMonitor(id=UpdateMonitor) slice 1 
%parent order:{ModConLog}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('UpdateMonitor')}=tabular_CPD(bnet,bnet.names('UpdateMonitor'),'CPT',cpt);
clear cpt;



%%%%%%%%% ------- slice 2

%node ModCtrlLogic(id=ModConLog) slice 2 
%parent order:{ModConLog}
cpt(1,:)=[0.986871, 0.013129];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ModConLog'))}=tabular_CPD(bnet,n+bnet.names('ModConLog'),'CPT',cpt);
clear cpt; 

%node WrongLogicExec(id=WrongReact) slice 2 
%parent order:{ModConLog, ModConLog, WrongReact}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.2, 0.8];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModConLog', 'WrongReact', 'ModConLog', 'WrongReact'},names, bnet.dag, cpt,[3]);
bnet.CPD{bnet.eclass2(bnet.names('WrongReact'))}=tabular_CPD(bnet,n+bnet.names('WrongReact'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ICSServ(id=ICSServ) slice 2 
%parent order:{ICSServ}
cpt(1,:)=[0.995165, 0.004835];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ICSServ'))}=tabular_CPD(bnet,n+bnet.names('ICSServ'),'CPT',cpt);
clear cpt; 

%node ICSMasq(id=ICSMasq) slice 2 
%parent order:{ICSServ, ICSMasq}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.994351, 0.005649];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ICSServ', 'ICSMasq', 'ICSMasq'},names, bnet.dag, cpt,[1]);
bnet.CPD{bnet.eclass2(bnet.names('ICSMasq'))}=tabular_CPD(bnet,n+bnet.names('ICSMasq'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofComMsg(id=SpoofComMes) slice 2 
%parent order:{ICSMasq, SpoofComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.98331628, 0.01668372];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ICSMasq', 'SpoofComMes', 'SpoofComMes'},names, bnet.dag, cpt,[1]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofComMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node localMITM(id=MITM) slice 2 
%parent order:{MITM}
cpt(1,:)=[0.985993, 0.014007];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('MITM'))}=tabular_CPD(bnet,n+bnet.names('MITM'),'CPT',cpt);
clear cpt; 

%node ManContr(id=ModComMes) slice 2 
%parent order:{MITM, ModComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985763, 0.014237];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModComMes', 'MITM', 'ModComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModComMes'))}=tabular_CPD(bnet,n+bnet.names('ModComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofRepMsg(id=SpoofRepMes) slice 2 
%parent order:{MITM, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.9828439999999999, 0.017156];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofRepMes', 'MITM', 'SpoofRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofRepMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModRepMsg(id=ModRepMes) slice 2 
%parent order:{MITM, ModRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985695, 0.014305];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModRepMes', 'MITM', 'ModRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModRepMes'))}=tabular_CPD(bnet,n+bnet.names('ModRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node CorrReact(id=CorrReact) slice 2 
%parent order:{NotCoherStatus, NotCoherStatus, CorrReact}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.3, 0.7];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'NotCoherStatus', 'CorrReact', 'NotCoherStatus', 'CorrReact'},names, bnet.dag, cpt,[3]);
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
endclear 

h_states = {'ModConLog', 'WrongReact', 'ICSServ', 'ICSMasq', 'SpoofComMes', 'MITM', 'ModComMes', 'SpoofRepMes', 'ModRepMes', 'NotCoherStatus', 'CorrReact', 'ICSCompr'};
obs = {'Periodic', 'SuspArgICS', 'QuickExecSuspCom', 'CoherentDev', 'ServLaunchCmd', 'SuspRunLoc', 'RunExecHash', 'ServBinMod_2', 'CoherentHist', 'CoherentRep', 'UpdateMonitor'};
names=[h_states, obs];

n=length(names);

intrac = {'ModConLog', 'WrongReact';
'ModConLog', 'UpdateMonitor';
'WrongReact', 'ICSCompr';
'ICSServ', 'ICSMasq';
'ICSServ', 'QuickExecSuspCom';
'ICSServ', 'ServLaunchCmd';
'ICSServ', 'ServBinMod_2';
'ICSMasq', 'SpoofComMes';
'ICSMasq', 'SuspArgICS';
'ICSMasq', 'SuspRunLoc';
'ICSMasq', 'RunExecHash';
'SpoofComMes', 'ICSCompr';
'SpoofComMes', 'CoherentDev';
'SpoofComMes', 'CoherentHist';
'SpoofComMes', 'CoherentRep';
'MITM', 'QuickExecSuspCom';
'MITM', 'ServBinMod_2';
'ModComMes', 'ICSCompr';
'ModComMes', 'CoherentDev';
'ModComMes', 'CoherentHist';
'ModComMes', 'CoherentRep';
'SpoofRepMes', 'NotCoherStatus';
'SpoofRepMes', 'Periodic';
'SpoofRepMes', 'CoherentDev';
'ModRepMes', 'NotCoherStatus';
'ModRepMes', 'CoherentDev';
'NotCoherStatus', 'CorrReact';
'CorrReact', 'ICSCompr'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc = {'ModConLog', 'ModConLog';
'WrongReact', 'WrongReact';
'ModConLog', 'WrongReact';
'ICSServ', 'ICSServ';
'ICSMasq', 'ICSMasq';
'SpoofComMes', 'SpoofComMes';
'MITM', 'MITM';
'ModComMes', 'ModComMes';
'MITM', 'ModComMes';
'SpoofRepMes', 'SpoofRepMes';
'MITM', 'SpoofRepMes';
'ModRepMes', 'ModRepMes';
'MITM', 'ModRepMes';
'CorrReact', 'CorrReact';
'NotCoherStatus', 'CorrReact';
};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node ModCtrlLogic(id=ModConLog) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModConLog')}=tabular_CPD(bnet,bnet.names('ModConLog'),'CPT',cpt);
clear cpt;

%node WrongLogicExec(id=WrongReact) slice 1 
%parent order:{ModConLog}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('WrongReact')}=tabular_CPD(bnet,bnet.names('WrongReact'),'CPT',cpt);
clear cpt;

%node ICSServ(id=ICSServ) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSServ')}=tabular_CPD(bnet,bnet.names('ICSServ'),'CPT',cpt);
clear cpt;

%node ICSMasq(id=ICSMasq) slice 1 
%parent order:{ICSServ}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSMasq')}=tabular_CPD(bnet,bnet.names('ICSMasq'),'CPT',cpt);
clear cpt;

%node SpoofComMsg(id=SpoofComMes) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofComMes')}=tabular_CPD(bnet,bnet.names('SpoofComMes'),'CPT',cpt);
clear cpt;

%node localMITM(id=MITM) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('MITM')}=tabular_CPD(bnet,bnet.names('MITM'),'CPT',cpt);
clear cpt;

%node ManContr(id=ModComMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModComMes')}=tabular_CPD(bnet,bnet.names('ModComMes'),'CPT',cpt);
clear cpt;

%node SpoofRepMsg(id=SpoofRepMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofRepMes')}=tabular_CPD(bnet,bnet.names('SpoofRepMes'),'CPT',cpt);
clear cpt;

%node ModRepMsg(id=ModRepMes) slice 1 
%parent order:{}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModRepMes')}=tabular_CPD(bnet,bnet.names('ModRepMes'),'CPT',cpt);
clear cpt;

%node NotCoherStatus (OR)(id=NotCoherStatus) slice 1 
%parent order:{ModRepMes, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.0, 1.0];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
bnet.CPD{bnet.names('NotCoherStatus')}=tabular_CPD(bnet,bnet.names('NotCoherStatus'),'CPT',cpt);
clear cpt;

%node CorrReact(id=CorrReact) slice 1 
%parent order:{NotCoherStatus}
cpt(1,:)=[1.0, 0.0];
cpt(2,:)=[1.0, 0.0];
bnet.CPD{bnet.names('CorrReact')}=tabular_CPD(bnet,bnet.names('CorrReact'),'CPT',cpt);
clear cpt;

%node UnstablePS (OR)(id=ICSCompr) slice 1 
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
bnet.CPD{bnet.names('ICSCompr')}=tabular_CPD(bnet,bnet.names('ICSCompr'),'CPT',cpt);
clear cpt;

%node MsgFreq(id=Periodic) slice 1 
%parent order:{SpoofRepMes}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('Periodic')}=tabular_CPD(bnet,bnet.names('Periodic'),'CPT',cpt);
clear cpt;

%node SuspArgICS(id=SuspArgICS) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 1.0E-4];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspArgICS')}=tabular_CPD(bnet,bnet.names('SuspArgICS'),'CPT',cpt);
clear cpt;

%node QuickExecSuspCom(id=QuickExecSuspCom) slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('QuickExecSuspCom')}=tabular_CPD(bnet,bnet.names('QuickExecSuspCom'),'CPT',cpt);
clear cpt;

%node DataCoherenceDev(id=CoherentDev) slice 1 
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
bnet.CPD{bnet.names('CoherentDev')}=tabular_CPD(bnet,bnet.names('CoherentDev'),'CPT',cpt);
clear cpt;

%node ServLaunchCmd(id=ServLaunchCmd) slice 1 
%parent order:{ICSServ}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('ServLaunchCmd')}=tabular_CPD(bnet,bnet.names('ServLaunchCmd'),'CPT',cpt);
clear cpt;

%node SuspRunLoc(id=SuspRunLoc) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspRunLoc')}=tabular_CPD(bnet,bnet.names('SuspRunLoc'),'CPT',cpt);
clear cpt;

%node RunExecHash(id=RunExecHash) slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('RunExecHash')}=tabular_CPD(bnet,bnet.names('RunExecHash'),'CPT',cpt);
clear cpt;

%node ServBinMod(id=ServBinMod_2) slice 1 
%parent order:{MITM, ICSServ}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('ServBinMod_2')}=tabular_CPD(bnet,bnet.names('ServBinMod_2'),'CPT',cpt);
clear cpt;

%node DataCoherenceHist(id=CoherentHist) slice 1 
%parent order:{ModComMes, SpoofComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('CoherentHist')}=tabular_CPD(bnet,bnet.names('CoherentHist'),'CPT',cpt);
clear cpt;

%node DataCoherenceMeasure(id=CoherentRep) slice 1 
%parent order:{SpoofComMes, ModComMes}
cpt(1,1,:)=[0.9999, 9.999999999998899E-5];
cpt(1,2,:)=[9.999999999998899E-5, 0.9999];
cpt(2,1,:)=[9.999999999998899E-5, 0.9999];
cpt(2,2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('CoherentRep')}=tabular_CPD(bnet,bnet.names('CoherentRep'),'CPT',cpt);
clear cpt;

%node UpdateMonitor(id=UpdateMonitor) slice 1 
%parent order:{ModConLog}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('UpdateMonitor')}=tabular_CPD(bnet,bnet.names('UpdateMonitor'),'CPT',cpt);
clear cpt;



%%%%%%%%% ------- slice 2

%node ModCtrlLogic(id=ModConLog) slice 2 
%parent order:{ModConLog}
cpt(1,:)=[0.986871, 0.013129];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ModConLog'))}=tabular_CPD(bnet,n+bnet.names('ModConLog'),'CPT',cpt);
clear cpt; 

%node WrongLogicExec(id=WrongReact) slice 2 
%parent order:{ModConLog, ModConLog, WrongReact}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.2, 0.8];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModConLog', 'WrongReact', 'ModConLog', 'WrongReact'},names, bnet.dag, cpt,[3]);
bnet.CPD{bnet.eclass2(bnet.names('WrongReact'))}=tabular_CPD(bnet,n+bnet.names('WrongReact'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ICSServ(id=ICSServ) slice 2 
%parent order:{ICSServ}
cpt(1,:)=[0.995165, 0.004835];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ICSServ'))}=tabular_CPD(bnet,n+bnet.names('ICSServ'),'CPT',cpt);
clear cpt; 

%node ICSMasq(id=ICSMasq) slice 2 
%parent order:{ICSServ, ICSMasq}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.994351, 0.005649];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ICSServ', 'ICSMasq', 'ICSMasq'},names, bnet.dag, cpt,[1]);
bnet.CPD{bnet.eclass2(bnet.names('ICSMasq'))}=tabular_CPD(bnet,n+bnet.names('ICSMasq'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofComMsg(id=SpoofComMes) slice 2 
%parent order:{ICSMasq, SpoofComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[1.0, 0.0];
cpt(2,1,:)=[0.98331628, 0.01668372];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ICSMasq', 'SpoofComMes', 'SpoofComMes'},names, bnet.dag, cpt,[1]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofComMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node localMITM(id=MITM) slice 2 
%parent order:{MITM}
cpt(1,:)=[0.985993, 0.014007];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('MITM'))}=tabular_CPD(bnet,n+bnet.names('MITM'),'CPT',cpt);
clear cpt; 

%node ManContr(id=ModComMes) slice 2 
%parent order:{MITM, ModComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985763, 0.014237];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModComMes', 'MITM', 'ModComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModComMes'))}=tabular_CPD(bnet,n+bnet.names('ModComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofRepMsg(id=SpoofRepMes) slice 2 
%parent order:{MITM, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.9828439999999999, 0.017156];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofRepMes', 'MITM', 'SpoofRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofRepMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModRepMsg(id=ModRepMes) slice 2 
%parent order:{MITM, ModRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.985695, 0.014305];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModRepMes', 'MITM', 'ModRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModRepMes'))}=tabular_CPD(bnet,n+bnet.names('ModRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node CorrReact(id=CorrReact) slice 2 
%parent order:{NotCoherStatus, NotCoherStatus, CorrReact}
cpt(1,1,1,:)=[1.0, 0.0];
cpt(1,1,2,:)=[1.0, 0.0];
cpt(1,2,1,:)=[0.0, 1.0];
cpt(1,2,2,:)=[0.0, 1.0];
cpt(2,1,1,:)=[0.3, 0.7];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[0.0, 1.0];
cpt(2,2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'NotCoherStatus', 'CorrReact', 'NotCoherStatus', 'CorrReact'},names, bnet.dag, cpt,[3]);
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