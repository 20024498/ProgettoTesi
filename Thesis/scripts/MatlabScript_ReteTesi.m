clear 

%Hidden variables
h_states = {'A', 'B'};
%Observable variables
obs = {'C'};
%Array containing each node name 
names=[h_states, obs];

%Number of nodes 
n=length(names);

%Intraslice edges
intrac = {'A', 'C';
'B', 'C'};

%Making intraslice adjiacent matrix
[intra, names] = mk_adj_mat(intrac, names, 1);

%Interslice edges
interc = {'A', 'A';
'B', 'B';
};

%Making interslice adjiacent matrix
inter = mk_adj_mat(interc, names, 0);

% Number of states (ns(i)=x means variable i has x states)
ns = [2 2 2];

% Creating the DBN
bnet = mk_dbn(intra, inter, ns, 'names', names);

% Creating the CPDs



%%%%%%%%% ------- slice 1

%node A(id=A) slice 1 
%parent order:{}
cpt(:,:)=[0.2, 0.8];
bnet.CPD{bnet.names('A')}=tabular_CPD(bnet,bnet.names('A'),'CPT',cpt);
clear cpt;

%node B(id=B) slice 1 
%parent order:{}
cpt(:,:)=[0.4, 0.6];
bnet.CPD{bnet.names('B')}=tabular_CPD(bnet,bnet.names('B'),'CPT',cpt);
clear cpt;

%node C(id=C) slice 1 
%parent order:{A, B}
cpt(1,1,:)=[0.9, 0.09999999999999998];
cpt(1,2,:)=[0.8, 0.2];
cpt(2,1,:)=[0.75, 0.25];
cpt(2,2,:)=[0.4, 0.6];
bnet.CPD{bnet.names('C')}=tabular_CPD(bnet,bnet.names('C'),'CPT',cpt);
clear cpt;



%%%%%%%%% ------- slice 2

%node A(id=A) slice 2 
%parent order:{A}
cpt(1,:)=[0.9, 0.1];
cpt(2,:)=[0.1, 0.9];
bnet.CPD{bnet.eclass2(bnet.names('A'))}=tabular_CPD(bnet,n+bnet.names('A'),'CPT',cpt);
clear cpt; 

%node B(id=B) slice 2 
%parent order:{B}
cpt(1,:)=[0.85, 0.15];
cpt(2,:)=[0.15, 0.85];
bnet.CPD{bnet.eclass2(bnet.names('B'))}=tabular_CPD(bnet,n+bnet.names('B'),'CPT',cpt);
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

% IMPORTANT: GeNIe start slices from 0,
T=5; %max time span thus from 0 to T-1
tStep=1; %Time Step
evidence=cell(n,T); % create the evidence cell array

% Evidence
% first cells of evidence are for time 0
t=2;
evidence{bnet.names('A'),t+1}=1; 
t=3;
evidence{bnet.names('A'),t+1}=2; 
% Inference algorithm (filtering / smoothing)
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
% IMPORTANT: To be consistent with GeNIe we start counting/printing time slices from 0


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

%Hidden variables
h_states = {'A', 'B'};
%Observable variables
obs = {'C'};
%Array containing each node name 
names=[h_states, obs];

%Number of nodes 
n=length(names);

%Intraslice edges
intrac = {'A', 'C';
'B', 'C'};

%Making intraslice adjiacent matrix
[intra, names] = mk_adj_mat(intrac, names, 1);

%Interslice edges
interc = {'A', 'A';
'B', 'B';
};

%Making interslice adjiacent matrix
inter = mk_adj_mat(interc, names, 0);

% Number of states (ns(i)=x means variable i has x states)
ns = [2 2 2];

% Creating the DBN
bnet = mk_dbn(intra, inter, ns, 'names', names);

% Creating the CPDs



%%%%%%%%% ------- slice 1

%node A(id=A) slice 1 
%parent order:{}
cpt(:,:)=[0.2, 0.8];
bnet.CPD{bnet.names('A')}=tabular_CPD(bnet,bnet.names('A'),'CPT',cpt);
clear cpt;

%node B(id=B) slice 1 
%parent order:{}
cpt(:,:)=[0.4, 0.6];
bnet.CPD{bnet.names('B')}=tabular_CPD(bnet,bnet.names('B'),'CPT',cpt);
clear cpt;

%node C(id=C) slice 1 
%parent order:{A, B}
cpt(1,1,:)=[0.9, 0.09999999999999998];
cpt(1,2,:)=[0.8, 0.2];
cpt(2,1,:)=[0.75, 0.25];
cpt(2,2,:)=[0.4, 0.6];
bnet.CPD{bnet.names('C')}=tabular_CPD(bnet,bnet.names('C'),'CPT',cpt);
clear cpt;



%%%%%%%%% ------- slice 2

%node A(id=A) slice 2 
%parent order:{A}
cpt(1,:)=[0.9, 0.1];
cpt(2,:)=[0.1, 0.9];
bnet.CPD{bnet.eclass2(bnet.names('A'))}=tabular_CPD(bnet,n+bnet.names('A'),'CPT',cpt);
clear cpt; 

%node B(id=B) slice 2 
%parent order:{B}
cpt(1,:)=[0.85, 0.15];
cpt(2,:)=[0.15, 0.85];
bnet.CPD{bnet.eclass2(bnet.names('B'))}=tabular_CPD(bnet,n+bnet.names('B'),'CPT',cpt);
clear cpt; 

% choose the inference engine
ec='JT';

% ff=0 --> no fully factorized  OR ff=1 --> fully factorized
ff=0;

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

% IMPORTANT: GeNIe start slices from 0,
T=5; %max time span thus from 0 to T-1
tStep=1; %Time Step
evidence=cell(n,T); % create the evidence cell array

% Evidence
% first cells of evidence are for time 0
t=2;
evidence{bnet.names('A'),t+1}=1; 
t=3;
evidence{bnet.names('A'),t+1}=2; 
% Inference algorithm (filtering / smoothing)
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
% IMPORTANT: To be consistent with GeNIe we start counting/printing time slices from 0


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