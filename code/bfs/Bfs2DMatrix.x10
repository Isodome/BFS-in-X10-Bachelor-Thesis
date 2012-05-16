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
    private var arrayPartSize : int;

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

                    val maxRowCoord = x10.lang.Math.min(minRowCoord + grid.rowSize - 1, n-1);
                    val maxColCoord = x10.lang.Math.min(minColCoord + grid.colSize - 1, n-1);
                    adj(p.id) = new Array[Boolean]( (minRowCoord..maxRowCoord) * (minColCoord..maxColCoord),false);
                }
            }
        }
        var partSize : int = vertexCount / PlaceGroup.WORLD.size();
        if (partSize * PlaceGroup.WORLD.size() < vertexCount) {
            partSize++;
        }
        this.arrayPartSize = partSize;
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

        val d = DistArray.make[Array[Int]](Dist.makeUnique(), null as Array[Int]);
        val f = DistArray.make[Array[Boolean]](Dist.makeUnique(), null as Array[Boolean]);
        val fTrans = DistArray.make[Int](Dist.makeBlockCyclic(0..(vertexCount-1), 0, grid.colSize), INF);

        finish for (place in PlaceGroup.WORLD) async {
            val arrayFrom = this.arrayPartSize * place.id;
            val arrayTo   = x10.lang.Math.min(arrayFrom + this.arrayPartSize-1, vertexCount - 1);
            d(place.id) = new Array[Int]( arrayFrom..arrayTo, INF);
            f(place.id) = new Array[Boolean]( arrayFrom..arrayTo, false);
        }


        // Array to collect all results in Place 0 after calculation
        val result_local = new Array[Int]( vertexCount, INF);
        val resultRef = GlobalRef[Array[Int]](result_local);

        finish {
            val clock = Clock.make();
            for (place in d.dist.places()) at (place) {
                async clocked(clock) {

                    if (d.dist(start / this.arrayPartSize) == here) {
                        d(here.id)(start) = 0;
                        f(here.id)(start) = true;
                    }
                    val myArrayRegion = f.dist.get(here);
                    val done = false;

                    while (done) {

                    // Phase 1: Transpose f  // Todo: Push instead of pull. make Distarray for Each gridrow
                       val colFrom = adj(here.id).region.minPoint()(1);
                       val colTo   = adj(here.id).region.maxPoint()(1);
                       val fregion  = (colFrom..colTo) as Region; 
                       val fTransposed = new Array[Boolean](fregion, false);
                       
                       finish for (var i:int = colFrom; i <= colTo; i++) {
                            val ii = i;
                            val arrayPartNum = ii / this.arrayPartSize;
                            fTransposed(i) = at (f.dist(arrayPartNum)) f(here.id)(ii);
                       }


                    }
                    // Copy local conten of d in result array at place 0
                    val localPortion = d(here.id);
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

    private def transposef() {

    }
}
