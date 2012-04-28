package bfs;

import x10.util.*;
import parser.*;
import Bfs;

public class BfsSerialMatrix extends BfsAlgorithm {

	private static val INF : Int = Bfs.INF;
	private var vertexCount : Int  = 0;
	private var adj : Array[Boolean](2);


	public def setVertexCount(n: Int) {
		this.vertexCount = n;
		this.adj = new Array[Boolean]( (0..(n-1))*(0..(n-1)), false);
	}

	public def addEdge(from : Int, to : Int) {
		assert (from < vertexCount && to < vertexCount) : "Vertex out of range";
        assert (from >= 0 && to >=0) : "Vertex out of range";
			adj( [from, to] ) = true;
	}
	
	public def finished() : void {
		// not required
	}

	public def run(start : Int) : Array[Int](1) {
		// assert adj is square

		var d : Array[Int](1) = new Array[Int](vertexCount, INF);
		d([start]) = 0;

		var current : List[Int] = new ArrayList[Int]();
		var next : List[Int] = new ArrayList[Int]();

		current.add(start);

		var depth : Int = 1;

		while(!current.isEmpty()) {
			for (vertex in current) {
				for (var to : Int = 0; to < vertexCount; to++) {
					if (adj([vertex, to]) && d([to]) == INF) {
						next.add(to);
						d([to]) = depth;
					}
				}
			}
			depth++;
			current.clear();
			val tmpList = current;
			current = next;
			next = tmpList;
		}
		return d;
	}
}
