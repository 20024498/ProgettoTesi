package Thesis;

import java.awt.EventQueue;
import java.io.FileNotFoundException;
import java.io.IOException;

public class Main {

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					String filePath = "net/rete.xdsl";
					//INIZIALIZZAZIONE PATH DELLA NATIVE LIBRARY
					try {
						Model.pathInit();
					} catch (NoSuchFieldException | SecurityException | IllegalArgumentException | IllegalAccessException e) {
						System.err.println("Impossibile settare il path della native library di Smile");
						e.printStackTrace();
					}
					
					//LICENZA
					try {
						Model.licenseInit();
					} catch (FileNotFoundException e1) {
						System.err.println("Impossibile recuperare il file di licenza\n");
					} catch (IOException e2) {
						System.err.println("Impossibile completare l'operazione di lettura della licenza\n");
					}
					
					Controller controller = new Controller(filePath);
					controller.start(filePath);
					
				} catch (Exception e) {
					e.printStackTrace();
				}
				
			}
			
		});
		
	}
	
}

