package dr.graphanalyser;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.Scanner;

public class GraphAnalyser {

	private static int[] nodeDegrees;

	private static double averageDegree = 0.0;
	private static long edgeCount = 0l;
	private static int maxDegree = Integer.MIN_VALUE;
	private static int minDegree = Integer.MAX_VALUE;

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		final String inputFile = args[0];
		try {
			parseGraph(inputFile);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return;
		}

		calculateStatistics();
		printResults();
	}

	private static void printResults() {
		System.out.println("Total Node Number: " + nodeDegrees.length);
		System.out.println("Average Degree: " + averageDegree);
		System.out.println("Min Degree: " + minDegree);
		System.out.println("Max Degree:" + maxDegree);
	}

	static void parseGraph(String file) throws FileNotFoundException {

		Scanner scanner = new Scanner(new FileReader(file));
		String nodeCountString = scanner.nextLine().trim();
		int nodeCount = Integer.parseInt(nodeCountString);
		nodeDegrees = new int[nodeCount];

		while (scanner.hasNextLine()) {
			final String currentLine = scanner.nextLine().trim();
			String[] nodes = currentLine.split(" ");

			int currentNode = -1;
			int i = 0;
			for (; currentNode == -1 && i < nodes.length; i++) {
				currentNode = parseInt(nodes[i]);
			}
			for (; i < nodes.length; i++) {
				if (isNumeric(nodes[i])) {
					nodeDegrees[currentNode]++;
				}
			}
		}
	}

	private static void calculateStatistics() {

		for (int i : nodeDegrees) {
			edgeCount += i;
			minDegree = i < minDegree ? i : minDegree;
			maxDegree = i > maxDegree ? i : maxDegree;
		}
		averageDegree = ((double) edgeCount) / ((double) nodeDegrees.length);
	}

	private static boolean isNumeric(String string) {
		return parseInt(string) > -1;
	}

	private static int parseInt(String string) {
		try {
			int i = Integer.parseInt(string);
			return i;
		} catch (NumberFormatException e) {
			return -1;
		}
	}

}
