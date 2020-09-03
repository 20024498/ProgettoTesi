package Thesis;

import java.awt.Color;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.util.ArrayList;
import org.apache.commons.text.StringEscapeUtils;
import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.parsers.*;
import java.io.*;
import smile.*;

public class Model {

	String filePath;
	Network net;
	StringBuilder code;
	
	public Model(String filePath) {
		this.filePath = filePath;
		this.net = new Network();
		this.code = new StringBuilder();
		
	}
	
	public void start(){
		
		
		
		//CONTROLLO ESTENSIONE
		try {
			checkExtension(filePath);
		} catch (Exception e3) {
			e3.getMessage();
			return;
		}
		
		//CARICAMENTO RETE
		net.readFile(filePath);
		
		//INIZIALIZZAZIONE CODICE
		code.append("clear \n\n");
		
		//VARIABILI NASCOSTE
		ArrayList<Integer> hStates = hiddenVariables();
	
		//VARIABILI OSSERVABILI (indicate con un colore diverso da quello di default)
		ArrayList<Integer> obs = observableVariables();

		//TEST HIDDEN MARKOV MODEL
		try {
			hmmTest(hStates, obs);
			System.out.println("RISPETTA HIDDEN MARKOV MODEL \n");
		}
		catch(NotHMMException e) {
			System.err.println("NON RISPETTA HIDDEN MARKOV MODEL");
			System.err.println(e.getMessage());
		}
		
		//INSIEME DEI NOMI
		code.append("names=[h_states, obs];\n\n");
		
		//NUMERO DI NODI
		code.append("n=length(names);\n\n");
		
		//ARCHI INTRASLICE
		intrasliceArcs();
		
		//MATRICE DI ADIACENZA ARCHI INTRASLICE
		code.append("[intra, names] = mk_adj_mat(intrac, names, 1);\n\n");
		
		//ARCHI INTERSLICE (SOLO ORDINE 1)
		intersliceArcs();
		
		//MATRICE DI ADIACENZA ARCHI INTERSLICE
		code.append("inter = mk_adj_mat(interc, names, 0);\n\n");
		
		//NUMERO DI STATI DI CIASCUN NODO
		numberOfStates();
	
		//CREAZIONE RETE BAYESIANA
		code.append("bnet = mk_dbn(intra, inter, ns, 'names', names);\n\n");
		
		//CREAZIONE LISTE NODI DI CUI CALCOLARE CPD
		ArrayList<Integer> tempNodes = new ArrayList<Integer>();
		ArrayList<Integer> cpdNodes = new ArrayList<Integer>();
		cpdNodesCalc(hStates, obs, cpdNodes, tempNodes);
		
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
					printTabularCpd(h);		
				
				// ARCHI TEMPORALI ENTRANTI
				else 
					printTempTabularCpd(h);			
			}
			
			// NODO DETERMINISTICO
			if(net.getNodeType(h) == Network.NodeType.TRUTH_TABLE) {
				
				// NO ARCHI TEMPORALI ENTRANTI
				if(i<tresh) {
					
					// NODO DI TIPO OR
					if(checkOR(h)) {
						printBooleanCpdOR(h);
					}
					// NODO DI TIPO AND
					else if(checkAND(h)) {
						printBooleanCpdAND(h);
					}
					//NODI DETERMINISTICI GENERICI
					else {
						printTabularCpd(h);
					}	
				}
				
				//ARCHI TEMPORALI ENTRANTI
				else {
					
					// NODO DETERMINISTICO GENERICO
					printTempTabularCpd(h);	
				}
			}
			
			// NODO RUMOROSO
			if(net.getNodeType(h) == Network.NodeType.NOISY_MAX) {
				
				//NO ARCHI TEMPORALI ENTRANTI
				if(i<tresh) {
					
					//NODO DI TIPO NOISY-OR
					if(checkNoisyOr(h)) 
						printNoisyOr(h);
					
					//NODO DI TIPO NOISY MAX
					else 
						printNoisyMax(h);		
				}
				
				//ARCHI TEMPORALI ENTRANTI
				else {
					
					//NODO DI TIPO NOISY MAX
						printTempNoisyMax(h);
				}
			}	
		}
		/*
		//INFERENZA
		printInference(filePath,"prova1","JT",true,11,1,true);
		
		//FILE DI OUTPUT
		saveFile("MatlabScript_"+extractFileName(filePath));
		System.out.println(code.toString());	
		*/	
	}
	
	
	
	private ArrayList<Integer> hiddenVariables(){
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
	
	private ArrayList<Integer> observableVariables(){
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
	
	
	private void hmmTest(ArrayList<Integer> hStates, ArrayList<Integer> obs) throws NotHMMException {
		
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
	
	private void intrasliceArcs() {
		
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
	
	private void intersliceArcs() {
		
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
	
	private void numberOfStates () {
		
		String init = "ns = [";
		StringBuilder str = new StringBuilder (init);

		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) 
			str.append(net.getOutcomeCount(h)+" ");
		if(str.length()>init.length())
			truncList(str, 1);
		
		code.append(str);
		code.append("];\n\n");
	}
	
	private void cpdNodesCalc(ArrayList<Integer> hStates, ArrayList<Integer> obs, ArrayList<Integer> cpdNodes, ArrayList<Integer> tempNodes ) {
		
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
	
	private void printTabularCpd(int nodeHandle) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(nodeHandle);
		myCpdPrint(nodeHandle);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=tabular_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'CPT',cpt);\n");
		code.append("clear cpt;\n\n");	
	}
	
	private void printTempTabularCpd(int nodeHandle) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 2 \n");
		printTempParentOrder(nodeHandle);
		myTempCpdPrint(nodeHandle);
		int nParents = net.getTemporalParents(nodeHandle, 1).length + net.getParents(nodeHandle).length;
		boolean moreParents = nParents>1;
		if(moreParents)
			cpt1Print(nodeHandle);
		code.append("bnet.CPD{bnet.eclass2(bnet.names('"+net.getNodeId(nodeHandle)+"'))}=tabular_CPD(bnet,n+bnet.names('"+net.getNodeId(nodeHandle)+"'),'CPT',"+(moreParents?"cpt1":"cpt")+");\n");
		code.append("clear cpt; ");
		if(moreParents) 
			code.append("clear cpt1;");
		code.append("\n\n");
	}
	
	
	//l'output corrispondente allo stato falso deve essere messo per primo
	private boolean checkAND(int h) {
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
	private boolean checkOR(int h) {
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
	
	private void printBooleanCpdAND (int nodeHandle) {
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(nodeHandle);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=boolean_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'named',");
		code.append("'all');\n");
		code.append("clear cpt;\n\n");
	}
	
	private void printBooleanCpdOR (int nodeHandle) {
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(nodeHandle);
		code.append("bnet.CPD{bnet.names('"+net.getNodeId(nodeHandle)+"')}=boolean_CPD(bnet,bnet.names('"+net.getNodeId(nodeHandle)+"'),'named',");
		code.append("'any');\n");
		code.append("clear cpt;\n\n");
	}
	
	
	private boolean checkNoisyOr(int nodeHandle) {
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
	
	private void printNoisyOr(int nodeHandle) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(nodeHandle);
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
	
	private void printNoisyMax(int nodeHandle) {
		
		code.append("%node "+net.getNodeName(nodeHandle)+"(id="+ net.getNodeId(nodeHandle)+")"+" slice 1 \n");
		printParentOrder(nodeHandle);
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
	
	
	
	private void printTempNoisyMax(int nodeHandle) {
	
		net.setNodeType(nodeHandle, Network.NodeType.CPT);
		printTempTabularCpd(nodeHandle);
		net.setNodeType(nodeHandle, Network.NodeType.NOISY_MAX);
		
	}
	
	public void saveFile(String fileName) {
		StringBuilder scriptName = new StringBuilder();
		scriptName.append(fileName);
		scriptName.append(".m");
	    BufferedWriter writer;
		try {
			writer = new BufferedWriter(new FileWriter(scriptName.toString()));
			writer.write(code.toString());
		    writer.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}  
	}
	
	private void setEvidence(String fileName, String caseName) throws ParserConfigurationException, SAXException, IOException {
		
		File inputFile = new File(fileName);
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
        Document doc = dBuilder.parse(inputFile);
        doc.getDocumentElement().normalize();
        NodeList caseList = doc.getElementsByTagName("case");
       
        for (int i = 0; i < caseList.getLength(); i++) {
           Node caseNode = caseList.item(i);
         
           if (caseNode.getNodeType() == Node.ELEMENT_NODE) {
               Element caseElement = (Element) caseNode;
               
               if(caseElement.getAttribute("name").equals(caseName)) {
            	   
            	   NodeList evidenceList = caseElement.getChildNodes();
                   for(int j = 0; j < evidenceList.getLength(); j++) {
                	   Node evidenceNode = evidenceList.item(j);
                	   if (evidenceNode.getNodeType() == Node.ELEMENT_NODE) {
                           Element evidenceElement = (Element) evidenceNode;
                           if(evidenceNode.getNodeName().contentEquals("evidence")) 
                        	  net.setTemporalEvidence(evidenceElement.getAttribute("node"), Integer.valueOf(evidenceElement.getAttribute("slice")), evidenceElement.getAttribute("state"));  
                	   }
                	   
                   }
            	   
               }
              
            }
        
        }

	}
	
	private void printEvidence(){
		
		ArrayList<TemporalEvidence> evidences = new ArrayList<TemporalEvidence>();
		for(int t=0;t<net.getSliceCount();t++) {
			for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
				if(net.hasTemporalEvidence(h)) {
					if(net.isTemporalEvidence(h, t))
						evidences.add(new TemporalEvidence(t, net.getNodeId(h), net.getTemporalEvidence(h, t)+1));
				}			
			}	
		}
			
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
	
	public void printInference(String fileName, String caseName, String inferenceEngine, boolean fullyFactorized, int timeSpan, int timeStep, boolean filtering) {
		
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
		try {
			setEvidence(fileName,caseName);
		} catch (ParserConfigurationException | SAXException | IOException e) {
		
			System.err.println("Impossibile parsificare il caso salvato su file");
			e.printStackTrace();
		}	
		
		printEvidence();
				
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
	
	/*private void printInference(String fileName) {
		
		String ec;
		char ff;
		char fi;
		int tStep;
		int tSpan = net.getSliceCount();
		String caseName = "";
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
		
		System.out.println("Inserisci il nome del caso salvato");
		caseName = scanner.nextLine();
		
		scanner.close();
		printInference(fileName ,caseName ,ec, (ff=='Y')?true:false, tSpan, tStep, (fi=='F')?true:false);
		
	}*/
	
	



	
		private void myCpdPrint(int nodeHandle) {
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
			private void myTempCpdPrint(int nodeHandle) {
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
			
			private void cpt1Print(int nodeHandle){
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
			
			private void printParentOrder(int nodeHandle) {
				
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
			
			private void printTempParentOrder(int nodeHandle) {
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

			
			private void truncList (StringBuilder str, int delChar) {
				str.setLength(str.length()-delChar);
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
			
			public static void pathInit() throws NoSuchFieldException, SecurityException, IllegalArgumentException, IllegalAccessException {
				 System.setProperty("java.library.path", "./libs" );
				 Field fieldSysPath = ClassLoader.class.getDeclaredField( "sys_paths" );
				 fieldSysPath.setAccessible( true );
				 fieldSysPath.set( null, null );
			}
			
			
			public static License licenseInit() throws IOException {
				InputStream is = new FileInputStream("license/License.java");
				BufferedReader buf = new BufferedReader(new InputStreamReader(is));
				String line = buf.readLine();
				StringBuilder sb = new StringBuilder();
				int skip = 0;
				while(line != null){ 
					if(skip++>2)
						sb.append(line).append("\n");
					line = buf.readLine();
				} 
				buf.close();
				String fileAsString = sb.toString();
				
				String[] splitStr = fileAsString.split(",\\n\\tnew byte\\[\\] ");
				splitStr[0] = splitStr[0].replaceAll("\t", "");
				splitStr[0] = splitStr[0].replaceAll("\" \\+", "");
				splitStr[0] = splitStr[0].replaceAll("\"", "");
				splitStr[0] = splitStr[0].replaceAll("\n", "");
				splitStr[0] = StringEscapeUtils.unescapeJava(splitStr[0]);
				
				splitStr[1] = splitStr[1].replaceAll("\\);","");
				splitStr[1] = splitStr[1].replaceAll("\t","");
				splitStr[1] = splitStr[1].replaceAll("\n","");
				splitStr[1] = splitStr[1].substring(1, splitStr[1].length()-1);
				String[] bytesStr = splitStr[1].split(",");
				byte[] bytes = new byte[bytesStr.length];
				for(int i=0;i<bytesStr.length;i++)
					bytes[i] = Byte.valueOf(bytesStr[i]); 
					
				return new smile.License(splitStr[0],bytes);	
			}
			

		
		public String extractFileName (String filePath) {
			String[] dirs = filePath.split("/");
			StringBuilder fileName = new StringBuilder(dirs[dirs.length-1]);
			fileName.setLength(fileName.length()-5);
			return fileName.toString();
		}
		
		private static void checkExtension(String filePath) throws Exception {
			if(filePath.length()<=5)
				throw new Exception("Formato file non supportato");
			if(!filePath.substring(filePath.length()-5, filePath.length()).equals(".xdsl"))
				throw new Exception("Formato file non supportato");
		}

		public String getFilePath() {
			return filePath;
		}

		public Network getNet() {
			return net;
		}

		public StringBuilder getCode() {
			return code;
		}
		
		

}
