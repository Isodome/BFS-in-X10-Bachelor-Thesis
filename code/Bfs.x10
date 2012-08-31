//import parser.Parser;
import parser.*;
import bfs.*;
import x10.util.*;
import x10.io.*;
import x10.lang.*;

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
    public static val BFS_2D_MATRIX     : Int = 7;
    public static val BFS_2D_LIST       : Int = 8;
    public static val BFS_2D_LIST_ALT   : Int = 9;
    
    /**
     * The main method for the Hello class
     */
    public static def main(args: Array[String]) {
        // Start parsing command line arguments
        var bfs : Int = BFS_NONE;
        var file : String = null;
		var resultFile : String = null;
        var startNode : int = 0;
        var stats : boolean = false;
        var benchmark : boolean = false;

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
            } else if (argument.equals("-start") || argument.equals("-s")) {
                if (args.region.contains(i+1)) {
                    i++;
                    try {
                        startNode = Int.parse(args(i).trim());
                    } catch (nfe : NumberFormatException) {
                        printError("Starting node no valid integer"); 
                        return;
                    }
                }
            } else if (argument.equals("-stats")) {  
               stats = true; 
            } else if (argument.equals("-benchmark")) {
                benchmark = true;  
            } else {
                file = args(i);
            }
            i++;
        }

        // You always need at least '-alg', '<alg>' and the input file, thus, at least 2 arguments 
        if (args.size < 2) {
            printError("Too few arguments.");
            return;
        }

		// Exit with error if the -alg argument is missing or die value didn't match
        if (bfs == BFS_NONE) {
            printError("Unvalid BFS-algorithm selected.");
            return;
        }

		// Exit with error, if no input file was specified
        if (file == null) {
            printError("You must specify a graph file.");
            return;
        }

        /* 
         * Parsing done, start algorithm
		 */
		var parser : Parser;

		// choose parser corresponding to the file ending
		if (file.endsWith(".sgraph")) {
			parser = new SGraphParser();
		} else {
			printError("Unknown file type.");
			return;
		}

		var algo : BfsAlgorithm;
		// choose algorithm
		if (bfs == BFS_SERIAL_MATRIX) {
			algo = new BfsSerialMatrix();
		} else if (bfs == BFS_SERIAL_LIST) {
			algo = new BfsSerialList();   
		} else if (bfs == BFS_SERIAL_SPARSE) {
			algo = new BfsSerialSparse(); 
		} else if (bfs == BFS_1D_MATRIX) {
			algo = new Bfs1DMatrix(); 
		} else if (bfs == BFS_1D_LIST) {
			algo = new Bfs1DList(); 
        } else if (bfs == BFS_2D_MATRIX) {
            algo = new Bfs2DMatrix();
        } else if (bfs == BFS_2D_LIST) {
            algo = new Bfs2DList();  
        } else if (bfs == BFS_2D_LIST_ALT) {
            algo = new Bfs2DListAlt();
        } else {
			printError("Unknown algorithm.");
			return;
		}

		/* Parse the graph file into to chosen algorithm */
		val f = file;
		val a = algo;
		val p = parser;
		finish async p.fillGraphInDataStructure(a, f);
		

        // Check whether startNode is within range
        if (!a.checkStartNode(startNode)) {
            printError("Starting node out of range");
            return;
        }
	    
        if(benchmark) {
            runBenchmark(algo);
        } else {
            //trigger garbage collection and run the algorithm
            x10.lang.System.gc();
            x10.io.Console.OUT.println("Parsing complete, starting algorithm ");
            val startingTime : Long = System.currentTimeMillis();
            val d : Array[Int](1) = algo.run(startNode);
            val duration = System.currentTimeMillis() - startingTime;
            x10.io.Console.OUT.println("Calculation took " + duration + " ms"); 
            printOutput(d, resultFile);
            if (stats) {
                printStats(d,resultFile); 
            }
        }
    }

    private static def runBenchmark(algo: BfsAlgorithm) : void {
        val nodeCount : Double = algo.getNodeCount() as Double;
        var results : Double = 0.0;
        for (var i:Int = 0; i < nodeCount; i++) {
            x10.lang.System.gc();
            results += (executeAndTime(algo, i) as Double) / nodeCount;
            if (i %1000 == 0) {
                 x10.io.Console.OUT.print(".");
                 x10.io.Console.OUT.flush();
            }
        }
        print("Average speed: " + results);
    }
    private static def executeAndTime(algo: BfsAlgorithm, startNode: int) : Long {
        val startingTime : Long = System.currentTimeMillis();
        val d : Array[Int](1) = algo.run(startNode);
        val duration = System.currentTimeMillis() - startingTime;
        return duration;
    }

    private static def bfsSerialMatrix() {
        //  val a : Array[Boolean](2) = Graph.makeMatrixFromTGF(file, graph);
        //  var algo : BfsSerial = new BfsSerial();
    }

    private static def printHelp() {
        var s : String = "usage: bfs_start -alg <alg> -o <result> input \n" + 
            "<alg>\t\tChoose the algorithm to use. Available:  [serial_matrix, serial_list, serial_sparse, 1d_matrix]\n";
        x10.io.Console.OUT.println(s);
    }


    private static def printError(s : String) {
        x10.io.Console.OUT.println("ERROR! " + s + "\n");
        printHelp();
        x10.lang.System.setExitCode(1);
    }


    private static def selectBFS(s :String) : Int {

        val trimmed = s.trim();
        if (trimmed.equals("serial_matrix")) {
            return BFS_SERIAL_MATRIX;
        } else if (trimmed.equals("serial_list")) {
            return BFS_SERIAL_LIST;
        } else if (trimmed.equals("serial_sparse")) {
            return BFS_SERIAL_SPARSE;
        } else if (trimmed.equals("1d_matrix")) {
            return BFS_1D_MATRIX;
        } else if (trimmed.equals("1d_list")) {
            return BFS_1D_LIST;
        } else if (trimmed.equals("2d_matrix")){
            return BFS_2D_MATRIX;
        } else if (trimmed.equals("2d_list")) {
            return BFS_2D_LIST;
        } else if (trimmed.equals("2d_list_alt")) {
            return BFS_2D_LIST_ALT;  
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
                val value : String = (a(i) == INF) ? "INF" : a(i).toString();
                print (i(0).toString() + ":" + value);
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
    private static def printStats(a:Array[Int](1), result : String) {
        if (result != null) {
            val counts = new ArrayList[Int]();
            var INFs : int = 0;
            for (i in a) {
                val steps = a(i);
                if (steps == INF) {
                    INFs++;
                } else {
                    while (counts.size() < steps+1) {
                        counts.add(0);
                    }
                    counts(steps) = counts(steps) + 1;
                }
            }

            val o = new File(result + ".stats");
            val p = o.printer();
            val nodeCount : Double = a.region.size() as Double;
            var average : Double = 0.0;

            for (var i : int = 0; i < counts.size(); i++) {
                p.print(i + ":" + counts(i) + " (" + counts(i)/nodeCount  +"%)" + "\n");
                average += (counts(i) * i)/nodeCount;
            }

            p.print("INF:" + INFs + "(" + INFs/nodeCount + "%)\n\n");
            p.print("Number of nodes: " + a.region.size() + "\n");
            p.print("Average length (without INFs): " + average + "\n" );


            p.flush();
            p.close();

        }
    }
}
