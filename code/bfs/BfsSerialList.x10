package bfs;

import parser.GraphStructure;

public class BfsSerialList extends BfsAlgorithm {

	private statix val INF : Int = Int.MAX_VALUE;
	private var vertexCount : Int = 0;
	private var adj : Array[ArrayList[Int]](1);

	public def setVertexCount(n: Int) : void {
		this.vertexCount = n;
		this.adj = new Array[ArrayList[Int]]( (1..n), null);
		for (i in adj) {
			adj(i) = new ArrayList[Int]();
		}
	}

	public def addEdge(from:Int, to:Int) : void {
		assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
		adj(from).add(to);
	}

	public def finish() : void {
		// nothing to do
	}
	public def run(start : Int) : Array[Int](1) {
		return null;
	}
}
