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
		this.adj = new Array[ArrayList[Int]]( n, (i:Int) => new ArrayList[Int]());
	}

	public def addEdge(from:Int, to:Int) : void {
		assert (from < vertexCount && to < vertexCount) : "Vertex out of range";
        assert (from >=0 && to >= 0) : "Vertex out of range";
		adj(from).add(to);
	}

    public def addEdge(from : Int, to : Array[Int]) {
        async {
            for (i in to) {
                addEdge(from, to(i));
            }
        }
    }

    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >=0 && numberToCheck < vertexCount;
    }
    public def getNodeCount() : Int {
        return vertexCount; 
    }
    public def finished() : void {
        // nothing to do
    }
    public def run(start : Int) : Array[Int](1) {
        val d : Array[Int](1) = new Array[Int](vertexCount, INF);
        val dTemp = new Array[Boolean](vertexCount, false);
        d(start) = 0;
        dTemp(start) = true;

        var current : List[Int] = new ArrayList[Int]();
        var nexts : List[Int] = new ArrayList[Int]();

        current.add(start);

        var depth : Int = 1;

        while(!current.isEmpty()) {
            val constCurrent = current;
            for (var j:Int =0; j < constCurrent.size(); j++) {
               val vertex = constCurrent(j);
            	val currentList = adj(vertex);
            	val currentSize = currentList.size();
            	for (var i:Int = 0; i< currentSize; i++) {
                	val to = currentList(i);
                    if (!dTemp(to)) {
                        nexts.add(to);
                        d(to) = depth;
                        dTemp(to) = true;
                    }
                }
            }
            depth++;
            constCurrent.clear();
            current = nexts;
            nexts = constCurrent;
        }
        return d;
    }
}
