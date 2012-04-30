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
        x10.io.Console.OUT.println("bin in 1dmatrix mit "+ Place.places().size());
        // distributed array to save locally 
        val dist = Dist.makeBlock( (0..(vertexCount-1)), 0, PlaceGroup.WORLD);
        val d = DistArray.make[Int](dist, INF);


        val nexts : DistArray[ArrayList[Int]](1) = DistArray.make[ArrayList[Int]](Dist.makeUnique(), (i:Point) => new ArrayList[Int]());
        val hasJobs : DistArray[Boolean](1) = DistArray.make[Boolean](Dist.makeUnique(), true);
        val sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());

        // Array to collect all results in Place 0 after calculation
        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val clock = Clock.make();
        finish for (place in d.dist.places()) at (place) async clocked(clock) {

            var depth : Int = 1;
            var current : ArrayList[Int] = new ArrayList[Int]();
            if (dist(start) == here) {
                d(start) = 0;
                current.add(start);
            }


            while(hasJobs(here.id)) {
                for (vertex in current) {
                    for (var to : Int = 0; to < vertexCount; to++)  {
                        if (adj([vertex, to])) {
                            sendBuffer(dist(to).id).add(to);
                        }
                    }
                }

                current.clear();
                Clock.resumeAll();
                finish for( buf in sendBuffer) {
                    val buffer : ArrayList[Int] = sendBuffer(buf);
                    async at(new Place(buf(0))) {
                        atomic {
                            for (i in buffer) {
                                nexts(here.id).add(i);
                            }
                        }
                    }
                }

                Clock.resumeAll();

                // Todo: Loop parallelism possible here
                for (vertex in nexts(here.id)) {
                    if (d(vertex) == INF) {
                        d(vertex) = depth;
                        current.add(vertex);
                    }
                }
                hasJobs(here.id) = !current.isEmpty();
                Clock.resumeAll();

                hasJobs(here.id) = hasJobs.reduce( (a:Boolean, b: Boolean)=> a || b ,false);

                depth++;
              
            }


            // Copy local conten of d in result array at place 0
            val localPortion = d.getLocalPortion();
            at(resultRef) async {
                val r  = resultRef();
                for (i : Point(1) in localPortion) {
                    r(i) = localPortion(i);
                }
            }

        }

        return result_local;
    }

}
