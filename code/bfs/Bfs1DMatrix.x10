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
    private var d : DistArray[Int];


    private transient var depth : Int;
    private transient var done : Boolean;
    private transient var dTemp : Array[Boolean](1);
    private transient var current : ArrayList[Int];
    private transient var recBuffers : DistArray[Array[ArrayList[Int]]](1);
    private transient var sendBuffer : Array[ArrayList[Int]];

    public def setVertexCount(n: Int) {
        this.vertexCount = n;
        val dist : Dist(2) = Dist.makeBlock( (0..(n-1)) * (0..(n-1)), 0 /*0 -> only split along 0th axis */, PlaceGroup.WORLD);
        adj = DistArray.make[Boolean](dist, false);
        d = DistArray.make[Int](Dist.makeBlock( 0..(vertexCount-1)), INF);
    }

    public def addEdge(from : Int, to : Int) {
        assert (from <= vertexCount && to <= vertexCount) : "Vertex out of range";
            async {
                val p = adj.dist(from, to);
                if (p == here) {
                    adj(from, to) = true;
                } else {
                    at (adj.dist(from, to)) {
                        adj( from, to ) = true;
                    }
                }
            }
    }

    public def addEdge(from : Int, to : Array[Int]) {

        at (adj.dist(from,from)) async {
            for (i in to) {
                adj(from, to(i)) = true;
            }
        }
    }

    public def checkStartNode(numberToCheck : Int) : boolean {
        return numberToCheck >=0 && numberToCheck < vertexCount;
    }

    public def finished() : void {
        // not required
    }

/*
    public def run(start:Int, homeClaim: Claim) {


    }
*/
    public def run(start : Int) : Array[Int](1) { 

        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        /*delete the following when clocks are finally working */
        val isAt = new Array[Place](Place.places().size(), (i:Int) => new Place(i));
        val team = new Team(isAt);


        finish {
            for (place in d.dist.places())  at (place)  {
                async  {

                    recBuffers = DistArray.make[Array[ArrayList[Int]]](Dist.makeUnique(), new Array[ArrayList[Int]](Place.places().size(), new ArrayList[Int]()));
                    sendBuffer = new Array[ArrayList[Int]](Place.places().size(), (i:Int) => new ArrayList[Int]());
                    dTemp = new Array[Boolean](vertexCount, false);

                    depth : Int = 1;
                    done = false;
                    current : ArrayList[Int] = new ArrayList[Int]();
                    if (d.dist(start) == here) {
                        d(start) = 0;
                        current.add(start);
                    }


                    while(!done) {
                        done = iterate(team);
                    }

                    // Copy place-local content of d in result array at place 0
                    val localPortion :Array[Int](1) = d.getLocalPortion();
                    finish at(resultRef) async {
                        val r :Array[Int] = resultRef();
                        for (i : Point(1) in localPortion) {
                            r(i) = localPortion(i);
                        }
                    }

                }}}

        return result_local;
    }
    private def iterate(team: Team) :Boolean {
        // Sort reachable vertices by owning place
        for (from in current) {
            for (var to: Int = 0; to < vertexCount; to++) {
                if (!dTemp(to) && adj(from, to)) {
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
        depth++;
        return (jobsLeft==0);
    }


    static public def say(s:String) {
        atomic{
            x10.io.Console.OUT.println(s);
        }
    }
}
