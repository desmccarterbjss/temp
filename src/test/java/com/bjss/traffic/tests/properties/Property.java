package com.bjss.traffic.tests.properties;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class Property {

	public static String get(String propertyFile, String propertyName)
	{
		System.out.println("[DEBUG] Loading '"+propertyName+"' from "+propertyFile);
		
		Properties prop = new Properties();
		ClassLoader loader = Thread.currentThread().getContextClassLoader();           
		InputStream stream = loader.getResourceAsStream(propertyFile);
		
		try {
			prop.load(stream);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			System.out.println("[ERR] 	    Failed to load '"+propertyName+"' from "+propertyFile);
			
			e.printStackTrace();
		}

		System.out.println("[DEBUG] 	    '"+propertyName+"' value is '"+prop.getProperty(propertyName)+"'");
		
		return prop.getProperty(propertyName);
	}
}
