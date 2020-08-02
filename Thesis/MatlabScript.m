clear 

h_states = {'Node1', 'Node2', 'Node3', 'Node4'};
obs =};
names=[h_states, obs];

n=length(names);

intrac={'Node1', 'Node4';
'Node2', 'Node4';
'Node3', 'Node4'};

[intra, names] = mk_adj_mat(intrac, names, 1);

interc={};

inter = mk_adj_mat(interc, names, 0);

ns = [2 2 2 2];

bnet = mk_dbn(intra, inter, ns, 'names', names);

%node Node1 slice 1 
%parent order:{}
cpt(:,:)=[0.5, 0.5];
bnet.CPD{bnet.names('Node1')}=tabular_CPD(bnet,bnet.names('Node1'),'CPT',cpt);
clear cpt;

%node Node2 slice 1 
%parent order:{}
cpt(:,:)=[0.5, 0.5];
bnet.CPD{bnet.names('Node2')}=tabular_CPD(bnet,bnet.names('Node2'),'CPT',cpt);
clear cpt;

%node Node3 slice 1 
%parent order:{}
cpt(:,:)=[0.5, 0.5];
bnet.CPD{bnet.names('Node3')}=tabular_CPD(bnet,bnet.names('Node3'),'CPT',cpt);
clear cpt;

%node Node4 slice 1 
%parent order:{Node1, Node2, Node3}
cpt(1,1,1,:)=[0.0, 1.0];
cpt(1,1,2,:)=[0.0, 1.0];
cpt(1,2,1,:)=[1.0, 0.0];
cpt(1,2,2,:)=[1.0, 0.0];
cpt(2,1,1,:)=[0.0, 1.0];
cpt(2,1,2,:)=[1.0, 0.0];
cpt(2,2,1,:)=[1.0, 0.0];
cpt(2,2,2,:)=[0.0, 1.0];
bnet.CPD{bnet.names('Node4')}=tabular_CPD(bnet,bnet.names('Node4'),'CPT',cpt);
clear cpt;

clear cpt;

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