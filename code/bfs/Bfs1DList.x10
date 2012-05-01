package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import parser.*;
import Bfs;


public class Bfs1DList extends BfsAlgorithm {

    private static val INF : Int = Bfs.INF;
    private var vertexCount: Int = 0;
    private var adj : DistArray[ArrayList[Int]](1);



    public def setVertexCount(n: Int) {
        this.vertexCount = n;
        val dist : Dist(1) = Dist.makeBlock( (0..(n-1)), 0 /*0 -> only split along 0th axis */, PlaceGroup.WORLD);
        adj = DistArray.make[ArrayList[Int]](dist, (i:Point) => new ArrayList[Int]());
    }

    public def addEdge(from : Int, to : Int) {
        assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
            async at (adj.dist(from)) {
                adj(from).add(to);
            }
    }

    public def finished() : void {
        // not required
    }

    public def run(start : Int) : Array[Int](1) { 
        x10.io.Console.OUT.println("Using 1d_list mode with " + Place.places().size() + " places");

        val d = DistArray.make[Int](adj.dist, INF);

        val recBuffers : DistArray[Array[ArrayList[Int]]](1) = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](Place.places().size(), new ArrayList[Int]()));
        val hasJobs : DistArray[Boolean](1) = DistArray.make[Boolean](Dist.makeUnique(), true);
        val sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());


        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val clock = Clock.make();
        clocked finish {
            for (place in d.dist.places()) at (place) {

            clocked async {

            var depth : Int = 1;
            var current : ArrayList[Int] = new ArrayList[Int]();
            if (d.dist(start) == here) {
                d(start) = 0;
                current.add(start);
            }


            while(hasJobs(here.id)) {
                // Sort reachable vertices by owning place
                for (from in current) {
                    for (to in adj(from)) {
                        sendBuffer(d.dist(to).id).add(to);
                    }
                }

                current.clear();
                
                finish for( targetPlace in d.dist.places()) {
                    val buffer : ArrayList[Int] = sendBuffer(targetPlace.id);
                    val sourcePlace = here.id;
                    if (!buffer.isEmpty()) {
                        async at(targetPlace) {
                            recBuffers(here.id)(sourcePlace) = buffer;
                        }
                        buffer.clear(); // only clean the local copy, even if targetPlace and sourcePlace are even!
                    }
                }

                Clock.resumeAll();

                // Todo: Loop parallelism possible here
                val receiveBuffers : Array[ArrayList[Int]] = recBuffers(here.id);
                for (iBuf in receiveBuffers) {
                    for (vertex in receiveBuffers(iBuf)) {
                        if (d(vertex) == INF) {
                            d(vertex) = depth;
                            current.add(vertex);
                        }
                    }
                    receiveBuffers(iBuf).clear();
                }
                hasJobs(here.id) = current.size() > 0;
                //x10.io.Console.OUT.println("Jobs in Platz " + here.id + " " + current.size());
                Clock.resumeAll();
                hasJobs(here.id) = hasJobs.reduce( (a:Boolean, b: Boolean)=> a || b ,false);
                /*
                   if (here.id == 0) {
                   val gotJobsLeft = hasJobs.reduce( (a:Boolean, b: Boolean)=> a || b ,false);
                   hasJobs.map(hasJobs, (a : Boolean) => gotJobsLeft);
                   } */
                depth++;
                Clock.resumeAll();

                //x10.io.Console.OUT.println("Platz " + here.id + " macht weiter: " + hasJobs(here.id));


            }

            // Copy local conten of d in result array at place 0
            val localPortion = d.getLocalPortion();
            at(resultRef) async {
                val r  = resultRef();
                for (i : Point(1) in localPortion) {
                    r(i) = localPortion(i);
                }
            }
            Clock.resumeAll();

        }}}
        return result_local;
    }

}

