package Thesis;

import java.io.IOException;

import javax.xml.parsers.ParserConfigurationException;

import org.xml.sax.SAXException;

public class Controller {
	
	Model model;
	View view;

	public Controller(String filePath){
		init(filePath);
	}
	
	private void init(String filePath) {
		
		try {
			String [] cases = View.retrieveCases(filePath);
			view = new View(cases);
			model = new Model(filePath);
		} catch (ParserConfigurationException | SAXException | IOException e) {
			e.printStackTrace();
		}
		

	}
	
	public void start(String filePath) {
		model.start();
		//INFERENZA
		model.printInference(filePath,"prova1","JT",true,11,1,true);
				
		//FILE DI OUTPUT
		model.saveFile("MatlabScript_"+model.extractFileName(filePath));
		System.out.println(model.getCode().toString());
	}
}
