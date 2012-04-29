package bfs;

import x10.lang.*;
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
		val dist : Dist(2) = Dist.makeBlock( (0..(n-1)) * (0..(n-1)), 0 /*0 -> only split along 0th axis */, PlaceGroup.WORLD);
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
        val dist = Dist.makeBlock( (0..(vertexCount-1)), 0, PlaceGroup.WORLD);
        val d = DistArray.make[Int](dist, INF);
        val d_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](d_local);

        val clock = Clock.make();
        for (place in d.dist.places()) at (place) async clocked(clock) {

            var depht : Int = 1;
            var current : ArrayList[Int] = new ArrayList[Int]();
            var next : ArrayList[Int] = new ArrayList[Int]();
            if (dist(start) == here) {
                d(start) = 0;
                current.add(start);
            }

            Clock.resumeAll();
            at(resultRef.home()) {
             
            }
        }

		return d_local;
	}

}
