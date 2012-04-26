package bfs;
import parser.GraphStructure;

abstract class BfsAlgorithm implements GraphStructure {

	abstract run(start : Int) : Array[UInt](1);
}
