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
                atomic adjacency(from).add(to);
            }
    }

    public def addEdge(from : Int, to : Array[Int]) {
        at(adjacency.dist(from)) async {
            atomic {
                for (i in to) {
                    adjacency(from).add(to(i));
                }
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
        // not required
    }

    public def run(start : Int) : Array[Int](1) { 

        val d = DistArray.make[Int](adjacency.dist, INF);

        val recBuffers : DistArray[Array[ArrayList[Int]]](1) = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](Place.places().size(), new ArrayList[Int]()));
        val sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());


        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        val adj = this.adjacency;

        /*delete the following when clocks are finally working */
        val isAt = new Array[Place](Place.places().size(), (i:Int) => new Place(i));
        val team = new Team(isAt);


        finish {
            for (place in d.dist.places())  at (place)  {
                async  {

                    var depth : Int = 1;
                    var done : Boolean = false;
                    val dTemp = new Array[Boolean](vertexCount, false);
                    var current : ArrayList[Int] = new ArrayList[Int]();
                    if (d.dist(start) == here) {
                        d(start) = 0;
                        current.add(start);
                    }


                    while(!done) {
                        // Sort reachable vertices by owning place
                        for (from in current) {
                            for (to in adj(from)) {
                                if (!dTemp(to)) {
                                    sendBuffer(d.dist(to).id).add(to);
                                    dTemp(to) = true;
                                }
                            }
                        }
                        current.clear();

                        finish for( targetPlace in d.dist.places()) async {
                            val buffer : ArrayList[Int] = sendBuffer(targetPlace.id);
                            val sourcePlace = here.id;
                            if (!buffer.isEmpty()) {
                                if (targetPlace == here) {
                                    recBuffers(here.id)(here.id) = buffer;
                                    sendBuffer(here.id) = new ArrayList[Int]();
                                } else {
                                    at(targetPlace) {
                                        recBuffers(here.id)(sourcePlace) = buffer;
                                    }
                                    buffer.clear(); // only clean the local copy, even if targetPlace and sourcePlace are even!
                                }
                            }
                        }
                        team.barrier(here.id);

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
                        val jobsLeft = team.allreduce(here.id, current.size(), Team.ADD);
                        done = (jobsLeft==0);

                        depth++;
                    }

                    // Copy place-local content of d in result array at place 0
                    val localPortion = d.getLocalPortion();
                    finish at(resultRef) async {
                        val r :Array[Int] = resultRef();
                        for (i : Point(1) in localPortion) {
                            r(i) = localPortion(i);
                        }
                    }

                }}}

        return result_local;
    }


    static public def say(s:String) {
        atomic{
            x10.io.Console.OUT.println(s);
        }
    }

}

