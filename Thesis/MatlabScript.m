clear 

h_states = {'ModConLog', 'WrongReact', 'ICSServ', 'ICSMasq', 'SpoofComMes', 'MITM', 'ModComMes', 'SpoofRepMes', 'ModRepMes', 'CorrReact', 'NotCoherStatus(Or)', 'NewICS(And)', 'ICSCompr(Or)'};
obs = {'Periodic', 'SuspArgICS', 'QuickExecSuspCom', 'CoherentDev'};
names=[h_states, obs];

n=length(names);

intrac={'WrongReact', 'ICSCompr(Or)';
'ICSServ', 'NewICS(And)';
'ICSMasq', 'NewICS(And)';
'ICSMasq', 'SuspArgICS';
'SpoofComMes', 'ICSCompr(Or)';
'SpoofComMes', 'CoherentDev';
'MITM', 'QuickExecSuspCom';
'ModComMes', 'ICSCompr(Or)';
'ModComMes', 'CoherentDev';
'SpoofRepMes', 'NotCoherStatus(Or)';
'SpoofRepMes', 'Periodic';
'SpoofRepMes', 'CoherentDev';
'ModRepMes', 'NotCoherStatus(Or)';
'ModRepMes', 'CoherentDev';
'CorrReact', 'ICSCompr(Or)';
'NewICS(And)', 'QuickExecSuspCom'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc={'ModConLog', 'ModConLog';
'ModConLog', 'WrongReact';
'WrongReact', 'WrongReact';
'ICSServ', 'ICSServ';
'ICSMasq', 'ICSMasq';
'SpoofComMes', 'SpoofComMes';
'MITM', 'MITM';
'MITM', 'ModComMes';
'MITM', 'SpoofRepMes';
'MITM', 'ModRepMes';
'ModComMes', 'ModComMes';
'SpoofRepMes', 'SpoofRepMes';
'ModRepMes', 'ModRepMes';
'CorrReact', 'CorrReact';
'NotCoherStatus(Or)', 'CorrReact';
'NewICS(And)', 'SpoofComMes'};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node ModConLog slice 1 
%parent order:{ModConLog}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModConLog')}=tabular_CPD(bnet,bnet.names('ModConLog'),'CPT',cpt);
clear cpt;

%node WrongReact slice 1 
%parent order:{ModConLog, WrongReact}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('WrongReact')}=tabular_CPD(bnet,bnet.names('WrongReact'),'CPT',cpt);
clear cpt;

%node ICSServ slice 1 
%parent order:{ICSServ}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSServ')}=tabular_CPD(bnet,bnet.names('ICSServ'),'CPT',cpt);
clear cpt;

%node ICSMasq slice 1 
%parent order:{ICSMasq}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ICSMasq')}=tabular_CPD(bnet,bnet.names('ICSMasq'),'CPT',cpt);
clear cpt;

%node SpoofComMes slice 1 
%parent order:{SpoofComMes, NewICS(And)}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofComMes')}=tabular_CPD(bnet,bnet.names('SpoofComMes'),'CPT',cpt);
clear cpt;

%node MITM slice 1 
%parent order:{MITM}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('MITM')}=tabular_CPD(bnet,bnet.names('MITM'),'CPT',cpt);
clear cpt;

%node ModComMes slice 1 
%parent order:{MITM, ModComMes}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModComMes')}=tabular_CPD(bnet,bnet.names('ModComMes'),'CPT',cpt);
clear cpt;

%node SpoofRepMes slice 1 
%parent order:{MITM, SpoofRepMes}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('SpoofRepMes')}=tabular_CPD(bnet,bnet.names('SpoofRepMes'),'CPT',cpt);
clear cpt;

%node ModRepMes slice 1 
%parent order:{MITM, ModRepMes}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('ModRepMes')}=tabular_CPD(bnet,bnet.names('ModRepMes'),'CPT',cpt);
clear cpt;

%node CorrReact slice 1 
%parent order:{CorrReact, NotCoherStatus(Or)}
cpt(:,:)=[1.0, 0.0];
bnet.CPD{bnet.names('CorrReact')}=tabular_CPD(bnet,bnet.names('CorrReact'),'CPT',cpt);
clear cpt;

%node NotCoherStatus(Or) slice 1 
%parent order:{ModRepMes, SpoofRepMes}
bnet.CPD{bnet.names('NotCoherStatus(Or)')}=boolean_CPD(bnet,bnet.names('NotCoherStatus(Or)'),'named','any');
clear cpt;

%node NewICS(And) slice 1 
%parent order:{ICSMasq, ICSServ}
bnet.CPD{bnet.names('NewICS(And)')}=boolean_CPD(bnet,bnet.names('NewICS(And)'),'named','all');
clear cpt;

%node ICSCompr(Or) slice 1 
%parent order:{WrongReact, SpoofComMes, ModComMes, CorrReact}
bnet.CPD{bnet.names('ICSCompr(Or)')}=boolean_CPD(bnet,bnet.names('ICSCompr(Or)'),'named','any');
clear cpt;

%node Periodic slice 1 
%parent order:{SpoofRepMes}
cpt(1,:)=[0.9999, 9.999999999998899E-5];
cpt(2,:)=[9.999999999998899E-5, 0.9999];
bnet.CPD{bnet.names('Periodic')}=tabular_CPD(bnet,bnet.names('Periodic'),'CPT',cpt);
clear cpt;

%node SuspArgICS slice 1 
%parent order:{ICSMasq}
cpt(1,:)=[0.9999, 1.0E-4];
cpt(2,:)=[1.0E-4, 0.9999];
bnet.CPD{bnet.names('SuspArgICS')}=tabular_CPD(bnet,bnet.names('SuspArgICS'),'CPT',cpt);
clear cpt;

%node QuickExecSuspCom slice 1 
%parent order:{NewICS(And), MITM}
leak=0.5;
parents_dn={'NewICS(And)', 'MITM'};
inh_prob=[1.0, 1.0];
inh_prob1=mk_named_noisyor(bnet.names('QuickExecSuspCom'),parents_dn,names,bnet.dag,inh_prob);
bnet.CPD{bnet.names('QuickExecSuspCom')}=noisyor_CPD(bnet, bnet.names('QuickExecSuspCom'),leak, inh_prob1);
clear inh_prob inh_prob1 leak;

%node CoherentDev slice 1 
%parent order:{ModComMes, SpoofRepMes, ModRepMes, SpoofComMes}
leak=0.5;
parents_dn={'ModComMes', 'SpoofRepMes', 'ModRepMes', 'SpoofComMes'};
inh_prob=[0.5, 0.5, 0.5, 0.5];
inh_prob1=mk_named_noisyor(bnet.names('CoherentDev'),parents_dn,names,bnet.dag,inh_prob);
bnet.CPD{bnet.names('CoherentDev')}=noisyor_CPD(bnet, bnet.names('CoherentDev'),leak, inh_prob1);
clear inh_prob inh_prob1 leak;



%%%%%%%%% ------- slice 2

%node ModConLog slice 2 
%parent order:{ModConLog}
cpt(1,:)=[0.86871, 0.13129];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ModConLog'))}=tabular_CPD(bnet,n+bnet.names('ModConLog'),'CPT',cpt);
clear cpt; 

%node WrongReact slice 2 
%parent order:{ModConLog, WrongReact}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.5, 0.5];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'WrongReact', 'ModConLog', 'WrongReact'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('WrongReact'))}=tabular_CPD(bnet,n+bnet.names('WrongReact'),'CPT',cpt1);
clear cpt; clear cpt1;

%node WrongReact slice 2 
%parent order:{ModConLog, WrongReact}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.5, 0.5];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'WrongReact', 'ModConLog', 'WrongReact'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('WrongReact'))}=tabular_CPD(bnet,n+bnet.names('WrongReact'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ICSServ slice 2 
%parent order:{ICSServ}
cpt(1,:)=[0.95165, 0.04835];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ICSServ'))}=tabular_CPD(bnet,n+bnet.names('ICSServ'),'CPT',cpt);
clear cpt; 

%node ICSMasq slice 2 
%parent order:{ICSMasq}
cpt(1,:)=[0.94351, 0.05649000000000004];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('ICSMasq'))}=tabular_CPD(bnet,n+bnet.names('ICSMasq'),'CPT',cpt);
clear cpt; 

%node SpoofComMes slice 2 
%parent order:{SpoofComMes, NewICS(And)}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.83316, 0.16684];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofComMes', 'NewICS', 'SpoofComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofComMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofComMes slice 2 
%parent order:{SpoofComMes, NewICS(And)}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.83316, 0.16684];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofComMes', 'NewICS', 'SpoofComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofComMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node MITM slice 2 
%parent order:{MITM}
cpt(1,:)=[0.85993, 0.14007];
cpt(2,:)=[0.0, 1.0];
bnet.CPD{bnet.eclass2(bnet.names('MITM'))}=tabular_CPD(bnet,n+bnet.names('MITM'),'CPT',cpt);
clear cpt; 

%node ModComMes slice 2 
%parent order:{MITM, ModComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.85763, 0.14237];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModComMes', 'MITM', 'ModComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModComMes'))}=tabular_CPD(bnet,n+bnet.names('ModComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModComMes slice 2 
%parent order:{MITM, ModComMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.85763, 0.14237];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModComMes', 'MITM', 'ModComMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModComMes'))}=tabular_CPD(bnet,n+bnet.names('ModComMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofRepMes slice 2 
%parent order:{MITM, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.82844, 0.17156];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofRepMes', 'MITM', 'SpoofRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofRepMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node SpoofRepMes slice 2 
%parent order:{MITM, SpoofRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.82844, 0.17156];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'SpoofRepMes', 'MITM', 'SpoofRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('SpoofRepMes'))}=tabular_CPD(bnet,n+bnet.names('SpoofRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModRepMes slice 2 
%parent order:{MITM, ModRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.85695, 0.14305];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModRepMes', 'MITM', 'ModRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModRepMes'))}=tabular_CPD(bnet,n+bnet.names('ModRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node ModRepMes slice 2 
%parent order:{MITM, ModRepMes}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.85695, 0.14305];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'ModRepMes', 'MITM', 'ModRepMes'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('ModRepMes'))}=tabular_CPD(bnet,n+bnet.names('ModRepMes'),'CPT',cpt1);
clear cpt; clear cpt1;

%node CorrReact slice 2 
%parent order:{CorrReact, NotCoherStatus(Or)}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.5, 0.5];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'CorrReact', 'NotCoherStatus', 'CorrReact'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('CorrReact'))}=tabular_CPD(bnet,n+bnet.names('CorrReact'),'CPT',cpt1);
clear cpt; clear cpt1;

%node CorrReact slice 2 
%parent order:{CorrReact, NotCoherStatus(Or)}
cpt(1,1,:)=[1.0, 0.0];
cpt(1,2,:)=[0.5, 0.5];
cpt(2,1,:)=[0.0, 1.0];
cpt(2,2,:)=[0.0, 1.0];
cpt1=mk_named_CPT_inter({'CorrReact', 'NotCoherStatus', 'CorrReact'},names, bnet.dag, cpt,[]);
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
t=5;
evidence{bnet.names('Periodic'),t+1}=1; 
t=6;
evidence{bnet.names('Periodic'),t+1}=2;
evidence{bnet.names('SuspArgICS'),t+1}=2;
t=7;
evidence{bnet.names('CoherentDev'),t+1}=2;
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