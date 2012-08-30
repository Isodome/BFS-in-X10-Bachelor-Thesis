package bfs;

import Bfs;
import x10.util.*;
import parser.GraphStructure;
import parser.IOHelper;

public class BfsSerialSparse extends BfsAlgorithm {
	
	private static val INF : Int = Bfs.INF;
	private var vertexCount : Int  = 0;
    private var edgeCount : Int =0;
	private var adj_tmp : Array[ArrayList[Int]](1);
	private var locked : Boolean = false;

	private var adj_idx : Array[Int](1);
	private var adj_val : Array[Int](1);

	public def setVertexCount(n: Int) : void {
		this.vertexCount = n;
        this.edgeCount = 0;
		this.adj_tmp = new Array[ArrayList[Int]](n, ( i: Int) => new ArrayList[Int]() );
	}

	public def addEdge(from : Int, to : Int) : void {
		assert (!locked) : "Not allowed to add edges after having called 'finished'";
		assert (from < vertexCount && to < vertexCount) : "Vertex out of range";
        assert (from >=0 && to >=0) : "Vertex out of range";

		adj_tmp(from).add(to);
        edgeCount++;
	}

    public def addEdge(from : Int, to : Array[Int]) {
        for (i in to) {
            addEdge(from, to(i));
        }
    }
	
    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >=0 && numberToCheck < vertexCount;
    }

    public def getNodeCount() : Int {
        return vertexCount; 
    }
	public def finished() : void {
		locked = true;
		adj_idx = new Array[Int] (vertexCount + 1, 0); // the last value is for easier iteration while the algorithm is running
		adj_idx(vertexCount) = edgeCount; // set the index of the vertexcount +1 -th edge directly behind the edge array
		adj_val = new Array[Int] (edgeCount, 0);


		var idx : Int = 0;
		for (vertex in adj_tmp) { // Iterates over all vertices
            val from : ArrayList[Int]   = adj_tmp(vertex);
			adj_idx(vertex) = idx;
			for ( to in from) { // Iterates over all vertices reachable from 'from'
				adj_val(idx) = to;
				idx++;
			}
		}
		adj_tmp = null; // no longer needed, feed to GC :)
	}


	public def run(start : Int) : Array[Int](1) {
		// assert adj is square

		var d : Array[Int](1) = new Array[Int](vertexCount, INF);
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
