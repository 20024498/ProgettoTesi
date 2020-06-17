package Thesis;

import java.awt.Color;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;

import smile.*;

public class Main {

	public static void main(String[] args) {
		
		
		//licenza
		licenseInit();
		
		/*TODO LICENZA TRAMITE FILE*/
		
		//Inizializzazione rete
		Network net = new Network();
		net.readFile("net/rete.xdsl");
		
		/*TODO CONTROLLO ORDINE ARCHI*/
		
		//clear iniziale
		StringBuilder code = new StringBuilder();
		code.append("clear \n\n");
		
		//variabili nascoste
		ArrayList<Integer> hStates = new ArrayList<Integer>();
		code.append("h_states = {");
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			if(net.getNodeBgColor(h).equals(new Color(229,246,247))) {
				hStates.add(h);
				code.append("'"+net.getNodeName(h)+"'");
				code.append(", ");
			}
		}
		if(code.length()>=2) {
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
		}
		code.append("};\n");
		
		//variabili osservabili
		ArrayList<Integer> obs = new ArrayList<Integer>();
		code.append("obs = {");
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			if(!net.getNodeBgColor(h).equals(new Color(229,246,247))) {
				obs.add(h);
				code.append("'"+net.getNodeName(h)+"'");
				code.append(", ");
			}
		}
		if(code.length()>=2) {
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
		}
		code.append("};\n");
		
		//insieme dei nomi
		code.append("names=[h_states, obs];\n\n");
		
		//numero di nodi
		code.append("n=length(names);\n\n");
		
		//archi intraslice
		code.append("intrac={");
		
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			int[] children;
			if((children = net.getChildren(h)).length>0) 
				for(Integer i : children) {
					code.append("'"+net.getNodeName(h)+"'");
					code.append(", ");
					code.append("'"+net.getNodeName(i)+"'");
					code.append(";\n");
				}	
		}
		if(code.length()>=2) {
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
		}
		
		
	
		
		code.append("};\n\n");
		
		//matrice adiacenza archi intraslice
		code.append("[intra, names] = mk_adj_mat(intrac, names, 1);\n\n");
		
		//archi interslice
		code.append("interc={");
		
		/*
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			TemporalInfo[] tChildren;
			
			tChildren = net.getTemporalChildren(h);
			
			
			if(tChildren.length>0)
				for(TemporalInfo i : tChildren) {
					code.append("'"+net.getNodeName(h)+"'");
					code.append(", ");
					code.append("'"+net.getNodeName(i.handle)+"'");
					code.append(";\n");
				}
			
			
		}
		
		if(code.length()>=2) {
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
		}
		*/
		//DA QUI
		boolean temp = false;
		for (int h : net.getAllNodes()) {
			for (int k : net.getAllNodes()) {
				if(net.temporalArcExists(h, k, 1)) {
					code.append("'"+net.getNodeName(h)+"'");
					code.append(", ");
					code.append("'"+net.getNodeName(k)+"'");
					code.append(";\n");
					temp = true;
				}	
			}
		}
		if(temp==true) {
			code.deleteCharAt(code.length()-1);
			code.deleteCharAt(code.length()-1);
		}
		
		
		// A QUI
		
		code.append("};\n\n");
		
		//matrice adiacenza archi interslice
		code.append("inter = mk_adj_mat(interc, names, 0);\n\n");
		
		//numero di stati i-esima variabile
		code.append("ns = [");
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) 
			code.append(net.getOutcomeCount(h)+" ");
		if(code.length()>=1)
			code.deleteCharAt(code.length()-1);
		code.append("];\n\n");
		
		//creazione rete bayesiana
		code.append("bnet = mk_dbn(intra, inter, ns, 'names', names);\n\n");
		
		//creazione lista node di cui calcolare cpd
		ArrayList<Integer> tempNodes = new ArrayList<Integer>();
		ArrayList<Integer> cpdNodes = new ArrayList<Integer>();
		for(Integer i : hStates)
			cpdNodes.add(i);
		for(Integer i : obs)
			cpdNodes.add(i);
		for(Integer i : hStates) 
			/*if((net.getTemporalParents(i, 1)).length!=0) {
				cpdNodes.add(i);
				tempNodes.add(i);
			}*/
			for(int parent :net.getAllNodes())
				if(net.temporalArcExists(parent, i, 1)){
					cpdNodes.add(i);
					tempNodes.add(i);
				}
						
		for(Integer i : obs) //necessario?
			/*if((net.getTemporalParents(i, 1)).length!=0){
				cpdNodes.add(i);
				tempNodes.add(i);
			}*/
			for(int parent :net.getAllNodes())
				if(net.temporalArcExists(parent, i, 1)){
					cpdNodes.add(i);
					tempNodes.add(i);
				}
		
		
		//calcolo cpd
		int tresh = cpdNodes.size() - tempNodes.size();
		for(int i =0; i<cpdNodes.size();i++) {
			int h=cpdNodes.get(i);
			// nodo probabilistico
			if(net.getNodeType(h) == Network.NodeType.CPT) {
				// nodo senza archi temporali entranti
				if(i<tresh) {
					
					code.append("%node "+net.getNodeName(h)+" slice 1 \n");
					myCpdPrint(net, h,code);
					code.append("bnet.CPD{bnet.names('"+net.getNodeName(h)+"')}=tabular_CPD(bnet,bnet.names('"+net.getNodeName(h)+"'),'CPT',cpt);\n");
					code.append("clear cpt;\n\n");
					
				}
				//nodo con archi tempoali entranti
				else {
					
					code.append("%node "+net.getNodeName(h)+" slice 2 \n");
					myTempCpdPrint(net, h,code);
					if(net.getTemporalParents(h, 1).length>1)
						cpt1Print(net, h, code);
					code.append("bnet.CPD{bnet.eclass2(bnet.names('"+net.getNodeName(h)+"'))}=tabular_CPD(bnet,n+bnet.names('"+net.getNodeName(h)+"'),'CPT',cpt1);\n");
					code.append("clear cpt; ");
					if(net.getTemporalParents(h, 1).length>1)
						code.append("clear cpt1;");
					code.append("\n\n");
				}
					
			}
			
			if(net.getNodeType(h) == Network.NodeType.TRUTH_TABLE) {
				
				if(i<tresh) {
					code.append("bnet.CPD{bnet.names('"+net.getNodeName(h)+"')}=boolean_CPD(bnet,bnet.names('"+net.getNodeName(h)+"'),'named',");
					if(checkOR(net, h,code)) {
						code.append("'any');\n");
						
					}
					else if(checkAND(net, h,code)) {
						code.append("'all');\n");
					}
					else {
						//Per ora niente (nodi deterministici)
					}
					
					code.append("clear cpt;\n\n");
				}
				else {
					//Per ora niente (archi temporali entranti)
				}
			}
				
			if(net.getNodeType(h) == Network.NodeType.NOISY_MAX) {
				
				//SOLO noisy-or per adesso(nodi binari)
				if(i<tresh) {
					code.append("%node "+net.getNodeName(h)+" slice 1 \n");
					code.append("leak=");
					double[] defs = net.getNodeDefinition(h);
					code.append(defs[defs.length-2]+";\n");
					code.append("parents_dn={");
					for(int p : net.getParents(h))
						code.append("'"+net.getNodeName(p)+"'"+", ");
					code.deleteCharAt(code.length()-1);
					code.deleteCharAt(code.length()-1);
					code.append("};\n");
					code.append("inh_prob=[");
					for(int d =1; d<defs.length-2;d+=4)
						code.append(defs[d]+", ");
					code.deleteCharAt(code.length()-1);
					code.deleteCharAt(code.length()-1);
					code.append("];\n");
					code.append("inh_prob1=mk_named_noisyor(bnet.names('"+net.getNodeName(h)+"'),parents_dn,names,bnet.dag,inh_prob);\n");
					code.append("bnet.CPD{bnet.names('"+net.getNodeName(h)+"')}=noisyor_CPD(bnet, bnet.names('"+net.getNodeName(h)+"'),leak, inh_prob1);\n");
					code.append("clear inh_prob inh_prob1 leak;\n\n");
					
					
				}
				else {
					//Per ora niente archi temporali
				}// occorre creare funzione su matlab ?
			}
			
		}
			
		//Inferenza
		printInference(code);
		
		//File di output
		saveFile(code.toString());
		System.out.println(code.toString());	
		
		
			

			
	}
	//SOLO STATI BINARI
	//l'output corrispondente allo stato falso deve essere messo per primo
	private static boolean checkAND(Network net, int h,StringBuilder code) {
		double[] defs = net.getNodeDefinition(h);
		int len = defs.length;
		if(defs[len-2]==0.0 && defs[len-1]==1.0) {
			for(int i=0; i<len-2;i++) {
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
	
	
	//SOLO STATI BINARI
	//l'output corrispondente allo stato falso deve essere messo per primo
	private static boolean checkOR(Network net, int h,StringBuilder code) {
		//code.append("\n-------------------------------->QUI:");
		double[] defs = net.getNodeDefinition(h);
		if(defs[0]==1.0 && defs[1]==0.0) {
			for(int i=2; i<defs.length;i++) {
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
				code.deleteCharAt(code.length()-1);
				code.deleteCharAt(code.length()-1);
				code.append("];\n");
			}
			
		}
			private static void myTempCpdPrint(Network net, int nodeHandle,StringBuilder code) {
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
			
		}
			
			private static void cpt1Print(Network net, int nodeHandle,StringBuilder code){
				TemporalInfo[] parents = net.getTemporalParents(nodeHandle, 1); 
				code.append("cpt1=mk_named_CPT_inter({'"+net.getNodeId(nodeHandle)+"', ");
				for(TemporalInfo t : parents)
					if(t.handle != nodeHandle)
						code.append("'"+net.getNodeId(t.handle)+"', ");
				code.append("'"+net.getNodeId(nodeHandle)+"'");
				code.append("},names, bnet.dag, cpt,[]);\n");
					
			}
			
			private static void saveFile(String code) {
					
					String fileName = "MatlabScript.m";
				    BufferedWriter writer;
					try {
						writer = new BufferedWriter(new FileWriter(fileName));
						writer.write(code);
					    writer.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				    
			}
			
			private static void printInference(StringBuilder code) {
				code.append("% choose the inference engine\n" + 
						"ec='JT';\n" + 
						"\n" + 
						"% ff=0 --> no fully factorized  OR ff=1 --> fully factorized\n" + 
						"ff=1;\n" + 
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
						"T=11; %max time span (from XML file campo Time Slice) thus from 0 to T-1\n" + 
						"tStep=1; %from  XML file campo Time Step\n" + 
						"evidence=cell(n,T); % create the evidence cell array\n" + 
						"\n" + 
						"% Evidence\n" + 
						"% first cells of evidence are for time 0\n" + 
						"t=5;\n" + 
						"evidence{bnet.names('Periodic'),t+1}=1; \n" + 
						"t=6;\n" + 
						"evidence{bnet.names('Periodic'),t+1}=2;\n" + 
						"evidence{bnet.names('SuspArgICS'),t+1}=2;\n" + 
						"t=7;\n" + 
						"evidence{bnet.names('CoherentDev'),t+1}=2;\n" + 
						"% Campo Algoritmo di Inferenza  (filtering / smoothing)\n" + 
						"filtering=1;\n" + 
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
