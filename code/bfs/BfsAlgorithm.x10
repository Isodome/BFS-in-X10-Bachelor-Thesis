package bfs;
import parser.GraphStructure;

public abstract class BfsAlgorithm implements GraphStructure {

	public abstract def run(start : Int) : Array[Int](1);
}
