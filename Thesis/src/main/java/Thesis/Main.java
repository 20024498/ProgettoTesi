package Thesis;

import java.awt.Color;
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
				code.append(net.getNodeName(h));
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
				code.append(net.getNodeName(h));
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
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			TemporalInfo[] tChildren;
			if((tChildren = net.getTemporalChildren(h)).length>0) 
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
			if((net.getTemporalParents(i, 1)).length!=0) {
				cpdNodes.add(i);
				tempNodes.add(i);
			}
		for(Integer i : obs) //necessario?
			if((net.getTemporalParents(i, 1)).length!=0){
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
			
			if(net.getNodeType(h) == Network.NodeType.TRUTH_TABLE) {}
				
			if(net.getNodeType(h) == Network.NodeType.NOISY_MAX) {}
			
			
			
		}
			
		
		
		System.out.println(code.toString());	
		
		
			

			
	}

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

}
