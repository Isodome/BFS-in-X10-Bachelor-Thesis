//import parser.Parser;
import parser.*;
import bfs.*;
import x10.util.*;

public class Bfs{
	// Constants specifying the algorithm	
	public static val BFS_NONE   : Int = 0;
	public static val BFS_SERIAL_MATRIX : Int = 1;

	/**
	 * The main method for the Hello class
	 */
	public static def main(args: Array[String]) {

		// Start parsing command line arguments
		var bfs : Int = BFS_NONE;
		var fileList : List[String] = new ArrayList[String]();

		var i : Int = args.region.minPoint()(0);
		while(args.region.contains(i)) {
			val argument : String = args(i); 
			if (argument.equals("--help") | argument.equals("-h")) {
				printHelp();
			} else if (argument.equals("-alg")) {
				if ( args.region.contains(i+1)){
					i++;
					bfs = selectBFS(args(i));
				} else {
					printError("No BFS-algorithm specified.");
					return;
				}
			} else {
				fileList.add(args(i));
			}
			i++;
		}

		if (args.size < 3) {
			printError("Too few arguments.");
			return;
		}

		if (bfs == BFS_NONE) {
			printError("Unvalid BFS-algorithm selected.");
			return;
		}
		if (fileList.isEmpty()) {
			printError("You must specify at least one graph file.");
			return;
		}

		/* 
		 * Parsing done, start algorithm
		 */

		for (file in fileList) {
			var p : Parser;

			if (file.endsWith(".sgraph")) {
				p = new SGraphParser();
			} else {
				continue;
			}

			if (bfs == BFS_SERIAL_MATRIX) {
			}
		}
	}

	private static def bfsSerialMatrix() {
		//	val a : Array[Boolean](2) = Graph.makeMatrixFromTGF(file, graph);
		//	var algo : BfsSerial = new BfsSerial();
	}

	private static def printHelp() {
		var s : String = "usage: bfs_start -alg <alg> -ds <ds> input1 input2 ... \n" + 
			"<alg>\t\tChoose the algorithm to use. Available:  [serial_matrix]\n";
		x10.io.Console.OUT.println(s);
	}


	private static def printError(s : String) {
		x10.io.Console.OUT.println("ERROR! " + s + "\n");
		printHelp();
	}


	private static def selectBFS(s :String) : Int {
		if (s.trim().equals("serial_matrix")) {
			return BFS_SERIAL_MATRIX;
		} else {
			return BFS_NONE;
		}
	}

	//	private static def print(s:String) {
	//		x10.io.Console.OUT.println(s);
	//	}
}
