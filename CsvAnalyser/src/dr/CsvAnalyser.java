package dr;

import java.awt.font.NumericShaper;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

public class CsvAnalyser {

	private static final int NUMBER_OF_VALUES = 1 + 5 + 5 + 5;
	private static DecimalFormat twoDForm;

	static {
		DecimalFormatSymbols dfs = DecimalFormatSymbols.getInstance();
		dfs.setDecimalSeparator('.');
		twoDForm = new DecimalFormat("#.##", dfs);
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		if (args.length != 1) {
			System.err.println("Please give exactly one argument");
			System.exit(1);
		}
		
		String filename = args[0];
		File fileOrDirectory = new File(filename);
		if (fileOrDirectory.isFile()) {
			analyseCsv(filename);
		} else if (fileOrDirectory.isDirectory()) {
			String[] csvFiles = fileOrDirectory.list(new FilenameFilter() {
				@Override
				public boolean accept(File dir, String name) {
					// TODO Auto-generated method stub
					return name.trim().endsWith(".csv");
				}
			});
			String absPath = fileOrDirectory.getAbsolutePath().trim();
			for (String file : csvFiles) {
				if (!absPath.endsWith("/")) {
					absPath += "/";
				}
				analyseCsv(absPath + file.trim());
			}
		}
	}

	private static void analyseCsv(String filename) {
		String content = fileToString(filename);
		String result = doStuff(content);
		appendToFile(result, filename);
	}

	private static void appendToFile(String text, String filename) {
		try {
			// Create file
			FileWriter fstream = new FileWriter(filename, true);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write(text);
			// Close the output stream
			out.close();
		} catch (Exception e) {// Catch exception if any
			System.err.println("Error: " + e.getMessage());
		}
	}

	private static String fileToString(String filename) {
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
		return content;
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
					testcases++;
				}
			}
		}

		for (int i = 0; i < average.length; i++) {
			average[i] /= (double) testcases;
		}

		StringBuilder sb = new StringBuilder();

		sb.append('\n');
		sb.append("Fastest Run,,,,,\n");
		sb.append("Seriell," + mins[0] + ",,,,\n");
		sb.append("1D");
		for (int i = 1; i < 6; i++) {
			sb.append("," + mins[i]);
		}
		sb.append("\n2D");
		for (int i = 6; i < 11; i++) {
			sb.append("," + mins[i]);
		}
		sb.append("\nInvasive");
		for (int i = 11; i < 16; i++) {
			sb.append("," + mins[i]);
		}
		sb.append("\n,,,,,\n");

		sb.append("Average Time,,,,,\n");
		sb.append("Seriell," + twoDForm.format(average[0]) + ",,,,\n");
		sb.append("1D");
		for (int i = 1; i < 6; i++) {
			sb.append("," + twoDForm.format(average[i]));
		}
		sb.append("\n2D");
		for (int i = 6; i < 11; i++) {
			sb.append("," + twoDForm.format(average[i]));
		}
		sb.append("\nInvasive");
		for (int i = 11; i < 16; i++) {
			sb.append("," + average[i]);
		}
		sb.append("\n");
		return sb.toString();
	}

}
