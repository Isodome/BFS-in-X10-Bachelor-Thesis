//import parser.Parser;
import parser.*;
import bfs.*;
import x10.util.*;
import x10.io.*;

public class Bfs {

	public static val INF : Int = -1;
    // Constants specifying the algorithm   
    public static val BFS_NONE          : Int = 0;
    public static val BFS_SERIAL_MATRIX : Int = 1;
    public static val BFS_SERIAL_SPARSE : Int = 2;
    public static val BFS_SERIAL_LIST   : Int = 3;
    public static val BFS_1D_MATRIX     : Int = 4;
    public static val BFS_1D_SPARSE     : Int = 5;
    public static val BFS_1D_LIST       : Int = 6;
    
    /**
     * The main method for the Hello class
     */
    public static def main(args: Array[String]) {
        // Start parsing command line arguments
        var bfs : Int = BFS_NONE;
        var file : String = null;
		var resultFile : String = null;

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
            } else if (argument.equals("-o")) {
                if ( args.region.contains(i+1)){
                    i++;
					resultFile = args(i);
                } else {
                    printError("No output file specified.");
                    return;
                }
            } else {
				file = args(i);
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
        if (file == null) {
            printError("You must specify at least one graph file.");
            return;
        }

        /* 
         * Parsing done, start algorithm
		 */
		var parser : Parser;

		if (file.endsWith(".sgraph")) {
			parser = new SGraphParser();
		} else {
			printError("Unknown file type.");
			return;
		}

		var algo : BfsAlgorithm;

		if (bfs == BFS_SERIAL_MATRIX) {
			algo = new BfsSerialMatrix();
		} else if (bfs == BFS_SERIAL_LIST) {
			algo = new BfsSerialList();   
		} else if (bfs == BFS_SERIAL_SPARSE) {
			algo = new BfsSerialSparse(); 
		} else {
			printError("Unknown algorithm.");
			return;
		}

		// Parse the graph file into to chosen algorithm
		parser.fillGraphInDataStructure(algo, file);

		//trigger garbage collection and run the algorithm
		x10.lang.System.gc();
		val d : Array[Int](1) = algo.run(1);
		printOutput(d, resultFile);
	}

    private static def bfsSerialMatrix() {
        //  val a : Array[Boolean](2) = Graph.makeMatrixFromTGF(file, graph);
        //  var algo : BfsSerial = new BfsSerial();
    }

    private static def printHelp() {
        var s : String = "usage: bfs_start -alg <alg> -o <result> input \n" + 
            "<alg>\t\tChoose the algorithm to use. Available:  [serial_matrix, serial_list, serial_sparse]\n";
        x10.io.Console.OUT.println(s);
    }


    private static def printError(s : String) {
        x10.io.Console.OUT.println("ERROR! " + s + "\n");
        printHelp();
		x10.lang.System.setExitCode(1);
    }


    private static def selectBFS(s :String) : Int {
        if (s.trim().equals("serial_matrix")) {
            return BFS_SERIAL_MATRIX;
        } else if (s.trim().equals("serial_list")) {
            return BFS_SERIAL_LIST;
        } else if (s.trim().equals("serial_sparse")) {
            return BFS_SERIAL_SPARSE;
        } else {
            return BFS_NONE;
        }
    }

    private static def print(s:String) {
        x10.io.Console.OUT.println(s);
    }


    private static def printOutput( a: Array[Int](1), result : String ) {
		if ( result == null) {
			for (i in a) {
				print (i(0).toString() + "\t: " + a(i).toString());
			}
		} else {
			val o = new File(result);
			val p = o.printer();
			for (i in a) {
				val value : String = a(i) == INF ? "INF" : a(i).toString();
				p.print(i(0).toString() + ":" + value + "\n");
			}
			p.flush();
			p.close();
		}
    }
}
