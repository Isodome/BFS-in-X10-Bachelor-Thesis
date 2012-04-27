package bfs;

import Bfs;
import x10.util.*;
import parser.GraphStructure;

public class BfsSerialList extends BfsAlgorithm {

	private static val INF : Int = Bfs.INF;
	private var vertexCount : Int = 0;
	private var adj : Array[ArrayList[Int]](1);

	public def setVertexCount(n: Int) : void {
		this.vertexCount = n;
		this.adj = new Array[ArrayList[Int]]( (1..n), null as ArrayList[Int]);
		for (i in adj) {
			adj(i) = new ArrayList[Int]();
		}
	}

	public def addEdge(from:Int, to:Int) : void {
		assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
		adj(from).add(to);
	}

	public def finished() : void {
		// nothing to do
	}
	public def run(start : Int) : Array[Int](1) {
		var d : Array[Int](1) = new Array[Int]((1..vertexCount), INF);
		d([start]) = 0;

		var current : List[Int] = new ArrayList[Int]();
		var next : List[Int] = new ArrayList[Int]();

		current.add(start);

		var depth : Int = 1;

		while(!current.isEmpty()) {
			for (vertex in current) {
				for (to in adj(vertex)) {
					if (d([to]) == INF) {
						next.add(to);
						d([to]) = depth;
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
