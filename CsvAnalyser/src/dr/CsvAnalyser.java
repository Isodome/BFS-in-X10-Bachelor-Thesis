package dr;

import java.awt.font.NumericShaper;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

public class CsvAnalyser {

	private static final int NUMBER_OF_VALUES = 11;
	private static DecimalFormat twoDForm = new DecimalFormat("#.##");

	static {
		DecimalFormatSymbols dfs = DecimalFormatSymbols.getInstance();
		dfs.setDecimalSeparator('.');
		twoDForm = new DecimalFormat("#.##", dfs);
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
;
		
		String filename = args[0];
		String content = null;
		try {
			BufferedReader reader = new BufferedReader(new FileReader(filename));
			StringBuilder sb = new StringBuilder();
			while (true) {
				String nextLine = reader.readLine();
				if (nextLine != null) {
					sb.append(nextLine);
					sb.append(',');
				} else {
					break;
				}
			}
			sb.deleteCharAt(sb.length() - 1);
			content = sb.toString();

		} catch (FileNotFoundException e) {
			content = null;
			e.printStackTrace();
		} catch (IOException e) {
			content = null;
			e.printStackTrace();
		}

		if (content != null) {
			String result = doStuff(content);
			System.out.print(result);
		}
	}

	private static String doStuff(String content) {
		int[] mins = new int[NUMBER_OF_VALUES];
		double[] average = new double[NUMBER_OF_VALUES];
		for (int i = 0; i < mins.length; i++) {
			mins[i] = Integer.MAX_VALUE;
			average[i] = 0.0;
		}
		int idx = 0;
		int testcases = 0;
		for (String cell : content.split(",")) {
			String trimmed = cell.trim();
			if (trimmed.matches("\\d+")) {
				int value = Integer.parseInt(trimmed);
				double dValue = (double) value;
				mins[idx] = value < mins[idx] ? value : mins[idx];
				average[idx] += dValue;
				idx++;
				if (idx == NUMBER_OF_VALUES) {
					idx = 0;
					testcases ++;
				}
			}
		}
		
		for (int i = 0; i < average.length; i++) {
			average[i] /= (double)testcases;
		}
		
		StringBuilder sb = new StringBuilder();
		
		sb.append('\n');
		sb.append("Fastest Run,,,,,\n");
		sb.append("Seriell,"+ mins[0] + ",,,,\n" );
		sb.append("1D");
		for (int i=1; i < 6; i++) {
			sb.append("," + mins[i]);
		}
		sb.append("\n2D");
		for (int i=6; i < 11; i++) {
			sb.append("," + mins[i]);
		}
		sb.append("\n\n");
		
		sb.append("Average Time,,,,,\n");
		sb.append("Seriell,"+ twoDForm.format(average[0]) + ",,,,\n" );
		sb.append("1D");
		for (int i=1; i < 6; i++) {
			sb.append("," + twoDForm.format(average[i]));
		}
		sb.append("\n2D");
		for (int i=6; i < 11; i++) {
			sb.append("," + twoDForm.format(average[i]));
		}
		
		return sb.toString();
	}



}
