package com.bjss.traffic.config;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.dbcp2.BasicDataSource;
import org.springframework.jdbc.core.JdbcTemplate;

import com.bjss.traffic.tests.properties.Property;

public class GetRawRefData {

	private final static String DIRECTORY_WITH_CSVS = System.getProperty("csvpath"); 
	private static String query = "";
			

	public GetRawRefData(){
		
	}
	
	/** Queries the CSV files that contains the reference data
	 * 
	 * @param tableName
	 * @param columnName
	 * @param whereClause
	 * @return
	 */
	public ArrayList<String> getRefData(String tableName, String columnName, 
			String whereClause, String columnTypes){
		
		query = "select "+columnName+" from "+tableName+" "+whereClause+" ";
		
		if( Property.get("royalmail.properties", "log.level").toUpperCase().equals("DEBUG") )
		{		
			System.out.println("[DEBUG] Executing query [" + query + "]");
		}
		
		BasicDataSource ds = new BasicDataSource();

		ds.setUrl("jdbc:relique:csv:" + DIRECTORY_WITH_CSVS);

		ds.setConnectionProperties(columnTypes);
		
		JdbcTemplate template = new JdbcTemplate(ds);

		ArrayList<String> results = 
				(ArrayList<String>) template.queryForList(query, String.class);
		
		return results;
	}
	
}
