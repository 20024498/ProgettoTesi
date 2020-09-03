package Thesis;

import java.awt.EventQueue;

public class Main {

	/**
	 * Launch the application.
	 */
	public static void main(String[] args) {
		EventQueue.invokeLater(new Runnable() {
			public void run() {
				try {
					String filePath = "net/rete7.xdsl";
					String[] cases = Model.retrieveCases(filePath);
					View window = new View(cases);
					window.getFrameProgramma().setVisible(true);
					Model.start(filePath);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
}

