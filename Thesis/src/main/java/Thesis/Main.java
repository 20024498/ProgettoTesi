package Thesis;

import java.awt.Color;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Scanner;

import smile.*;

public class Main {

	public static void main(String[] args) {
		
		
		//LICENZA
		licenseInit();
		
		/*TODO LICENZA TRAMITE FILE*/
		
		//INIZIALIZZAZIONE RETE
		Network net = new Network();
		String fileName = "rete10.xdsl";
		net.readFile("net/"+fileName);
		
		//INIZIALIZZAZIONE CODICE
		StringBuilder code = new StringBuilder();
		code.append("clear \n\n");
		
		//VARIABILI NASCOSTE
		ArrayList<Integer> hStates = hiddenVariables(net, code);
	
		//VARIABILI OSSERVABILI (indicate con un colore diverso da quello di default)
		ArrayList<Integer> obs = observableVariables(net, code);

		//TEST HIDDEN MARKOV MODEL
		try {
			hmmTest(net, hStates, obs);
			System.out.println("RISPETTA HIDDEN MARKOV MODEL \n");
		}
		catch(NotHMMException e) {
			System.err.println("NON RISPETTA HIDDEN MARKOV MODEL \n");
			System.err.println(e.getMessage());
		}
		
		//INSIEME DEI NOMI
		code.append("names=[h_states, obs];\n\n");
		
		//NUMERO DI NODI
		code.append("n=length(names);\n\n");
		
		//ARCHI INTRASLICE
		intrasliceArcs(net, code);
		
		//MATRICE DI ADIACENZA ARCHI INTRASLICE
		code.append("[intra, names] = mk_adj_mat(intrac, names, 1);\n\n");
		
		//ARCHI INTERSLICE (SOLO ORDINE 1)
		intersliceArcs(net, code);
		
		//MATRICE DI ADIACENZA ARCHI INTERSLICE
		code.append("inter = mk_adj_mat(interc, names, 0);\n\n");
		
		//NUMERO DI STATI DI CIASCUN NODO
		numberOfStates(net, code);
	
		//CREAZIONE RETE BAYESIANA
		code.append("bnet = mk_dbn(intra, inter, ns, 'names', names);\n\n");
		
		//CREAZIONE LISTE NODI DI CUI CALCOLARE CPD
		ArrayList<Integer> tempNodes = new ArrayList<Integer>();
		ArrayList<Integer> cpdNodes = new ArrayList<Integer>();
		cpdNodesCalc(net, hStates, obs, cpdNodes, tempNodes);
		
		//CICLO CALCOLO CPD
		int tresh = cpdNodes.size() - tempNodes.size();
		for(int i =0; i<cpdNodes.size();i++) {
			
			if(i==tresh)
				code.append("\n\n%%%%%%%%% ------- slice 2\n\n");
			
			int h = cpdNodes.get(i);
			
			// NODO PROBABILISTICO
			if(net.getNodeType(h) == Network.NodeType.CPT) {
				
				// NO ARCHI TEMPORALI ENTRANTI
				if(i<tresh) 
					printTabularCpd(net, h, code);		
				
				// ARCHI TEMPORALI ENTRANTI
				else 
					printTempTabularCpd(net, h, code);			
			}
			
			// NODO DETERMINISTICO
			if(net.getNodeType(h) == Network.NodeType.TRUTH_TABLE) {
				
				// NO ARCHI TEMPORALI ENTRANTI
				if(i<tresh) {
					
					// NODO DI TIPO OR
					if(checkOR(net, h,code)) {
						printBooleanCpdOR(net, h, code);
					}
					// NODO DI TIPO AND
					else if(checkAND(net, h,code)) {
						printBooleanCpdAND(net, h, code);
					}
					//NODI DETERMINISTICI GENERICI
					else {
						printTabularCpd(net, h, code);
					}	
				}
				
				//ARCHI TEMPORALI ENTRANTI
				else {
					
					// NODO DETERMINISTICO GENERICO
					printTempTabularCpd(net, h, code);	
				}
			}
			
			// NODO RUMOROSO
			if(net.getNodeType(h) == Network.NodeType.NOISY_MAX) {
				
				//NO ARCHI TEMPORALI ENTRANTI
				if(i<tresh) {
					
					//NODO DI TIPO NOISY-OR
					if(checkNoisyOr(net,h)) 
						printNoisyOr(net,h,code);
					
					//NODO DI TIPO NOISY MAX
					else 
						printNoisyMax(net, h, code);		
				}
				
				//ARCHI TEMPORALI ENTRANTI
				else {
					// TODO Per ora niente archi temporali
					
					//NODO DI TIPO NOISY MAX
						printTempNoisyMax(net, h, code);
				}
			}	
		}
			
		//INFERENZA
		printInference(net,code,"JT",true,11,1,true);
		
		//FILE DI OUTPUT
		saveFile(code.toString(),fileName);
		System.out.println(code.toString());	
			
	}
	
	
	
	private static ArrayList<Integer> hiddenVariables(Network net, StringBuilder code){
		ArrayList<Integer> hStates = new ArrayList<Integer>();
		String init = "h_states = {";
		StringBuilder str = new StringBuilder (init);
		
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			if(net.getNodeBgColor(h).equals(new Color(229,246,247))) {
				hStates.add(h);
				str.append("'"+net.getNodeId(h)+"'");
				str.append(", ");
			}
		}
		
		if(str.length()>init.length()) 
			truncList(str, 2);
		
		code.append(str);
		code.append("};\n");
		
		return hStates;
	}
	
	private static ArrayList<Integer> observableVariables(Network net, StringBuilder code){
		ArrayList<Integer> obs = new ArrayList<Integer>();
		String init = "obs = {";
		StringBuilder str = new StringBuilder (init);
		
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			if(!net.getNodeBgColor(h).equals(new Color(229,246,247))) {
				obs.add(h);
				str.append("'"+net.getNodeId(h)+"'");
				str.append(", ");
			}
		}
		if(str.length()>init.length()) 
			truncList(str, 2);
		
		code.append(str);
		code.append("};\n");
		
		return obs;
	}
	
	
	private static void hmmTest(Network net,ArrayList<Integer> hStates, ArrayList<Integer> obs) throws NotHMMException {
		
		if(hStates.isEmpty())
			throw new NotHMMException("Nessuno stato nascosto trovato");
		if(obs.isEmpty())
			throw new NotHMMException("Nessuno stato osservabile trovato");
		for(Integer i : hStates)
			if(net.getMaxNodeTemporalOrder(i)>1)
				throw new NotHMMException("Archi temporali di ordine maggiore di 1 rilevati tra gli stati nascosti");
		for(Integer i : obs)
			if(net.getMaxNodeTemporalOrder(i)>0)
				throw new NotHMMException("Archi temporali rilevati tra gli osservabili");
		for(Integer h : hStates)
			for(Integer p : net.getParents(h))
				if(net.temporalArcExists(p, h, 0))
					throw new NotHMMException("Archi temporali rilevati tra stati nascosti e osservabili");
					
	}
	
	private static void intrasliceArcs(Network net, StringBuilder code) {
		
		String init = "intrac = {";
		StringBuilder str = new StringBuilder (init);
		
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			int[] children;
			if((children = net.getChildren(h)).length>0) 
				for(Integer i : children) {
					str.append("'"+net.getNodeId(h)+"'");
					str.append(", ");
					str.append("'"+net.getNodeId(i)+"'");
					str.append(";\n");
				}	
		}
		if(str.length()>init.length()) 
			truncList(str, 2);
		
		code.append(str);
		code.append("};\n\n");
	}
	
	private static void intersliceArcs(Network net, StringBuilder code) {
		
		String init = "interc = {";
		StringBuilder str = new StringBuilder (init);
		
		boolean temp = false;
		for (int p : net.getAllNodes()) {
			for (int c : net.getAllNodes()) {
				if(net.temporalArcExists(p, c, 1)) {
					str.append("'"+net.getNodeId(p)+"'");
					str.append(", ");
					str.append("'"+net.getNodeId(c)+"'");
					str.append(";\n");
					temp = true;
				}	
			}
		}
		if(temp==true) 
			truncList(str, 2);
		
		code.append(str);
		code.append("};\n\n");
		
	}
	
	private static void numberOfStates (Network net, StringBuilder code) {
		
		String init = "ns = [";
		StringBuilder str = new StringBuilder (init);

		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) 
			str.append(net.getOutcomeCount(h)+" ");
		if(str.length()>init.length())
			truncList(str, 1);
		
		code.append(str);
		code.append("];\n\n");
	}
	
	private static void cpdNodesCalc(Network net, ArrayList<Integer> hStates, ArrayList<Integer> obs, ArrayList<Integer> cpdNodes, ArrayList<Integer> tempNodes ) {
		
		for(Integer i : hStates)
			cpdNodes.add(i);
		
		for(Integer i : obs)
			cpdNodes.add(i);
		
		for(Integer i : hStates) 
			for(int parent :net.getAllNodes())
				if(net.temporalArcExists(parent, i, 1)&& !tempNodes.contains(i)){
					cpdNodes.add(i);
					tempNodes.add(i);
				}
						
		for(Integer i : obs) 
			for(int parent :net.getAllNodes())
				if(net.temporalArcExists(parent, i, 1) && !tempNodes.contains(i)){
					cpdNodes.add(i);
					tempNodes.add(i);
				}
	}
	
	private static void printTabularCpd(Network net, int nodeHandle,StringBuilder code) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(net, nodeHandle, code);
		myCpdPrint(net, nodeHandle,code);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=tabular_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'CPT',cpt);\n");
		code.append("clear cpt;\n\n");	
	}
	
	private static void printTempTabularCpd(Network net, int nodeHandle,StringBuilder code) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 2 \n");
		printTempParentOrder(net, nodeHandle, code);
		myTempCpdPrint(net, nodeHandle,code);
		int nParents = net.getTemporalParents(nodeHandle, 1).length + net.getParents(nodeHandle).length;
		boolean moreParents = nParents>1;
		if(moreParents)
			cpt1Print(net, nodeHandle, code);
		code.append("bnet.CPD{bnet.eclass2(bnet.names('"+net.getNodeId(nodeHandle)+"'))}=tabular_CPD(bnet,n+bnet.names('"+net.getNodeId(nodeHandle)+"'),'CPT',"+(moreParents?"cpt1":"cpt")+");\n");
		code.append("clear cpt; ");
		if(moreParents) 
			code.append("clear cpt1;");
		code.append("\n\n");
	}
	
	
	//l'output corrispondente allo stato falso deve essere messo per primo
	private static boolean checkAND(Network net, int h,StringBuilder code) {
		if(net.getOutcomeCount(h)>2)
			return false;
		double[] defs = net.getNodeDefinition(h);
		int len = defs.length;
		if(defs[len-2]==1.0 && defs[len-1]==0.0) {
			for(int i=0; i<len-2;i++) {
				if(i%2==0) {
					if(defs[i]!=0.0)
						return false;
				}
				else
					if(defs[i]!=1.0)
						return false;
			}
		}
		else 
			return false;
		
		return true;
	}
	
	
	
	//l'output corrispondente allo stato falso deve essere messo per primo
	private static boolean checkOR(Network net, int h,StringBuilder code) {
		if(net.getOutcomeCount(h)>2)
			return false;
		double[] defs = net.getNodeDefinition(h);
		if(defs[0]==0.0 && defs[1]==1.0) {
			for(int i=2; i<defs.length;i++) {
				if(i%2==0) {
					if(defs[i]!=1.0)
						return false;
				}
				else
					if(defs[i]!=0.0)
						return false;
			}
		}
		else 
			return false;
		
		return true;
		
		
	}
	
	private static void printBooleanCpdAND (Network net, int nodeHandle,StringBuilder code) {
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(net, nodeHandle, code);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=boolean_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'named',");
		code.append("'all');\n");
		code.append("clear cpt;\n\n");
	}
	
	private static void printBooleanCpdOR (Network net, int nodeHandle,StringBuilder code) {
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(net, nodeHandle, code);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=boolean_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'named',");
		code.append("'any');\n");
		code.append("clear cpt;\n\n");
	}
	
	
	private static boolean checkNoisyOr(Network net, int nodeHandle) {
		if(net.getNodeType(nodeHandle) != Network.NodeType.NOISY_MAX)
			return false;
		int parents[] = net.getParents(nodeHandle);
		for(int p : parents)
			if(net.getOutcomeCount(p)>2)
				return false;
		if(net.getOutcomeCount(nodeHandle)>2)
			return false;
		
		return true;
	}
	
	private static void printNoisyOr(Network net, int nodeHandle,StringBuilder code) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(net, nodeHandle, code);
		code.append("leak=");
		double[] defs = net.getNodeDefinition(nodeHandle);
		code.append(defs[defs.length-1]+";\n");
		code.append("parents_dn={");
		for(int p : net.getParents(nodeHandle))
			code.append("'"+net.getNodeId(p)+"'"+", ");
		truncList(code, 2);
		code.append("};\n");
		code.append("inh_prob=[");
		for(int d =1; d<defs.length-2;d+=4)
			code.append((defs[d])+", ");
		truncList(code, 2);
		code.append("];\n");
		code.append("inh_prob1=mk_named_noisyor(bnet.names('"+net.getNodeId(nodeHandle)+"'),parents_dn,names,bnet.dag,inh_prob);\n");
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=noisyor_CPD(bnet, bnet.names('"+net.getNodeId(nodeHandle)+"'),leak, inh_prob1);\n");
		code.append("clear inh_prob inh_prob1 leak;\n\n");
		
	}
	
	private static void printNoisyMax(Network net, int nodeHandle,StringBuilder code) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(net, nodeHandle, code);
		double[] cpt = net.getNoisyExpandedDefinition(nodeHandle);
		int[] parents = net.getParents(nodeHandle); 
		int[] pIndex = new int[parents.length];
		int[] coords = new int[parents.length];
		
		int totCptColumn = cpt.length/net.getOutcomeCount(nodeHandle);
		for(int i=0; i<totCptColumn;i++) {
			code.append("cpt(");
			if(parents.length==0)
				code.append(":,");
			int prod = 1;
			for(int j=parents.length-1;j>=0;j--) {
				coords[j]=(((pIndex[j]++/prod)%net.getOutcomeCount(parents[j])));
				prod*=net.getOutcomeCount(parents[j]);
				
			}
			for(int k =0; k<parents.length;k++)
				code.append(coords[k]+1 +",");
			
			code.append(":)=[");
			for(int w =0; w<net.getOutcomeCount(nodeHandle);w++)
				code.append(cpt[i*net.getOutcomeCount(nodeHandle)+w]+", ");
			truncList(code, 2);
			code.append("];\n");
		}
		
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=tabular_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'CPT',cpt);\n");
		code.append("clear cpt;\n\n");
		
	}
	
	
	
	private static void printTempNoisyMax(Network net, int nodeHandle,StringBuilder code) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 2 \n");
		
		//TODO
		double[] temp = net.getNodeTemporalDefinition(nodeHandle, 1); 
		double[] exp = net.getNoisyExpandedDefinition(nodeHandle);
		for(double t : temp)
			System.err.println(t);
		System.err.println();
		for(double e : exp)
			System.err.println(e);
		
		/*
		double[] cpt = net.getNodeTemporalDefinition(nodeHandle, 1); 
		TemporalInfo[] parents = net.getTemporalParents(nodeHandle, 1); 
		int[] pIndex = new int[parents.length];
		int[] coords = new int[parents.length];
		
		int totCptColumn = cpt.length/net.getOutcomeCount(nodeHandle);
		for(int i=0; i<totCptColumn;i++) {
			code.append("cpt(");
			if(parents.length==0)
				code.append(":,");
			int prod = 1;
			for(int j=parents.length-1;j>=0;j--) {
				coords[j]=(((pIndex[j]++/prod)%net.getOutcomeCount(parents[j].handle)));
				prod*=net.getOutcomeCount(parents[j].handle);
				
			}
			for(int k =0; k<parents.length;k++)
				code.append(coords[k]+1 +",");
			
			code.append(":)=[");
			for(int w =0; w<net.getOutcomeCount(nodeHandle);w++)
				code.append(cpt[i*net.getOutcomeCount(nodeHandle)+w]+", ");
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
			code.append("];\n");
		}		
		*/
	}
	
	private static void saveFile(String code,String fileName) {
		StringBuilder scriptName = new StringBuilder("MatlabScript_");
		scriptName.append(fileName);
		scriptName.setLength(scriptName.length()-4);
		scriptName.append("m");
	    BufferedWriter writer;
		try {
			writer = new BufferedWriter(new FileWriter(scriptName.toString()));
			writer.write(code);
		    writer.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}  
	}
	
	private static void printEvidence(Network net, StringBuilder code){
		
		ArrayList<TemporalEvidence> evidences = new ArrayList<TemporalEvidence>();
		for(int t=0;t<net.getSliceCount();t++) 
			for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) 
				if(net.hasTemporalEvidence(h)) 
					evidences.add(new TemporalEvidence(t, net.getNodeId(h), net.getTemporalEvidence(h, t)+1));	
			
		boolean slicePrinted = false;
		int slice=0;
		for(TemporalEvidence e : evidences) { 
			if(e.timeSlice>slice)
				slicePrinted=false;
			if(!slicePrinted) {
				slice = e.timeSlice;
				slicePrinted = true;
				code.append("t="+slice+";\n");
			}
			code.append("evidence{bnet.names('"+e.name+"'),t+1}="+e.state+"; \n");
		}
	}
	
	private static void printInference(Network net, StringBuilder code,String inferenceEngine, boolean fullyFactorized, int timeSpan, int timeStep, boolean filtering) {
		
		code.append("% choose the inference engine\n" + 
				"ec='"+ inferenceEngine +"';\n" + 
				"\n" + 
				"% ff=0 --> no fully factorized  OR ff=1 --> fully factorized\n" + 
				"ff="+((fullyFactorized==true)?"1":"0")+";\n" + 
				"\n" + 
				"% list of clusters\n" + 
				"if (ec=='JT')\n" + 
				"	engine=bk_inf_engine(bnet, 'clusters', 'exact'); %exact inference\n" + 
				"else\n" + 
				"	if (ff==1)\n" + 
				"		engine=bk_inf_engine(bnet, 'clusters', 'ff'); % fully factorized\n" + 
				"	else\n" + 
				"		clusters={[]};\n" + 
				"		engine=bk_inf_engine(bnet, 'clusters', clusters);\n" + 
				"	end\n" + 
				"end\n" + 
				"\n" + 
				"% IMPORTANT: DrawNet start slices from 0,\n" + 
				"T="+timeSpan+"; %max time span (from XML file campo Time Slice) thus from 0 to T-1\n" + 
				"tStep="+timeStep+"; %from  XML file campo Time Step\n" + 
				"evidence=cell(n,T); % create the evidence cell array\n" + 
				"\n" + 
				"% Evidence\n" + 
				"% first cells of evidence are for time 0\n");  
				
		printEvidence(net, code);
			
		/*code.append("t=5;\n" + 
				"evidence{bnet.names('Periodic'),t+1}=1; \n" + 
				"t=6;\n" + 
				"evidence{bnet.names('Periodic'),t+1}=2;\n" + 
				"evidence{bnet.names('SuspArgICS'),t+1}=2;\n" + 
				"t=7;\n" + 
				"evidence{bnet.names('CoherentDev'),t+1}=2;\n"); */
				
				
		code.append("% Campo Algoritmo di Inferenza  (filtering / smoothing)\n" + 
				"filtering="+((filtering==true)?"1":"0")+";\n" + 
				"% filtering=0 --> smoothing (is the default - enter_evidence(engine,evidence))\n" + 
				"% filtering=1 --> filtering\n" + 
				"if ~filtering\n" + 
				"	fprintf('\\n*****  SMOOTHING *****\\n\\n');\n" + 
				"else\n" + 
				"	fprintf('\\n*****  FILTERING *****\\n\\n');\n" + 
				"end\n" + 
				"\n" + 
				"[engine, loglik] = enter_evidence(engine, evidence, 'filter', filtering);\n" + 
				"\n" + 
				"% analysis time is t for anterior nodes and t+1 for ulterior nodes\n" + 
				"for t=1:tStep:T-1\n" + 
				"%t = analysis time\n" + 
				"\n" + 
				"% create the vector of marginals\n" + 
				"% marg(i).T is the posterior distribution of node T\n" + 
				"% with marg(i).T(false) and marg(i).T(true)\n" + 
				"\n" + 
				"% NB. if filtering then ulterior nodes cannot be marginalized at time t=1\n" + 
				"\n" + 
				"if ~filtering\n" + 
				"	for i=1:(n*2)\n" + 
				"		marg(i)=marginal_nodes(engine, i , t);\n" + 
				"	end\n" + 
				"else\n" + 
				"	if t==1\n" + 
				"		for i=1:n\n" + 
				"			marg(i)=marginal_nodes(engine, i, t);\n" + 
				"		end\n" + 
				"	else\n" + 
				"		for i=1:(n*2)\n" + 
				"			marg(i)=marginal_nodes(engine, i, t);\n" + 
				"		end\n" + 
				"	end\n" + 
				"end\n" + 
				"\n" + 
				"% Printing results\n" + 
				"% IMPORTANT: To be consistent with DrawNet we start counting/printing time slices from 0\n" + 
				"\n" + 
				"\n" + 
				"% Anterior nodes are printed from t=1 to T-1\n" + 
				"fprintf('\\n\\n**** Time %i *****\\n****\\n\\n',t-1);\n" + 
				"%fprintf('*** Anterior nodes \\n');\n" + 
				"for i=1:n\n" + 
				"	if isempty(evidence{i,t})\n" + 
				"		for k=1:ns(i)\n" + 
				"			fprintf('Posterior of node %i:%s value %i : %d\\n',i, names{i}, k, marg(i).T(k));\n" + 
				"		end\n" + 
				"			fprintf('**\\n');\n" + 
				"		else\n" + 
				"			fprintf('Node %i:%s observed at value: %i\\n**\\n',i,names{i}, evidence{i,t});\n" + 
				"		end\n" + 
				"	end\n" + 
				"end\n" + 
				"\n" + 
				"% Ulterior nodes are printed at last time slice\n" + 
				"fprintf('\\n\\n**** Time %i *****\\n****\\n\\n',T-1);\n" + 
				"%fprintf('*** Ulterior nodes \\n');\n" + 
				"for i=(n+1):(n*2)\n" + 
				"	if isempty(evidence{i-n,T})\n" + 
				"		for k=1:ns(i-n)\n" + 
				"			fprintf('Posterior of node %i:%s value %i : %d\\n',i, names{i-n}, k, marg(i).T(k));\n" + 
				"		end\n" + 
				"		fprintf('**\\n');\n" + 
				"	else\n" + 
				"		fprintf('Node %i:%s observed at value: %i\\n**\\n',i,names{i-n}, evidence{i-n,T});\n" + 
				"	end\n" + 
				"end");
	}
	
	private static void printInference(Network net, StringBuilder code) {
		
		String ec;
		char ff;
		char fi;
		int tStep;
		int tSpan = net.getSliceCount();
		String[] infEngines = {"JT","BK"}; 
		Scanner scanner = new Scanner(System.in);
		
		do {
		System.out.println("Inserisci il motore inferenziale: ('JT','BK',..)");
		ec = scanner.nextLine();
		}while(!Arrays.asList(infEngines).contains(ec.toUpperCase()));
		
		do {
		System.out.println("Inserisci incremento dei time step: ('1','2',ecc...)");
		tStep = scanner.nextInt();
		}while(tStep<0 || tStep > tSpan);
		
		do {
		System.out.println("Fully factorized ? (Y/N)");
		ff = Character.toUpperCase(scanner.nextLine().charAt(0));
		}while(ff!='Y' || ff!= 'N');
		
		do {
		System.out.println("Filtering o Smoothing ? (F/S)");
		fi = Character.toUpperCase(scanner.nextLine().charAt(0));
		}while(fi!='F' || fi!='S');
		
		scanner.close();
		printInference(net,code, ec, (ff=='Y')?true:false, tSpan, tStep, (fi=='F')?true:false);
		
	}
	
	



	
		private static void myCpdPrint(Network net, int nodeHandle, StringBuilder code) {
			double[] cpt = net.getNodeDefinition(nodeHandle); 
			int[] parents = net.getParents(nodeHandle); 
			int[] pIndex = new int[parents.length];
			int[] coords = new int[parents.length];
			
			int totCptColumn = cpt.length/net.getOutcomeCount(nodeHandle);
			for(int i=0; i<totCptColumn;i++) {
				code.append("cpt(");
				if(parents.length==0)
					code.append(":,");
				int prod = 1;
				for(int j=parents.length-1;j>=0;j--) {
					coords[j]=(((pIndex[j]++/prod)%net.getOutcomeCount(parents[j])));
					prod*=net.getOutcomeCount(parents[j]);
					
				}
				for(int k =0; k<parents.length;k++)
					code.append(coords[k]+1 +",");
				
				code.append(":)=[");
				for(int w =0; w<net.getOutcomeCount(nodeHandle);w++)
					code.append(cpt[i*net.getOutcomeCount(nodeHandle)+w]+", ");
				truncList(code, 2);
				code.append("];\n");
			}
			
		}
			private static void myTempCpdPrint(Network net, int nodeHandle,StringBuilder code) {
				double[] cpt = net.getNodeTemporalDefinition(nodeHandle, 1); 
				TemporalInfo[] tParents = net.getTemporalParents(nodeHandle, 1); 
				
				
				int[] nParents = net.getParents(nodeHandle);
				int[] parents = new int[nParents.length+tParents.length];
				int p = 0;
				for(int z=0;z<nParents.length;z++,p++)
					parents[p]=nParents[z];
				for(int z=0;z<tParents.length;z++,p++)
					parents[p]=tParents[z].handle;
				
			
				int[] pIndex = new int[parents.length];
				int[] coords = new int[parents.length];
				
				int totCptColumn = cpt.length/net.getOutcomeCount(nodeHandle);
				for(int i=0; i<totCptColumn;i++) {
					code.append("cpt(");
					if(parents.length==0)
						code.append(":,");
					int prod = 1;
					for(int j=parents.length-1;j>=0;j--) {
						coords[j]=(((pIndex[j]++/prod)%net.getOutcomeCount(parents[j])));//parents[j].handle
						prod*=net.getOutcomeCount(parents[j]);//parents[j].handle
						
					}
					for(int k =0; k<parents.length;k++)
						code.append(coords[k]+1 +",");
					
					code.append(":)=[");
					for(int w =0; w<net.getOutcomeCount(nodeHandle);w++)
						code.append(cpt[i*net.getOutcomeCount(nodeHandle)+w]+", ");
					truncList(code, 2);
					code.append("];\n");
				}		
			
		}
			
			private static void cpt1Print(Network net, int nodeHandle,StringBuilder code){
				int[] parents = net.getParents(nodeHandle);
				TemporalInfo[] tParents = net.getTemporalParents(nodeHandle, 1); 
				ArrayList<Integer> parentsList = new ArrayList<Integer>();
				ArrayList<Integer> tparentsList = new ArrayList<Integer>();
				ArrayList<Integer> family = new ArrayList<Integer>();
				
				code.append("cpt1=mk_named_CPT_inter({");
				
				for(int p : parents) {
					code.append("'"+net.getNodeId(p)+"', ");
					parentsList.add(p);
					family.add(p);
				}
			
				for(TemporalInfo t : tParents) {
						code.append("'"+net.getNodeId(t.handle)+"', ");
						tparentsList.add(t.handle);
						family.add(t.handle);	
				}
			
				code.append("'"+net.getNodeId(nodeHandle)+"'");
				family.add(nodeHandle);
					
				StringBuilder idx = new StringBuilder();
				code.append("},names, bnet.dag, cpt,[");
				for(Integer t : tparentsList)
					if(parentsList.contains(t))
						idx.append(family.lastIndexOf(t)+1+",");
				
				if(idx.length()>0)
					truncList(idx, 1);
				
				code.append(idx.toString());
				code.append("]);\n");
					
			}
			
		
			
			/*private static void printParentOrder(Network net, int nodeHandle,StringBuilder code) {
				//%parent order:{SpoofComMes, NewICS}
				code.append("%parent order:{");
				boolean temp = false;
				boolean noParents = true;
				
				for (int p : net.getAllNodes()) {
					if(net.temporalArcExists(p, nodeHandle, 1)) {
						code.append(net.getNodeId(p));
						code.append(", ");
						temp = true;
						noParents = false;
					}	
				}	
				if(temp==false) {
					
					int[] parents = net.getParents(nodeHandle);
					for(int p: parents) {
						code.append(net.getNodeId(p));
						code.append(", ");
						noParents = false;
					}
				}
				
				if(noParents==false) {
					truncList(code, 2);
				}
				
				code.append("}\n");
			}*/
			
			private static void printParentOrder(Network net, int nodeHandle,StringBuilder code) {
				//%parent order:{SpoofComMes, NewICS}
				code.append("%parent order:{");
				
					int[] parents = net.getParents(nodeHandle);
					for(int p: parents) {
						code.append(net.getNodeId(p));
						code.append(", ");
					}
				
				if(parents.length!=0) {
					truncList(code, 2);
				}
				
				code.append("}\n");
			}
			
			private static void printTempParentOrder(Network net, int nodeHandle,StringBuilder code) {
				//%parent order:{SpoofComMes, NewICS}
				code.append("%parent order:{");
				boolean noParents = true;
				
				int[] parents = net.getParents(nodeHandle);
				for(int p: parents) {
					code.append(net.getNodeId(p));
					code.append(", ");
					noParents = false;
				}
				
				for (int p : net.getAllNodes()) {
					if(net.temporalArcExists(p, nodeHandle, 1)) {
						code.append(net.getNodeId(p));
						code.append(", ");
						noParents = false;
					}	
				}	
				
				if(noParents==false) {
					truncList(code, 2);
				}
				
				code.append("}\n");
			}

			
			private static void truncList (StringBuilder code, int delChar) {
				code.setLength(code.length()-delChar);
			}
			

			
			
			private static class NotHMMException extends Exception{
				private static final long serialVersionUID = 1L;
				public NotHMMException(String message) {
					super(message);
				}
			}
			
			private static class TemporalEvidence {
				
				private int timeSlice;
				private String name;
				private int state;
				
				public TemporalEvidence(int timeSlice,String name,int state) {
					this.timeSlice=timeSlice;
					this.name=name;
					this.state=state;
				}	
			}
			
	
	/*
		private static void printCptMatrix(Network net, int nodeHandle) {
			
			double[] cpt = net.getNodeDefinition(nodeHandle);
			int[] parents = net.getParents(nodeHandle);
			int dimCount = 1 + parents.length;
			
			int[] dimSizes = new int[dimCount];
			for (int i = 0; i < dimCount - 1; i ++) 
				dimSizes[i] = net.getOutcomeCount(parents[i]);
			
			dimSizes[dimSizes.length - 1] = net.getOutcomeCount(nodeHandle);
			
			int[] coords = new int[dimCount];
			for (int elemIdx = 0; elemIdx < cpt.length; elemIdx ++) {
				indexToCoords(elemIdx, dimSizes, coords);
				String outcome = net.getOutcomeId(nodeHandle, coords[dimCount - 1]);
				System.out.printf(" P(%s(OUTCOME NODO)", outcome);
				
				if (dimCount > 1) {
					System.out.print(" | ");
					for (int parentIdx = 0; parentIdx < parents.length; parentIdx++){
						if (parentIdx > 0) System.out.print(",");
						int parentHandle = parents[parentIdx];
						System.out.printf("%s(PARENT)=%s(OUTCOME PARENT)",net.getNodeId(parentHandle),net.getOutcomeId(parentHandle, coords[parentIdx]));
					}
				}
				double prob = cpt[elemIdx];
				System.out.printf(")=%f\n", prob);
			}
		}
		
		private static void indexToCoords(int index, int[] dimSizes, int[] coords) {
			int prod = 1;
			for (int i = dimSizes.length - 1; i >= 0; i --) {
				coords[i] = (index / prod) % dimSizes[i];
				prod *= dimSizes[i];
			}
		}
		
		*/
			
			private static License licenseInit() {
				return new smile.License(
						"SMILE LICENSE b868fc1e e51692e8 1e85e6f2 " +
						"THIS IS AN ACADEMIC LICENSE AND CAN BE USED " +
						"SOLELY FOR ACADEMIC RESEARCH AND TEACHING, " +
						"AS DEFINED IN THE BAYESFUSION ACADEMIC " +
						"SOFTWARE LICENSING AGREEMENT. " +
						"Serial #: 2eil2unyjs5or1wst5l3g1cxj " +
						"Issued for: ANDREA GILI (20024498@studenti.uniupo.it) " +
						"Academic institution: Universit\u00e0 del Piemonte Orientale " +
						"Valid until: 2020-10-18 " +
						"Issued by BayesFusion activation server",
						new byte[] {
						53,-6,-125,-49,125,-71,13,-89,-24,121,87,33,-27,-6,85,110,
						114,2,11,-16,-35,13,91,-106,-118,62,83,-3,79,20,-119,-102,
						-50,1,-29,-90,-102,29,61,90,15,-109,-21,-5,6,81,56,90,
						22,-104,-84,90,-10,-34,85,-107,-82,-109,120,22,-10,-120,93,75
						}
					);

			}

}
