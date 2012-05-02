package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import parser.*;
import Bfs;


public class Bfs1DList extends BfsAlgorithm {

    private static val INF : Int = Bfs.INF;
    private var vertexCount: Int = 0;
    private var adjacency : DistArray[ArrayList[Int]](1);



    public def setVertexCount(n: Int) {
        this.vertexCount = n;
        val dist : Dist(1) = Dist.makeBlock( (0..(n-1)), 0 /*0 -> only split along 0th axis */, PlaceGroup.WORLD);
        adjacency = DistArray.make[ArrayList[Int]](dist, (i:Point) => new ArrayList[Int]());
    }

    public def addEdge(from : Int, to : Int) {
        assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
            async at (adjacency.dist(from)) {
                adjacency(from).add(to);
            }
    }

    public def finished() : void {
        // not required
    }

    public def run(start : Int) : Array[Int](1) { 
        say("Using 1d_list mode with " + Place.places().size() + " places");

        val d = DistArray.make[Int](adjacency.dist, INF);

        val recBuffers : DistArray[Array[ArrayList[Int]]](1) = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](Place.places().size(), new ArrayList[Int]()));
        val hasJobs : DistArray[Boolean](1) = DistArray.make[Boolean](Dist.makeUnique(), true);
        val sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());


        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val adj = this.adjacency;
        clocked finish {
            for (place in d.dist.places())  at (place)  {
                clocked async  {

                    var depth : Int = 1;
                    var current : ArrayList[Int] = new ArrayList[Int]();
                    if (d.dist(start) == here) {
                        d(start) = 0;
                        current.add(start);
                    }


                    while(hasJobs(here.id)) {
                        say("Anfang Phase 1 in place " + here.id + " depth ist: " + depth);

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
                        say("Ende Phase 1 in place " + here.id + " depth ist: " + depth  );
                        Clock.advanceAll();
                        say("Anfang Phase 2 in place " + here.id + " depth ist: " + depth );

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
                        //say("Jobs in Platz " + here.id + " " + current.size());
                        say("Ende Phase 2 in place " + here.id  + " depth ist: " + depth );
                        Clock.advanceAll();
                        say("Anfang Phase 3 in place " + here.id + " depth ist: " + depth );

                        hasJobs(here.id) = hasJobs.reduce( (a:Boolean, b: Boolean)=> a || b ,false);
                        /*
                           if (here.id == 0) {
                           val gotJobsLeft = hasJobs.reduce( (a:Boolean, b: Boolean)=> a || b ,false);
                           hasJobs.map(hasJobs, (a : Boolean) => gotJobsLeft);
                           } 
                         */
                        depth++;
                        say("Ende Phase 3 in place " + here.id  + " depth ist: " + depth );
                        Clock.advanceAll();

                        //say("Platz " + here.id + " macht weiter: " + hasJobs(here.id));


                    }

                    // Copy place-local content of d in result array at place 0
                    val localPortion = d.getLocalPortion();
                    finish at(resultRef) async {
                        val r :Array[Int] = resultRef();
                        for (i : Point(1) in localPortion) {
                            r(i) = localPortion(i);
                        }
                    }

                    say("Kopieren fertig in place " + here.id);
                }}}

        say("Returning");
        return result_local;
    }

    static public def say(s:String) {
		atomic{
			x10.io.Console.OUT.println(s);
		}
	}

}

