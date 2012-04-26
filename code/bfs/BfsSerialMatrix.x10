package bfs;

import x10.util.*;
import parser.GraphStructure;

public class BfsSerialMatrix extends BfsAlgorithm {
	
	private static val INF : Int = Int.MAX_VALUE;
	private var vertexCount : Int  = 0;
	private var adj : Array[Boolean](2);

	
	public def setVertexCount(n: Int) {
		this.vertexCount = n;
		this.adj = new Array[Boolean]( (1..n)*(1..n), false);
	}

	public def addEdge(from:Int, to:Int) {
		assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
		adj( [from, to] ) = true;
	}

	public def run(start : Int) : Array[Int](1) {
		// assert adj is square

		var d : Array[Int](1) = new Array[Int]((1..vertexCount), INF);
		d([start]) = 0;

		var current : List[Int] = new ArrayList[Int]();
		var next : List[Int] = new ArrayList[Int]();

		current.add(start);

		var depth : Int = 1;

		while(!current.isEmpty()) {
			for (vertex in current) {
				for (var idx : Int = 1; idx <= vertexCount; idx++) {
					if (adj([vertex, idx]) && d([idx]) == INF) {
						next.add(idx);
						d([idx]) = depth;
					}
				}
			}
			depth++;
			current.clear();
			var tmpList : List[Int] = current;
			current = next;
			next = tmpList;
		}
		return d;
	}
}
