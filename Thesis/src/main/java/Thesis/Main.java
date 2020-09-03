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
					View window = new View();
					window.getFrameProgramma().setVisible(true);
					Model.start();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		});
	}
	
}

