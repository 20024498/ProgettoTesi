package Thesis;

import java.awt.Color;

import smile.*;

public class Main {

	public static void main(String[] args) {
		
		//licenza
		licenseInit();
		
		//Inizializzazione rete
		Network net = new Network();
		net.readFile("net/rete.xdsl");
		
		//clear iniziale
		StringBuilder code = new StringBuilder();
		code.append("clear \n\n");
		
		//variabili nascoste
		code.append("h_states = {");
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			if(net.getNodeBgColor(h).equals(new Color(229,246,247))) {
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
		code.append("obs = {");
		for (int h = net.getFirstNode(); h >= 0; h = net.getNextNode(h)) {
			
			if(!net.getNodeBgColor(h).equals(new Color(229,246,247))) {
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
}
