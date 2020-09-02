clear 

h_states = {'Node1', 'Node2', 'Node3', 'Node4'};
obs = {};
names=[h_states, obs];

n=length(names);

intrac = {'Node1', 'Node4';
'Node2', 'Node4';
'Node3', 'Node4'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc = {'Node1', 'Node1';
'Node2', 'Node2';
'Node3', 'Node3';
'Node4', 'Node4'};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node Node1(id=Node1) slice 1 
%parent order:{}
cpt(:,:)=[0.6, 0.4];
bnet.CPD{bnet.names('Node1')}=tabular_CPD(bnet,bnet.names('Node1'),'CPT',cpt);
clear cpt;

%node Node2(id=Node2) slice 1 
%parent order:{}
cpt(:,:)=[0.2, 0.8];
bnet.CPD{bnet.names('Node2')}=tabular_CPD(bnet,bnet.names('Node2'),'CPT',cpt);
clear cpt;

%node Node3(id=Node3) slice 1 
%parent order:{}
cpt(:,:)=[0.5, 0.5];
bnet.CPD{bnet.names('Node3')}=tabular_CPD(bnet,bnet.names('Node3'),'CPT',cpt);
clear cpt;

%node Node4(id=Node4) slice 1 
%parent order:{Node1, Node2, Node3}
leak=0.9;
parents_dn={'Node1', 'Node2', 'Node3'};
inh_prob=[0.35, 0.6, 0.85];
inh_prob1=mk_named_noisyor(bnet.names('Node4'),parents_dn,names,bnet.dag,inh_prob);
bnet.CPD{bnet.names('Node4')}=noisyor_CPD(bnet, bnet.names('Node4'),leak, inh_prob1);
clear inh_prob inh_prob1 leak;



%%%%%%%%% ------- slice 2

%node Node1(id=Node1) slice 2 
%parent order:{Node1}
cpt(1,:)=[0.1, 0.9];
cpt(2,:)=[0.5, 0.5];
bnet.CPD{bnet.eclass2(bnet.names('Node1'))}=tabular_CPD(bnet,n+bnet.names('Node1'),'CPT',cpt);
clear cpt; 

%node Node2(id=Node2) slice 2 
%parent order:{Node2}
cpt(1,:)=[0.7, 0.3];
cpt(2,:)=[0.25, 0.75];
bnet.CPD{bnet.eclass2(bnet.names('Node2'))}=tabular_CPD(bnet,n+bnet.names('Node2'),'CPT',cpt);
clear cpt; 

%node Node3(id=Node3) slice 2 
%parent order:{Node3}
cpt(1,:)=[0.6, 0.4];
cpt(2,:)=[0.55, 0.45];
bnet.CPD{bnet.eclass2(bnet.names('Node3'))}=tabular_CPD(bnet,n+bnet.names('Node3'),'CPT',cpt);
clear cpt; 

%node Node4(id=Node4) slice 2 
%parent order:{Node1, Node2, Node3, Node4}
cpt(1,1,1,1,:)=[0.9000400000000001, 0.09995999999999998];
cpt(1,1,1,2,:)=[0.8572, 0.14279999999999998];
cpt(1,1,2,1,:)=[0.8824000000000001, 0.11759999999999998];
cpt(1,1,2,2,:)=[0.8320000000000001, 0.16799999999999998];
cpt(1,2,1,1,:)=[0.8334, 0.16659999999999997];
cpt(1,2,1,2,:)=[0.762, 0.23799999999999996];
cpt(1,2,2,1,:)=[0.804, 0.19599999999999998];
cpt(1,2,2,2,:)=[0.72, 0.27999999999999997];
cpt(2,1,1,1,:)=[0.7144, 0.28559999999999997];
cpt(2,1,1,2,:)=[0.5920000000000001, 0.408];
cpt(2,1,2,1,:)=[0.664, 0.33599999999999997];
cpt(2,1,2,2,:)=[0.52, 0.48];
cpt(2,2,1,1,:)=[0.524, 0.476];
cpt(2,2,1,2,:)=[0.31999999999999995, 0.68];
cpt(2,2,2,1,:)=[0.44000000000000006, 0.5599999999999999];
cpt(2,2,2,2,:)=[0.19999999999999996, 0.8];
cpt1=mk_named_CPT_inter({'Node1', 'Node2', 'Node3', 'Node4', 'Node4'},names, bnet.dag, cpt,[]);
bnet.CPD{bnet.eclass2(bnet.names('Node4'))}=tabular_CPD(bnet,n+bnet.names('Node4'),'CPT',cpt1);
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
t=3;
evidence{bnet.names('Node1'),t+1}=1; 
t=4;
evidence{bnet.names('Node2'),t+1}=2; 
t=6;
evidence{bnet.names('Node3'),t+1}=1; 
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