package bfs;

import x10.array.PlaceGroup;
import x10.lang.*;

public class Grid {
    

    public val rows : Int;
    public val cols : Int;
    private val pg : PlaceGroup;
    private transient var myPoint : Point(2);
    private val n : Int;

    public val rowSize : Int;
    public val colSize : Int;
    
    private def this (rows : Int, cols : Int, pg : PlaceGroup, n : int ) {
       this.rows = rows;
       this.cols = cols;
       this.pg = pg;
       this.n=n;

       var colSize : Int = n / cols;
       if (colSize * cols < n) {
           colSize++;
       }

       var rowSize : Int = n / rows;
       if (rowSize * rows < n) {
           rowSize++;
       }

       this.rowSize = rowSize;
       this.colSize = colSize;
    }


    public static def make(rows : Int, cols : Int, pg : PlaceGroup, n : int) : Grid {
        if (rows * cols != pg.size()) {
            throw new IllegalArgumentException("Number of Places does not equal rows * cols");
        }
        return new Grid(rows, cols, pg, n);
    }

    public static def make (pg: PlaceGroup, n: int) {
        val rows = findRowCount(pg.size());
        Console.OUT.println(rows + "x"+ pg.size()/rows + " chosen");
        return make(rows, pg.size()/rows, pg, n);
    }

    private static def findRowCount(numPlaces:int) : int {
        val sqrtD = Math.sqrt(numPlaces as Double) + 0.5; // in case the sqrt is an Integer, add 0.5 to get the correct result after rounding up; 
        var rows : int = sqrtD as int;
        while (numPlaces % rows != 0 && rows > 1) {
            rows--;
        }
        return Math.max(1, rows);
    }


    public def getPlaceForGridPosition(i0:int, i1:int) : Place {
        val index : Int = getPlaceIDForGridPosition(i0,i1);
        return pg(index);
    }

    public def getPlaceIDForGridPosition(i0:int, i1:int) :int {
        return i0 * cols + i1;
    }

    public operator this(i0:int, i1:int) : Place {
        return getPlaceForGridPosition(i0/ rowSize, i1 / colSize);
    }

    public def places() : PlaceGroup {
        return pg;
    }
    public def getMyPosition() : Point {
        if (myPoint == null) {
            for (var i: int = 0; i< rows; i++) {
                for (var j : int = 0; j < cols; j++) {
                    if (this(i,j)==here) {
                        myPoint = Point.make(i,j);
                    }
                }
            }
        }
        return myPoint;
    }

}
