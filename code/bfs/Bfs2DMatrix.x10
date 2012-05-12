package bfs;

import x10.lang.*;
import x10.array.*;
import x10.util.*;
import Bfs;

public class Bfs2DMatrix extends BfsAlgorithm {


    private static val INF = Bfs.INF;
    private var vertexCount : Int = 0;
    private var adj : DistArray[Array[Boolean]](1);
    private var grid : Grid;

    public def setVertexCount(n : Int) {
        this.vertexCount = n;
        adj = DistArray.make[Array[Boolean]](Dist.makeUnique(), null as Array[Boolean]);
        this.grid = Grid.make(adj.dist.places(), n);


        finish for (var i: int = 0; i< grid.rows; i++) {
            val myRow = i;
            for (var j: int = 0; j < grid.cols; j++){
                val myCol = j;
                val p = grid.getPlaceForGridPosition(i,j);
                at(p) async {
                    val minRowCoord = myRow * grid.rowSize;
                    val minColCoord = myCol * grid.colSize;

                    val maxRowCoord = x10.lang.Math.min(minRowCoord + grid.rowSize, n-1);
                    val maxColCoord = x10.lang.Math.min(minColCoord + grid.colSize, n-1);
                    adj(p.id) = new Array[Boolean]( (minRowCoord..maxRowCoord) * (minColCoord..maxColCoord),false);
                }
            }
        }
    }

    public def addEdge(from : Int, to : Int) {
        async {
            assert (from < vertexCount && to < vertexCount) : "Vertex out of range";
            assert (from >= 0 && to >=0) : "Vertex out of range";
            val p = grid(to,from);
            at(p) {
                adj(p.id)(to, from) = true;
            }
        }
    }

    public def addEdge(from : Int, to : Array[Int]) {
        for (i in to) {
            addEdge(from, to(i));
        }
    }

    public def finished() : void {
        // not required
    }

    public def run(start : Int) : Array[Int](1) {

        val dist = Dist.makeBlockCyclic( (0..(vertexCount-1)), 0, 5);//adj.rowSize);
        val d = DistArray.make[Int](dist, INF);
        val f = DistArray.make[Boolean](dist, false);




        // Array to collect all results in Place 0 after calculation
        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        finish {
            val clock = Clock.make();
            for (place in d.dist.places()) at (place) {
                async clocked(clock) {

                    if (d.dist(start) == here) {
                        d(start) = 0;
                        f(start) = true;
                    }

                    // Copy local conten of d in result array at place 0
                    val localPortion = d.getLocalPortion();
                    at(resultRef) async {
                        val r  = resultRef();
                        for (i : Point in localPortion) {
                            r(i) = localPortion(i);
                        }
                    }
                }}}
        return result_local;
    }

    private static def findRowCount(numPlaces:int) : int {
        val sqrtD = Math.sqrt(numPlaces as Double) + 0.5; // in case the sqrt is an Integer, add 0.5 to get the correct result after rounding up; 
        var rows : int = sqrtD as int;
        while (numPlaces % rows != 0 && rows > 1) {
            rows--;
        }
        return Math.max(1, rows);
    }
}
