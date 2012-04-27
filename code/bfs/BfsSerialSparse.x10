package bfs;

import Bfs;
import x10.util.*;
import parser.GraphStructure;
import parser.IOHelper;

public class BfsSerialSparse extends BfsAlgorithm {
	
	private static val INF : Int = Bfs.INF;
	private var vertexCount : Int  = 0;
	private var adj_tmp : Array[ArrayList[Int]](1);
	private var locked : Boolean = false;

	private var adj_idx : Array[Int](1);
	private var adj_val : Array[Int](1);

	public def setVertexCount(n: Int) : void {
		this.vertexCount = n;
		this.adj_tmp = new Array[ArrayList[Int]]( (1..n), null as ArrayList[Int]);
		for (i in adj_tmp) {
			adj_tmp(i) = new ArrayList[Int]();
		}
	}

	public def addEdge(from:Int, to:Int) : void {
		assert (!locked) : "Not allowed to add edges after having called 'finished'";
		assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
		adj_tmp(from).add(to);
	}

	
	public def finished() : void {
		locked = true;
		val edgeCount : Int = adj_tmp.reduce( (i : Int, a : ArrayList[Int]) => i + a.size(), 0);
		adj_idx = new Array[Int] ( (1..(vertexCount + 1)) ); // the last value is for easier iteration while the algorithm is running
		adj_idx(vertexCount + 1) = edgeCount + 1;
		adj_val = new Array[Int] ( (1..edgeCount) );


		var idx : Int = 1;
		for (vertex in adj_tmp) {
			val out : ArrayList[Int] = adj_tmp(vertex);
			adj_idx(vertex) = idx;
			for ( to in out) {
				adj_val(idx) = to;
				idx++;
			}
		}
		adj_tmp = null; // no longer needed
	}


	public def run(start : Int) : Array[Int](1) {
		// assert adj is square

		var d : Array[Int](1) = new Array[Int]((1..vertexCount), INF);
		d([start]) = 0;

		var current : List[Int] = new ArrayList[Int]();
		var next : List[Int] = new ArrayList[Int]();

		current.add(start);

		var depth : Int = 1;

		// adjust everything from here on

		while(!current.isEmpty()) {
			for (vertex in current) {
				for (var idx : Int = adj_idx(vertex); idx < adj_idx(vertex + 1); idx++) {
					val to : Int = adj_val(idx);
					if (d([to]) == INF) {
						next.add(idx);
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
