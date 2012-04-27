package bfs;

import x10.array.*;
import x10.util.*;
import parser.*;
import Bfs;


public class Bfs1DMatrix extends BfsAlgorithm {

	private static val INF : Int = Bfs.INF;
	private var vertexCount: Int = 0;
	private var adj : DistArray[Boolean](2);

	public def setVertexCount(n: Int) {
		this.vertexCount = n;
		val dist : Dist(2) = Dist.makeBlock( (1..n) * (1..n), 0, PlaceGroup.WORLD);
		adj = DistArray.make[Boolean](dist, false);
	}

	public def addEdge(from : Int, to : Int) {
		assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
		async at (adj.dist(from, to)) {
			adj( [from, to] ) = true;
		}
	}
	
	public def finished() : void {
		// not required
	}

	public def run(start : Int) : Array[Int](1) {
		return null;
	}

}
