package Thesis;

import smile.*;

public class Main {

	public static void main(String[] args) {
		licenseInit();
		Network net = new Network();
		System.out.println("FUNZIONA");

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
